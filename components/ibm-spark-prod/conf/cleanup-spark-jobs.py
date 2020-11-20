#!/usr/bin/python
'''
Script to cleanup spark jobs
'''

# ---------------------------------------------  IMPORTS --------------------------------------------- #

import json, datetime, time
import argparse
import requests
import sys
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# ---------------------------------------------  FUNCTIONS -------------------------------------------- #
def purge_active_jobs(job_service_url,instance_id,hb_endpoint,purge_time):
    print("Purge request for instance {}".format(instance_id))
    j_response = requests.get("{}/{}/jobs/meta/list?state=ACTIVE".format(job_service_url, instance_id), headers=headers, verify=False, timeout=120)
    if j_response.status_code == 200:
        jobs = j_response.json()
        for job in jobs:
            job_id = job["job_id"]
            print("Purge request for instance {} job_id {}".format(instance_id,job_id))
            url = "{}/{}/v2/jobs/{}".format(hb_endpoint, instance_id, job_id)
            if "jobState" not in job:
                print("job_state not found, cluster state {}".format(job["state"]))
                job_state = ""
                try:
                  print("Try to get Job State")
                  getjob_response = requests.get(url, headers=headers, verify=False, timeout=5)
                  if getjob_response.status_code != 200:
                      print("\n\n\nCould not found jobState, making get call on job : {}, cluster_state : {}, HTTP code : {}\n\n\n".format(job_id,state,getjob_response.status_code))
                  else:
                      print("\n\n\nCould not found jobState, failed get on job : {}, cluster_state : {}, HTTP code : {}\n\n\n".format(job_id,state,getjob_response.status_code))
                  return 0
                except (requests.Timeout, requests.ConnectionError, KeyError) as e:
                  print("Timeout occurred - move forward")
            else:
                job_state = job["jobState"]
                print("Found Job State {}".format(job_state))

            if (job_state == "FAILED") or (job_state == "FINISHED"):
                if "start_time" in job:
                    job_time = job["start_time"]
                elif "finish_time" in job:
                    job_time = job["finish_time"]
                elif "fail_time" in job:
                    job_time = job["fail_time"]
                else:
                    getjob_response = requests.get(url, headers=headers, verify=False)
                    if getjob_response.status_code != 200:
                        print("\n\n\nCould not found  any time, making get call on job : {}, cluster_state : {}, HTTP code : {}\n\n\n".format(job_id,state,getjob_response.status_code))
                    else:
                        print("\n\n\nCould not found any time, failed get on job : {}, cluster_state : {}, HTTP code : {}\n\n\n".format(job_id,state,getjob_response.status_code))
                    return 0
            else:
                try:
                  print("Try to get Job Updated State")
                  getjob_response = requests.get(url, headers=headers, verify=False, timeout=5)
                  if getjob_response.status_code != 200:
                      print("\n\n\nCould not found finish_time, making get call on job : {}, HTTP code : {}\n\n\n".format(job_id,getjob_response.status_code))
                  else:
                     print("\n\n\nCould not found finish_time, failed get on job : {}, HTTP code : {}\n\n\n".format(job_id,getjob_response.status_code))
                  return 0
                except (requests.Timeout, requests.ConnectionError, KeyError) as e:
                  print("Timeout occurred - move forward")

            if (job_state == "FAILED") or (job_state == "FINISHED"):
              print("job_time : {}".format(job_time))
              date_time_str = job_time.split('.')[0]
              date_time_obj = datetime.datetime.strptime(date_time_str, '%A %d %B %Y %H:%M:%S')
              job_time_sec = time.mktime(date_time_obj.timetuple())

              current_time = time.time()
              diff_in_min = (current_time - time.mktime(date_time_obj.timetuple()))/60
              if diff_in_min >= purge_time:
                  url = "{}/{}/v2/jobs/{}".format(hb_endpoint, instance_id, job_id)
                  try:
                    dj_response = requests.delete(url, headers=headers, verify=False,timeout=40)
                    if dj_response.status_code != 204:
                        print("\n\n\nFailed to delete job_id : {}, job_state : {}, time diff : {}, HTTP code : {}\n\n\n".format(job_id,job_state,diff_in_min,dj_response.status_code))
                    else:
                        print("\n\n\nDeleted job_id : {}, job_state : {}, time diff : {}, HTTP code : {}\n\n\n".format(job_id,job_state,diff_in_min,dj_response.status_code))
                  except (requests.Timeout, requests.ConnectionError, KeyError) as e:
                    print("Timeout occurred in deleting JOB {} - move forward".format(job_id))
    else:
        print("Failed to get jobs in state : ACTIVE. HTTP Code : {}".format(j_response.status_code))

def purge_failed_or_delete_failed_jobs(job_service_url,instance_id,hb_endpoint,purge_time):
    j_response = requests.get("{}/{}/jobs/meta/list?state=FAILED&state=DELETE_FAILED".format(job_service_url, instance_id), headers=headers, verify=False, timeout=120)
    if j_response.status_code == 200:
        jobs = j_response.json()

        for job in jobs:
            job_id = job["job_id"]
            state = job["state"]
            url = "{}/{}/v2/jobs/{}".format(hb_endpoint, instance_id, job_id)
            try:
              dj_response = requests.delete(url, headers=headers, verify=False,timeout=40)
              if dj_response.status_code != 204:
                  print("\n\n\nFailed to delete job_id : {}, cluster_state : {}, HTTP code : {}\n\n\n".format(job_id,state,dj_response.status_code))
              else:
                  print("\n\n\nDeleted job_id : {}, cluster_state : {},  HTTP code : {}\n\n\n".format(job_id,state,dj_response.status_code))
            except (requests.Timeout, requests.ConnectionError, KeyError) as e:
              print("Timeout occurred in deleting JOB {} - move forward".format(job_id))
    else:
        print("Failed to get jobs in state : FAILED,DELETE_FAILED. HTTP Code : {}".format(j_response.status_code))


# ---------------------------------------------  PARSE ARGS ------------------------------------------- #
parser = argparse.ArgumentParser()
parser.add_argument("instance_manager_url", help="Instance manager url to get instance details")
parser.add_argument("hb_endpoint", help="Hummingbird endpoint url to delete jobs")
parser.add_argument("job_service_url", help="Job service url to get metadata of jobs")
parser.add_argument("purge_time_file", help="purge time for FINISHED / FAILED jobs")
args = parser.parse_args()


# ---------------------------------------------  BUILD JSON  ------------------------------------------- #
instance_manager_url = args.instance_manager_url
hb_endpoint = args.hb_endpoint
job_service_url = args.job_service_url

purge_time_file = args.purge_time_file

print("Start HB Jobs cleanup")

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
        print("Get the instance details for instance {}".format(instance_id))
        if "api_key" not in instance:
            api_key = None
        else:
            api_key = instance["api_key"]

        headers = {'Accept':'application/json','X-Api-Key':api_key}

        if purge_time == -1:
            purge_failed_or_delete_failed_jobs(job_service_url,instance_id,hb_endpoint,purge_time)
        else:
            purge_active_jobs(job_service_url,instance_id,hb_endpoint,purge_time)
            purge_failed_or_delete_failed_jobs(job_service_url,instance_id,hb_endpoint,purge_time)
    exit(0)
else:
    print("Failed to get instances, got responseCode {}".format(response))
    exit(2)