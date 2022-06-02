# Data load from On-premises Hive(HDFS) to BigQuery on Google Cloud Platform.
  Configuration driven shell script to load data from Hive(HDFS) to Google BigQuery. The script support PARQUET, ORC and CSV file format. 

## High Level design
![image](https://user-images.githubusercontent.com/9164441/171553948-c8ae37d4-89a2-453b-b583-a722e9c4aa78.png)


## Prerequisite:
Hadoop cluster with GCS connector installed to each data node
  GCP project with below API enabled

- GCS 
- BigQuery
- Cloud Logging
- Service Account with roles GCS objectCreator, BigQuery jobUser, BigQuery dataViewer, BigQuery dataEditor and logWriter
- Service Account Key configured to Hadoop cluster
- BigQuery dataset and table should be created accroding to Hive table schema with one additional column data_load_time of type Timestamp.
  
## Components
### conf/sample_table_details.csv:
 Comma(,) separated Configuration file containing table details as below:
1. Hive Schema
2. Tabe Name
3. File Path in HDFS
4. GCP Project Id
5. GCS bucket Name for data
6. BigQuery Datset
7. BigQuery Table Name
8. File Type
9. BigQuery Table Schema file Path
  
  
### script/hive_to_bq_data_load.sh
  Trigger this shell script from Hadoop edge node with argument table detail (sample_table_details.csv) configuration file. The script will parse the configuration file and extract components and perform data load operation. The script works as below
- Write log entry to cloud logging for data load batch start
- Trigger distp to copy files from HDFS to GCS bucket
- Trigger bq load command to load data from GCS bucket to BigQuery table
- Write log entry to Cloud Logging for each activity, success and failure, time taken for each task
- Write log entry to Cloud Logging with consolidated result such as number of table processed, success count, failure count, total duration of batch completion.
  
  