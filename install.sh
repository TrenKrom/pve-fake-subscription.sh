#!/bin/sh

set -e -u

install pve-fake-subscription.sh /usr/local/sbin/pve-fake-subscription.sh
install pve-fake-subscription.service /etc/systemd/system/pve-fake-subscription.service

install pve-refresh-subscription.timer /etc/systemd/system/pve-refresh-subscription.timer
install pve-refresh-subscription.path /etc/systemd/system/pve-refresh-subscription.path

touch /etc/subscription

systemctl daemon-reload

systemctl enable --now pve-fake-subscription.service
systemctl enable --now pve-refresh-subscription.timer
systemctl enable --now pve-refresh-subscription.path

exit 0
