import sys
import StringIO,pycurl,ast
from datetime import datetime
import time
import json

#-------------------------------------------------------------------------------------------#
# post request 
#-------------------------------------------------------------------------------------------#
def post_request(url,apikey,data):
    c = pycurl.Curl()
    c.setopt(pycurl.URL, str(url))
    c.setopt(pycurl.CONNECTTIMEOUT, 30)
    c.setopt(pycurl.TIMEOUT, 120)
    c.setopt(pycurl.HTTPHEADER, ['Content-Type: application/json','Accept: application/json',"X-Api-Key: {}".format(apikey)])
    c.setopt(pycurl.POST, 1)
    c.setopt(pycurl.POSTFIELDS, data)
    c.setopt(pycurl.SSL_VERIFYPEER, 0)
    c.setopt(pycurl.SSL_VERIFYHOST, 0)
    buff = StringIO.StringIO()
    c.setopt(pycurl.WRITEFUNCTION, buff.write)
    c.perform()
    responseCode=c.getinfo(pycurl.HTTP_CODE)
    responseData=buff.getvalue()
    return responseCode,responseData

#-------------------------------------------------------------------------------------------#
# delete request
#-------------------------------------------------------------------------------------------#
def delete_request(url, api_key):
    c = pycurl.Curl()
    c.setopt(pycurl.URL, url)
    c.setopt(pycurl.CUSTOMREQUEST, "DELETE")
    c.setopt(pycurl.SSL_VERIFYPEER, 0)
    c.setopt(pycurl.SSL_VERIFYHOST, 0)
    if api_key is not None:
        c.setopt(pycurl.HTTPHEADER, ['X-Api-Key: ' + str(api_key)])
    c.perform()
    responseCode=c.getinfo(pycurl.HTTP_CODE)
    return responseCode

def create_kernel(instance_id,api_key,payload):
    url=service_endpoint_url+'/ae/'+instance_id+"/jkg/api/kernels"
    
    responseCode,responseData = post_request(url,apikey,payload)
    if responseCode != 201:
        print "failed to create dry run kernel"
        return 1
    else:
        jdata = [responseData]
        kernel_details = ast.literal_eval(json.dumps(jdata))
        kernel_details = json.loads(kernel_details[0])
        print "Successfully create kernel : {}".format(kernel_details)
        return 0

if __name__ == "__main__":
    if len (sys.argv) < 2:
        print "Error : missing arguments"
        print "Usage : python {0} <service_endpoint_url> <number_of_dry_run_kernel_to_create>".format(sys.argv[0])
        exit(1)
    else:
        service_endpoint_url = sys.argv[1]
        dry_run_num = int(sys.argv[2])
        
    payload='{}'
    apikey=''
    url=service_endpoint_url+'/ae'+'/dryrun'
        
    responseCode,responseData = post_request(url,apikey,payload)
    if responseCode != 200:
        print "failed to create instance"
        exit(1)
    else:
        instance_details = json.loads(responseData)
        print "Successfully create instance : {}".format(instance_details['instance_id'])
    
    instance_id = instance_details['instance_id']
    api_key = instance_details['api_key']
    payload='{"name":"scala","isDryRun":"true"}'
    
    failed = 0
    
    for i in range(dry_run_num):
        failed_flag = create_kernel(instance_id,api_key,payload)
        if failed_flag:
            failed = failed + 1
    
    if failed:
        print "failed to create dry run kernel {} times".format(failed)
        exit(1)
        
#    url=service_endpoint_url+'/ae/'+instance_details['instance_id']+"/jkg/api/kernels/"+kernel_details['id']
#    responseCode = delete_request(url,apikey)
#    if responseCode != 204:
#        print "failed to delete kernel"
#        exit(2)
#    else:
#        print "Successfully deleted kernel : {}".format(kernel_details)
    
    