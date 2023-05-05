# AWS Microservices Basic Architecture Terraform Module

Terraform module, which creates the whole basic but needed resources to create a microservices architecture in AWS, where it is common to identify these layers:    
- Frontend, where the end user is able to interact and request data coming from the architecture backbone
- Access (Traffic Gateway), which will control the incoming traffic and also expose backend functionalities in the form of HTTP APIs. 
- Backend, in charge of holding and managing the software runtime components.
- Registry, where the business logic is stored in the form of container images.
- Storage, responsible of managing the data handled by the solution.
- Networking, foundation of the architecture where components are placed.   

## Reference Architecture

The components provisioned with this module could be represented with the following architecture diagram:

![arch_diagram](arch_diagram.png)

### Networking

The foundation layer of the solucion is placed under:

- `Single VPC` with a provided CIDR
- `6 subnets` located in 2 different AZ (availability zones)
    - 2 public subnets
    - 2 private subnets
    - 2 database subnets (also private)
- `Single NAT Gateway` with an external `associated Elastic IP`
- `Security groups` to allow both http and https inbound traffic
- An **optional** `Virtual Private Gateway` (when there is a need of a Site-to-Site VPN)

### Runtime

The backbone runtime layer basically consists in a full ready-to-use EKS cluster with:

- AWS managed control plane with a provided version exposing a public endpoint (for using kubectl)
- `EKS Managed Node Group`
    - Fully-private (located in private subnets)
    - Max size is variable
    - Support for Amazon Linux 2 EKS Optimized AMI and Bottlerocket nodes
    - Instance classes and disk size provided by the user
    - User-managed SSH key pairs for accesing nodes with corresponding security group
- `User managed cluster auth` (IAM roles, accounts and groups can be mapped in there)
- AWS EKS Cluster Addons
    - [CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)
    - [Kube-proxy](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/)
    - [VPC-CNI](https://github.com/aws/amazon-vpc-cni-k8s)
    - [eks-cluster-autoscaler](https://aws.github.io/aws-eks-best-practices/cluster-autoscaling/)
    - [eks-load-balancer-controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
    - [eks-ack-addons](https://aws-controllers-k8s.github.io/community/docs/community/overview/)
- AWS EKS Identity Provider Configuration
- `Nginx` deployed as Ingress Controller (which generates an AWS ALB on its behalf)

There is an adittional resource in charge of creating an EC2 instance known as `bastion server`, which is located in a public subnet and allows to jump to internal resources (databases, services, etc).

### Registry

Every time there are containers involved in a solution, there should be a container registry in charge of storing and versioning the images with the packaged application source code to be deployed.

### Storage

### Traffic

### Frontend

## Usage

### Prerequisites

- Create an AWS account and populate a user with `AdministratorAccess` IAM role. If you want to control roles more granularly, it's up to you specifying needed roles to create the resources involved in this module.

- Get user console and programatic access credentials and set them up in your local environment. See [Configuring AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html) for more details. 

- Download needed tooling (AWS CLI, Terraform CLI)

- Create an S3 bucket to store infrastructure state, and place it under terraform backend configuration:

```hcl
backend "s3" {
  bucket = "mycompany-infra-state"      # <= Bucket name
  key = "microservices-basic.tfstate"   # <= Where to store infra manifests within the bucket
  region = "nowhere-region"             # <= AWS Region
  profile = "my-cool-profile"           # <= (optional) specific AWS profile to use
}
```

### Module Instantiation

- Create a `main.tf` file with the module definition with custom variables depending on your needs:

```hcl
module "microservices_architecture_basic" {
    
  source = "git@github.com:ingeniala/terraform-aws-microservices-basic.git"

  # See needed input variables 
}
```

- It's advisable to work with [Terraform workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces) to isolate infra environments and states. For example switching to a newly created dev environment:

```bash
terraform workspace new dev
```

- Done! Initialize module and then plan and apply the infra changes

```bash
terraform init

terraform plan -out=my-cool-plan.out

terraform apply "my-cool-plan.out"
```

## Examples

- [Basic](https://github.com/ingeniala/terraform-aws-microservices-basic/tree/master/examples/basic): Basic setup for a regular non-production environment. 

## Contributing

We are grateful to the community for contributing bugfixes and improvements! Please see below to learn how you can take part.

- [Code of Conduct](https://github.com/ingeniala/terraform-aws-microservices-basic/blob/master/CODE_OF_CONDUCT.md)
- [Contributing Guide](https://github.com/ingeniala/terraform-aws-microservices-basic/blob/master/CONTRIBUTING.md)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |
| <a name="provider_helm"></a> [time](#provider\_helm) | >= 2.6.0 |
| <a name="provider_random"></a> [tls](#provider\_random) | >= 3.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 4.0 |
| <a name="module_eks_managed_node_group"></a> [eks\_managed\_node\_group](#module\_eks\_managed\_node\_group) | ./modules/eks-managed-node-group | n/a |
| <a name="module_fargate_profile"></a> [fargate\_profile](#module\_fargate\_profile) | ./modules/fargate-profile | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | 1.1.0 |
| <a name="module_self_managed_node_group"></a> [self\_managed\_node\_group](#module\_self\_managed\_node\_group) | ./modules/self-managed-node-group | n/a |

## Resources

| Name | Type | 
|------|------|
| <a name="resource_aws_eip_nat_eip"></a> [aws\_eip.nat\_eip](#resource\_aws\_eip\_nat\_eip) | resource |
| <a name="resource_aws_security_group_vpc_tls"></a> [aws\_security\_group.vpc\_tls](#resource\_aws\_security\_group\_vpc\_tls) | resource |
| <a name="resource_aws_security_group_vpc_http"></a> [aws\_security\_group.vpc\_http](#resource\_aws\_security\_group\_vpc\_http) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="env"></a> [env](#env) | Environment name | `string` | null | yes |
| <a name="project"></a> [project](#project) | Project name | `string` | null | yes |
| <a name="aws_profile"></a> [aws\_profile](#aws\_profile) | AWS Profile to use when interacting with resources during installation | `string` | null | yes |
| <a name="vpc_cidr_block"></a> [vpc\_cidr\_block](#vpc\_cidr\_block) | CIDR block for VPC | `string` | null | yes |
| <a name="vpc_subnet_extra_mask_bits"></a> [vpc\_subnet\_extra\_mask\_bits](#vpc\_subnet\_extra\_mask\_bits) | Extra mask bits amount for performing subnetting within the VPC | `number` | null | yes |
| <a name="vpc_enable_vpn"></a> [vpc\_enable\_vpn](#vpc\_enable\_vpn) | Whether to enable a Virtual Private Network Gateway attached to the VPC | `bool` | bool | no |



## Outputs

| Name | Description | 
|------|------|

## License

MIT Licensed. See [LICENSE](https://github.com/ingeniala/terraform-aws-microservices-basic/tree/master/LICENSE) for full details.
