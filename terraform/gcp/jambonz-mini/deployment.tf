provider "google" {
  project = var.project
  region = var.region
}

resource "random_string" "uuid" {
  length = 6
  special = false
  upper = false
}

resource "google_compute_address" "jambonz_static_ip" {
  name = "jambonz-static-ip-${random_string.uuid.result}"
  region = var.region
}

resource "google_compute_firewall" "jambonz_mini_firewall_rule" {
  name = "jambonz-firewall-rule-${random_string.uuid.result}"

  source_ranges = [
    "0.0.0.0/0"
  ]
  target_tags = [
    "jambonz-mini-${random_string.uuid.result}"
  ]
  network = "https://www.googleapis.com/compute/v1/projects/${var.project}/global/networks/default"
  allow {
    protocol = "tcp"
    ports = ["22", "80", "443", "3020", "5060", "5061", "8443"]
  }
  allow {
    protocol = "udp"
    ports = ["5060"]
  }
}

resource "google_compute_instance" "jambonz_mini" {
  name = "jambonz-mini-${random_string.uuid.result}"
  zone = var.zone
  machine_type = var.instance_type
  tags = [
    "jambonz-mini-${random_string.uuid.result}"
  ]
  boot_disk {
    device_name = "boot"
    initialize_params {
      image = "https://www.googleapis.com/compute/v1/projects/${var.project}/global/images/${var.image}"
    }
  }
  network_interface {
    network = "https://www.googleapis.com/compute/v1/projects/${var.project}/global/networks/default"
    access_config {
      nat_ip = google_compute_address.jambonz_static_ip.address
    }
  }
  metadata = {
    startup-script = <<-EOT
#!/bin/bash -xe

DNS_NAME="${var.dns_name}"
JAEGER_USERNAME="${var.jaeger_username}"
JAEGER_PASSWORD="${var.jaeger_password}"


# get instance metadata
PRIVATE_IPV4="$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)" 
PUBLIC_IPV4="$(curl -s -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)" 
INSTANCE_ID="$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)"

# replace ip addresses in the ecosystem.config.js file
sudo sed -i -e "s/\(.*\)PRIVATE_IP\(.*\)/\1$PRIVATE_IPV4\2/g" /home/admin/apps/ecosystem.config.js 
sudo sed -i -e "s/\(.*\)--JAMBONES_API_BASE_URL--\(.*\)/\1http:\/\/$PUBLIC_IPV4\/v1\2/g" /home/admin/apps/ecosystem.config.js 

# set initial admin password to admin
JAMBONES_MYSQL_USER=admin JAMBONES_MYSQL_PASSWORD=JambonzR0ck$ JAMBONES_MYSQL_DATABASE=jambones JAMBONES_MYSQL_HOST=127.0.0.1 /home/admin/apps/jambonz-api-server/db/reset_admin_password.js

# replace JWT_SECRET
uuid=$(uuidgen)
sudo sed -i -e "s/\(.*\)JWT-SECRET-GOES_HERE\(.*\)/\1$uuid\2/g" /home/admin/apps/ecosystem.config.js 

#Add BasicAuth password for Jaeger
sudo htpasswd -b -c /etc/nginx/.htpasswd $JAEGER_USERNAME "$JAEGER_PASSWORD"

# configure webapp
if [[ -z $DNS_NAME ]]; then
  # portals will be accessed by IP address of server
  echo "VITE_API_BASE_URL=http://$PUBLIC_IPV4/api/v1" > /home/admin/apps/jambonz-webapp/.env 
  API_BASE_URL=http://$PUBLIC_IPV4/api/v1 TAG="<script>window.JAMBONZ = { API_BASE_URL: '$API_BASE_URL'};</script>"
  sed -i -e "\@</head>@i\ $TAG" /home/admin/apps/jambonz-webapp/dist/index.html
else
  # portals will be accessed by DNS name
  echo "VITE_API_BASE_URL=http://$DNS_NAME/api/v1" > /home/admin/apps/jambonz-webapp/.env 
  API_BASE_URL=http://$DNS_NAME/api/v1 TAG="<script>window.JAMBONZ = { API_BASE_URL: '$API_BASE_URL'};</script>"
  sed -i -e "\@</head>@i\ $TAG" /home/admin/apps/jambonz-webapp/dist/index.html

  sudo cat << EOF > /etc/nginx/sites-available/default 
  server {
      listen 80;
      server_name $DNS_NAME;
      location /api/ {
          rewrite ^/api/(.*)$ /\$1 break;
          proxy_pass http://localhost:3002;
          proxy_set_header Host \$host;
      }
      location / {
          proxy_pass http://localhost:3001;
          proxy_set_header Host \$host;
      }
  }
  server {
    listen 80;
    server_name api.$DNS_NAME; 
    location / {
      proxy_pass http://localhost:3002; 
      proxy_set_header Host \$host;
    }
  }
  server {
    listen 80;
    server_name grafana.$DNS_NAME; 
    location / {
      proxy_pass http://localhost:3010; 
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection 'upgrade';
      proxy_set_header Host \$host;
      proxy_cache_bypass \$http_upgrade;
    }
  }
  server {
    listen 80;
    server_name homer.$DNS_NAME; 
    location / {
      proxy_pass http://localhost:9080; 
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection 'upgrade';
      proxy_set_header Host \$host;
      proxy_cache_bypass \$http_upgrade;
    }
  }
  server {
    listen 80;
    server_name jaeger.$DNS_NAME; 
    location / {
      proxy_pass http://localhost:16686; 
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection 'upgrade';
      proxy_set_header Host \$host;
      proxy_cache_bypass \$http_upgrade;
      auth_basic "Secured Endpoint";
      auth_basic_user_file /etc/nginx/.htpasswd;
    }
  }
EOF

  sudo systemctl restart nginx
fi

# restart heplify-server
sudo systemctl restart heplify-server

sudo -u admin bash -c "pm2 restart /home/admin/apps/ecosystem.config.js" 
sudo -u admin bash -c "pm2 save"
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u admin --hp /home/admin

# get an apiban key
APIBANKEY=$(curl -X POST -u jambonz:1a074994242182a9e0b67eae93978826 -d "{\"client\": \"$uuid\"}" -s https://apiban.org/sponsor/newkey | jq -r '.ApiKey')
sudo sed -i -e "s/API-KEY-HERE/$APIBANKEY/g" /usr/local/bin/apiban/config.json
sudo /usr/local/bin/apiban/apiban-iptables-client FULL

EOT
  }

  depends_on = [
    google_compute_address.jambonz_static_ip
  ]
}
