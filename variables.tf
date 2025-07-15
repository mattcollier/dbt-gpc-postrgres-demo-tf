variable "project_id" {}
variable "region" { default = "us-central1" } # free-tier region
variable "db_user" { default = "dbt" }
variable "db_password" {}
variable "db_name" { default = "mydb" }

# dbt Cloud publishes its egress ranges here:
# https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses
variable "dbt_cloud_cidrs" {
  type = list(string)
  default = [
    "52.45.144.63/32",
    "54.81.134.249/32",
    "52.22.161.231/32",
    "52.3.77.232/32",
    "3.214.191.130/32",
    "34.233.79.135/32"
  ] # North-America (us-east-1) cell  [oai_citation:3‡dbt Developer Hub](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses)
}