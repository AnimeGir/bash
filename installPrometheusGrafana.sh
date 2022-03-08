#!/bin/bash

useradd --no-create-home --shell /bin/false prometheus  &&
useradd --no-create-home --shell /bin/false node_exporter &&
mkdir /etc/prometheus &&
mkdir /var/lib/prometheus &&
chown prometheus:prometheus /etc/prometheus &&
chown prometheus:prometheus /var/lib/prometheus &&
cd /opt/ &&
wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz &&
tar -xvf prometheus-2.26.0.linux-amd64.tar.gz &&
cp /opt/prometheus-2.26.0.linux-amd64/prometheus /usr/local/bin/ &&
cp /opt/prometheus-2.26.0.linux-amd64/promtool /usr/local/bin/ &&
chown prometheus:prometheus /usr/local/bin/prometheus &&
chown prometheus:prometheus /usr/local/bin/promtool &&
cp -r /opt/prometheus-2.26.0.linux-amd64/consoles /etc/prometheus &&
cp -r /opt/prometheus-2.26.0.linux-amd64/console_libraries /etc/prometheus &&
cp -r /opt/prometheus-2.26.0.linux-amd64/prometheus.yml /etc/prometheus &&
chown -R prometheus:prometheus /etc/prometheus/consoles &&
chown -R prometheus:prometheus /etc/prometheus/console_libraries &&
chown -R prometheus:prometheus /etc/prometheus/prometheus.yml &&
prometheus /usr/local/bin/prometheus \
        --config.file /etc/prometheus/prometheus.yml \
        --storage.tsdb.path /var/lib/prometheus/ \
        --web.console.templates=/etc/prometheus/consoles \
        --web.console.libraries=/etc/prometheus/console_libraries &&
"[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/prometheus.service &&
systemctl daemon-reload &&
systemctl start prometheus &&
systemctl enable prometheus &&
ufw allow 9090/tcp &&
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add – &&
echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list &&
apt-get update &&
apt-get install grafana &&
systemctl start grafana-server &&
systemctl status grafana-server &&
systemctl enable grafana-server.service &&
systemctl status prometheus &&
prometheus --version &&
promtool --version