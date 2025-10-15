

resource "aws_ecs_cluster" "my_ecs" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "my_td" {
  family                   = "${var.ecs_cluser_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.desired_td_cpu
  memory                   = var.desired_td_memory
  execution_role_arn       = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = var.container_name
    image     = "nginx:latest" # Replace with your image
    essential = true
    portMappings = [{
      containerPort = var.container_port
    }]
  }])
}



resource "aws_ecs_service" "my_svc" {
  name            = "${var.ecs_cluster_name}-service"
  cluster         = aws_ecs_cluster.my_ecs.id
  task_definition = aws_ecs_task_definition.my_td.arn
  launch_type     = "FARGATE"
  desired_count   = var.service_count

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [
  aws_lb_listener.app_listener
  ]
}
