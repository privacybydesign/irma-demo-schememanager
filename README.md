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

Keys can be generated using [silvia](https://github.com/credentials/silvia). In the case of IRMA we rely on credentials of 6 attributes and keys of 1,024 bits:

```
$ ./silvia_keygen -a 6 -n 1024 -p ipk.xml -P isk.xml
Writing public key to ipk.xml
Writing private key to isk.xml
Generating 1024-bit issuer key pair for 6 attributes ... OK
```

You will need to place these keys at the correct place in the directory tree.
