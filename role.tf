resource "aws_iam_role" "traefik" {
  name = "traefik"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "traefik_policy" {
  name = "traefik_policy"
  role = aws_iam_role.traefik.id
  policy = data.aws_iam_policy_document.traefik_policy.json
}


data "aws_iam_policy_document" "traefik_policy" {
  statement {
    sid = "main"
    actions = [
      "ecs:ListClusters",
      "ecs:DescribeClusters",
      "ecs:ListTasks",
      "ecs:DescribeTasks",
      "ecs:DescribeContainerInstances",
      "ecs:DescribeTaskDefinition",
      "ec2:DescribeInstances"
    ]
    resources = [
      "*",
    ]
  }
}


resource "aws_iam_role" "ecs_role" {
  name = "ecs_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_policy_secrets" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = aws_iam_role.ecs_role.name
}


resource "aws_iam_policy" "traefik_iam_policy" {
  name   = "traefik-iam-policy"
  policy = data.aws_iam_policy_document.traefik_policy.json
}


resource "aws_iam_access_key" "traefik" {
  user = aws_iam_user.traefik.name
}

resource "aws_iam_user" "traefik" {
  name = "traefik"
  path = "/system/"
}


resource "aws_iam_user_policy_attachment" "ecs_traefik_policy" {
   user       = aws_iam_user.traefik.name
   policy_arn = aws_iam_policy.traefik_iam_policy.arn
}


resource "aws_iam_user_policy_attachment" "ecs_traefik_policy_secrets" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  user       = aws_iam_user.traefik.name
}


# aws secretsmanager delete-secret --secret-id traefik-secret-access-key --force-delete-without-recovery --region sa-east-1
/*Store access keys in Secret manager to retrieve it with Fargate*/
resource "aws_secretsmanager_secret" "traefik_secret_access_key" {
  name        = "traefik-secret-access-key"
  recovery_window_in_days = 0
  description = "contains traefik secret access key"
}
 
resource "aws_secretsmanager_secret_version" "key" {
  depends_on = [aws_secretsmanager_secret.traefik_secret_access_key]
  secret_id     = aws_secretsmanager_secret.traefik_secret_access_key.id
  secret_string = aws_iam_access_key.traefik.secret
}
 

output "access_key" {
  value = aws_iam_access_key.traefik.id
}
 
output "secret_id" {
  value = aws_secretsmanager_secret.traefik_secret_access_key.id
}


