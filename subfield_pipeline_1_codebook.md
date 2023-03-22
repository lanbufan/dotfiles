```python
#                       88            ad88 88            88          88
#                       88           d8"   ""            88          88
#                       88           88                  88          88
# ,adPPYba, 88       88 88,dPPYba, MM88MMM 88  ,adPPYba, 88  ,adPPYb,88
# I8[    "" 88       88 88P'    "8a  88    88 a8P_____88 88 a8"    `Y88
#  `"Y8ba,  88       88 88       d8  88    88 8PP""""""" 88 8b       88
# aa    ]8I "8a,   ,a88 88b,   ,a8"  88    88 "8b,   ,aa 88 "8a,   ,d88
# `"YbbdP"'  `"YbbdP'Y8 8Y"Ybbd8"'   88    88  `"Ybbd8"' 88  `"8bbdP"Y8

```

---
# **subfield.dev Pipeline 1 Documentation**
---

## Description

> a scrapy spider that crawl a university domain (i.e., www.ubc.ca) to harvest URLs identified as either *people_url* or *bio_url* using a keyword approach. A *people_url* is a webpage containing the faculty listing of a specific academic unit. For an example, see [UBC sociology faculty listing](https://sociology.ubc.ca/people/). In this example, the URL is harvested by the crawler since the keyword **people** is contained either in the URL itself or in the visible text associated with it. The second harvested URL is a *bio_url*, or a professor invididual webpage. For an example, see [UBC sociology faculty member individual webpage](https://sociology.ubc.ca/profile/seth-abrutyn/). As with the *people_url*, this *bio_url* is harvested by the crawler wince the keyword **profile** was a positive hit.


## Raw Output

For each university domain, the crawler produces 4 **raw** output files:

1. a JSON file containing all the crawled URLs identified as *people_url* or *bio_url*
    
    * **{university_name}_vps_run_1_2022_12_10.json** --> acadia_vps_run_1_2022_12_10.json
    
    * "vps" stands for virtual personal server
    
    * "run_{number}" denote the most recent iteration of the crawler for this domain.
    

2. a JSON file containing all the crawled URLs, including both links **NOT** identified as *people_url* or *bio_url* and those identified as *people_url* or *bio_url*.
    
    * **{university_name}_requests_vps_run_1_2022_12_10.json** --> acadia_requests_vps_run_1_mongo_2022_12_10.json
    
    * "requests" refers to all the server requests sent to university server. Convention taken from ZYTE.


3. a JSON dump containing the *raw_html* for **all** the crawled URLs.  

    * **{university_name}_vps_run_1_mongo_2022_12_10.json** --> acadia_vps_run_1_mongo_2022_12_10.json
    
    
4. a OUT file containing all of scrapy spider log.

    * **{university_name}_vps_run_1_log** --> acadia_vps_run_1_log.out


## Pre-Processed Output

As part of pipe_1, the first two JSON outputs are transformed into CSVs:

1. the people/bio_url JSON becomes **{university_name}_items_university-crawl_vps_1_final.csv**
    * "items" refers to the URLs yield by the pipeline in SCRAPY. Convention taken from ZYTE.
    * "final" indicates that the spider successfully completed crawling the university domain.
    
    
2. the raw_url JSON becomes **{university_name}_requests_university-crawl_vps_1_final.csv**

## Codebooks

### people/bio_url CSV metadata (items)

| metadata   | description                                                                                                                                                                                                                   | datatype     | status                                                                 |
|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|------------------------------------------------------------------------|
| people_url | harvested url identified as potentially be a faculty listing webpage (people_url), or a individualized faculty member webpage (bio_url).                                                                                      | string       | not yet confirmed as valid people_url. pipe 2 and 3 take care of that. |
| trail      | list containing all the URLs and associated visible texts that the spider previously navigated to get to the current people_url, or depth. ['visible_txt_depth_1', 'url_depth_1', ..., 'visible_text_depth_x', 'url_depth_x'] | python list  | NA                                                                     |
| white_list | list of whitelist keywords that were found in either the people_url or its visible text suggesting a people/bio_url.                                                                                                          | python_list  | NA                                                                     |
| link_text  | indicates the location of the matched whitelist keywords. in_url, has_number, or in visible_txt.                                                                                                                              | string       | NA                                                                     |

### all crawled url metadata (requests CSV)

| metadata | description                                                                       | datatype | status |
|----------|-----------------------------------------------------------------------------------|----------|--------|
| url_raw  | url crawled by the spider. not caught by blacklist and other conditional filters. | string   | NA     |
