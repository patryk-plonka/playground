# Ansible Playbook Guide

This guide will help you install Ansible and run two playbooks: `initial.yaml` and `ongoing.yaml`.

## Prerequisites

- A system running Linux, macOS, or Windows 10 (via WSL)
- Python installed (version 2.7 or later)
- SSH key generator (`ssh-keygen`) installed

## Step 1: Install Ansible

### On Ubuntu

```bash
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

### On CentOS
```bash
sudo yum install epel-release
sudo yum install ansible
```
### On macOS
```bash
brew install ansible
```
## Step 2: Generate SSH Certificates
Run the provided bash script to generate SSH certificates. This script is located at /scripts/openssh-key.sh.

```bash
bash /scripts/openssh-key.sh
```

## Step 3: Clone the Repository
Clone the repository containing the playbooks.

```bash
git clone <repository_url>
cd <repository_directory>
```

Replace <repository_url> with the URL of your Git repository and <repository_directory> with the name of the directory created by git clone.

## Step 4: Run the Playbooks
Run initial.yaml
This playbook should be run only once at the beginning. It will configure the following:

- Update packages using the apt package manager
- Set up NTP
- Create two users with SSH certificates, one for the Ansible to run ongoing playbook
- Enable the firewall and open SSH and the Kind Kubernetes API
- Install necessary troubleshooting tools

```bash 
ansible-playbook initial.yaml
```

Run ongoing.yaml
This playbook should be run regularly when a new change is needed. It will install and configure the following:
- Update packages
- Install Kind
- Create a Kind cluster from a Jinja2 template
- Set up an energy-saving cron job to shut down the system

```bash
ansible-playbook ongoing.yaml
```

# Conclusion
You have now installed Ansible and run two playbooks. If you encounter any issues, please refer to the official Ansible documentation.

Please replace `<repository_url>` and `<repository_directory>` with the actual URL of your Git repository and the name of the directory created by `git clone`, respectively. If you continue to experience issues, consider seeking help from the Ansible community or the server administrator.