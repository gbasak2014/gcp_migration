#!/bin/bash

###########################################################
# This script will be triggered from Hadoop edge node.
# The script will read table details from comma separated file. Trigger distcp to push hive data from HDFS to GCS bucket
# Trigger bq load command to load data from GCS to BigQuery table.
# 
# table detail CSV file sructure
# <Hive Schema>,<Tabe Name>,<File Path in HDFS>,<GCP Project Id>,<GCS bucket Name for data>,<BigQuery Datset>,<BigQuery Table Name>,<File Type>,<BigQuery Table Schema file Path>
#  
# ##########################################################


if [ $# -lt 1 ]
then
   echo "Argument require: <Table detail file>"
   exit
fi

# write_log write log entry to Cloud Logging
write_log()
{
   MSG="$1"
   SEV=$2
   # Log Name: MY_DATA_LOAD
   gcloud logging write MY_DATA_LOAD "${MSG}"  --severity=${SEV}
}

TABLE_DETAIL_FILE=$1

# Job Start time in second for calculating total time of data load job
JOB_START_SEC=`date +%s`

# For number of table processed
TBL_CNT=0

# For number of error
ERR_COUNT=0

#For number success table
SUCCESS_COUNT=0

echo write_log "Starting data load batch job at $(date)" INFO

while IFS= read -r tbl_detail
do
   TBL_CNT=$(($TBL_CNT + 1))
   # Load time, will inserted to BigQuery table
   DATA_LOAD_TIME=`date +"%Y-%m-%d %H:%M:%S"`
   IFS=',' read -r -a arr <<< ${tbl_detail}

   #Lets parse CSV file and extract each components
   HIVE_SCHEMA="${arr[0]}"
   HIVE_TABLE="${arr[1]}"      
   HDFS_PATH="${arr[2]}"
   GCP_PROJECT="${arr[3]}"
   GCS_BUCKET="${arr[4]}"
   BQ_DS="${arr[5]}"
   BQ_TABLE="${arr[6]}"
   HIVE_FILE_TYPE="${arr[7]}"
   SCHEMA_FILE_PATH="${arr[8]}"

   echo "================================================================================="
   echo "Starting ${GCP_PROJECT}.${BQ_DS}.${BQ_TABLE}"
   
   # File will uploaded to this GCS location
   GCS_FILE_PATH="${GCS_BUCKET}/${BQ_DS}/${BQ_TABLE}/data_load_time=${DATA_LOAD_TIME}"
   # We have created extra column in BigQuery table e.g. data_load_time hence this is required, load data as
   # externally partitioned hive table.
   URI_PREFIX="${GCS_BUCKET}/${BQ_DS}/${BQ_TABLE}/{data_load_time:TIMESTAMP}"
   # Data will be loaded from this GCS path
   BQ_LOAD_URI="${GCS_BUCKET}/${BQ_DS}/${BQ_TABLE}/*"
   
   # Starting job for the table
   TABLE_START_SEC=$(date +%s)

   write_log "${TBL_CNT}: Starting data load job for table: ${GCP_PROJECT}.${BQ_DS}.${BQ_TABLE} at: $(date)" INFO
   TASK_START_SEC=$(date +%s)
   
   write_log "${TBL_CNT}.01: Starting data copy to GCS from ${HDFS_PATH} to ${GCS_FILE_PATH} at: $(date)" INFO
   hadoop distcp "${HDFS_PATH}/" "${GCS_FILE_PATH}/"
   STATUS=$?
   TASK_END_SEC=`date +%s`
   TASK_DURATION=$(($TASK_END_SEC - $TASK_START_SEC))
   
   # for tracking table load status
   TABLE_STATUS="SUCCESS"
   if [ $STATUS == 0 ]
   then
   	  # task 01 for table number TBL_CNT
      write_log "${TBL_CNT}.01: Completed data copy to GCS for table: ${BQ_DS}.${BQ_TABLE} in ${TASK_DURATION} seconds" INFO
      # Data copied to GCS, now start loading data from GCS to BigQuery table
      TASK_START_SEC=`date +%s`
      # task 02 for table number TBL_CNT
      write_log "${TBL_CNT}.02: Starting data load to BigQuery task for table: ${BQ_DS}.${BQ_TABLE} at: $(date)" INFO
      bq load --source_format=${HIVE_FILE_TYPE} --hive_partitioning_mode=CUSTOM --hive_partitioning_source_uri_prefix=${URI_PREFIX} ${GCP_PROJECT}:${BQ_DS}.${BQ_TABLE} "${BQ_LOAD_URI}" ${SCHEMA_FILE_PATH}
      STATUS=$?
      TASK_END_SEC=`date +%s`
      TASK_DURATION=$(($TASK_END_SEC - $TASK_START_SEC))
      if [ $STATUS == 0 ]
      then
         write_log "${TBL_CNT}.02: Completed data load task to table: ${BQ_DS}.${BQ_TABLE} in ${TASK_DURATION} seconds" INFO
         SUCCESS_COUNT=$(($SUCCESS_COUNT + 1))
      else
         write_log "${TBL_CNT}.02: ERROR loading data to teble: ${BQ_DS}.${BQ_TABLE}" ERROR
         ERR_COUNT=$(($ERR_COUNT + 1))
         TABLE_STATUS="FAIL"
      fi
   else
      write_log "${TBL_CNT}.01: ERROR data copy to GCS for table: ${BQ_DS}.${BQ_TABLE}" ERROR
      ERR_COUNT=$(($ERR_COUNT + 1))
      TABLE_STATUS="FAIL"
   fi
   # Completed job for the table
   TABLE_END_SEC=`date +%s`
   DURATION=$(($TABLE_END_SEC - $TABLE_START_SEC))
   write_log "${TBL_CNT}: Completed data load job for table: ${GCP_PROJECT}.${BQ_DS}.${BQ_TABLE} with status {TABLE_STATUS} at: $(date) in ${DURATION} seconds" INFO
   echo "Completed ${GCP_PROJECT}.${BQ_DS}.${BQ_TABLE}"
   echo "================================================================================="
done < ${TABLE_DETAIL_FILE}
JOB_END_SEC=`date +%s`
JOB_DURATION=$(($JOB_END_SEC - $JOB_START_SEC))
write_log "Data load batch job compled, Table Count: ${TBL_CNT}, Success Count: ${SUCCESS_COUNT}, Error Count: ${ERR_COUNT}, Duration: ${JOB_DURATION} seconds" INFO
