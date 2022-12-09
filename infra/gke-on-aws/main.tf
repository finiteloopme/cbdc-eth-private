/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


locals {
  name_prefix = "${var.name_prefix}-${random_string.suffix.result}"
}
resource "random_string" "suffix" {
  length    = 2
  special   = false
  lower     = true
  min_lower = 2
}

# # Manage Customer role instead of AWSServiceRoleForAutoScaling
# module "iam_assumable_role" {
#   role_description = "Role for Anthos to manage auto-scaling.  Default AWSServiceRoleForAutoScaling may not be created when installing GKE"
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

#   trusted_role_services = [
#     "autoscaling.amazonaws.com",
#   ]

#   trusted_role_actions = [
#     "sts:AssumeRole",
#   ]

#   create_role = true
#   role_name         = "anthos-role-for-auto-scaling"
#   role_path         = "/"
#   role_requires_mfa = false

#   custom_role_policy_arns = [
#     module.iam_policy.arn,
#   ]
#   number_of_custom_role_policy_arns = 1
# }
# # Requires a custom policy
# module "iam_policy" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-policy"

#   name        = "anthos-policy-for-auto-scaling"
#   path        = "/"
#   description = "Custom Anthos policy for auto scaling.  Duplicate of arn:aws:iam::aws:policy/aws-service-role/AutoScalingServiceRolePolicy"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "EC2InstanceManagement",
#             "Effect": "Allow",
#             "Action": [
#                 "ec2:AttachClassicLinkVpc",
#                 "ec2:CancelSpotInstanceRequests",
#                 "ec2:CreateFleet",
#                 "ec2:CreateTags",
#                 "ec2:DeleteTags",
#                 "ec2:Describe*",
#                 "ec2:DetachClassicLinkVpc",
#                 "ec2:ModifyInstanceAttribute",
#                 "ec2:RequestSpotInstances",
#                 "ec2:RunInstances",
#                 "ec2:StartInstances",
#                 "ec2:StopInstances",
#                 "ec2:TerminateInstances"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Sid": "EC2InstanceProfileManagement",
#             "Effect": "Allow",
#             "Action": [
#                 "iam:PassRole"
#             ],
#             "Resource": "*",
#             "Condition": {
#                 "StringLike": {
#                     "iam:PassedToService": "ec2.amazonaws.com*"
#                 }
#             }
#         },
#         {
#             "Sid": "EC2SpotManagement",
#             "Effect": "Allow",
#             "Action": [
#                 "iam:CreateServiceLinkedRole"
#             ],
#             "Resource": "*",
#             "Condition": {
#                 "StringEquals": {
#                     "iam:AWSServiceName": "spot.amazonaws.com"
#                 }
#             }
#         },
#         {
#             "Sid": "ELBManagement",
#             "Effect": "Allow",
#             "Action": [
#                 "elasticloadbalancing:Register*",
#                 "elasticloadbalancing:Deregister*",
#                 "elasticloadbalancing:Describe*"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Sid": "CWManagement",
#             "Effect": "Allow",
#             "Action": [
#                 "cloudwatch:DeleteAlarms",
#                 "cloudwatch:DescribeAlarms",
#                 "cloudwatch:GetMetricData",
#                 "cloudwatch:PutMetricAlarm"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Sid": "SNSManagement",
#             "Effect": "Allow",
#             "Action": [
#                 "sns:Publish"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Sid": "EventBridgeRuleManagement",
#             "Effect": "Allow",
#             "Action": [
#                 "events:PutRule",
#                 "events:PutTargets",
#                 "events:RemoveTargets",
#                 "events:DeleteRule",
#                 "events:DescribeRule"
#             ],
#             "Resource": "*",
#             "Condition": {
#                 "StringEquals": {
#                     "events:ManagedBy": "autoscaling.amazonaws.com"
#                 }
#             }
#         },
#         {
#             "Sid": "SystemsManagerParameterManagement",
#             "Effect": "Allow",
#             "Action": [
#                 "ssm:GetParameters"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Sid": "VpcLatticeManagement",
#             "Effect": "Allow",
#             "Action": [
#                 "vpc-lattice:DeregisterTargets",
#                 "vpc-lattice:GetTargetGroup",
#                 "vpc-lattice:ListTargets",
#                 "vpc-lattice:ListTargetGroups",
#                 "vpc-lattice:RegisterTargets"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# EOF
# }
module "kms" {
  source        = "./modules/kms"
  anthos_prefix = local.name_prefix
  aws_region    = var.aws_region
}

module "iam" {
  source                 = "./modules/iam"
  gcp_project_number     = module.gcp_data.project_number
  anthos_prefix          = local.name_prefix
  db_kms_arn             = module.kms.database_encryption_kms_key_arn
  cp_main_volume_kms_arn = module.kms.control_plane_main_volume_encryption_kms_key_arn
  cp_config_kms_arn      = module.kms.control_plane_config_encryption_kms_key_arn
  np_config_kms_arn      = module.kms.node_pool_config_encryption_kms_key_arn
}

module "vpc" {
  source                        = "./modules/vpc"
  aws_region                    = var.aws_region
  vpc_cidr_block                = var.vpc_cidr_block
  anthos_prefix                 = local.name_prefix
  subnet_availability_zones     = var.subnet_availability_zones
  public_subnet_cidr_block      = var.public_subnet_cidr_block
  cp_private_subnet_cidr_blocks = var.cp_private_subnet_cidr_blocks
  np_private_subnet_cidr_blocks = var.np_private_subnet_cidr_blocks
}

module "gcp_data" {
  source       = "./modules/gcp_data"
  gcp_location = var.gcp_location
  gcp_project  = var.gcp_project_id
}

module "anthos_cluster" {
  source                                           = "./modules/anthos_cluster"
  anthos_prefix                                    = local.name_prefix
  location                                         = var.gcp_location
  aws_region                                       = var.aws_region
  cluster_version                                  = coalesce(var.cluster_version, module.gcp_data.latest_version)
  database_encryption_kms_key_arn                  = module.kms.database_encryption_kms_key_arn
  control_plane_config_encryption_kms_key_arn      = module.kms.control_plane_config_encryption_kms_key_arn
  control_plane_root_volume_encryption_kms_key_arn = module.kms.control_plane_root_volume_encryption_kms_key_arn
  control_plane_main_volume_encryption_kms_key_arn = module.kms.control_plane_main_volume_encryption_kms_key_arn
  node_pool_config_encryption_kms_key_arn          = module.kms.node_pool_config_encryption_kms_key_arn
  node_pool_root_volume_encryption_kms_key_arn     = module.kms.node_pool_root_volume_encryption_kms_key_arn
  control_plane_iam_instance_profile               = module.iam.cp_instance_profile_id
  node_pool_iam_instance_profile                   = module.iam.np_instance_profile_id
  admin_users                                      = var.admin_users
  vpc_id                                           = module.vpc.aws_vpc_id
  role_arn                                         = module.iam.api_role_arn
  subnet_ids                                       = [module.vpc.aws_cp_subnet_id_1, module.vpc.aws_cp_subnet_id_2, module.vpc.aws_cp_subnet_id_3]
  node_pool_subnet_id                              = module.vpc.aws_cp_subnet_id_1
  fleet_project                                    = "projects/${module.gcp_data.project_number}"
  depends_on                                       = [module.kms, module.iam, module.vpc]
  control_plane_instance_type                      = var.control_plane_instance_type
  node_pool_instance_type                          = var.node_pool_instance_type

}
module "create_vars" {
  source                = "terraform-google-modules/gcloud/google"
  platform              = "linux"
  create_cmd_entrypoint = "./gke-on-aws/modules/scripts/create_vars.sh"
  create_cmd_body       = "\"${local.name_prefix}\" \"${var.gcp_location}\" \"${var.aws_region}\" \"${var.cluster_version}\" \"${module.kms.database_encryption_kms_key_arn}\" \"${module.iam.cp_instance_profile_id}\" \"${module.iam.api_role_arn}\" \"${module.vpc.aws_cp_subnet_id_1},${module.vpc.aws_cp_subnet_id_2},${module.vpc.aws_cp_subnet_id_3}\" \"${module.vpc.aws_vpc_id}\" \"${var.gcp_project_id}\" \"${var.pod_address_cidr_blocks}\" \"${var.service_address_cidr_blocks}\" \"${module.iam.np_instance_profile_id}\" \"${var.node_pool_instance_type}\" \"${module.kms.node_pool_config_encryption_kms_key_arn}\" \"${module.kms.node_pool_root_volume_encryption_kms_key_arn}\""
  module_depends_on     = [module.anthos_cluster]
}


