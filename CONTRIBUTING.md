# Overview
This repository hosts helm charts intended for use with IBM(R) Cloud Private.

The `stable` directory is used only for charts distributed by IBM.
All contributions should be made to the `community` directory.

The helm repositories in the `repo/stable` and `repo/community` directories are helm repositories, and their index.yaml file is built automatically based on the `MASTER` branch. The `repo/stable` repository is part of the default configuration of IBM Cloud Private, and as such, all charts in that repository will be displayed by default in the IBM Cloud Private catalog. The `repo/community` repository can be easily added to the IBM Cloud Private user interface by navigating to *Manage > Helm Reposities* adding https://github.com/ibm/charts/tree/master/repo/community to the list of Helm repositories. (It may be added by default in future releases of IBM Cloud Private.)


## License
This project is licensed under the Apache 2.0 license, and all contributed charts must also be licensed under the Apache 2.0 license. Each contributed chart should include a LICENSE file containing the Apache 2.0 license. More information
can be found in the LICENSE file or online at

  http://www.apache.org/licenses/LICENSE-2.0
  
## Chart Standards and Guidelines
To enable a consistent user experience, contributed charts must conform to the set of standards documented in [GUIDELINES.md]. In addition to required standards, this document also offers guidance on additional ways that charts can be enhanced to improve the user experience on IBM Cloud Private, but are not required for inclusion in this repository.

## Certficate of Origin

This project uses the _Developer Certificateof Origin_ as posted at https://developercertificate.org

A developer sign-off is required for all contributions to the `community` subdirectory. This sign-off certifies that you have the right to contribute the code to this community.
To sign off, include the line below in your commit comment.

```
Signed-off-by: John Mellor <john.mellor@ibm.com>
```
You must use your real name, not an alias or pseudonym. If you are contributing on behalf of a company or organization, you should use an email address associated with that company or organization.
By signing off as described above, you agree to the following terms:
```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
1 Letterman Drive
Suite D4700
San Francisco, CA, 94129

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.


Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```
