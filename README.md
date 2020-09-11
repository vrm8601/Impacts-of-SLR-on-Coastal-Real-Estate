# Economic Impacts of Sea Level Rise on Coastal Real Estate

## Abstract

As a result of the industrialized global economy, an increase of carbon and methane gas concentrations in the atmosphere has contributed to an overall warming climate, and in turn, global sea level rise. Such a change has vast implications for coastal communities.  This study models the potential loss of value coastal properties in New Hanover County, North Carolina will experience due to sea level rise. The methods used were linear regression to predict the future value of properties in addition to methods used in ArcGIS in order to find the parcels affected by different increments of sea level rise. This analysis could be used to inform coastal residents on the potential loss in value of their property and what to expect in future years. 

## Background

Due to increasing concentrations of carbon dioxide and methane gases in the atmosphere, average global sea level has increased three inches in the last 25 years (Global Greenhouse). Appendix A visualizes this rapid increase in sea level and displays future projections. The three primary factors are thermal expansion, melting glaciers, and the loss of Greenland and Antartica’s ice sheets. The main risks resulting from a rising sea level are shoreline erosion and degradation, amplified storm surge, permanent land inundation, and saltwater intrusion. Shoreline erosion occurs as rising seas cause tides to push further inland, even during calm conditions. The effects of storms will be amplified as storm drains are unable to drain into the ocean as sea water will flood further into the system through the discharge end. The water table will also rise, and between the higher water table and ineffective drainage systems permanent inundation or chronic flooding will occur. Saltwater intrusion may also occur leading to contamination of water supplies and damage to local agricultural. All these risks increase the likelihood of loss of property, property damage, and an increase in insurance rates. 


## Data Sources
1. Property Data
    * New Hanover County Tax Parcel DataBase
    ftp://ftp.nhcgov.com/outbound/gisdata/taxdata/nhclttax/
    *Tax_parcel_data.txt (original NHC tax parcel dataset)
    * all_parcels_with_zipcodes.csv (same as above but includes zipcodes for each parcel)
    * Zillow Home Value Index Data
    https://www.zillow.com/research/data/
    * Zip_Zhvi_AllHomes.csv
2. Sea Level Projections
    * IPCC
    * NOAA 
    https://coast.noaa.gov/slrdata/
    * SAS_GIS_Data.zip
3. Results Comparison
   * USGS predictions
   * actual.sas7bdat


These datasets can be found in the "Original Data" folder. Cleaned versions of the data used can be found in the "perm library" folder in this repository. 

## Objectives
This project aims to investigate the monetary impact of sea level rise on coast real estate in New Hanover County by pursuing the following objectives:
1. Identify and quantify the monetary value of real estate within New Hanover County that will experience increased flood risks as sea level rises
2. Find the potential loss in monetary value of these properties for different increments of sea level change
3. Calculate the difference in property value predictions with and without sea level rise.

All results are grouped by zip code and displayed on an interactive map in which any zip code in New Hanover County can be clicked on and the number of homes affected and the total value at risk will be shown.


## Referemces

“Global Greenhouse Gas Emissions Data.” EPA, Environmental Protection Agency, 13 Sept. 2019, https://www.epa.gov/ghgemissions/global-greenhouse-gas-emissions-data.  
