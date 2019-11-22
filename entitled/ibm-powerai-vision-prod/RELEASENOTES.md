# Release Notes

## What's new

## Fixes

## Prerequisites

## Installing

You can install PowerAI Vision stand-alone or PowerAI Vision with IBM Cloud Private. For more information, see the [Installing PowerAI Vision topic](https://www.ibm.com/support/knowledgecenter/SSRU69_1.1.0/rn/main.htm).

## Limitations
The following are the limitations for IBM PowerAI Vision Version 1.1.0:
* If you import a .zip file into an existing data set, the .zip file cannot contain a directory structure.
* PowerAI Vision uses an entire GPU when you are training a dataset, and when a REST API endpoint is deployed (even if the endpoint is idle). The number of active GPU tasks (model training and deployment) that you can run, at the same time, depends on the number of GPUs on your Power® System server. For example, if your Power Systems™ server has 4 GPUs, you can have a maximum of four training and inference jobs running simultaneously. You must verify that there are enough available GPUs on the system for the desired workload. To check the status of the GPUs, run the nvidia-smi -l command.

## Version History
