#!/usr/bin/python
'''
Script to cleanup spark jobs
'''

import json, time
from datetime import datetime
import argparse
import requests
import sys
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def purge_active_kernels(kernel_service_url,instance_id,hb_endpoint,purge_time):
    print("Purge request for instance {}".format(instance_id))
    k_response = requests.get("{}/{}/meta/api/kernels?state=Active".format(kernel_service_url, instance_id), headers=headers, verify=False, timeout=120)
    if k_response.status_code == 200:
        kernel_list_json = k_response.json()
        if len(kernel_list_json) != 0 :
            for kernel in kernel_list_json:
                kernel_id = kernel["kernel_id"]
                state_api_response = requests.get("{}/{}/jkg/api/kernels/{}".format(hb_endpoint, instance_id, kernel_id), headers=headers, verify=False, timeout=120)
                if state_api_response.status_code == 200:
                    active_kernel_json = state_api_response.json()
                    active_time = active_kernel_json["last_activity"]
                    kernel_state = active_kernel_json["execution_state"]
                    if kernel_state != "busy":
                        print("kernel : {}".format(kernel_id))
                        utc_dt = datetime.strptime(active_time, "%Y-%m-%dT%H:%M:%S.%fZ")
                        actual_time = (utc_dt - datetime(1970, 1, 1)).total_seconds()
                        current_time = time.time()
                        time_diff = current_time - actual_time
                        time_diff = time_diff/60

                        print("time_diff {}, purge_time {}, current_time {}".format(time_diff,purge_time,current_time))

                        if time_diff > purge_time:
                            print("\n\tkernel activation time : {}\n\tIdle for time(s) : {}\n\tDeleting kernel".format(active_time,time_diff))
                            delete_kernel(hb_endpoint,instance_id,kernel_id,api_key)
                else:
                    print("Failed to get {} jkg kernel state, got responseCode {}".format(kernel_id, state_api_response))
                    delete_kernel(hb_endpoint,instance_id,kernel_id,api_key)
        else:
            print("There are no kernels in 'Active' state under instance {}".format(instance_id))
    else:
        print("Failed to get kernels in state 'Active', got responseCode {}".format(response))
        exit(2)

def purge_failed_kernels(kernel_service_url,instance_id,hb_endpoint):
    response = requests.get("""{}/{}/meta/api/kernels?state=Failed""".format(kernel_service_url, instance_id), headers=headers, verify=False, timeout=120)
    if response.status_code == 200:
        kernel_list_json = response.json()
        if len(kernel_list_json) != 0 :
            for kernel in kernel_list_json:
                kernel_id = kernel["kernel_id"]
                delete_kernel(hb_endpoint,instance_id,kernel_id,api_key)
        else:
            print("There are no kernels in 'Failed' state under instance {}".format(instance_id))
    else:
        print("Failed to get kernels in state 'Failed', got responseCode {}".format(response))

#-------------------------------------------------------------------------------------------#
# Delete Kernel
#-------------------------------------------------------------------------------------------#
def delete_kernel(hb_endpoint,instance_id,kernel_id, api_key):
    print("Deleting kernel {}".format(kernel_id))
    response = requests.delete("{}/{}/jkg/api/kernels/{}".format(hb_endpoint, instance_id, kernel_id), headers=headers, verify=False,timeout=40)
    if response.status_code != 204:
        print("Failed to delete kernel {} of instance {}".format(kernel_id, instance_id))

# ---------------------------------------------  PARSE ARGS ------------------------------------------- #
parser = argparse.ArgumentParser()
parser.add_argument("instance_manager_url", help="Instance manager url to get instance details")
parser.add_argument("hb_endpoint", help="Hummingbird endpoint url to delete jobs")
parser.add_argument("kernel_service_url", help="Job service url to get metadata of jobs")
parser.add_argument("purge_time_file", help="purge time for FINISHED / FAILED jobs")
args = parser.parse_args()


# ---------------------------------------------  BUILD JSON  ------------------------------------------- #
instance_manager_url = args.instance_manager_url
hb_endpoint = args.hb_endpoint
kernel_service_url = args.kernel_service_url

purge_time_file = args.purge_time_file

print("Start HB Kernel cleanup")

with open(purge_time_file) as json_file:
    data = json.load(json_file)
    purge_time = data["spark"]["idleTimeBeforeShutdown"]
    purge_time = purge_time
    print("setting purge time : {}mins".format(purge_time))


headers = {'Content-Type':'application/json','Accept':'application/json'}
response = requests.get("{}/list".format(instance_manager_url), headers=headers, verify=False, timeout=120)

if response.status_code == 200:
    instances = response.json()

    for instance in instances:
        instance_id = instance["_id"]

        if "api_key" not in instance:
            api_key = None
        else:
            api_key = instance["api_key"]

        headers = {'Accept':'application/json','X-Api-Key':api_key}

        print("instance : {}".format(instance_id))
        if purge_time == -1:
            purge_failed_kernels(kernel_service_url,instance_id,hb_endpoint)
        else:
            purge_active_kernels(kernel_service_url,instance_id,hb_endpoint,purge_time)
            purge_failed_kernels(kernel_service_url,instance_id,hb_endpoint)
    exit(0)
else:
    print("Failed to get instances, got responseCode {}".format(response))
    exit(2)