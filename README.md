# Zappi

Scripts to pull usage data from Zappi via MyEnergi API and to output as a CSV file for importing into InfluxDB.

Works as a wrapper around the get_zappi_history.py script, aggregating and formatting the output as a CSV file ready for import.

First clone ashleypittman's repo and create ~/.zappirc file e.g.
>`username: <serial number of hub>`  
>`password: <API key>`

and install pre-requisites with:  
>`pip install -r requirements.txt`

Based on work by:

- https://github.com/prlakerveld/mec
- https://github.com/ashleypittman/mec
- https://github.com/twonk/MyEnergi-App-Api

## Notes
- Time stamps are UTC.
- CT clamp values are only returned 'per-minute' and not accumulated 'per-hour'.  
 pect1 - Grid Import  
  pect2 - Solar  
  nect3 - iBoost+  
  div - Zappi
- It's possible the API will change in the future. This way I can just update the mec repo and hopefully everything else will continue to work.

## To Do
- Test running for date ranges.
- Write awk script to aggregate output and format for InfluxDB.
- Write main script to call other scripts for required dates. Should make note of when run so it will gather stats since last run.
- Design InfluxDB schema.
- Create DB and import.
- Create dashboards.
- YoY report.