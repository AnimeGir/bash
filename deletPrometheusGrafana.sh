#!/bin/bash

systemctl stop grafana-server.service &&
systemctl disable grafana-server.service &&
apt -y remove grafana &&
systemctl stop node_exporter.service &&
systemctl disable node_exporter.service &&
rm /etc/systemd/system/node_exporter.service &&
rm -rf /opt/node_exporter &&
systemctl stop prometheus.service &&
systemctl disable prometheus.service &&
rm /etc/systemd/system/prometheus.service &&
rm -rf /opt/prometheus &&
userdel prometheus &&
groupdel prometheus