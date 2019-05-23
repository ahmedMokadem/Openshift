provider "aws" {
  region       = "eu-west-1"
  shared_credentials_file = "~/.aws/credentials"
}

#SSH Inbound Traffic

###ETCD security group

resource "aws_security_group" "security" {
 name = "openshift-terraform-security"
 vpc_id      = "vpc-06e55c08796123647"
 egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
 ingress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}


#alc masters
resource "aws_launch_configuration" "terraform-openshift-masters" {
 key_name               = "${aws_key_pair.generated.key_name}"
 image_id               = "${var.ami}"
 iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"
 instance_type          = "t3.xlarge"
 security_groups        = ["${aws_security_group.security.id}"]
 lifecycle {
   create_before_destroy = true
 }
 root_block_device {
    volume_type = "gp2"
    volume_size = 60
 }
 ebs_block_device {
      device_name = "/dev/sdb"
      volume_size = "50"
      volume_type = "gp2"
      delete_on_termination = true
  }
}
#auto scaling group
resource "aws_autoscaling_group" "openshift-masters-asg" {
 launch_configuration = "${aws_launch_configuration.terraform-openshift-masters.id}"
 name                 = "Openshift Master"
 vpc_zone_identifier  = ["subnet-0f9959d52c6baa920","subnet-0e0a18a03371102a9","subnet-0b85034db8a86b01e"]
 availability_zones   = ["eu-west-1c","eu-west-1a","eu-west-1b"]
 min_size = 3
 max_size = 3
 tag {
   key = "Name"
   value = "terraform-asg-masters"
   propagate_at_launch = true
 }
}

#alb asg attachement
resource "aws_autoscaling_attachment" "asg_attachment" {
 autoscaling_group_name = "${aws_autoscaling_group.openshift-master-asg.id}"
 alb_target_group_arn   = "${aws_alb_target_group.terraform-openshift-alb.arn}"
}



#alb asg nodes
resource "aws_launch_configuration" "terraform-openshift-nodes" {
 key_name               = "${aws_key_pair.generated.key_name}"
 image_id               = "${var.ami}"
 iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"
 instance_type          = "t3.large"
 security_groups        = ["${aws_security_group.security.id}"]
 lifecycle {
   create_before_destroy = true
 }
 root_block_device {
    volume_type = "gp2"
    volume_size = 60
 }
 ebs_block_device {
      device_name = "/dev/sdb"
      volume_size = "50"
      volume_type = "gp2"
      delete_on_termination = true
 }
}
resource "aws_autoscaling_group" "openshift-node-asg" {
 launch_configuration = "${aws_launch_configuration.terraform-openshift-nodes.id}"
 name                 = "Openshift Node"
 vpc_zone_identifier  = ["subnet-0f9959d52c6baa920","subnet-0e0a18a03371102a9","subnet-0b85034db8a86b01e"]
 availability_zones   = ["eu-west-1c","eu-west-1a","eu-west-1b"]
 min_size = 3
 max_size = 4
 tag {
   key = "Name"
   value = "terraform-asg-nodes"
   propagate_at_launch = true
 }
}

#alb asg infra
resource "aws_launch_configuration" "terraform-openshift-infra" {
 key_name               = "${aws_key_pair.generated.key_name}"
 image_id               = "${var.ami}"
 iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"
 instance_type          = "t3.large"
 security_groups        = ["${aws_security_group.security.id}"]
 lifecycle {
   create_before_destroy = true
 }
 root_block_device {
    volume_type = "gp2"
    volume_size = 60
 }
 ebs_block_device {
      device_name = "/dev/sdb"
      volume_size = "50"
      volume_type = "gp2"
      delete_on_termination = true
 }
}
resource "aws_autoscaling_group" "openshift-infra-asg" {
 launch_configuration = "${aws_launch_configuration.terraform-openshift-infra.id}"
 name                 = "Openshift Infra"
 vpc_zone_identifier  = ["subnet-0f9959d52c6baa920","subnet-0e0a18a03371102a9","subnet-0b85034db8a86b01e"]
 availability_zones   = ["eu-west-1c","eu-west-1a","eu-west-1b"]
 min_size = 3
 max_size = 3
 tag {
   key = "Name"
   value = "terraform-asg-infra"
   propagate_at_launch = true
 }

}




#alb
resource "aws_alb_target_group" "terraform-openshift-alb" {
  name     = "terraform-openshift-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-06e55c08796123647"
}
resource "aws_alb" "oc-terraform-alb" {
  name            = "oc-terraform-alb"
  internal        = false
  subnets         = ["subnet-031a4fe65c687a12d","subnet-003b64a619169a13f","subnet-04cac1f9e3ff65e0a"]
  security_groups = ["${aws_security_group.lb_sg.id}"]
}
resource "aws_alb_listener" "front-end" {
  load_balancer_arn = "${aws_alb.oc-terraform-alb.id}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.terraform-openshift-alb.id}"
    type             = "forward"
  }
}
resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ELB"

  vpc_id = "vpc-06e55c08796123647"
  name   = "alb_security_group"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

#keyyyyy
resource "tls_private_key" "generated" {
 algorithm = "RSA"
 rsa_bits  = 4096
}
resource "aws_key_pair" "generated" {
 key_name   = "KeYYYY"
 depends_on = ["tls_private_key.generated"]
 public_key = "${tls_private_key.generated.public_key_openssh}"
}
#Storing the key pair via local file
resource "local_file" "private_key_pem" {
 content    = "${tls_private_key.generated.private_key_pem}"
 depends_on = ["tls_private_key.generated"]
 filename   =  "/home/storedkeys/KeYYYY.pem"
 provisioner "local-exec" {
   command = "chmod a+rwx /home/storedkeys/KeYYYY.pem"
 }
}


