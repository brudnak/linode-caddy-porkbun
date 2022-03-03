# Linode Caddy PorkBun :green_heart: :lock: :pig:

>Simple script to create a Linode instance with Caddy2 and a custom domain.

### What's the point?

Using `Caddy2`, which is built with Go :blue_heart:. You're able to launch a Docker install of Rancher with your own unique domain name outside of AWS Route53.

>Caddy ships with apps for an HTTPS server (static files, reverse proxing, load balancing, etc.), TLS certificate manager, and fully-managed internal PKI. Caddy apps collaborate to make complex infrastructure just work with fewer moving parts.

More information about Caddy2 here: [https://caddyserver.com/v2](https://caddyserver.com/v2)

### How it works?

You'll need 2 things to make this script work.

1. A TLD that you own which you can create an `A` record for pointing at your Linode IP address.
2. The following folder structure for every TLD / Linode instance that you want to create. You'll also need the `terraform.tfvars` file.

```txt
.
├── README.md
├── config
│   ├── example1
│   │   └── Caddyfile
│   ├── example2
│   │   └── Caddyfile
│   ├── example3
│   │   └── Caddyfile
│   └── example4
│       └── Caddyfile
├── main.tf
├── scripts
│   └── caddy.sh
└── terraform.tfvars
```

### What The Caddy Files Should Look Like?

```txt
example.com

reverse_proxy 0.0.0.0:9000
```

### What The TFVARS File Should Look Like?

```tf
# Variable Section

# Linode Specific Variables
linode_access_token      = "generate-a-linode-token-from-their-website-enter-it-here"
linode_ssh_root_password = "whatever-ssh-password-you-want"

# Rancher Specific Variables within Linode
rancher_bootstrap_password = "whatever-rancher-ui-password-you-want"

# Variable Shared Across Rancher, Linode, and Caddy
rancher_instances = [{
  rancher_version : "v2.6-head",
  url : "example-1.com",
  linode_instance_label : "terraform-example-1",
  linode_set_system_hostname : "example1",
  caddyfile_path : "config/example1/Caddyfile"
  },
  {
    rancher_version : "v2.6-head",
    url : "example-2.com",
    linode_instance_label : "terraform-example-2",
    linode_set_system_hostname : "example2",
    caddyfile_path : "config/example2/Caddyfile"
  },
  {
    rancher_version : "v2.6.3",
    url : "example-3.com",
    linode_instance_label : "terraform-example-3",
    linode_set_system_hostname : "example3",
    caddyfile_path : "config/example3/Caddyfile"
  },
  {
    rancher_version : "v2.6.3",
    url : "example-4.com",
    linode_instance_label : "terraform-example-4",
    linode_set_system_hostname : "example4",
    caddyfile_path : "config/example4/Caddyfile"
  },
]

```