resource "aws_iam_role" "ecs_role" {
    
    name = "argos-ecs-role"

    assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": { "Service": "ecs.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }
    ]
}   
    EOF
}

resource "aws_iam_role_policy_attachment" "svc" {
    role = aws_iam_role.ecs_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}