#!/bin/bash
# Script to use MyEnergi API to obtain historical stats since script was last run.
# Data is formatted into CSV and imported into InfluxDB.

# Variables
LAST_RUN=`cat last_run`
TODAY=`date -I`
BUCKET=MyEnergi     # InfluxDB bucket name
ORG=MyOrg           # InfluxDB organisation name
DAY_TEMP=day.temp   # Temp output file name
ZAPPI_CSV=zappi.csv # Temp CSV file name
SOLAR_CSV=solar.csv # Temp CSV file name
export SOLAR_CSV

if [ "$INFLUX_TOKEN" == "" ]
then
    read -rsp "Please enter your InfluxDB token: " INFLUX_TOKEN
    echo
    export INFLUX_TOKEN
fi

# Check for last_run date
if [ "$LAST_RUN" = "" ]
then
    echo "Last run date not set. Pulling last two months of data."
    LAST_RUN=`date -I -d "$TODAY - 2 months"`
fi

# Loop through each day between last run and yesterday
while [ "$LAST_RUN" != "$TODAY" ]
do
    # Call python API script to obtain stats for this day
    echo -n "Obtaining data for $LAST_RUN... "
    python mec/get_zappi_history.py --day=`date -d $LAST_RUN +%d` --month=`date -d $LAST_RUN +%m` --year=`date -d $LAST_RUN +%Y` --per-minute > $DAY_TEMP

    # Process data with awk 
    echo -n "formatting... "
    export LAST_RUN
    awk -f zappi.awk $DAY_TEMP > $ZAPPI_CSV

    # Import into InfluxDB
    echo "importing..."
    influx write -b $BUCKET -o $ORG -f $ZAPPI_CSV
    influx write -b $BUCKET -o $ORG -f $SOLAR_CSV

    LAST_RUN=`date -I -d "$LAST_RUN + 1 day"`
done

# Update last run file
echo -n $TODAY > last_run

# Clean up
rm $DAY_TEMP $ZAPPI_CSV $SOLAR_CSV