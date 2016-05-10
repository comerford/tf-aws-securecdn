{
	"Version": "2008-10-17",
	"Id": "PolicyForCloudFrontPrivateContent",
	"Statement": [
		{
			"Sid": "1",
			"Effect": "Allow",
			"Principal": {
				"AWS": "${principal_arn}"
			},
			"Action": "s3:GetObject",
			"Resource": "${s3_bucket}"
		}
	]
}
