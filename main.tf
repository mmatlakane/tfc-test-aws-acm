terraform {
  required_providers {
    aws = {
      source        = "hashicorp/aws"
      version       = "5.22.0"
     
    }
  }
}
provider "aws" {
  alias      = "validation_account"
  access_key = var.dev_aws_key
  secret_key = var.dev_aws_secret
  region     = "us-east-1"

assume_role {
    role_arn = "arn:aws:iam::700688370064:role/route53"
  }
}

resource "aws_acm_certificate" "cert_validation" {
  domain_name       = var.domain_name
  validation_method = var.dns_validation ? "DNS" : "EMAIL"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    name        = var.name
    local-name  = var.local-name
    environment = var.environment
  }
}
resource "aws_acm_certificate_validation" "cert_validation_dns" {
  count                   = var.dns_validation ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert_validation.arn
  validation_record_fqdns = [aws_route53_record.cert_validation_route53_record.fqdn]
}
resource "aws_acm_certificate_validation" "cert_validation_cross_account_dns" {
  count                   = var.dns_validation && var.cross_account_validation ? 1 : 0
  #provider                = aws.validation_account
  certificate_arn         = aws_acm_certificate.cert_validation.arn
  validation_record_fqdns = [aws_route53_record.cert_validation_route53_record_cross_account[0].fqdn]
}
resource "aws_acm_certificate_validation" "cert_validation_email" {
  count           = var.dns_validation ? 0 : 1
  certificate_arn = aws_acm_certificate.cert_validation.arn
}
# resource "aws_acm_certificate_validation" "cert_validation_both" {
#   count                   = var.dns_validation ? 1 : 0
#   certificate_arn         = aws_acm_certificate.cert_validation.arn
#   validation_record_fqdns = [for record in var.record_fqdn : record.fqdn]
# }
resource "aws_route53_zone" "cert_validation_zone" {
  name = var.domain_name
}
resource "aws_route53_record" "cert_validation_route53_record" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.cert_validation.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.cert_validation.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.cert_validation.domain_validation_options)[0].resource_record_type
  zone_id         = aws_route53_zone.cert_validation_zone.zone_id
  ttl             = 60
}
resource "aws_route53_record" "cert_validation_route53_record_cross_account" {
  count           = var.dns_validation && var.cross_account_validation ? 1 : 0
  provider        = aws.validation_account
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.cert_validation.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.cert_validation.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.cert_validation.domain_validation_options)[0].resource_record_type
  zone_id         = aws_route53_zone.cert_validation_zone.zone_id
  ttl             = 60
}