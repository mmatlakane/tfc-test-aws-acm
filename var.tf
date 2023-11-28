# variable "acm_domain_name" {
#   type = string
#   description = " Domain name for which the certificate should be issued"
# }

# variable "r53_zone_id" {
#   type = string
#   description = "The ID of the hosted zone to contain this record."
# }
variable "domain_name" {
  type    = string
  default = "gladmanchikosha.com"

}
variable "name" {

}
variable "environment" {
  type    = string
  default = "dev"

}
variable "local-name" {
  type    = string
  default = "dev-test-cert"
}
variable "dns_validation" {
  type = bool
  default=true

}
variable "dns_validation_method" {
  type    = string
  default = "DNS"
}
variable "cross_account_validation" {
  type    = bool
  default = true
}
variable "dev_aws_key" {

}
variable "dev_aws_secret" {

}