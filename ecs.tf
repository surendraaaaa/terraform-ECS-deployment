resource "aws_ecs_cluster" "my_ecs" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "my_td" {
  family                   = "${var.ecs_cluster_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.desired_td_cpu
  memory                   = var.desired_td_memory
  execution_role_arn       = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "backend"
      image        = "surendraprajapati/jenkins-k8s-3tier-backend:v2"
      essential    = true
      portMappings = [{ containerPort = 5000 }]
      environment = [
        {
          name  = "MONGO_URL"
          value = var.mongodb_uri
        }
      ]
    },
    {
      name         = "frontend"
      image        = "surendraprajapati/jenkins-k8s-3tier-frontend:v2"
      essential    = true
      portMappings = [{ containerPort = 3000 }]
    }
  ])
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
    container_name   = "frontend"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.app_listener
  ]
}
