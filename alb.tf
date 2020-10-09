

resource "aws_lb" "traefik" {
  name               = "api"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.traefik.id]
  subnets            = module.vpc.public_subnets
}


resource "aws_lb_target_group" "traefik_api" {
  name        = "traefik-api"
  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
  health_check {
    path    = "/"
    matcher = "200-202,300-302"
  }
  depends_on = [aws_lb.traefik]
}


resource "aws_lb_target_group" "traefik" {
  name        = "traefik"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
  health_check {
    path    = "/"
    matcher = "200-202,404"
  }
  depends_on = [aws_lb.traefik]
}


resource "aws_lb_target_group" "traefik_ssl" {
  name        = "traefik-ssl"
  target_type = "ip"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = data.aws_vpc.main.id
  health_check {
    protocol = "HTTPS"
    path    = "/"
    matcher = "200-202,404"
  }
  depends_on = [aws_lb.traefik]
}

resource "aws_lb_listener" "front_api" {
  load_balancer_arn = aws_lb.traefik.arn
  port              = "8080"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik_api.arn
  }
}

resource "aws_lb_listener" "front_ssl" {
  load_balancer_arn = aws_lb.traefik.arn
  port              = "443"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik_ssl.arn
  }
}


resource "aws_lb_listener" "front" {
  load_balancer_arn = aws_lb.traefik.arn
  port              = "80"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik.arn
  }
}
