resource "aws_lb" "elkademy-front-lb" { //network load balancer
  name                             = "elkademy-front"
  subnets                          = module.vpc.public_subnets //work on public subnet
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "elkademy-front" {
  load_balancer_arn = aws_lb.elkademy-front-lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.elkademy-front-blue.id //first target will be this one,then it will switch between blue and green,blue and green are just a name that we give of different EC2 runing
    type             = "forward"
  }
  lifecycle {
    ignore_changes = [
      default_action,
    ]
  }
}

resource "aws_lb_target_group" "elkademy-front-blue" {
  name                 = "elkademy-front-http-blue"
  port                 = "3000"
  protocol             = "TCP"
  target_type          = "ip"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = "30"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "TCP"
    interval            = 30
  }
}
resource "aws_lb_target_group" "elkademy-front-green" {
  name                 = "elkademy-front-http-green"
  port                 = "3000"
  protocol             = "TCP"
  target_type          = "ip"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = "30"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "TCP"
    interval            = 30
  }
}
