# Zappi
Scripts to pull usage data from Zappi via MyEnergi API which is then formatted as a CSV file and imported into InfluxDB. Works as a wrapper around the get_zappi_history.py script. I opted for this approach, rather than modifying the get_zappi_history.py output, as the API might change in the future (MyEnergi are supposedly working on a public API).

Designed to be run periodically as opposed to continually i.e. once a month. The script only imports whole days worth of data and remembers when it was last run, making it easy to re-run on an adhoc basis. The last run date is stored in the file "last_run". If not set then the script will pull the last two months of data.

Based on work by:

- https://github.com/ashleypittman/mec
- https://github.com/twonk/MyEnergi-App-Api

## Setup
Clone this repo into a directory then clone ashleypittman's repo inside it.

Create the ~/.zappirc file with the following content:
>`username: <serial number of hub>`  
>`password: <API key>`

Within the mec directory install pre-requisites with:  
>`pip install -r requirements.txt`

## InfluxDB Schemas
I've used the following schema to store grid import / export (CT1), car charging (Zappi diverted), solar PV generation (CT2) and immersion heater diverter (CT3).

I'm storing averaged per-minute values for every quarter of an hour (this is configurable via the 'average' variable in the awk script and deals with missing data) to enable 'detailed' per day information, but also storing the daily totals to enable longer term usage analysis.

#datatype measurement,tag,dateTime:RFC3339,double,double,double,double,double  
m,range,time,car,import,export,solar,water  
zappi,15m,time,c,i,e,s,w  
zappi,totals,day,c,i,e,s,w

A second measurement is also created to store the max solar values taken from the per-minute readings for each day. This can show the performance of the panels over time and maybe indicate when they need cleaning!

#datatype measurement,dateTime:RFC3339,double  
m,time,max  
solar_max,time,value