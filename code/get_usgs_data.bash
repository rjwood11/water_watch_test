#!/usr/bin/env bash

# Retrieve USGS streamflow data from website for each location

rm data/index.html@site=03433500

wget -P data/ https://waterservices.usgs.gov/nwis/dv/?site=03433500