variable "ecs_cluster_name" {
    default = "terra-ecs"
    type = string
}

variable "container_name" {
    default = "app-container"
    type = string
}

variable "container_port" {
    default = 80
    type = number
}

variable "service_count" {
    default = 1
    type = number
}

variable "desired_td_memory" {
    default = 512
    type = number
}

variable "desired_td_cpu" {
    default = 256
    type = number
}

variable "alb_sg_name" {
    default = "terra-alb-sg"
    type = string
}

variable "ecs_task_sg_name" {
    default = "terra-ecs-task-sg"
    type = string
}

variable "lb_name" {
    default = "terra-ecs-lb"
    type = string
}

variable "lb_type" {
    default = "application"
    type = string
    description = "application or network"
}

variable "lb_target_group_name" {
    default = "terra-ecs-lb-tg"
    type = string
}

variable "mongodb_uri" {
  description = "MongoDB connection string"
  type        = string
}