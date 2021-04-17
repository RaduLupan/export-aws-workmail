# export-aws-workmail
This repository contains Terraform configurations that deploy the [prerequisites](https://docs.aws.amazon.com/workmail/latest/adminguide/mail-export.html) for exporting mailbox content from AWS WorkMail.

Please check the [wiki](https://github.com/RaduLupan/export-aws-workmail/wiki) page for a step-by-step tutorial on this solution.

## Pre-requisites

* [Amazon Web Services (AWS) account](http://aws.amazon.com/).
* Terraform 0.14 installed on your computer. Check out HasiCorp [documentation](https://learn.hashicorp.com/terraform/azure/install) on how to install Terraform.

## Quick start

1. Configure your [AWS access 
keys](http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) as 
environment variables:

```
$ export AWS_ACCESS_KEY_ID=(your access key id)
$ export AWS_SECRET_ACCESS_KEY=(your secret access key)
```

2. Clone this repository:

```
$ git clone https://github.com/RaduLupan/export-aws-workmail.git
$ cd export-aws-workmail
```
3. Deploy AWS WorkMail export prerequisites:

```
$ terraform init
$ terraform apply
```
