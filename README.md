# Data load from On-premises Hadoop cluster Hive(HDFS) to BigQuery on Google Cloud Platform.

### High Level design
![image](https://user-images.githubusercontent.com/9164441/171553948-c8ae37d4-89a2-453b-b583-a722e9c4aa78.png)


### Prerequisite:
Hadoo cluster with GCS connector configured to each node
GCP project with below API enabled
GCS 
BigQuery
Cloud Logging

### Components
### conf/sample_table_details.csv:
Comma(,) Configuration file containing table details as below:
Hive Schema
Tabe Name
File Path in HDFS
GCP Project Id
GCS bucket Name for data
BigQuery Datset
BigQuery Table Name
File Type
BigQuery Table Schema file Path

  

### script/hive_to_bq_data_load.sh
fd
fddgdg
