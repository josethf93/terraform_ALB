resource "aws_lb" "EPCCalb" {
  name               = "epcc-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-019f73092e25c1591", "subnet-0105aa6b9327f5cc1"]
  tags = {
    Environment = "EPCC test"
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "epcc_albsg"
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
}

resource "aws_lb_target_group" "epcctg" {
  name     = "epcctg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.EPCCalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.epcctg.arn
  }
}

#Resource: aws_lb_target_group_attachment
data "aws_instance" "epccec2instance" {
  instance_id = "i-0df7b9c7c335e1e83"
}

resource "aws_instance" "joseth_ec2" {
  count                  = var.instance_count
  ami                    = var.amiid
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.alb_sg.id]
  subnet_id              = "subnet-019f73092e25c1591"
  tags = {
    "Name" = "EPCC EC2 ${var.tags[0]} ${count.index + 1}"
  }
}

resource "aws_lb_target_group_attachment" "test" {
  count            = 2
  target_group_arn = aws_lb_target_group.epcctg.arn
  target_id        = aws_instance.joseth_ec2[count.index].id
  port             = 80
}

output "endpoint" {
  value = aws_lb.EPCCalb.dns_name
}