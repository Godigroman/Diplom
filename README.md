
ssh-keygen -t rsa -f ~/.ssh/id_rsa_terraform

eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa_terraform

cat ~/.ssh/id_rsa_terraform.pub
Добавить свой публиный ключ в переменную ssh_public_key (terraform\variables.tf)

export TF_VAR_token=$(yc iam create-token)

cd ./terraform
terraform init
terraform plan
terraform apply --auto-approve

cd ../ansible
ansible-playbook -i hosts playbook.yaml


ssh to bastion:
ssh user@<bastion_public_ip>

ssh to fqdn:
ssh -J user@<bastion_public_ip> user@<fqdn>


Перезапуска плэйбука с тегом zabbix:
ansible-playbook -i hosts playbook.yaml -t zabbix
