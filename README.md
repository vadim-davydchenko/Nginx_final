At the top is our client, which offers hosting at `https://app.${base_domain}`

In this case, DNS acts as a balancer - the app.${base_domain} domain has two A records and, accordingly, some of the clients, when requested, will receive the address of one server, and the other part - of another.

The lb1 / lb2 servers are simple nginx-based balancers - their tasks include:
  - terminate SSL connections from clients;
  - check the availability of application servers - app1 / app2;
  - forward requests from clients to available application servers app1 / app2;
  - add additional headers (X-Forwarded-For) - in order for backend hosts to receive information about the user's real IP.
  
The app1 / app2 servers also host the nginx web server, which accepts connections from balancers and forwards requests to the local application - whoami.

#### Setting load balancer lb1/lb2
- Compile `nginx` with `upstream_check_module` support.
  - Add deb-src repositories, install dependencies and download sources
  
    ```
    apt update
    apt install nginx -y
    sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list
    apt-get update
    cd /opt/
    apt-get build-dep nginx -y
    sudo apt-get source nginx
    ```
  - Setting `Upstream Check Module`
  
    ```
    cd /opt/
    git clone https://github.com/yaoweibin/nginx_upstream_check_module
    ```
  - Add a line to the common_configure_flags directive in /opt/nginx-1.18.0/debian/rules
  
    `--add-module=/opt/nginx_upstream_check_module/`
    
  - Patch nginx
    
    ```
    cd /opt/nginx-1.18.0/
    patch -p1 < /opt/nginx_upstream_check_module/check_1.16.1+.patch
    ```
  - Build package
    
    `pkg-buildpackage -b --no-sign`
  
  - Install package
    
    `dpkg -i /opt/nginx-core_1.18.0-0ubuntu1.3_amd64.deb`
    
- Get an `ssl` certificate for `app.${base_domain}` on both balancers `(lb1 / lb2)`
  ```
  sudo apt install certbot -y
  sudo mkdir -p /opt/www/acme
  sudo letsencrypt certonly --webroot -w /opt/www/acme -d app.${base_domain} -d app.${base_domain}
  ```
  - After receiving the certificate, we send the keys to `lb2` and `lb2` create a folder
    ```
    sudo mkdir -p /etc/letsencrypt/live/app.${base_domain}
    scp -r /etc/letsencrypt/live/app.${base_domain}/* user@lb2:/etc/letsencrypt/live/app.${base_domain}
    ```
- Setting [lb1](https://github.com/vadim-davydchenko/nginx_final/blob/master/lb1.conf) and [lb2](https://github.com/vadim-davydchenko/nginx_final/blob/master/lb2.conf)

  - Setting logging в in `nginx.conf`
  ```
  http {
  log_format format '"$request "$request_time" "$upstream_response_time"';
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
  }
  ```
- Install and setting `nginx-exporter` on the both LB
  ```
  wget https://github.com/martin-helmich/prometheus-nginxlog-exporter/releases/download/v1.8.0/prometheus-nginxlog-exporter_1.8.0_linux_amd64.deb
  sudo apt install ./prometheus-nginxlog-exporter_1.8.0_linux_amd64.deb
  sudo systemctl start prometheus-nginxlog-exporter
  sudo systemctl status prometheus-nginxlog-exporter
  sudo docker run --name nginx-exporter -p 4040:4040 -v /var/log/nginx/access.log:/mnt/nginxlogs -d -v /etc/prometheus-nginxlog-exporter.hcl:/etc/prometheus-nginxlog-   exporter.hcl quay.io/martinhelmich/prometheus-nginxlog-exporter -config-file /etc/prometheus-nginxlog-exporter.hcl
  ```
  - Config in [/etc/prometheus-nginxlog-exporter.hcl](https://github.com/vadim-davydchenko/nginx_final/blob/master/prometheus-nginxlog-exporter.hcl)

#### Setting application app1/app2

- Run application `whoami` on the hosts
```
sudo chmod +x ./whoami 
./whoami -port 8080 &
```
- Setting [app1](https://github.com/vadim-davydchenko/nginx_final/blob/master/app1.conf) and [app2]()
