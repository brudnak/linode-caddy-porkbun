terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }
}

provider "linode" {
  token       = var.linode_access_token
  api_version = "v4beta"

}

resource "linode_instance" "linode_instance" {

  count     = length(var.rancher_instances)
  label     = var.rancher_instances[count.index].linode_instance_label
  image     = "linode/ubuntu20.04"
  region    = "us-west"
  type      = "g6-standard-4"
  root_pass = var.linode_ssh_root_password

  connection {
    type     = "ssh"
    user     = "root"
    password = var.linode_ssh_root_password
    host     = one(self.ipv4)
  }

  provisioner "file" {
    source      = var.rancher_instances[count.index].caddyfile_path
    destination = "Caddyfile"
  }

  provisioner "file" {
    source      = "scripts/caddy.sh"
    destination = "caddy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io",
      "docker run -d --restart=unless-stopped -p 9000:80 -p 9001:443 --privileged -e CATTLE_BOOTSTRAP_PASSWORD=${var.rancher_bootstrap_password} rancher/rancher:${var.rancher_instances[count.index].rancher_version} --acme-domain ${var.rancher_instances[count.index].url}",
      "sudo hostnamectl set-hostname ${var.rancher_instances[count.index].linode_set_system_hostname}",
      "chmod u+x caddy.sh",
      "sleep 3m",
      "sudo ./caddy.sh",
    ]
  }
}




# Output Section

output "linode_instance_ip_addresses" {
  value = [
    for linode_instance in linode_instance.linode_instance : "Linode IP address incase you need to SSH into it: ${linode_instance.ip_address}"
  ]
}

# Variable Section

# Linode Specific Variables
variable "linode_access_token" {
  type        = string
  description = "This is the Linode access token to create resources in Linode."
}


variable "linode_ssh_root_password" {
  type        = string
  description = "This value is what gets assigned as your ssh password to remote into the Linode instances."
}

# Rancher Specific Variables within Linode
variable "rancher_bootstrap_password" {
  type        = string
  description = "This is the bootstrap password that gets assigned to login to the Rancher UI."
}

# - Variable Shared Across Rancher, Linode, and AWS
# ---- rancher_version is injected into the docker run command to set the version of Rancer you want to use.
# ---- url
# ---- linode_instance_label is what the Linode instance is named.
# ---- linode_set_system_hostname sets the Linode instance hostname, making it easy to know where you are when using ssh.
variable "rancher_instances" {
  type = list(object({
    rancher_version : string,
    url : string,
    linode_instance_label : string,
    linode_set_system_hostname : string,
    caddyfile_path : string,
  }))
  description = "Rancher instances is a list/array of objects. Each object creates a Linode instance and AWS Route53 record."
}
