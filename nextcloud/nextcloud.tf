#-------------------------------------------------------------
### IAM Instance profile
#-------------------------------------------------------------
module "iam_instance_profile" {
  source    = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//instance_profile"
  role      = "${module.iam_app_role.iamrole_name}"
}

#-------------------------------------------------------------
### IAM Policy
#-------------------------------------------------------------
module "iam_app_policy" {
  source        = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//rolepolicy"
  policyfile    = "${data.template_file.iam_policy_app.rendered}"
  rolename      = "${module.iam_app_role.iamrole_name}"
}


#-------------------------------------------------------------
### IAM Policy template file
#-------------------------------------------------------------
data "template_file" "iam_policy_app" {
  template = "${file("${path.module}/${local.ec2_role_policy_file}")}"
}


#-------------------------------------------------------------
### EC2 Role
#-------------------------------------------------------------
module "iam_app_role" {
  source        = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//role"
  policyfile    = "${local.ec2_policy_file}"
  rolename      = "${local.short_environment_identifier}-${local.app_name}"
}



#-------------------------------------------------------------
### Create Nextcloud instance
#-------------------------------------------------------------


#Launch cfg
resource "aws_launch_configuration" "launch_cfg" {
  name_prefix          = "${local.short_environment_identifier}-nextcloud-launch-cfg-"
  image_id             = "${data.aws_ami.amazon_ami.id}"
  iam_instance_profile = "${module.iam_instance_profile.iam_instance_name}"
  instance_type        = "${var.nextcloud_instance_type}"
  security_groups      = [
    "${local.sg_bastion_in}",
    "${local.sg_https_out}",
    "${local.sg_mis_app_in}",
  ]
  enable_monitoring    = "true"
  associate_public_ip_address = false
  key_name                    = "${data.terraform_remote_state.common.common_ssh_deployer_key}"
#  user_data                   = "${data.template_file.nextcloud_fs_user_data.rendered}"
  root_block_device {
    volume_type        = "gp2"
    volume_size        = 50
  }
  lifecycle {
    create_before_destroy = true
  }
}


data "null_data_source" "tags" {
  count = "${length(keys(var.tags))}"
  inputs = {
    key                 = "${element(keys(var.tags), count.index)}"
    value               = "${element(values(var.tags), count.index)}"
    propagate_at_launch = true
  }
}

#ASG
resource "aws_autoscaling_group" "asg" {
  name                      = "${local.environment_identifier}-${local.app_name}"
  vpc_zone_identifier       = ["${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
	data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3,
  )}"]
  launch_configuration      = "${aws_launch_configuration.launch_cfg.id}"
  min_size                  = "${var.instance_count}"
  max_size                  = "${var.instance_count}"
  desired_capacity          = "${var.instance_count}"
  tags = [
    "${data.null_data_source.tags.*.outputs}",
    {
      key                 = "Name"
      value               = "${local.environment_identifier}-${local.app_name}"
      propagate_at_launch = true
    }
  ]
  lifecycle {
    create_before_destroy = true
  }
}
