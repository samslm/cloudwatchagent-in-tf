 provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "us-east-1"
}
resource "aws_instance" "tes"{
  ami = "ami-06eecef118bbf9259"
  instance_type   = "t2.micro"
  vpc_security_group_ids = ["sg-01274397ad1641871"]
  key_name = "nisha"
  iam_instance_profile = "CloudWatchAgentServerRole"
  user_data = <<-EOF
                #! /bin/bash
                wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
                sudo rpm -U ./amazon-cloudwatch-agent.rpm
                echo '''{
       "agent": {
                "metrics_collection_interval": 60,
                "run_as_user": "root"
        },
        "metrics": {
                "aggregation_dimensions": [
                        [
                                "InstanceId"
                        ]
                ],
                "append_dimensions": {
                        "AutoScalingGroupName": "{aws:AutoScalingGroupName}",
                        "ImageId": "{aws:ImageId}",
                        "InstanceId": "{aws:InstanceId}",
                        "InstanceType": "{aws:InstanceType}"
                },
                "metrics_collected": {
                        "disk": {
                                "measurement": [
                                        "used_percent"
                                ],
                                "metrics_collection_interval": 60,
                                "resources": [
                                        "*"
                                ]
                        },
                        "mem": {
                                "measurement": [
                                        "mem_used_percent"
                                ],
                                "metrics_collection_interval": 60
                        }
                }
        }
}''' >> /opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
    EOF
}
