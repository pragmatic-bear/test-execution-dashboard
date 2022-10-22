#!/bin/bash

MY_DIR="$(dirname "$0")"

set -e

POSITIONAL=()

while [[ $# -gt 0 ]]; do
  key="$1"

  case ${key} in
  -s | --sourceusername)
    FROM_ORG="$2"
    shift
    shift
    ;;
  -u | --targetusername)
    TO_ORG="$2"
    shift
    shift
    ;;
  -i | --asyncapexjobid)
    RUN_ID="$2"
    shift
    shift
    ;;
  -n | --namespace)
    NAMESPACE="$2"
    shift
    shift
    ;;
  *) # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift
    ;;
  esac
done

SOURCE_QUERY="SELECT Id, ApexTestRunResultId, TestTimestamp, RunTime, ApexClass.Name, MethodName FROM ApexTestResult"
if [[ -z $RUN_ID ]]; then
    echo "Getting All Completed Test Results.."
    SOURCE_QUERY="$SOURCE_QUERY WHERE ApexTestRunResult.Status = 'Completed'"
else
    echo "Getting Test Results for Job Id $RUN_ID.."
    SOURCE_QUERY="$SOURCE_QUERY WHERE ApexTestRunResult.AsyncApexJobId = '$RUN_ID'"
fi;
SOURCE_CMD="sfdx force:data:soql:query --query=\"$SOURCE_QUERY\" --resultformat=csv"
if [[ -z $FROM_ORG ]]; then
    echo ".. from project default org"
else
    echo ".. from $FROM_ORG"
    SOURCE_CMD="$SOURCE_CMD --targetusername=$FROM_ORG"
fi;

if [[ -z $NAMESPACE ]]; then
    echo "No Namespace prefix will be applied for import"
else
    echo "Follwoing Namespace prefix will be applied to import: $NAMESPACE"
    NAMESPACE="${NAMESPACE}__"
fi;

eval $SOURCE_CMD > test-result.csv

#delete first line in CSV
tail -n+2 test-result.csv > test-result2.csv
#replace with SObject field API names
echo -e "${NAMESPACE}TestResultId__c,${NAMESPACE}TestRunId__c,${NAMESPACE}TestTimestamp__c,${NAMESPACE}RunTime__c,${NAMESPACE}ClassName__c,${NAMESPACE}MethodName__c\n$(cat test-result2.csv)" > test-result3.csv

if [[ -z $TO_ORG ]]; then
    echo "Uploading Test Results to project default org"
    sfdx force:data:bulk:upsert --sobjecttype "${NAMESPACE}TestResult__c" --csvfile test-result3.csv --externalid "${NAMESPACE}TestResultId__c"
else
    echo "Uploading Test Results to $TO_ORG"
    sfdx force:data:bulk:upsert --sobjecttype "${NAMESPACE}TestResult__c" --csvfile test-result3.csv --externalid "${NAMESPACE}TestResultId__c" --targetusername=$TO_ORG
fi;