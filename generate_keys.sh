#!/bin/bash

# Set this if you want seperate keys per credential
CREDENTIAL_KEYS=

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

BASE_URI=http://www.irmacard.org/credentials/phase1

LOG=""

function archive_keys {
  cd ${1}

  local NOW=`date`
  local TMP_FILE=`mktemp`
  local KEY_FILE="${CONF_DIR}/irma_key_${2}_${3}.gpg"

  ${ARCHIVE_CMD} ${ARCHIVE_OPT} ${TMP_FILE} ${PRIVATE_PATH} &> /dev/null

  if [[ ! ${GPG_KEYID} ]]
  then
    local PASSPHRASE=`mkpasswd "${1} ${2} ${3} ${NOW}"`
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

  # Generate the keys
  silvia_keygen -a 6 -n 1024 -p ${1} -P ${2} -u "${BASE_URI}/${3}/" &> /dev/null

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
    local KEY_DIR=${WORK_DIR}/${PRIVATE_PATH}/${1}/private
  else
    local KEY_DIR=${WORK_DIR}/private
  fi
  mkdir -p ${KEY_DIR}

  generate_keys ipk.xml ${KEY_DIR}/isk.xml ${1}
  [[ ${SECURE} ]] && (archive_keys ${WORK_DIR} ${1})
}

function generate_credential_keys {
  cd ${2}
  echo "Generating keys for ${1}: ${2} @ " `pwd`

  local WORK_DIR=`mktemp -d`
  local KEY_DIR=${WORK_DIR}/${PRIVATE_PATH}/${1}/Issues/${2}/private
  mkdir -p ${KEY_DIR}

  generate_keys ipk.xml ${KEY_DIR}/isk.xml ${1}/${2}

  (archive_keys ${WORK_DIR} ${1} ${2})
}

function parse_issuer {
  if [[ ! ${CREDENTIAL_KEYS} ]]
  then
    (generate_issuer_keys ${1})
  else
    cd Issues
    for cred in `ls`; do
      (generate_credential_keys ${1} ${cred})
    done
  fi
}

function parse_dir {
  cd $1
  [[ -d Issues ]] && (parse_issuer $1)
}

CONF_DIR=`pwd`

for dir in ${ISSUERS}; do 
  [[ -d ${dir} ]] && (parse_dir ${dir})
done

# Cleanup
[[ ${CLEANUP} ]] && rm -rf ${WORK_DIR}

echo ""
echo ${LOG}
