module "mc_transit" {
  source                 = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version                = "2.5.1"
  cloud                  = "AWS"
  name                   = "ue2-transit"
  region                 = "us-east-2"
  cidr                   = "10.0.0.0/23"
  account                = var.account
  bgp_ecmp               = true
  enable_transit_firenet = true
  gw_name                = "ue2-transit"
  insane_mode            = false
  local_as_number        = 65001
  instance_size          = "c5.xlarge"
  ha_gw                  = false
  enable_segmentation    = true
}


module "mc_transit_egress" {
  source                        = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version                       = "2.5.1"
  cloud                         = "AWS"
  name                          = "ue2-egress-transit"
  region                        = "us-east-2"
  cidr                          = "10.0.2.0/23"
  account                       = var.account
  enable_transit_firenet        = true
  gw_name                       = "ue2-egress-transit"
  insane_mode                   = false
  instance_size                 = "c5.xlarge"
  ha_gw                         = false
  enable_egress_transit_firenet = true
}

# Create an Aviatrix Segmentation Network Domain
resource "aviatrix_segmentation_network_domain" "dev" {
  domain_name = "dev"
  depends_on  = [module.mc_transit]
}

resource "aviatrix_segmentation_network_domain" "prd" {
  domain_name = "prd"
  depends_on  = [module.mc_transit]
}

module "mc_firenet" {
  source         = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version        = "1.5.0"
  transit_module = module.mc_transit_egress
  firewall_image = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  egress_enabled = true
  bootstrap_bucket_name_1 = aws_s3_bucket.this.id
  iam_role_1 = aws_iam_instance_profile.this.role
}


module "mc_spoke_dev" {
  source             = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version            = "1.6.3"
  cloud              = "AWS"
  name               = "ue2-spoke-dev"
  region             = "us-east-2"
  cidr               = "10.16.0.0/24"
  account            = var.account
  gw_name            = "ue2-spoke-dev"
  insane_mode        = false
  ha_gw              = false
  network_domain     = aviatrix_segmentation_network_domain.dev.domain_name
  transit_gw         = module.mc_transit.transit_gateway.gw_name
  attached_gw_egress = true
  transit_gw_egress  = module.mc_transit_egress.transit_gateway.gw_name
}


module "dev-pub" {
  source    = "jye-aviatrix/aws-linux-vm-public/aws"
  version   = "2.0.2"
  key_name  = "ec2-key-pair"
  vm_name   = "dev-pub"
  vpc_id    = module.mc_spoke_dev.vpc.vpc_id
  subnet_id = module.mc_spoke_dev.vpc.public_subnets[0].subnet_id
  use_eip   = true
}

output "dev-pub" {
  value = module.dev-pub
}


module "dev-priv" {
  source    = "jye-aviatrix/aws-linux-vm-private/aws"
  version   = "2.0.1"
  key_name  = "ec2-key-pair"
  vm_name   = "dev-priv"
  vpc_id    = module.mc_spoke_dev.vpc.vpc_id
  subnet_id = module.mc_spoke_dev.vpc.private_subnets[0].subnet_id
}

output "dev-priv" {
  value = module.dev-priv
}


module "mc_spoke_prd" {
  source             = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version            = "1.6.3"
  cloud              = "AWS"
  name               = "ue2-spoke-pub"
  region             = "us-east-2"
  cidr               = "10.32.0.0/24"
  account            = var.account
  gw_name            = "ue2-spoke-pub"
  insane_mode        = false
  ha_gw              = false
  network_domain     = aviatrix_segmentation_network_domain.prd.domain_name
  transit_gw         = module.mc_transit.transit_gateway.gw_name
  attached_gw_egress = true
  transit_gw_egress  = module.mc_transit_egress.transit_gateway.gw_name
}


module "prd-pub" {
  source    = "jye-aviatrix/aws-linux-vm-public/aws"
  version   = "2.0.2"
  key_name  = "ec2-key-pair"
  vm_name   = "prd-pub"
  vpc_id    = module.mc_spoke_prd.vpc.vpc_id
  subnet_id = module.mc_spoke_prd.vpc.public_subnets[0].subnet_id
  use_eip   = true
}

output "prd-pub" {
  value = module.prd-pub
}


module "prd-priv" {
  source    = "jye-aviatrix/aws-linux-vm-private/aws"
  version   = "2.0.1"
  key_name  = "ec2-key-pair"
  vm_name   = "prd-priv"
  vpc_id    = module.mc_spoke_prd.vpc.vpc_id
  subnet_id = module.mc_spoke_prd.vpc.private_subnets[0].subnet_id
}

output "prd-priv" {
  value = module.prd-priv
}
