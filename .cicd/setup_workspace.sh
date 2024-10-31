#! /bin/bash


## zip files
echo "Using Terraform variables env_vars/${ENV}.auto.tfvars"
cp env_vars/${ENV}.auto.tfvars .
tar -cvf myconfig.tar *.tf *.tfvars 
gzip myconfig.tar
#curl --header "Authorization: Bearer ${TFC_TOKEN}" --header "Content-Type: application/vnd.api+json" --data @./.cicd/api_templates/configversion.json.template "https://${TFC_ADDR}/api/v2/workspaces/${WORKSPACE_ID}/configuration-versions" > configuration_version.txt


curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @.cicd/api_templates/configversion.json.template \
  https://app.terraform.io/api/v2/workspaces/${WORKSPACE_ID}/configuration-versions > configuration_version.txt


cat configuration_version.txt
export config_version_id=$(cat configuration_version.txt | jq -r .data.id)
export upload_url=$(cat configuration_version.txt | jq -r '.["data"]["attributes"]["upload-url"]')
echo "Config Version ID is ${config_version_id}"
echo "Upload URL is ${upload_url}"
curl --request PUT -F 'data=@myconfig.tar.gz' "${upload_url}"