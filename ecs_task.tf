data "aws_region" "current" {}

resource "aws_ecs_task_definition" "traefik" {
  family = "traefik"

  volume {
    name      = "letsencrypt"
  }

  container_definitions     = templatefile("task-definitions/traefik.json.tpl", {
    loggroup                = aws_cloudwatch_log_group.traefik.name
    debug_level             = var.debug_level
    region                  = data.aws_region.current.name
    ecs_cluster_name        = aws_ecs_cluster.traefik.name
    aws_access_key          = aws_iam_access_key.traefik.id
    secret_arn              = aws_secretsmanager_secret.traefik_secret_access_key.id
    lets_encrypt_email      = var.lets_encrypt_email
    traefik_hostname        = var.traefik_hostname
  })

  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_role.arn
  task_role_arn            = aws_iam_role.traefik.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}

resource "aws_ecs_task_definition" "whoami" {
  family = "whoami"
  container_definitions = templatefile("task-definitions/whoami.json.tpl", {
    alb_endpoint        = aws_lb.traefik.dns_name
    app_hostname            = var.app_hostname
  })
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
}

