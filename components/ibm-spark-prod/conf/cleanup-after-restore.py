#!/usr/bin/python
'''
Script to cleanup spark jobs
'''

import json, time
from datetime import datetime
import argparse
import requests
import sys
import os
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def purge_kernels(kernel_service_url,instance_id,state):
    response = requests.get("""{}/{}/meta/api/kernels?state={}""".format(kernel_service_url, instance_id, state), headers=headers, verify=False)
    if response.status_code == 200:
        kernel_list_json = response.json()
        if len(kernel_list_json) != 0 :
            for kernel in kernel_list_json:
                kernel_id = kernel["kernel_id"]
                print(kernel_id)
                release_name=getReleaseName(kernel_id)
                print(release_name)
                delete_kernel_release(kernel_id,release_name)
        else:
            print("There are no kernels in {} state under instance {}".format(state,instance_id))
    else: 
        print("Failed to get kernels in state {}, got responseCode {}".format(state,response))


def purge_jobs(job_service_url,instance_id,state):
    j_response = requests.get("{}/{}/jobs/meta/list?state={}".format(job_service_url, instance_id,state), headers=headers, verify=False)
    if j_response.status_code == 200:
        jobs = j_response.json()
        if len(jobs) != 0 :
            for job in jobs:
                job_id = job["job_id"]
                print(job_id)
                state = job["state"]
                release_name=getReleaseName(job_id)
                print(release_name)
                delete_job_release(job_id,release_name)
        else:
            print("There are no jobs in {} state under instance {}".format(state,instance_id))
    else: 
        print("Failed to get jobs in state {}, got responseCode {}".format(state,response))

  
  
#-------------------------------------------------------------------------------------------#
# Get release names
#-------------------------------------------------------------------------------------------#          
def getReleaseName(unique_id):
    host=os.getenv("KUBERNETES_SERVICE_HOST")
    print(host)
    port=os.getenv("KUBERNETES_SERVICE_PORT")
    print(port)
    f = open("/var/run/secrets/kubernetes.io/serviceaccount/token", "r")
    token=f.read()
    print(token)
    result = requests.get("https://{}:{}/api/v1/namespaces/{}/pods?labelSelector=unique_id%3D{}".format(host,port,namespace,unique_id), headers={'Authorization': 'Bearer {}'.format(token)}, verify=False)
    print(result.text)
    response=json.loads(result.text)
    return response['items'][0]['metadata']['labels']['release']
    
#-------------------------------------------------------------------------------------------#
# Delete Kernel
#-------------------------------------------------------------------------------------------#

def delete_kernel_release(kernel_id,release_name):
    print("Deleting resource for kernel {}".format(kernel_id))
    f = open("/opt/hb/confidential_config/cpd_service_broker/cpd_service_broker.properties", "r")
    platform_token=f.read()
    response = requests.delete("http://zen-core-api-svc:3333/v2/release/{}".format(release_name), headers={'secret': '{}'.format(platform_token)}, verify=False,timeout=40)
    if response.status_code != 202:
        print("Failed to delete kernel {} of instance {}".format(kernel_id, instance_id))
        
        
#-------------------------------------------------------------------------------------------#
# Delete Job
#-------------------------------------------------------------------------------------------#

def delete_job_release(job_id,release_name):
    print("Deleting resource for job {}".format(job_id))
    f = open("/opt/hb/confidential_config/cpd_service_broker/cpd_service_broker.properties", "r")
    platform_token=f.read()
    print(platform_token)
    response = requests.delete("http://zen-core-api-svc:3333/v2/release/{}".format(release_name), headers={'secret': '{}'.format(platform_token)}, verify=False,timeout=40)
    if response.status_code != 202:
        print("Failed to delete Job {} of instance {}".format(job_id, instance_id))
        
# ---------------------------------------------  PARSE ARGS ------------------------------------------- #
parser = argparse.ArgumentParser()
parser.add_argument("namespace", help="Current namespace")
args = parser.parse_args()

# ---------------------------------------------  BUILD JSON  ------------------------------------------- #
instance_manager_url = "https://spark-hb-control-plane:9443/instance_manager/v1/instance"
kernel_service_url = "https://spark-hb-control-plane:9443/ae/v1"
job_service_url = "https://spark-hb-control-plane:9443/jobService/v2"
namespace=args.namespace
    
print("Start cleanup")



headers = {'Content-Type':'application/json','Accept':'application/json'}
response = requests.get("{}/list".format(instance_manager_url), headers=headers, verify=False)
    
if response.status_code == 200:
    instances = response.json()
    
    for instance in instances:
        instance_id = instance["_id"]
            
        if "api_key" not in instance:
            api_key = None
        else:
            api_key = instance["api_key"]
        
        headers = {'Accept':'application/json','X-Api-Key':api_key}
            
        # Delete kernels stuck in Deploying or Deleting state
        purge_kernels(kernel_service_url,instance_id,"Deploying")
        purge_kernels(kernel_service_url,instance_id,"Deleting")
        # Delete jobs stuck in Deploying or Deleting state
        purge_jobs(job_service_url,instance_id,"DEPLOYING")
        purge_jobs(job_service_url,instance_id,"DELETING")
    exit(0)
else:
    print("Failed to get instances, got responseCode {}".format(response))
    exit(2)