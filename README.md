# The `irma-demo` scheme manager

This repository contains the credential definitions, issuer information, and their public *and* private keys of the `irma-demo` scheme manager.

***CAREFUL!*** This scheme manager is only ever meant to be used for development, demoing and experimenting! Because the issuer private keys are included in this repository everyone can issue any credential from this scheme manager, choosing the attributes freely. Thus their authenticity cannot be trusted. (For an actual scheme manager, see the [Privacy by Design Foundation scheme manager](https://github.com/credentials/pbdf-schememanager).)

Use this repository by putting it in the `irma_configuration` folder of your project (for example, [the IRMA mobile app](https://github.com/credentials/irma_mobile/tree/rctevents/ios/irma_configuration) or the [IRMA API server](https://github.com/credentials/irma_api_server/tree/master/src/main/resources)). Be sure to call the folder `irma-demo`! E.g.,

    git clone https://github.com/credentials/irma-demo-schememanager irma-demo

## Directory structure

A scheme manager, issuer, or credential type (call it an *entity*) is always stored in `description.xml`, contained in a folder whose name *must* be that of the entity as specified by the xml file. Multiple issuers are grouped under the scheme manager, and each issuer may issue multiple credential types.

    SchemeManager
    +-- IssuerName
    |   +-- Issues
    |   |   +-- CredentialName
    |   |       +--- description.xml
    |   |       +--- logo.png
    |   +-- PublicKeys
    |   |   +-- 0.xml
    |   |   +-- 1.xml
    |   +-- PrivateKeys (need not be present)
    |   |   +-- 0.xml
    |   |   +-- 1.xml
    |   +-- description.xml
    |   +-- logo.png
    +-- description.xml

## Some notes on adding a new organization

First setup up the descriptions of the organization, the credentials it issues and the credentials it verifies. Make sure you add a description for your organization, and a logo.png file.

Keys can be generated using [irmatool](https://github.com/mhe/irmatool) or [silvia](https://github.com/credentials/silvia). It is safest to use keys of 4096 bits, for example (this will probably take a few minutes):

```
$ irmatool genkeypair -a 6 -l 4096 -c 0 -p ipk.xml -k isk.xml
$ silvia_keygen -a 6 -n 4096 -c 0 -p ipk.xml -P isk.xml
```

You will need to place these keys at the correct place in the directory tree. Alternatively, the `generate_keys.sh` script can generate keys (with counter 0) for you at the correct place.

# Note

This repository contains the same tree as (the now deprecated) [github.com/credentials/irma_configuration](https://github.com/credentials/irma_configuration) but with the outer `irma_configuration` folder removed.
