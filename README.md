# Route53 Learning with Terraform

Terraform project supporting the provisioning of aws infrastructure for Route53.
It creates 2 hosted zones and DNS records for:

- ACM certificate validation
- API Gateway for 2 regions (us-east-1, sa-east-1)
- S3 static website
- Geolocation
- Weighted traffic

It also provides 2 EC2 instances on both regions to test geolocation DNS records

### Prerequisites

Complete the following manual steps before provisioning:

- Install terraform
- Setup an aws profile (default is called `personal`)
- Create 2 key pairs called `Route53LearningKeyPairUS` (us-east-1) and `Route53LearningKeyPairBR` (sa-east-1) or set your own to `ssh_key_pair_name` variable


### Provisioning infrastructure

Run ``terraform plan -var 'hosted_zone_domain=<your domain>' -var 'hosted_zone_sub_domain=<your sub domain>'``

