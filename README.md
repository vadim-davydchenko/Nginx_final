At the top is our client, which offers hosting at https://app.${base_domain}.

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
