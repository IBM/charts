import sys
from datetime import datetime
import time,json,requests
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def create_kernel(instance_id,api_key,payload):
    url=service_endpoint_url+'/ae/'+instance_id+"/jkg/api/kernels"
    response = requests.post(url, data = payload, headers=headers, verify=False, timeout=120)
    if response.status_code != 201:
        print("failed to create dry run kernel")
        return 1
    else:
        kernel_details = response.json()
        print("Successfully create kernel : {}".format(kernel_details))
        return 0

if __name__ == "__main__":
    if len (sys.argv) < 2:
        print("Error : missing arguments")
        print("Usage : python {0} <service_endpoint_url> <number_of_dry_run_kernel_to_create>".format(sys.argv[0]))
        exit(1)
    else:
        service_endpoint_url = sys.argv[1]
        dry_run_num = int(sys.argv[2])

    payload='{}'
    apikey=''
    url=service_endpoint_url+'/ae'+'/dryrun'

    headers={'Content-Type': 'application/json'}
    response = requests.post(url, data = payload, headers=headers, verify=False, timeout=120)
    if response.status_code != 200:
        print("failed to create instance")
        exit(1)
    else:
        instance_details = response.json()
        print("Successfully create instance : {}".format(instance_details['instance_id']))

    instance_id = instance_details['instance_id']
    api_key = instance_details['api_key']
    payload='{"name":"scala","isDryRun":"true"}'
    headers={'Content-Type': 'application/json','Accept': 'application/json','X-Api-Key': '{}'.format(api_key)}

    failed = 0

    for i in range(dry_run_num):
        failed_flag = create_kernel(instance_id,api_key,payload)
        if failed_flag:
            failed = failed + 1

    if failed:
        print("failed to create dry run kernel {} times".format(failed))
        exit(1)