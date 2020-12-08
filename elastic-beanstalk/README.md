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

- copy ssh key

Edit main.tf `aws_key_pair` resource, and set `public_key` value as the key.pub content.   

- run terraform

```shell
$ terraform init
$ terraform plan
$ terraform apply
```

Clean up
---

```shell
$ terraform destroy
```

Reference
---

- https://github.com/tomfa/terraform-sandbox
- https://gist.github.com/tomfa/6fc429af5d598a85e723b3f56f681237
- https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/AWSHowTo.S3.html (delete s3 created by eb)