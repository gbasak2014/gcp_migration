# Data load from On-premises Hadoop cluster Hive(HDFS) to BigQuery on Google Cloud Platform.

### High Level design
![image](https://user-images.githubusercontent.com/9164441/171553948-c8ae37d4-89a2-453b-b583-a722e9c4aa78.png)


### Prerequisite:
Hadoo cluster with GCS connector configured to each node
GCP project with below API enabled

- GCS 
- BigQuery
- Cloud Logging

### Components
### conf/sample_table_details.csv:
 Comma(,) Configuration file containing table details as below:
- 0. Hive Schema
- 1. Tabe Name
- 2. File Path in HDFS
- 3. GCP Project Id
- 4. GCS bucket Name for data
- 5. BigQuery Datset
- 6. BigQuery Table Name
- 7. File Type
- 8. BigQuery Table Schema file Path

  

### script/hive_to_bq_data_load.sh
 fd
 fddgdg
