# Awk script to process data from get_zappi_history.py

BEGIN {
    date=ENVIRON["LAST_RUN"]
    average=15
    loop=1
}

# Process per-minute lines (use substr to pull out fields)
$1~/[0-90-9:0-90-9]/ {

    # Debug...
    c=substr($0,81,5)
    i=substr($0,117,5)
    e=substr($0,127,5)
    s=substr($0,137,5)
    w=substr($0,167,5)
    printf("car=%d, import=%d, export=%d, solar=%d, water=%d\n",c,i,e,s,w)


    if (loop == 1) {
        car=0
        import=0
        export=0
        solar=0
        water=0
    }
    if (loop <= average) {
        car=car+substr($0,81,5)
        import=import+substr($0,117,5)
        export=export+substr($0,127,5)
        solar=solar+substr($0,137,5)
        water=water+substr($0,167,5)
    }
    if (loop == average) {
        car=car/average
        import=import/average
        export=export/average
        solar=solar/average
        water=water/average

        printf("Average: car=%d, import=%d, export=%d, solar=%d, water=%d\n",car,import,export,solar,water)
        loop=1
    } else {
        loop++
    }

    next
}

# Process totals
$1=="Totals"  {
    car=substr($0,81,5)
    import=substr($0,117,5)
    export=substr($0,127,5)
    solar=substr($0,137,5)
    water=substr($0,167,5)
    printf("Totals: car=%s, import=%s, export=%s, solar=%s, water=%s\n",car,import,export,solar,water)
m}
