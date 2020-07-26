
data "aws_s3_bucket" "bucket" {
  bucket = var.s3.bucket
}

resource "aws_s3_bucket_object" "tls" {
  count = length(local.tls_files)
  bucket = data.aws_s3_bucket.bucket.bucket
  key    = format("%s/tls/%s", var.s3.path, local.tls_files[count.index].name)
  content = local.tls_files[count.index].content
}

resource "aws_s3_bucket_object" "ignition" {
  bucket = data.aws_s3_bucket.bucket.bucket
  key    = format("%s/etcd-tls.ign", var.s3.path)
  content = data.ignition_config.config.rendered
}