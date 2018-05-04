# Breaking Changes
* The docker-registry secret required by microclimate has been changed from microclimate-icp-secret to microclimate-registry-secret

# What’s new in Chart Version 1.1.1

With Microclimate on IBM Cloud Private 2.1.0.2, the following new
features are available:
* Various UI updates including
    - The user is now taken directly to the created/imported project.
    - If a project cannot be created or imported, the user can now click on "previous" to updated/adjust settings and try again.
    - Theia version updated to 0.0.38.
* Users can authenticate with Jenkins using their IBM Cloud Private credentials.


# Fixes
* Swift applications can now be deployed using the pipeline.
* Swift application build logs are now shown.
* Formatting added for Spring an Node.js applications.
* Various fixes to improve realiability and stability.  

# Prerequisites
1. IBM Cloud Private version 2.1.0.2

# Documentation
For detailed upgrade instructions go to https://microclimate-dev2ops.github.io/installicp

# Version History

| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
| 1.1.0 | Apr 27, 2018 | >=2.1.0.1 |  | None |  |
| 1.0.0 | Mar 30, 2018| >=2.1.0.1 |  | None  | New product release. See https://microclimate-dev2ops.github.io/ |
