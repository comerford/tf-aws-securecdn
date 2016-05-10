# No arguments, just a comment to describe it
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "identity for accessing CDN asset store in S3 bucket"
}

# Going with basic config here, lot of defaults
# Tip - if you have a CF distro you want to copy, use the (dev) CF CLI command
# e.g. "aws cloudfront list-distributions" to see an existing config (XML)
# makes this easier to figure out
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${var.origin_domain_name}"
    origin_id   = "${var.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }
  enabled             = true
  comment             = "S3 backed secure asset store, managed by Terraform"

  aliases = ["${split(",", var.domain_aliases)}"]

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = "${var.s3_origin_id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  # restriction is required, even if you are turning it off
  restrictions {
      geo_restriction {
        restriction_type = "none"
      }
  }
  # this is for US/Europe only
  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn = "${var.acm_ssl_cert}"
    minimum_protocol_version = "TLSv1"
    # note that other method is a higher charge
    ssl_support_method = "sni-only"
  }
}

# Need a template to be able to insert the access identity into the buket policy
# The bucket name is not strictly required, since we know that in advance, but cleaner this way
# Because of a bug, this causes "terraform plan" to carp about a $ symbol
# Likely due to passing the non-rendered version into the plan stage
# "terraform apply" will still work, assuming no errors, but need to be super careful here
# Bug: https://github.com/hashicorp/terraform/issues/5462
resource "template_file" "bucket_policy" {
    template = "${file("templates/bucket_policy.tpl")}"
    vars {
        principal_arn = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
        s3_bucket = "arn:aws:s3:::${var.bucket_name}/*"
    }
}

# set up a byucker which will only have access from the origin identity
resource "aws_s3_bucket" "s3_origin_bucket" {
    bucket = "${var.bucket_name}"
    acl = "private"
    # rendered version of the policy via the template
    policy = "${template_file.bucket_policy.rendered}"
    tags {
      Owner = "${var.tag_Owner}"
      Name = "${var.tag_Name}"
    }
}

# This assumes zones have already been created for cdn.example.com and that it is a root domain
# This is usually required so that you can create the ACM cert, another pre-req, so not including config here
# Because of the root domain, we use an alias record for the root, then a CNAME for the sub domains

resource "aws_route53_record" "root_record" {
   zone_id = "${var.domain_zone_id}"
   name = "${var.bucket_name}"
   type = "A"
   alias {
        name = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
        #hard coded zone ID for all CF distributions, go figure....
        zone_id = "Z2FDTNDATAQYW2"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "cname_records" {
   # use the number of aliases in the list to allow for multiple
   count = "${length(split(",", var.cname_aliases))}"
   zone_id = "${var.domain_zone_id}"
   name = "${element(split(",", var.cname_aliases), count.index)}"
   type = "CNAME"
   ttl = 300
   records = ["${aws_cloudfront_distribution.s3_distribution.domain_name}"]
}
