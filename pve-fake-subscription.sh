#!/bin/sh

set -e -u

EXEC_NAME="${0##*/}"

for PROG in date openssl md5sum cut tr base64; do
	test $(command -v "${PROG}") || { printf '%s: \033[31;40;1m%s\033[0m: command not found\n' "${EXEC_NAME}" "${PROG}" >&2; exit 199; }
done

CHECKTIME=$(date +%s)

# From https://github.com/proxmox/pve-manager/blob/49318c671b82f31e6b273b79447526161739b97a/PVE/API2/Subscription.pm#L33
PVE_KEY="pve4p-$(openssl rand -hex 5)"

VALID_DIRECTORY=$(md5sum '/etc/ssh/ssh_host_rsa_key.pub' | cut -d ' ' -f 1 | tr '[:lower:]' '[:upper:]')

# From https://github.com/proxmox/proxmox-rs/blob/89c1d597a9d15743049eadcb1add380573265904/proxmox-subscription/src/subscription_info.rs#L237
SHARED_KEY_DATA='kjfdlskfhiuewhfk947368'

REG_DATE=$(date -d @${CHECKTIME} +'%Y-%m-%d %H:%M:%S')

NEXT_DUE_DATE=$(date -d @$((${CHECKTIME}+1728000)) +'%Y-%m-%d')

PRODUCT_NAME='Proxmox VE Premium Subscription 4 CPUs/year'

JSON_BODY='{
	"checktime": %d,
	"status": "active",
	"key": "%s",
	"validdirectory": "%s",
	"productname": "%s",
	"regdate": "%s",
	"nextduedate": "%s"
}'

JSON_DATA_B64=$(printf "${JSON_BODY}" "${CHECKTIME}" "${PVE_KEY}" "${VALID_DIRECTORY}" "${PRODUCT_NAME}" "${REG_DATE}" "${NEXT_DUE_DATE}" | base64 -w 0)

INPUT=$(printf '%s%s\n%s' "${CHECKTIME}" "${JSON_DATA_B64}" "${SHARED_KEY_DATA}" | openssl dgst -md5 -binary | base64 -w 0 | tr -d '=')

SUBSCRIPTION_FILE="${PVE_KEY}
${INPUT}
${JSON_DATA_B64}"

test -n "${PVE_SUBSCRIPTION_FILE:-}" && exec 1> "${PVE_SUBSCRIPTION_FILE}"

printf '%s\n' "${SUBSCRIPTION_FILE}"

exit 0
