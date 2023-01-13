resource "aws_codedeploy_app" "elkademy" {
  compute_platform = "ECS"
  name             = "elkademy"
}

resource "aws_codedeploy_deployment_group" "elkademy" {
  app_name               = aws_codedeploy_app.elkademy.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce" //we have few way to update all of server,here we choose allAtOnce
  deployment_group_name  = "elkademy"
  service_role_arn       = aws_iam_role.elkademy-codedeploy.arn//from file iam-codedeploy.tf,to have access to ECS and Load balancer,to make the switch of the target group

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service { //define our ECS cluster
    cluster_name = aws_ecs_cluster.elkademy.name
    service_name = aws_ecs_service.front.name
  }

  load_balancer_info { //define our load balancer
    target_group_pair_info {
      prod_traffic_route { //listener to split the trafic
        listener_arns = [aws_lb_listener.elkademy-front.arn]
      }

      target_group { //blue target
        name = aws_lb_target_group.elkademy-front-blue.name
      }

      target_group { //green target
        name = aws_lb_target_group.elkademy-front-green.name
      }
    }
  }
}
