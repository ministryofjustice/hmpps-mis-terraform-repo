### Memory Alarms alert

#BWS
resource "aws_cloudwatch_metric_alarm" "bws_instance-memory-alert" {
  count                     = "${length(data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids)}"
  alarm_name                = "${local.environment_name}__Memory-Utilization__alert__BWS__${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "MemoryUtilization"
  namespace                 = "CWAgent"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "85"
  alarm_description         = "Memory Utilization  is averaging 85% for ${data.terraform_remote_state.ec2-ndl-bws.bws_primary_dns_ext[count.index]}. Please contact the MIS Team or the MIS AWS Support Contact."
  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
  ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

  dimensions {
                 InstanceId = "${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
				 ImageId      = "${data.terraform_remote_state.ec2-ndl-bws.bws_ami_id[count.index]}"
				 InstanceType = "${data.terraform_remote_state.ec2-ndl-bws.bws_instance_type[count.index]}"
				 objectname   = "Memory"
    }
 }


 #BCS
 resource "aws_cloudwatch_metric_alarm" "bcs_instance-memory-alert" {
   count                     = "${length(data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids)}"
   alarm_name                = "${local.environment_name}__Memory-Utilization__alert__BCS__${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
   comparison_operator       = "GreaterThanOrEqualToThreshold"
   evaluation_periods        = "1"
   metric_name               = "MemoryUtilization"
   namespace                 = "CWAgent"
   period                    = "120"
   statistic                 = "Average"
   threshold                 = "85"
   alarm_description         = "Memory Utilization  is averaging 85% for ${data.terraform_remote_state.ec2-ndl-bcs.bcs_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
   alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
   ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

   dimensions {
                  InstanceId   = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
				  ImageId      = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_ami_id[count.index]}"
				  InstanceType = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_type[count.index]}"
				  objectname   = "Memory"
     }
  }


 #BPS
 resource "aws_cloudwatch_metric_alarm" "bps_instance-memory-alert" {
   count                     = "${length(data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids)}"
   alarm_name                = "${local.environment_name}__Memory-Utilization__alert__BPS__${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
   comparison_operator       = "GreaterThanOrEqualToThreshold"
   evaluation_periods        = "1"
   metric_name               = "MemoryUtilization"
   namespace                 = "CWAgent"
   period                    = "120"
   statistic                 = "Average"
   threshold                 = "85"
   alarm_description         = "Memory Utilization  is averaging 85% for ${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
   alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
   ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

   dimensions {
                  InstanceId   = "${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
				  ImageId      = "${data.terraform_remote_state.ec2-ndl-bps.bps_ami_id[count.index]}"
				  InstanceType = "${data.terraform_remote_state.ec2-ndl-bps.bps_instance_type[count.index]}"
				  objectname   = "Memory"
     }
  }


 #DIS
 resource "aws_cloudwatch_metric_alarm" "dis_instance-memory-alert" {
   count                     = "${length(data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids)}"
   alarm_name                = "${local.environment_name}__Memory-Utilization__alert__DIS__${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
   comparison_operator       = "GreaterThanOrEqualToThreshold"
   evaluation_periods        = "1"
   metric_name               = "MemoryUtilization"
   namespace                 = "CWAgent"
   period                    = "120"
   statistic                 = "Average"
   threshold                 = "85"
   alarm_description         = "Memory Utilization  is averaging 85% for ${data.terraform_remote_state.ec2-ndl-dis.dis_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
   alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
   ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

   dimensions {
                  InstanceId   = "${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
				  ImageId      = "${data.terraform_remote_state.ec2-ndl-dis.dis_ami_id[count.index]}"
				  InstanceType = "${data.terraform_remote_state.ec2-ndl-dis.dis_instance_type[count.index]}"
				  objectname   = "Memory"
     }
  }


 #BFS
 resource "aws_cloudwatch_metric_alarm" "bfs_instance-memory-alert" {
   count                     = "${length(data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids)}"
   alarm_name                = "${local.environment_name}__Memory-Utilization__alert__BFS__${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
   comparison_operator       = "GreaterThanOrEqualToThreshold"
   evaluation_periods        = "1"
   metric_name               = "MemoryUtilization"
   namespace                 = "CWAgent"
   period                    = "120"
   statistic                 = "Average"
   threshold                 = "85"
   alarm_description         = "Memory Utilization  is averaging 85% for ${data.terraform_remote_state.ec2-ndl-bfs.bfs_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
   alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
   ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

   dimensions {
                  InstanceId = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
				  ImageId      = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_ami_id[count.index]}"
				  InstanceType = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_type[count.index]}"
				  objectname   = "Memory"
     }
  }


  ### Memory Alarms severe

  #BWS
  resource "aws_cloudwatch_metric_alarm" "bws_instance-memory-severe" {
    count                     = "${length(data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids)}"
    alarm_name                = "${local.environment_name}__Memory-Utilization__severe__BWS__${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "1"
    metric_name               = "MemoryUtilization"
    namespace                 = "CWAgent"
    period                    = "120"
    statistic                 = "Average"
    threshold                 = "88"
    alarm_description         = "Memory Utilization  is averaging 88% for ${data.terraform_remote_state.ec2-ndl-bws.bws_primary_dns_ext[count.index]}. Please contact the MIS Team or the MIS AWS Support Contact."
    alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
    ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

    dimensions {
                   InstanceId = "${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
  				 ImageId      = "${data.terraform_remote_state.ec2-ndl-bws.bws_ami_id[count.index]}"
  				 InstanceType = "${data.terraform_remote_state.ec2-ndl-bws.bws_instance_type[count.index]}"
  				 objectname   = "Memory"
      }
   }


   #BCS
   resource "aws_cloudwatch_metric_alarm" "bcs_instance-memory-severe" {
     count                     = "${length(data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids)}"
     alarm_name                = "${local.environment_name}__Memory-Utilization__severe__BCS__${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "1"
     metric_name               = "MemoryUtilization"
     namespace                 = "CWAgent"
     period                    = "120"
     statistic                 = "Average"
     threshold                 = "88"
     alarm_description         = "Memory Utilization  is averaging 88% for ${data.terraform_remote_state.ec2-ndl-bcs.bcs_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
     alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
     ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

     dimensions {
                  InstanceId   = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
  				  ImageId      = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_ami_id[count.index]}"
  				  InstanceType = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_type[count.index]}"
  				  objectname   = "Memory"
       }
    }


   #BPS
   resource "aws_cloudwatch_metric_alarm" "bps_instance-memory-severe" {
     count                     = "${length(data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids)}"
     alarm_name                = "${local.environment_name}__Memory-Utilization__severe__BPS__${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "1"
     metric_name               = "MemoryUtilization"
     namespace                 = "CWAgent"
     period                    = "120"
     statistic                 = "Average"
     threshold                 = "88"
     alarm_description         = "Memory Utilization  is averaging 88% for ${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
     alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
     ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

     dimensions {
                  InstanceId   = "${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
  				  ImageId      = "${data.terraform_remote_state.ec2-ndl-bps.bps_ami_id[count.index]}"
  				  InstanceType = "${data.terraform_remote_state.ec2-ndl-bps.bps_instance_type[count.index]}"
  				  objectname   = "Memory"
       }
    }


   #DIS
   resource "aws_cloudwatch_metric_alarm" "dis_instance-memory-severe" {
     count                     = "${length(data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids)}"
     alarm_name                = "${local.environment_name}__Memory-Utilization__severe__DIS__${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "1"
     metric_name               = "MemoryUtilization"
     namespace                 = "CWAgent"
     period                    = "120"
     statistic                 = "Average"
     threshold                 = "88"
     alarm_description         = "Memory Utilization  is averaging 88% for ${data.terraform_remote_state.ec2-ndl-dis.dis_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
     alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
     ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

     dimensions {
                  InstanceId   = "${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
  				  ImageId      = "${data.terraform_remote_state.ec2-ndl-dis.dis_ami_id[count.index]}"
  				  InstanceType = "${data.terraform_remote_state.ec2-ndl-dis.dis_instance_type[count.index]}"
  				  objectname   = "Memory"
       }
    }


   #BFS
   resource "aws_cloudwatch_metric_alarm" "bfs_instance-memory-severe" {
     count                     = "${length(data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids)}"
     alarm_name                = "${local.environment_name}__Memory-Utilization__severe__BFS__${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "1"
     metric_name               = "MemoryUtilization"
     namespace                 = "CWAgent"
     period                    = "120"
     statistic                 = "Average"
     threshold                 = "88"
     alarm_description         = "Memory Utilization  is averaging 88% for ${data.terraform_remote_state.ec2-ndl-bfs.bfs_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
     alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
     ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

     dimensions {
                    InstanceId   = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
  				    ImageId      = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_ami_id[count.index]}"
  				    InstanceType = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_type[count.index]}"
  				    objectname   = "Memory"
       }
    }


	### Memory Alarms critical

	#BWS
	resource "aws_cloudwatch_metric_alarm" "bws_instance-memory-critical" {
	  count                     = "${length(data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids)}"
	  alarm_name                = "${local.environment_name}__Memory-Utilization__critical__BWS__${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
	  comparison_operator       = "GreaterThanOrEqualToThreshold"
	  evaluation_periods        = "1"
	  metric_name               = "MemoryUtilization"
	  namespace                 = "CWAgent"
	  period                    = "120"
	  statistic                 = "Average"
	  threshold                 = "92"
	  alarm_description         = "Memory Utilization  is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bws.bws_primary_dns_ext[count.index]}. Please contact the MIS Team or the MIS AWS Support Contact."
	  alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
      ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

	  dimensions {
	                 InstanceId   = "${data.terraform_remote_state.ec2-ndl-bws.bws_instance_ids[count.index]}"
					 ImageId      = "${data.terraform_remote_state.ec2-ndl-bws.bws_ami_id[count.index]}"
					 InstanceType = "${data.terraform_remote_state.ec2-ndl-bws.bws_instance_type[count.index]}"
					 objectname   = "Memory"
	    }
	 }


	 #BCS
	 resource "aws_cloudwatch_metric_alarm" "bcs_instance-memory-critical" {
	   count                     = "${length(data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids)}"
	   alarm_name                = "${local.environment_name}__Memory-Utilization__critical__BCS__${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
	   comparison_operator       = "GreaterThanOrEqualToThreshold"
	   evaluation_periods        = "1"
	   metric_name               = "MemoryUtilization"
	   namespace                 = "CWAgent"
	   period                    = "120"
	   statistic                 = "Average"
	   threshold                 = "92"
	   alarm_description         = "Memory Utilization  is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bcs.bcs_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
	   alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
       ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

	   dimensions {
	                  InstanceId   = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_ids[count.index]}"
					  ImageId      = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_ami_id[count.index]}"
					  InstanceType = "${data.terraform_remote_state.ec2-ndl-bcs.bcs_instance_type[count.index]}"
					  objectname   = "Memory"
	     }
	  }


	 #BPS
	 resource "aws_cloudwatch_metric_alarm" "bps_instance-memory-critical" {
	   count                     = "${length(data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids)}"
	   alarm_name                = "${local.environment_name}__Memory-Utilization__critical__BPS__${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
	   comparison_operator       = "GreaterThanOrEqualToThreshold"
	   evaluation_periods        = "1"
	   metric_name               = "MemoryUtilization"
	   namespace                 = "CWAgent"
	   period                    = "120"
	   statistic                 = "Average"
	   threshold                 = "92"
	   alarm_description         = "Memory Utilization  is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bps.bps_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
	   alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
       ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

	   dimensions {
	                  InstanceId   = "${data.terraform_remote_state.ec2-ndl-bps.bps_instance_ids[count.index]}"
					  ImageId      = "${data.terraform_remote_state.ec2-ndl-bps.bps_ami_id[count.index]}"
					  InstanceType = "${data.terraform_remote_state.ec2-ndl-bps.bps_instance_type[count.index]}"
					  objectname   = "Memory"
	     }
	  }


	 #DIS
	 resource "aws_cloudwatch_metric_alarm" "dis_instance-memory-critical" {
	   count                     = "${length(data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids)}"
	   alarm_name                = "${local.environment_name}__Memory-Utilization__critical__DIS__${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
	   comparison_operator       = "GreaterThanOrEqualToThreshold"
	   evaluation_periods        = "1"
	   metric_name               = "MemoryUtilization"
	   namespace                 = "CWAgent"
	   period                    = "120"
	   statistic                 = "Average"
	   threshold                 = "92"
	   alarm_description         = "Memory Utilization  is averaging 92% for ${data.terraform_remote_state.ec2-ndl-dis.dis_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
	   alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
       ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

	   dimensions {
	                  InstanceId   = "${data.terraform_remote_state.ec2-ndl-dis.dis_instance_ids[count.index]}"
					  ImageId      = "${data.terraform_remote_state.ec2-ndl-dis.dis_ami_id[count.index]}"
					  InstanceType = "${data.terraform_remote_state.ec2-ndl-dis.dis_instance_type[count.index]}"
					  objectname   = "Memory"
	     }
	  }


	 #BFS
	 resource "aws_cloudwatch_metric_alarm" "bfs_instance-memory-critical" {
	   count                     = "${length(data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids)}"
	   alarm_name                = "${local.environment_name}__Memory-Utilization__critical__BFS__${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
	   comparison_operator       = "GreaterThanOrEqualToThreshold"
	   evaluation_periods        = "1"
	   metric_name               = "MemoryUtilization"
	   namespace                 = "CWAgent"
	   period                    = "120"
	   statistic                 = "Average"
	   threshold                 = "92"
	   alarm_description         = "Memory Utilization  is averaging 92% for ${data.terraform_remote_state.ec2-ndl-bfs.bfs_primary_dns_ext[count.index]}. Please contact the MIS AWS Support Contact."
	   alarm_actions             = [ "${aws_sns_topic.alarm_notification.arn}" ]
       ok_actions                = [ "${aws_sns_topic.alarm_notification.arn}" ]

	   dimensions {
	                  InstanceId   = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_ids[count.index]}"
					  ImageId      = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_ami_id[count.index]}"
					  InstanceType = "${data.terraform_remote_state.ec2-ndl-bfs.bfs_instance_type[count.index]}"
					  objectname   = "Memory"
	     }
	  }
