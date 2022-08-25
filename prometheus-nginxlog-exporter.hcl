listen {
  port = 4040
}

namespace "nginx" {

format = "$remote_addr $status $request_time $upstream_response_time"
source_files = ["/var/log/nginx/log.access.log"]

  }
  labels {
    app = "default"
  }
