/*
output "vpc_id" {
  value         = data.aws_vpcs.nchau-vpc.ids[0]  
  description   = "List of Nicole's VPCs"
}
*/
output "aws_s3_bucket" {
  description   = "bucket_name"
  value         = aws_s3_bucket.nc-bucket.id
}
output "website_endpoint" {
  value = "http://${aws_s3_bucket_website_configuration.bucket.website_endpoint}/index.html"
}