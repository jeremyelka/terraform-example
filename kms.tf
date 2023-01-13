#
# kms
#
data "aws_iam_policy_document" "artifact-elkademy-kms-policy" {
  policy_id = "key-default-1"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_kms_key" "artifact-elkademy" {
  description = "kms key for demo artifacts"
  policy      = data.aws_iam_policy_document.artifact-elkademy-kms-policy.json
}

resource "aws_kms_alias" "artifact-elkademy" {
  name          = "alias/artifact-elkademy"
  target_key_id = aws_kms_key.artifact-elkademy.key_id
}


