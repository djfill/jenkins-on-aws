# Synopsis
This repository provisions and configures a secure Jenkins server on Ubuntu in AWS. It is fronted by NGINX and has public facing DNS so you are able to configure webhooks to trigger pipelines from github (for e.g.). It is basically a coded version of the set of prerequisite instructions found in the Digital Ocean tutorial [how-to-set-up-continuous-integration-pipelines-in-jenkins-on-ubuntu-16-04](https://www.digitalocean.com/community/tutorials/how-to-set-up-continuous-integration-pipelines-in-jenkins-on-ubuntu-16-04) up to and including the section "Add the Jenkins User to the Docker Group". 
The intention is to quickly provision the Jenkins server so that you can focus on integrating Jenkins with github and defining the CI/CD process with the example Node.js application.

# Prerequisites
If you are familiar with AWS, already have an account with Access Keys and SSH key pairs then you should be good to go. If not, you may need to refer to some of the following. We are also using dynamic inventory so again please read and follow the links if unfamiliar. Knowledge in Ansible and Terraform is a bonus but not essential as the step by step guide will guide you through so long as you have them installed locally.
## AWS account
If you don't have one click [here](https://aws.amazon.com/free/)
## Ansible v2.5.0+ installed
Follow the [installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) if you do not have it installed.
## Terraform v0.10.7+ installed
Follow the [installation guide](https://www.terraform.io/intro/getting-started/install.html) if you do not have it installed.
##Domain name
You'll need a domain name. Get a free one [here](http://www.freenom.com/) if you do not have one.

## Ansible configuration
To read up  on Ansible configuration go [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_configuration.html)
### Ansible and Dynamic Amazon EC2 Inventory Management
To read up on Dynamic Inventory go [here](https://aws.amazon.com/blogs/apn/getting-started-with-ansible-and-dynamic-amazon-ec2-inventory-management/) but to summarise you to download [ec2.py](https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py) and [ec2.ini](https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini) and place them in <user_home_directory>/ansible/ then configure <user_home_directory>/.ansible.cfg to include the following:
```
[defaults]
inventory = <user_home_directory>/ansible/ec2.py
host_key_checking = False
```

## AWS Access Key
Add your AWS Access key and token here:
<user_home_directory>/.aws/credentials
Further reading [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)

## AWS EC2 Key Pair
If you don't already have one, generate a key pair as described [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

## Load your private key 
If you are unfamiliar load your private key to your ssh-agent as described [here](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)

# Steps
As per the prerequisites you should now have an AWS account with a key pair with the private key loaded into your ssh-agent daemon and access set up to your AWS subscription either by environment variables or the credentials file.

1. Fork this repository by clicking on the Fork button.
2. Clone the forked repository from your git account.
3. Edit the following variables in terraform/terraform.tfvars
   region - The region you want to deploy to.
   key_name - The key name within AWS you want to ssh with
   ssh_ingress_cidr_blocks - A list of cidr blocks you want to ssh from (you may use one range, use [whatsmyip](http://www.whatsmyip.org/) if necessary).
4. Edit the following variables in ansible/group_vars/all.yaml
   domain - Replace with your domain name.
   email - Replace with your email (This will be used to register with [letsencrypt](https://letsencrypt.org/) Certificate Authority) 
5. cd terraform
6. terraform init
7. terraform plan
8. terraform apply
9. copy the ip address output, log into your domain provider (e.g. [freenom](http://www.freenom.com/)) and create an A record for 'blank' and 'www' for that ip address.
10. cd ../ansible
11. ansible-playbook main.yaml

#What next?
You should now be able to type in your domain name into any browser from any location and be redirected to a secure Jenkins instance. You will need to copy the 'one-time' unlock key from the output of the ansible playbook into the initial prompt when you first log into Jenkins.
Carry on with the tutorial at Digital Ocean [how-to-set-up-continuous-integration-pipelines-in-jenkins-on-ubuntu-16-04](https://www.digitalocean.com/community/tutorials/how-to-set-up-continuous-integration-pipelines-in-jenkins-on-ubuntu-16-04) 
