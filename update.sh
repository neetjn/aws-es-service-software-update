#!/bin/sh

# note: setting env variables
. ./.env

AWS_ES_CONSOLE="https://$AWS_REGION.console.aws.amazon.com/esv3/home?region=$AWS_REGION#opensearch/domains/$AWS_ES_DOMAIN?tabId=notificationConfig"

# note: getting service software options for target domain
STATUS=$(aws es describe-elasticsearch-domain --region $AWS_REGION --domain-name $AWS_ES_DOMAIN \
  | jq '.DomainStatus.ServiceSoftwareOptions')

# note: checking eligibility status based off service software options
IS_ELIGIBLE=$(echo $STATUS | jq '.UpdateStatus' | grep "ELIGIBLE")

if [ -z $IS_ELIGIBLE ]; then
  echo "No service software update is available for domain \"$AWS_ES_DOMAIN\""
else
  echo "Beginning update..."
  echo "Service software options: \n$STATUS"
  CURRENT_VERSION=$(echo $STATUS | jq '.CurrentVersion')
  NEW_VERSION=$(echo $STATUS | jq '.NewVersion')
  VERSION_DIFF="$CURRENT_VERSION -> $NEW_VERSION"
  read -p "Are you sure you would like to proceed updating domain \"$AWS_ES_DOMAIN\" from service software version $VERSION_DIFF (y/n) " yn
  case $yn in
    y)
      echo "Beginning service software update $VERSION_DIFF..."
      # note: initiating the service software update
      UPDATE_STATUS=$(aws es start-elasticsearch-service-software-update --region $AWS_REGION --domain $AWS_ES_DOMAIN --debug)
      echo "Update status: \n$UPDATE_STATUS"
      echo "To view the updates via the aws console use the following link: $AWS_ES_CONSOLE"
      ;;
    n)
      echo "Skipping update, exiting script."
      ;;
    *)
      echo "Invalid response \"$yn\", exiting script."
      ;;
  esac
fi
