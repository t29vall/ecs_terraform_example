
variable "ecs-cluster" {
    description = "ECS Cluster"
    type        = string
    default     = "arn:aws:ecs:us-east-1:758213233865:cluster/cluster3"
}

variable "vpc-id" {
    description = "VPC ID"
    type        = string
    default     = "vpc-7fc57102"
}

variable "alb-subnets" {
    description = "ALB Subnets"
    type        = list(string)
    default     = ["subnet-321db103", "subnet-fa8de8a5"]
}

variable "dashboard-image" {
    description = "Dashboard Image"
    type        = string
    default     = "758213233865.dkr.ecr.us-east-1.amazonaws.com/dashboard_service:latest"
}

variable "analytics-image" {
    description = "Analytics Image"
    type        = string
    default     = "758213233865.dkr.ecr.us-east-1.amazonaws.com/analytics_service:latest"
}

variable "data-image" {
    description = "Data Image"
    type        = string
    default     = "758213233865.dkr.ecr.us-east-1.amazonaws.com/data_service:latest"
}