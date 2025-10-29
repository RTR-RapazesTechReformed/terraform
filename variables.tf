variable "email_list" {
  description = "Lista de e-mails para o SNS e Lambda"
  type        = list(string)
}

variable "iam_role_arn" {
  description = "ARN da role IAM para a função Lambda"
  type        = string
}