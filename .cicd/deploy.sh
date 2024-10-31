#! /bin/bash


## Call TFC API
sed "s/my-workspace-id/${WORKSPACE_ID}/" < .cicd/api_templates/run.json.template  > run.json
cat run.json
#curl --header "Authorization: Bearer ${TFC_TOKEN}" --header "Content-Type: application/vnd.api+json" --data @run.json "https://${TFC_ADDR}/api/v2/runs" > run_result.txt

cat run.json

curl -v \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @run.json \
  https://app.terraform.io/api/v2/runs > run_result.txt


cat run_result.txt
run_id=$(cat run_result.txt | jq -r .data.id)
echo "Run ID is ${run_id}"
curl --header "Authorization: Bearer $TFC_TOKEN" --header "Content-Type: application/vnd.api+json" "https://app.terraform.io/api/v2/runs/${run_id}" > result.txt
cat result.txt
result=$(cat result.txt | jq -r .data.attributes.status)
echo "Run result is ${result}. View this Run in TFC UI:"
echo "https://app.terraform.io/app/${TFC_ORG}/workspaces/${TFC_WORKSPACE}/runs/${run_id}"