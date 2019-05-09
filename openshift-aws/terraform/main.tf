provider "aws" {
  region       = "eu-west-1"
  shared_credentials_file = "~/.aws/credentials"
}

#SSH Inbound Traffic

###ETCD security group

resource "aws_security_group" "etcd-sg" {
  name        = "allow_all_etcd"
  description = "Allow Etcd Traffic"
  vpc_id      = "vpc-06e55c08796123647"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2379
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


 ingress {
    from_port   = 2380
    to_port     = 2380
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
#Master security group

resource "aws_security_group" "master-sg" {
  name        = "allow_all_from_masters"
  description = "Allow Master  Traffic"
  vpc_id      = "vpc-06e55c08796123647"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8053
    to_port     = 8053
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8053
    to_port     = 8053
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#node security group

resource "aws_security_group" "node-sg" {
  name        = "allow_all_nodes"
  description = "Allow nodes TCP/UDP Traffic"
  vpc_id      = "vpc-06e55c08796123647"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#infra security group

resource "aws_security_group" "infra-sg" {
  name        = "allow_all_infra"
  description = "Allow infra TCP/UDP Traffic"
  vpc_id      = "vpc-06e55c08796123647"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#alc masters
resource "aws_launch_configuration" "terraform-openshift-masters" {
 key_name               = "${aws_key_pair.generated.key_name}"
 image_id               = "ami-0c3c7cbc06d0fe061"
 iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"
 instance_type          = "t3.xlarge"
 security_groups        = ["${aws_security_group.master-sg.id}","${aws_security_group.etcd-sg.id}"]
 lifecycle {
   create_before_destroy = true
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
 autoscaling_group_name = "${aws_autoscaling_group.openshift-masters-asg.id}"
 alb_target_group_arn   = "${aws_alb_target_group.terraform-openshift-alb.arn}"
}



#alb asg nodes
resource "aws_launch_configuration" "terraform-openshift-nodes" {
 key_name               = "${aws_key_pair.generated.key_name}"
 image_id               = "ami-0bde82cd082087c35"
 iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"
 instance_type          = "t3.large"
 security_groups        = ["${aws_security_group.node-sg.id}"]
 lifecycle {
   create_before_destroy = true
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
 image_id               = "ami-0bde82cd082087c35"
 iam_instance_profile   = "${aws_iam_instance_profile.ec2_profile.name}"
 instance_type          = "t2.medium"
 security_groups        = ["${aws_security_group.infra-sg.id}"]
 lifecycle {
   create_before_destroy = true
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
  port     = 8443
  protocol = "HTTP"
  vpc_id   = "vpc-06e55c08796123647"
}
resource "aws_alb" "oc-terraform-alb" {
  name            = "oc-terraform-alb"
  subnets         = ["subnet-0f9959d52c6baa920","subnet-0e0a18a03371102a9","subnet-0b85034db8a86b01e"]
  security_groups = ["${aws_security_group.master-sg.id}"]
}
resource "aws_alb_listener" "front-end" {
  load_balancer_arn = "${aws_alb.oc-terraform-alb.id}"
  port              = "8443"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.terraform-openshift-alb.id}"
    type             = "forward"
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

