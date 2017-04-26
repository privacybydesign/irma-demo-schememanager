# IRMA Configuration files

This repository contains all the configuration files for the irma project. It describes the issuers and declares which credentials are issued by these issuers.

## Picking the right branch

The latest versions of the [Android app](https://github.com/credentials/irma_android_cardemu) and the [API server](https://github.com/credentials/irma_api_server) use the `combined` branch, which can contain keys for multiple scheme managers. Currently it only contains the demo keys from the `demo` branch. The master, demo and pilot branches are used by older projects and are structured differently.

## Directory structure
Stores configuration files per issuer/relying party. Typical directory structure:

    SchemeManager
    +-- IssuerName
    |	+-- Issues
    |	|   +-- CredentialName
    |	|   	+--- description.xml
    |   +-- PublicKeys
    |   |   +-- 0.xml
    |   |   +-- 1.xml
    |	+-- PrivateKeys (need not be present)
    |	|   +-- 0.xml
    |   |   +-- 1.xml
    |	+-- description.xml
    |	+-- logo.png
    +-- description.xml

## Some notes on adding a new organization

First setup up the descriptions of the organization, the credentials it issues and the credentials it verifies. Make sure you add a description for your organization, and a logo.png file.

Keys can be generated using [irmatool](https://github.com/mhe/irmatool) or [silvia](https://github.com/credentials/silvia). It is safest to use keys of 4096 bits, for example (this will probably take a few minutes):

```
$ irmatool genkeypair -a 6 -l 4096 -c 0 -p ipk.xml -k isk.xml
$ silvia_keygen -a 6 -n 4096 -c 0 -p ipk.xml -P isk.xml
```

You will need to place these keys at the correct place in the directory tree. Alternatively, the `generate_keys.sh` script can generate keys (with counter 0) for you at the correct place.
