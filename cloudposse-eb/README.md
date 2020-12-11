How to run
---

```shell
$ terraform init
$ terraform plan -input=false -var-file=fixtures.ap-southeast-1.tfvars
$ terraform apply -input=false -var-file=fixtures.ap-southeast-1.tfvars
```

Clean up
---

```shell
$ terraform destroy -input=false -var-file=fixtures.ap-southeast-1.tfvars
```

Reference
---

https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment
https://registry.terraform.io/modules/cloudposse/elastic-beanstalk-environment/aws/latest