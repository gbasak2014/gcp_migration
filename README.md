# Data load from On-premises Hadoop cluster Hive(HDFS) to BigQuery on Google Cloud Platform.

### High Level design
![image](https://user-images.githubusercontent.com/9164441/171553948-c8ae37d4-89a2-453b-b583-a722e9c4aa78.png)


### Prerequisite:
Hadoo cluster with GCS connector configured to each node
  GCP project with below API enabled

- GCS 
- BigQuery
- Cloud Logging
- Service Account with roles GCS objectCreator, BigQuery jobUser, BigQuery dataViewer, BigQuery dataEditor and logWriter
- Service Account Key configured to Hadoop cluster
  
### Components
### conf/sample_table_details.csv:
 Comma(,) separated Configuration file containing table details as below:
- 1. Hive Schema
- 2. Tabe Name
- 3. File Path in HDFS
- 4. GCP Project Id
- 5. GCS bucket Name for data
- 6. BigQuery Datset
- 7. BigQuery Table Name
- 8. File Type
- 9. BigQuery Table Schema file Path

  

### script/hive_to_bq_data_load.sh
 fd
 fddgdg
