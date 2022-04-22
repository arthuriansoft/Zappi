# Zappi

Scripts to pull usage data from Zappi via MyEnergi API and to output as a CSV file for importing into InfluxDB.

Based on work by:

- https://github.com/prlakerveld/mec
- https://github.com/ashleypittman/mec
- https://github.com/twonk/MyEnergi-App-Api

Install pre-requisites with:  
>`pip install -r requirements.txt`

## Notes
- Time stamps are UTC.
- CT clamp values are only returned 'per-minute' and not accumulated 'per-hour'.

pect1 - Grid Import
pect2 - Solar
nect3 - iBoost+
div - Zappi

## To Do
- Test running for date ranges.
- Modify script to average per-minute figures to hourly.
- Design InfluxDB schema.
- Modify script to output suitable CSV format.
- Create DB and import.
- Create dashboards.
- YoY report.