#!/bin/bash

# Script to list out all the S3 buckets and display bucket info.
# Input parameter - Lists out all the S3 buckets and user need to select the correspnding number to get the bucket details
# To display info for all the buckets, select All

BUCKET_NAME=""
BUCKET_REGION=""
CREATE_DATE=""
TIMESTAMP=""
NUM_OF_FILES=""
TOTAL_SIZE_TB=""
TOTAL_SIZE_KB=""
TOTAL_SIZE_MB=""
LATEST_FILE=""
TOTAL_COST=""

getBucketLists(){
clear
echo "************ Displaying all the S3 buckets ************"
  aws s3 ls > bucket_list.txt
  echo ""
}

getBucketName(){
echo "Following buckets are available. Select the bucket name that you need info about!!"
echo ""
values=`cat bucket_list.txt | awk '{print $3}'`
bucket_names=( $values All exit )
select bucket_name in "${bucket_names[@]}"; do
    echo ""
    echo "You have chosen $bucket_name"
    if [[ $bucket_name == All ]]
    then
      getAllBucketDetails
      break
    elif [[ $bucket_name == exit ]]
    then
      break
    else
     getBucketDetails $bucket_name
     break
    fi
done


}

getS3Cost() {

TOTAL_SIZE_TB=$(echo "$TOTAL_SIZE_KB / 3072.0 " | bc)

if [[ $TOTAL_SIZE_TB -lt 50 ]]
then
        TOTAL_COST=$(echo "$TOTAL_SIZE_TB * 0.0025" | bc)
        echo "$TOTAL_COST"
elif [[ $TOTAL_SIZE_TB -gt 50 && $TOTAL_SIZE_TB -lt 450 ]]
then
        TOTAL_COST=$(echo "(50 * 0.0025) + ($TOTAL_SIZE_TB-50) * 0.024" | bc)
        echo "$TOTAL_COST"
else
        TOTAL_COST=$(echo "(50 * 0.0025) +  (450 * 0.024) + ($TOTAL_SIZE_TB-450) * 0.023" | bc)
        echo "$TOTAL_COST"
fi

}

getBucketDetails(){
  BUCKET_NAME=$1
  echo "********* Displaying Bucket Information for bucket $BUCKET_NAME *********"
  echo ""
  CREATION_DATE=`aws s3 ls | grep $BUCKET_NAME | awk {'print $1, $2'}`
  BUCKET_REGION=`aws s3api get-bucket-location --bucket $BUCKET_NAME --query LocationConstraint`
  NUM_OF_FILES=`aws s3api list-objects --bucket $BUCKET_NAME --query "[length(Contents[])]" | sed -n '2p'`
  TOTAL_SIZE_KB=`aws s3 ls s3://$BUCKET_NAME --recursive --human-readable --summarize | tail -1 | awk '{print $3}'`
  LATEST_FILE=`aws s3 ls s3://$BUCKET_NAME --recursive | sort | tail -n 1 | awk '{print $4, $1, $2}'`
  TOTAL_COST=`getS3Cost $TOTAL_SIZE_KB`

  echo "Name of the bucket : $BUCKET_NAME"
  echo "Creation date of the bucket : $CREATION_DATE"
  echo "Region of the S3 Bucket : $BUCKET_REGION"
  echo "Number of files : $NUM_OF_FILES"
  echo "Total size of files in KB : $TOTAL_SIZE_KB"
  echo "Last Modified date of the most recent file $LATEST_FILE"
  echo "Total cost of the bucket : $TOTAL_COST"

echo ""

}

getAllBucketDetails() {

echo "*********  Displaying Bucket Information ************"
echo ""

while read  CREATE_DATE TIMESTAMP BUCKET_NAME
do
  getBucketDetails $BUCKET_NAME
  echo ""
done < bucket_list.txt

echo "********* End of Display  ************"
}

main () {
getBucketLists
getBucketName
#getAllBucketDetails
}


main