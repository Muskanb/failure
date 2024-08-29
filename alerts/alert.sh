#!/bin/bash

read errorMessage
service=$1

SLACK_CHANNEL="#ec2-health"

echo "Received error: '$errorMessage' for service '$service'"

if [[ $errorMessage == "" ]] ; then
    echo "No error message, exiting"
    aws cloudwatch put-metric-data --metric-name $service --namespace "DatabaseBackups" --value 1 --region eu-south-1
    exit 0
fi

if ! command -v slacktee.sh &> /dev/null
then
    echo "> slacktee.sh could not be found, installing.."
    git clone https://github.com/course-hero/slacktee.git && sudo bash ./slacktee/install.sh -s && sudo sh -c 'echo '\''
    webhook_url=""
    token="randommmmmmmmm"
    tmp_dir="/tmp"
    channel="#ec2-health"
    username="slacktee"
    icon="ghost"
    attachment="danger"'\'' >> /etc/slacktee.conf' && sudo rm -r slacktee
fi

echo "> Creating JIRA ticket (assignee: PM)"
JIRATicketOutput=$(curl -X POST \
  https://privado-ai.atlassian.net/rest/api/2/issue/ \
     -H 'Accept: */*' \
     -H "Content-Type: application/json" \
     -u changesssssss \
     --data-binary @- << EOF
{
    "fields": {
       "project":
       {
          "key": "DM"
       },
       "summary": "BACKUP Script failed for $service",
       "description": "ERROR: $errorMessage",
       "issuetype": {
          "name": "Bug"
       },
       "assignee": {
          "accountId":"5e8d9104f135980b7bdced15"    
        }
   }
}
EOF
)

echo "> Updating cloudwatch metric value"
aws cloudwatch put-metric-data --metric-name $service --namespace "hhhh" --value 0 --region eu-south-1


echo "> Sending slack message"
echo $errorMessage | slacktee.sh -t ":rotating_light: Backup CRON failed for $service" -a "danger" -e "Jira Ticket Details:" '```'$JIRATicketOutput'```' -c "$SLACK_CHANNEL"
