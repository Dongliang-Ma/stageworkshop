#!/usr/bin/env bash

# shellcheck disable=SC2034
          RELEASE='release.json'
# update lib.common.sh::ntnx_download with new NTNX version metadata
   PC_VERSION_DEV='5.10'
PC_VERSION_STABLE='5.8.2'
    FILES_VERSION='3.2.0' # was: '3.1.0.1'

          PRISM_ADMIN='admin'
           MY_SP_NAME='SP01'
    MY_CONTAINER_NAME='Default'
MY_IMG_CONTAINER_NAME='Images'

# shellcheck disable=2206
          OCTET=(${PE_HOST//./ }) # zero index
    IPV4_PREFIX=${OCTET[0]}.${OCTET[1]}.${OCTET[2]}
DATA_SERVICE_IP=${IPV4_PREFIX}.$((${OCTET[3]} + 1))
        PC_HOST=${IPV4_PREFIX}.$((${OCTET[3]} + 2))
    DNS_SERVERS='8.8.8.8'
    NTP_SERVERS='0.us.pool.ntp.org,1.us.pool.ntp.org,2.us.pool.ntp.org,3.us.pool.ntp.org'
       NW1_NAME='Primary'
       NW1_VLAN=0
     NW1_SUBNET="${IPV4_PREFIX}.1/25"
 NW1_DHCP_START="${IPV4_PREFIX}.50"
   NW1_DHCP_END="${IPV4_PREFIX}.125"
# https://sewiki.nutanix.com/index.php/Hosted_POC_FAQ#I.27d_like_to_test_email_alert_functionality.2C_what_SMTP_server_can_I_use_on_Hosted_POC_clusters.3F
 SMTP_SERVER_ADDRESS='nutanix-com.mail.protection.outlook.com'
    SMTP_SERVER_FROM='NutanixHostedPOC@nutanix.com'
    SMTP_SERVER_PORT=25

# For Nutanix HPOC/Marketing clusters
# https://sewiki.nutanix.com/index.php/HPOC_IP_Schema
# IP Range: ${IPV4_PREFIX}.0/25
# DHCP Pool: ${IPV4_PREFIX}.50 - ${IPV4_PREFIX}.120
case "${OCTET[0]}.${OCTET[1]}" in
  10.20 )
    DNS_SERVERS='10.21.253.10'
    ;;
  10.21 )
    if (( ${OCTET[3]} == 60 )) || (( ${OCTET[3]} == 77 )); then
      log 'GPU cluster, aborting! See https://sewiki.nutanix.com/index.php/Hosted_Proof_of_Concept_(HPOC)#GPU_Clusters'
      exit 0
    fi

       DNS_SERVERS='10.21.253.10,10.21.253.11'
          NW1_VLAN=$(( ${OCTET[2]} * 10 ))
          NW2_NAME='Secondary'
          NW2_VLAN=$(( ${OCTET[2]} * 10 + 1 ))
        NW2_SUBNET="${IPV4_PREFIX}.129/25"
    NW2_DHCP_START="${IPV4_PREFIX}.132"
      NW2_DHCP_END="${IPV4_PREFIX}.253"
    ;;
  10.55 )
       DNS_SERVERS='10.21.253.11'
          NW2_NAME='Secondary'
          NW2_VLAN=$(( ${OCTET[2]} * 10 + 1 ))
        NW2_SUBNET="${IPV4_PREFIX}.129/25"
    NW2_DHCP_START="${IPV4_PREFIX}.132"
      NW2_DHCP_END="${IPV4_PREFIX}.253"
    ;;
esac

HTTP_CACHE_HOST='localhost'
HTTP_CACHE_PORT=8181

# Conventions for *_REPOS arrays, the URL must end with:
# - trailing slash (which imples _IMAGES argument to function repo_source())
# - or full package filename.

#  MY_AFS_SRC_URL='http://10.21.250.221/images/ahv/techsummit/nutanix-afs-el7.3-release-afs-3.0.0.1-stable.qcow2'
# MY_AFS_META_URL='http://10.21.250.221/images/ahv/techsummit/nutanix-afs-el7.3-release-afs-3.0.0.1-stable-metadata.json'
# http://download.nutanix.com/afs/2.2.3/v1/afs-2.2.3.json
# http://download.nutanix.com/afs/3.1.0.1/afs-3.1.0.1.json
# https://s3.amazonaws.com/get-ahv-images/afs-3.1.0.1.json

# https://stedolan.github.io/jq/download/#checksums_and_signatures
     JQ_REPOS=(\
      'https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64' \
)
  QCOW2_REPOS=(\
   'http://10.21.250.221/images/tech-enablement/' \
   'http://10.21.250.221/images/ahv/techsummit/' \
   'https://s3.amazonaws.com/get-ahv-images/' \
) # talk to Nathan Cox to populate S3, Sharon to populate Daisy File Share
 QCOW2_IMAGES=(\
  CentOS7.qcow2 \
  Windows2016.qcow2 \
  Windows2012R2.qcow2 \
  Windows10-1709.qcow2 \
  CentOS7.iso \
  Windows2016.iso \
  Windows2012R2.iso \
  Windows10.iso \
  Nutanix-VirtIO-1.1.3.iso \
  'https://s3.amazonaws.com/technology-boot-camp/ERA-Server-build-1.0.0-21edfbc990a8f3424fed146d837483cb1a00d56d.qcow2' \
  'http://download.nutanix.com/karbon/0.8/acs-centos7.qcow2' \
)
# "XenDesktop-7.15.iso" http://10.21.250.221/images/ahv/techsummit/XD715.iso
# http://download.nutanix.com/era/1.0.0/ERA-Server-build-1.0.0-bae7ca0d653e1af2bcb9826d1320e88d8c4713cc.qcow2

# https://pkgs.org/download/sshpass
# https://sourceforge.net/projects/sshpass/files/sshpass/
  SSHPASS_REPOS=(\
   'http://mirror.centos.org/centos/7/extras/x86_64/Packages/sshpass-1.06-2.el7.x86_64.rpm' \
)

   AUTH_SERVER='AutoDC'  # TODO:240 refactor AUTH_SERVER choice to input file, set default here.
     AUTH_HOST="${IPV4_PREFIX}.$((${OCTET[3]} + 3))"
     LDAP_PORT=389
 MY_DOMAIN_URL="ldaps://${AUTH_HOST}/"
MY_DOMAIN_FQDN='ntnxlab.local'
MY_DOMAIN_NAME='NTNXLAB'
MY_DOMAIN_USER='administrator@'${MY_DOMAIN_FQDN}
MY_DOMAIN_PASS='nutanix/4u'
MY_DOMAIN_ADMIN_GROUP='SSP Admins'
  AUTODC_REPOS=(\
   'http://10.21.250.221/images/ahv/techsummit/AutoDC.qcow2' \
   'https://s3.amazonaws.com/get-ahv-images/AutoDC-04282018.qcow2' \
   'nfs://pocfs.nutanixdc.local/images/CorpSE_Calm/autodc-2.0.qcow2' \
  # 'smb://pocfs.nutanixdc.local/images/CorpSE_Calm/autodc-2.0.qcow2' \
   'http://10.59.103.143:8000/autodc-2.0.qcow2' \
)

   ATTEMPTS=40
      SLEEP=60 # pause (in seconds) between ATTEMPTS

     CURL_OPTS='--insecure --silent --show-error' # --verbose'
CURL_POST_OPTS="${CURL_OPTS} --max-time 5 --header Content-Type:application/json --header Accept:application/json --output /dev/null"
CURL_HTTP_OPTS="${CURL_POST_OPTS} --write-out %{http_code}"
      SSH_OPTS='-o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null'
     SSH_OPTS+=' -q' # -v'
