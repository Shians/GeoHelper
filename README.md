# GEO Helper Script
This script generates GEO high-throughput sequencing submission v2.1 template
compliant annotations for fastq and fastq.gz files.

## Requirements
macOS or Linux bases system with ```gzip``` and ```head``` utilities available.

## Usage
With R inside the directory containing all the fastq files:
```
source("https://github.com/Shians/GeoHelper/raw/master/geo_helper.R")
cat(get_raw_files_info())
```

or from the shell

```
Rscript -e 'source("https://github.com/Shians/GeoHelper/raw/master/geo_helper.R"); cat(get_raw_files_info())'
```

The printed output should be suitable for copy-pasting into the GEO template 
spreadsheet.

macOS users can use
```
cat(get_raw_files_info(), file = pipe("pbcopy"))
```

or

```
Rscript -e 'source("https://github.com/Shians/GeoHelper/raw/master/geo_helper.R"); cat(get_raw_files_info())'
```
to directly output into the clipboard for immediate pasting into excel.
