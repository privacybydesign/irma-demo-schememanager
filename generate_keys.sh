#!/bin/bash

# This script will iterate over each issuers specified in ${ISSUERS},
# and generates IRMA public/private keys for them, placing them at the
# expected place in the folder structure (assuming ${SECURE} is not set;
# if it is, the private keys are encrypted instead).

# NOTES:
# - This script will overwrite any existing keys if present!
# - It is assumed that each of the specified issuers has an identically
#   named directory in the current working directory.
# - The resulting keys will always have counter 0.
# - The script assumes you have silvia_keygen installed and compiled.
#   https://github.com/mhe/irmatool may be easier to get up and running
#   (although it uses different flags than silvia_keygen)

# Set this to the names of the issuers for which you want to generate new keys
ISSUERS="Bar"

# Set this if you want to archive and encrypt the keys
SECURE=true
# Set this if you want to encrypt for a GPG key
#GPG_KEYID=

CLEANUP=true

ARCHIVE_CMD=tar
ARCHIVE_OPT=-zcvf

ENCRYPT_OPT="--cipher-algo AES --symmetric"

PRIVATE_PATH=irma_private_keys

# Amount of attributes each key will support
ATTRS=6

# Unix timestamp of the expiry date for the keys. 1 year from now if left empty
#EXPIRY=

function archive_keys {
  cd ${1}

  local NOW=`date`
  local TMP_FILE=`mktemp`
  local KEY_FILE="${CONF_DIR}/irma_key_${2}.gpg"

  ${ARCHIVE_CMD} ${ARCHIVE_OPT} ${TMP_FILE} ${PRIVATE_PATH} &> /dev/null

  if [[ ! ${GPG_KEYID} ]]
  then
    local PASSPHRASE=`mkpasswd "${1} ${2} ${NOW}"`
    gpg --batch --armor --passphrase ${PASSPHRASE} --output ${KEY_FILE} \
        --cipher-algo AES --symmetric ${TMP_FILE}
    echo "Result: ${KEY_FILE} using passphrase: ${PASSPHRASE}"
  else
    gpg --encrypt -r $GPG_KEYID --batch --armor --output ${KEY_FILE} ${TMP_FILE}
    echo "Result: ${KEY_FILE} using GPG Key: ${GPG_KEYID}"
  fi
  echo ""

  rm -rf ${1} ${TMP_FILE}
}


function generate_keys {
  # Make sure the files are writable
  touch ${1} ${2}
  chmod +w ${1} ${2}

  local EXPIRY_OPTS=
  if [[ ${EXPIRY} ]]
  then
    EXPIRY_OPTS="-d ${EXPIRY}"
  fi

  # Generate the keys
  silvia_keygen -a ${ATTRS} -n 4096 -p ${1} -P ${2} ${EXPIRY_OPTS} &> /dev/null

  # Make the keys readonly
  chmod 440 ${1}
  chmod 400 ${2}
}

function generate_issuer_keys {
  WORK_DIR=`pwd`
  echo "Generating keys for ${1} @ " `pwd`

  if [[ ${SECURE} ]]
  then
    local WORK_DIR=`mktemp -d`
    local KEY_DIR=${WORK_DIR}/${PRIVATE_PATH}/${1}/PrivateKeys
  else
    local KEY_DIR=${WORK_DIR}/PrivateKeys
  fi
  mkdir -p ${KEY_DIR}
  mkdir PublicKeys &> /dev/null

  generate_keys "PublicKeys/0.xml" ${KEY_DIR}/0.xml
  [[ ${SECURE} ]] && (archive_keys ${WORK_DIR} ${1})
}

function parse_dir {
  cd $1
  [[ -d Issues ]] && (generate_issuer_keys ${1})
}

CONF_DIR=`pwd`

for dir in ${ISSUERS}; do 
  [[ -d ${dir} ]] && (parse_dir ${dir})
done

# Cleanup
[[ ${CLEANUP} ]] && rm -rf ${WORK_DIR}
