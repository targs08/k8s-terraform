
data "aws_s3_bucket" "bucket" {
  bucket = var.s3.bucket
}

resource "aws_s3_bucket_object" "tls" {
  count = length(local.tls_files)
  bucket = data.aws_s3_bucket.bucket.bucket
  key    = format("%s/tls/%s", var.s3.path, local.tls_files[count.index].name)
  content = local.tls_files[count.index].content
}

resource "aws_s3_bucket_object" "tls-nodes-crt" {
  count = length(var.nodes)
  bucket = data.aws_s3_bucket.bucket.bucket
  key    = format("%s/tls/etcd/%s.crt", var.s3.path, element(var.nodes, count.index))
  content = element(module.etcd-node.*.cert_pem, count.index)
}

resource "aws_s3_bucket_object" "tls-nodes-key" {
  count = length(var.nodes)
  bucket = data.aws_s3_bucket.bucket.bucket
  key    = format("%s/tls/etcd/%s.key", var.s3.path, element(var.nodes, count.index))
  content = element(module.etcd-node.*.private_key_pem, count.index)
}

resource "aws_s3_bucket_object" "ignition" {
  bucket = data.aws_s3_bucket.bucket.bucket
  key    = format("%s/etcd/common.ign", var.s3.path)
  content = data.ignition_config.common.rendered
}

resource "aws_s3_bucket_object" "ignition-nodes" {
  count = length(var.nodes)
  bucket = data.aws_s3_bucket.bucket.bucket
  key    = format("%s/etcd/%s.ign", var.s3.path, element(var.nodes, count.index))
  content = element(data.ignition_config.nodes.*.rendered, count.index)
}