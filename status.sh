#!/bin/sh

# note: setting env variables
. ./.env

# note: describe service software options
SERVICE_SOFTWARE_OPTIONS=$(aws es describe-elasticsearch-domain --region $AWS_REGION --domain-name $AWS_ES_DOMAIN | jq '.DomainStatus.ServiceSoftwareOptions')

# note: show metrics for degraded cluster health
YELLOW_CLUSTER_STATUS=$(aws cloudwatch get-metric-statistics \
  --region $AWS_REGION \
  --metric-name ClusterStatus.yellow \
  --start-time "$AWS_MONITOR_DATE T00:00:00Z" \
  --end-time "$AWS_MONITOR_DATE T23:59:59Z" \
  --period 3600 \
  --namespace AWS/ES \
  --statistics Maximum \
  --dimensions Name=DomainName,Value=$AWS_ES_DOMAIN)

RED_CLUSTER_STATUS=$(aws cloudwatch get-metric-statistics \
  --region $AWS_REGION \
  --metric-name ClusterStatus.red \
  --start-time "$AWS_MONITOR_DATE T00:00:00Z" \
  --end-time "$AWS_MONITOR_DATE T23:59:59Z" \
  --period 3600 \
  --namespace AWS/ES \
  --statistics Maximum \
  --dimensions Name=DomainName,Value=$AWS_ES_DOMAIN)

echo "Service Software Options: \n$SERVICE_SOFTWARE_OPTIONS\n"
echo "CloudWatch statistics for ClusterStatus.yellow metric on ES domain \"$AWS_ES_DOMAIN\": \n$YELLOW_CLUSTER_STATUS\n"
echo "CloudWatch statistics for ClusterStatus.red metric on ES domain \"$AWS_ES_DOMAIN\": \n$RED_CLUSTER_STATUS"
