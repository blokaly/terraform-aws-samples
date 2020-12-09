Preparation
---

- replace `region` of the aws provider in ecs.tf file
- replace `availability_zones`, `instance_type` and `ecs_aws_ami` in ecs.tfvars file

Reference of how to find the AWS AMI: 
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html#finding-quick-start-ami

How to run
---

```shell
$ terraform init
$ terraform plan -input=false -var-file=ecs.tfvars
$ terraform apply -input=false -var-file=ecs.tfvars
```

Clean up
---

```shell
$ terraform destroy -input=false -var-file=ecs.tfvars
```

Reference
---

- https://github.com/arminc/terraform-ecs
