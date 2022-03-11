#!/bin/bash
#install prometheus
#check version - https://prometheus.io/download/
#your_ip:9090
VERSION="2.34.0"
VERSION_NODE="1.3.1"
export VERSION=$VERSION &&
groupadd --system prometheus &&
useradd --system -g prometheus -s /bin/false prometheus &&
apt install -y wget tar &&
wget "https://github.com/prometheus/prometheus/releases/download/v$VERSION-rc.1/prometheus-$VERSION-rc.1.linux-amd64.tar.gz" -O - | tar -xzv -C /tmp &&
mkdir /etc/prometheus &&
mkdir /var/lib/prometheus &&
cp -r /tmp/prometheus-$VERSION-rc.1.linux-amd64 /etc/prometheus &&
rm -rf /tmp/prometheus-$VERSION-rc.1.linux-amd64 &&
echo "global:
  scrape_interval:     10s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']" > /etc/prometheus/prometheus.yml &&
chown -R prometheus:prometheus /var/lib/prometheus /etc/prometheus &&
chown prometheus:prometheus /usr/local/bin &&
echo "[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
ExecReload=/bin/kill -HUP $MAINPID
[Install]
WantedBy=default.target" > /etc/systemd/system/prometheus.service &&
systemctl daemon-reload &&
systemctl start prometheus.service &&
systemctl enable prometheus.service &&
systemctl status prometheus.service &&
#install Node_exporter
#check version - https://prometheus.io/download/
#your_ip:9100
export VERSION=$VERSION_NODE &&
wget "https://github.com/prometheus/node_exporter/releases/download/v$VERSION_NODE/node_exporter-$VERSION_NODE.linux-amd64.tar.gz" -O - | tar -xzv -C /tmp &&
cp  /tmp/node_exporter-$VERSION_NODE.linux-amd64/node_exporter /usr/local/bin &&
chown -R prometheus:prometheus /usr/local/bin/node_exporter &&
echo "[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
Restart=always
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node_exporter.service &&
systemctl daemon-reload &&
systemctl start node_exporter.service &&
systemctl enable node_exporter.service &&
systemctl status node_exporter.service &&
echo "scrape_configs:
- job_name: 'node'
scrape_interval: 10s
static_configs:
      - targets: ['localhost:9100'] " >> /etc/prometheus/prometheus.yml &&
systemctl reload prometheus.service &&
#install grafana
#your_ip:3000
#login/password - admin/admin
apt-get install -y software-properties-common wget apt-transport-https &&
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add - &&
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main" &&
apt-get update && apt-get -y install grafana &&
echo "apiVersion: 1
datasources:
- name: Prometheus
type: prometheus
access: proxy
url: http://localhost:9090" > /etc/grafana/provisioning/datasources/prometheus.yml &&
chown grafana:grafana /etc/grafana/provisioning/datasources/prometheus.yml &&
systemctl start grafana-server.service &&
systemctl enable grafana-server.service &&
#check services status
systemctl status prometheus.service &&
systemctl status node_exporter.service &&
systemctl status grafana-server.service