if [ "${ENVIRONMENT}" = "prd" ]
then
export lzTFC=aws secretsmanager get-secret-value --region us-east-1 --secret-id secret-name | jq -r ".SecretString"
export TFC_TOKEN=echo $lzTFC | jq -r .TFC_TOKEN
else
# TFC4B BHPEG Token (NPE)
export lzTFC=aws secretsmanager get-secret-value --region us-east-1 --secret-id secret-name-npe | jq -r ".SecretString"
export TFC_TOKEN=echo $lzTFC | jq -r .TFC_TOKEN
fi 


if [ "${lzTFC}" != "" ]
then
  echo "Fetched TFC ORG Token"
else
  echo "lzTFC is empty"
  exit 1
fi    


# Get the workspace ID if it already exists:
curl   --header "Authorization: Bearer $TFC_TOKEN"   --header "Content-Type: application/vnd.api+json"   "https://$TFC_ADDR/api/v2/organizations/$TFC_ORG/workspaces/$TFC_WORKSPACE" > workspaceId
cat workspaceId
export WORKSPACE_ID=cat workspaceId | jq -r '.data.id'
echo $WORKSPACE_ID


## Fetch Spoke Account's terraform user Credentals ###
export AWS_CREDS=$(aws secretsmanager get-secret-value --region us-east-1 --secret-id "ACCOUNT_ID/${ACCOUNT_ID}" | jq -r ".SecretString" 2> /dev/null)


if [ -n "${AWS_CREDS}" ]; then
    echo "Fetched AWS Account Credentials"
    export SPOKE_AWS_ACCESS_KEY_ID=$(echo "$AWS_CREDS" | jq -r '.AWS_ACCESS_KEY_ID')
    export SPOKE_AWS_SECRET_ACCESS_KEY=$(echo "$AWS_CREDS" | jq -r '.AWS_SECRET_ACCESS_KEY')
else
    echo "AWS Account Credentials for ACCOUNT_ID - ${ACCOUNT_ID} not found in Secrets Manager"
    echo "Creating the secrets in Secrets Manager"
    
    echo "Retrieving Guardrail workspace ID"
    workspace_id=$(curl -s --header "Authorization: Bearer ${TFC_TOKEN}" --header "Content-Type: application/vnd.api+json" \
                   "https://${TFC_ADDR}/api/v2/organizations/${TFC_ORG}/workspaces/${TFC_WORKSPACE_TFC4B}" | jq -r .data.id)


    if [ -z "$workspace_id" ]; then
        echo "Guardrail workspace ID not found"
        exit 1
    fi
    
    echo "Fetching current statefile URL for workspace ${TFC_WORKSPACE_TFC4B}"
    url=$(curl -s --header "Authorization: Bearer ${TFC_TOKEN}" --header "Content-Type: application/vnd.api+json" \
          "https://${TFC_ADDR}/api/v2/workspaces/${workspace_id}/current-state-version" | jq -r '.data.attributes."hosted-state-download-url"')
    
    if [ -z "$url" ]; then
        echo "Failed to retrieve statefile URL"
        exit 1
    fi


    echo "Downloading statefile and extracting credentials"
    content=$(wget "$url" -q -O -)
    export SPOKE_AWS_ACCESS_KEY_ID=$(echo "$content" | jq -r '.outputs.iam_terraform.value."access_key"')
    export SPOKE_AWS_SECRET_ACCESS_KEY=$(echo "$content" | jq -r '.outputs.iam_terraform.value."secret_key"')


    cat > creds_terraform.json <<EOF
{
  "AWS_ACCESS_KEY_ID": "${SPOKE_AWS_ACCESS_KEY_ID}",
  "AWS_SECRET_ACCESS_KEY": "${SPOKE_AWS_SECRET_ACCESS_KEY}"
}
EOF


    aws secretsmanager create-secret --region us-east-1 --name "ACCOUNT_ID/${ACCOUNT_ID}" \
        --description "Terraform user credentials for account - ${ACCOUNT_ID}" \
        --secret-string file://creds_terraform.json


    rm creds_terraform.json
fi


# Store credentials in Terraform Cloud workspace as sensitive variables
echo "Storing credentials in Terraform Cloud workspace as sensitive variables"
curl -s --header "Authorization: Bearer ${TFC_TOKEN}" --header "Content-Type: application/vnd.api+json" \
     --request POST \
     --data @- <<EOF
{
  "data": {
    "type": "vars",
    "attributes": {
      "key": "AWS_ACCESS_KEY_ID",
      "value": "${SPOKE_AWS_ACCESS_KEY_ID}",
      "category": "env",
      "sensitive": true
    },
    "relationships": {
      "workspace": {
        "data": {
          "id": "${workspace_id}"
        }
      }
    }
  }
}
EOF


curl -s --header "Authorization: Bearer ${TFC_TOKEN}" --header "Content-Type: application/vnd.api+json" \
     --request POST \
     --data @- <<EOF
{
  "data": {
    "type": "vars",
    "attributes": {
      "key": "AWS_SECRET_ACCESS_KEY",
      "value": "${SPOKE_AWS_SECRET_ACCESS_KEY}",
      "category": "env",
      "sensitive": true
    },
    "relationships": {
      "workspace": {
        "data": {
          "id": "${workspace_id}"
        }
      }
    }
  }
}
EOF


echo "Credentials stored successfully in Terraform Cloud workspace as sensitive variables."