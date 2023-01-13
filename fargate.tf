resource "aws_ecs_task_definition" "elkademy" {
  family             = "elkademy"
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn      = aws_iam_role.ecs-elkademy-task-role.arn
  cpu                = 256
  memory             = 512
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]

  container_definitions = <<DEFINITION
[
  {
    "essential": true,
    "image": "${aws_ecr_repository.elkademy-repo.repository_url}",
    "name": "elkademy-front",
    "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
               "awslogs-group" : "demo",
               "awslogs-region": "${var.AWS_REGION}",
               "awslogs-stream-prefix": "ecs"
            }
     },
     "secrets": [],
     "environment": [],
     "healthCheck": {
       "command": [ "CMD-SHELL", "curl -f http://localhost:3000/ || exit 1" ],
       "interval": 30,
       "retries": 3,
       "timeout": 5
     }, 
     "portMappings": [
        {
           "containerPort": 3000,
           "hostPort": 3000,
           "protocol": "tcp"
        }
     ]
  }
]
DEFINITION

}


resource "aws_ecs_service" "front" {
  name            = "front"
  cluster         = aws_ecs_cluster.elkademy.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.elkademy.arn
  launch_type     = "FARGATE"
  depends_on      = [aws_lb.elkademy-front-lb]

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = slice(module.vpc.public_subnets, 1, 2)
    security_groups  = [aws_security_group.ecs-front.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.elkademy-front-blue.id
    container_name   = "elkademy-front"
    container_port   = "3000"
  }
  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer
    ]
  }
}

# security group
resource "aws_security_group" "ecs-front" {
  name        = "ECS front"
  vpc_id      = module.vpc.vpc_id
  description = "ECS front"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

# logs
resource "aws_cloudwatch_log_group" "elkademy" {
  name = "elkademy"
}
