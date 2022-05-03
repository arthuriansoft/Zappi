#!/bin/bash
# Script to use MyEnergi API to obtain historical stats since script was last run.
# Data is formatted into CSV and imported into InfluxDB.

# Variables
LAST_RUN=`cat last_run`
TODAY=`date -I`

# Check for last_run date
if [ "$LAST_RUN" = "" ]
then
    echo "Last run date not set. Pulling last two months of data."
    LAST_RUN=`date -I -d "$TODAY - 2 months"`
fi

# Loop through each day between last run and yesterday
while [ "$LAST_RUN" != "$TODAY" ]
do
    # Call python API script to obtain stats for this day and process through awk
    echo "python mec/get_zappi_history.py --day=`date -d $LAST_RUN +%d` --month=`date -d $LAST_RUN +%m` --year=`date -d $LAST_RUN +%Y` --per-minute" | awk -f <myfile> > day.csv



    # Import into InfluxDB



    LAST_RUN=`date -I -d "$LAST_RUN + 1 day"`
done

# Update last run file
#echo -n $TODAY > last_run