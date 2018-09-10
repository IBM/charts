# Travis build process
The build process is a simple means to build the index.yaml file.  
The index is built on the commit to master to prevent contention to the index file.  

`[skip ci]` and `from IBM/ibm-source-master` in the commit to master prevents additional build process to occur.

The .build directory will be relocated at some point in the future, you should not depend on its location in `IBM/charts`.

## Travis setting
   - MASTER_BRANCH - used to build only the master index.yaml, set most the time to `master` unless you are developing, debugging or disabling the travis process
   - PAT - used for access the github repository

