# Awk script to process data from get_zappi_history.py

BEGIN {
    date=ENVIRON["LAST_RUN"]
    solar_csv=ENVIRON["SOLAR_CSV"]
    average=15  # Averages each per-minute value this many times
    loop=1
    max_solar=0
    previous_min=-1
    skip=0

    # Output CSV headers
    printf("#datatype measurement,tag,dateTime:RFC3339,double,double,double,double,double\n")
    printf("m,range,time,car,import,export,solar,water\n")
}

# Process per-minute lines
$1~/[0-90-9:0-90-9]/ {

    # Debug...
    c=substr($0,81,7)
    i=substr($0,117,7)
    e=substr($0,127,7)
    s=substr($0,137,7)
    w=substr($0,167,7)
    #printf("time=%s, car=%d, import=%d, export=%d, solar=%d, water=%d\n",$1,c,i,e,s,w)

    # Reset totals
    if (loop == 1) {
        car=0
        import=0
        export=0
        solar=0
        water=0
    }

    # Add values to totals
    if (loop <= average) {
        car=car+substr($0,81,7)
        import=import+substr($0,117,7)
        export=export+substr($0,127,7)
        this_solar=substr($0,137,7) # This value is used when comparing max
        solar=solar+this_solar
        water=water+substr($0,167,7)
    }

    # Check for missing data
    minute=substr($1,4,2)
    minute_diff=minute-previous_min
    if (minute_diff != 1 && minute_diff != -59) {
        if (minute_diff < 1) {  # We've missed data at the end of the hour
            minute_diff=60+minute_diff
        }
        loop=loop+minute_diff-1
        skip=skip+minute_diff-1
    }
    previous_min=minute

    # Cacluate averages
    if (loop > average) {   # We've overshot so adjust averages due to missing data
        skip=skip-(loop-average)
    }
    if (loop >= average) {
        car=car/(average-skip)
        import=import/(average-skip)
        export=export/(average-skip)
        solar=solar/(average-skip)
        water=water/(average-skip)

        time=date"T"$1":00Z"
        printf("zappi,%sm,%s,%d,%d,%d,%d,%d\n",average,time,car,import,export,solar,water)

        if (loop > average) {
            loop=(loop-average)+1   # Make the next loop shorter to recover from missing data
            car=0
            import=0
            export=0
            solar=0
            water=0
        } else {
            loop=1
        }
        skip=0
    } else {
        loop++
    }

    # Update max solar value
    if (this_solar+0 > max_solar+0) {
        max_solar=this_solar
    }

    next
}

# Process totals
$1=="Totals"  {
    gsub(/kWh/,"   ")
    car=substr($0,81,7)
    import=substr($0,117,7)
    export=substr($0,127,7)
    solar=substr($0,137,7)
    water=substr($0,167,7)
    time=date"T00:00:00Z"
    if (car + 0.0 < 0) car = car * -1
    if (import + 0.0 < 0) import = import * -1
    if (export + 0.0 < 0) export = export * -1
    if (solar + 0.0 < 0) solar = solar * -1
    if (water + 0.0 < 0) water = water * -1
    printf("zappi,totals,%s,%.3f,%.3f,%.3f,%.3f,%.3f\n",time,car,import,export,solar,water)
}

# Print out max solar details
END {
    time=date"T00:00:00Z"
    printf("#datatype measurement,dateTime:RFC3339,double\n") > solar_csv
    printf("m,time,max\n") >> solar_csv
    printf("solar_max,%s,%d\n",time,max_solar) >> solar_csv
}