# Nginx Role for Load Balancers and Application Servers

![Architecture Overview](https://github.com/vadim-davydchenko/Nginx_final/blob/master/classicweb.png)

This Ansible role sets up the infrastructure illustrated above, designed for hosting at `https://app.${base_domain}`.

## Key Components

- **DNS Balancing**: `app.${base_domain}` points to two load balancers (`lb1` and `lb2`) via A records, distributing client requests.
- **Load Balancers (`lb1`, `lb2`)**:
  - Terminate SSL connections.
  - Check and route requests to application servers (`app1`, `app2`).
  - Add headers (e.g., `X-Forwarded-For`) to preserve client IPs.
  - Export logs for monitoring.
- **Application Servers (`app1`, `app2`)**:
  - Use Nginx to route traffic to a local application (e.g., `whoami`).

## How to Use

### Run the Playbook

To deploy the infrastructure, execute the following command:

```bash
ansible-playbook -i inventory.yml nginx.yml -b
```

## What This Role Does

1. **Configures Load Balancers**:
   - Compiles Nginx with health-check support.
   - Obtains SSL certificates using Certbot.
   - Sets up routing, headers, and logging as per the architecture.

2. **Configures Application Servers**:
   - Deploys Nginx to forward traffic to the local app (`whoami`).
   - Ensures proper response to load balancers.

3. **Monitoring**:
   - Installs Prometheus Nginx Log Exporter for both load balancers.

## Simplified View

Refer to the diagram above for a clear understanding of how traffic flows through the infrastructure, from DNS to load balancers and finally to application servers.

This role simplifies deployment and management of a robust Nginx-based architecture for your applications.
