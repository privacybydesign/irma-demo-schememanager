# IRMA Configuration files

This repository contains all the configuration files for the irma project. It describes all the issuer and verifies and declares which credentials are issued respectively verified by these parties.

**The master branch is most likely not the branch you want to be using! See below for which branch to pick**

## Picking the right branch

The master branch contains only configuration files and dummy puplic keys (from the demo branch). To use irma_configuration in your own project, you want to use the correct set of keys. To this end you should pick one of the following two branches:

 * The *demo* branch contains public and private keys for all the issuers. It is **highly recommended** to use this branch when developing.
 * The *pilot* branch contains the public keys for all the issuers in the pilot. It does **not** contain the private keys. Use this branch when testing issuers (you'll have to add the corresponding private key yourself) and verifiers for the pilot.

## Directory structure
Stores configuration files per issuer/relying party. Typical directory structure:

	Organization
	+-- Issues
	|   +-- CredetialName
	|   	+--- description.xml
	|   	+--- id.txt
	|   	+--- structure.xml
	+-- Verifies
	|   +-- VerifySpecName
	|   	+--- description.xml
	|   	+--- specification.xml
	+-- private
	|   +-- isk.xml (not present in master branch)
	+-- description.xml
	+-- baseURL.txt
	+-- gp.xml
	+-- ipk.xml
	+-- logo.png
	+-- sp.xml

Finally, there is the special directory _android_ that contains a list of issuers and verifiers.

## Some notes on adding a new organization

First setup up the descriptions of the organisation, the credentials it issues and the credentials it verifies.

 1. Make sure you add a description for your organization, and a logo.png file.
 2. For every credential this organization issues, make sure you use a unique id.
 3. Remember to add your verifier/issuer to the appropriate lists in the android directory.

Commit these changes to the master branch. Then, merge master into demo and pilot before adding the key material. Make sure you add the correct keys to each branch.

 * In the demo branch, add a demo public and private key-pair (you can create a new one (see below) or copy an existing one).
 * In the pilot branch, create a fresh key-pair (see below). Securely store the private key, and only add the public key to the repository.

Keys can be generated using [silvia](https://github.com/credentials/silvia). In the case of IRMA we rely on credentials of 6 attributes and keys of 1,024 bits:

```
$ ./silvia_keygen -a 6 -n 1024 -p ipk.xml -P isk.xml
Writing public key to ipk.xml
Writing private key to isk.xml
Generating 1024-bit issuer key pair for 6 attributes ... OK
```
