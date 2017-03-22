# GEO Helper Script
This script generates GEO high-throughput sequencing submission v2.1 template
compliant annotations for fastq and fastq.gz files.

## Requirements
macOS or Linux bases system with ```gzip``` and ```head``` utilities available.

## Usage
Inside the directory containing all the fastq files:
```
source("https://github.com/Shians/GeoHelper/raw/master/geo_helper.R")
get_raw_files_info()
```
