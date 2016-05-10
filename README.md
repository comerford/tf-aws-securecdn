Secure S3 Backed CDN with Terraform
===================================
This repo contains a generalised Terraform config for creating a secure S3-backed asset store behind a Cloudfront CDN.

How do I use it?
================
You will need the following at a minimum:

* AWS API keys with sufficient permissions to:
  * Add route53 resource records
  * Create Cloudfront distributions (and origin identities)
  * Create S3 Buckets
* An [ACM SSL cert](https://aws.amazon.com/certificate-manager/) in us-east-1 (currently only available in that region)
* A route53 hosted zone for the chosen domain (in the same account)

First thing to do is to create the terraform.tfvars file ([example included]()). The keys can be passed in via environment variables (Note: if you do add the tfvars file it will be git ignored, for safety). Sample (example.com) versions of the relevant pieces have been included, and there are only ~10 variables that need to be set.
