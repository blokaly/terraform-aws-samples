How to run
---

- generate ssh key

Under current folder, execute the following commands, use `key` as the file name:

```shell
$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/charlie/.ssh/id_rsa): key
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in key.
Your public key has been saved in key.pub.
The key fingerprint is:
......

$ chmod 400 key*
```

- run terraform

```shell
$ terraform init
$ terraform plan
$ terraform apply
```
SSH connect
---

```shell
$ terraform output ip
$ ssh -i "key" ec2-user@<ip address>
```

Clean up
---

```shell
$ terraform destroy
```

Reference
---

- https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
- https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/master/examples/basic/main.tf  
- https://letslearndevops.com/2018/08/23/terraform-get-latest-centos-ami/
- https://dev.to/aakatev/deploy-ec2-instance-in-minutes-with-terraform-ip2
