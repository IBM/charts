 # PPA Archive Generation

Spec file to control the generation of a .tar.gz file that contains the Event Streams Helm chart and associated docker images.
This is the asset that gets loaded into Pasport Advantage for paying customers to download. We package the Enterprise edition in this manner. 
For the community edition we separate out the helm chart and docker images with the former packaged into ICP and the latter hosted on
dockerhub. ICP supply a utility called the offline packager that can be used to generate the archive file from this spec
 (https://github.ibm.com/IBMPrivateCloud/offline-packager)