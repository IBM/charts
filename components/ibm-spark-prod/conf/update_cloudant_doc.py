import sys
import StringIO,pycurl
from datetime import datetime
import time
import json

#-------------------------------------------------------------------------------------------#
# get request
#-------------------------------------------------------------------------------------------#
def get_request(url, user,passwd):
    buf = StringIO.StringIO()
    c = pycurl.Curl()
    c.setopt(pycurl.URL, str(url))
    c.setopt(pycurl.WRITEFUNCTION, buf.write)
    c.setopt(pycurl.CONNECTTIMEOUT, 30)
    c.setopt(pycurl.TIMEOUT, 120)
    c.setopt(pycurl.USERPWD, "%s:%s" % (str(user), str(passwd)))
    c.setopt(pycurl.SSL_VERIFYPEER, 0)
    c.setopt(pycurl.SSL_VERIFYHOST, 0)
    c.perform()
    responseCode=c.getinfo(pycurl.HTTP_CODE)
    if responseCode == 200:
        backinfo = buf.getvalue()
        return responseCode,backinfo
    else:
        return responseCode, None

#-------------------------------------------------------------------------------------------#
# post request
#-------------------------------------------------------------------------------------------#
def post_request(url,user,passwd,data):
        c = pycurl.Curl()
        c.setopt(pycurl.URL, str(url))
        c.setopt(pycurl.CONNECTTIMEOUT, 30)
        c.setopt(pycurl.TIMEOUT, 120)
        c.setopt(pycurl.HTTPHEADER, ['Content-Type: application/json','Accept: application/json'])
        c.setopt(pycurl.USERPWD, "%s:%s" % (str(user), str(passwd)))
        c.setopt(pycurl.SSL_VERIFYPEER, 0)
        c.setopt(pycurl.SSL_VERIFYHOST, 0)
        c.setopt(pycurl.POST, 1)
        c.setopt(pycurl.POSTFIELDS, data)
        c.perform()
        responseCode=c.getinfo(pycurl.HTTP_CODE)
        return responseCode

#-------------------------------------------------------------------------------------------#
# put request
#-------------------------------------------------------------------------------------------#
def put_request(url,user,passwd,data):
        response = StringIO.StringIO()
        c = pycurl.Curl()
        c.setopt(pycurl.URL, str(url))
        c.setopt(pycurl.CONNECTTIMEOUT, 30)
        c.setopt(pycurl.TIMEOUT, 120)
        c.setopt(pycurl.HTTPHEADER, ['Content-Type: application/json','Accept: application/json'])
        c.setopt(pycurl.USERPWD, "%s:%s" % (str(user), str(passwd)))
        c.setopt(pycurl.SSL_VERIFYPEER, 0)
        c.setopt(pycurl.SSL_VERIFYHOST, 0)
        c.setopt(pycurl.CUSTOMREQUEST, "PUT")
        c.setopt(pycurl.POSTFIELDS, data)
        c.setopt(c.WRITEFUNCTION, response.write)
        c.perform()
        responseCode=c.getinfo(pycurl.HTTP_CODE)
        return responseCode

if __name__ == "__main__":
    if len (sys.argv) < 6:
        print "Error : missing one or more arguments"
        print "Usage : python {0} <cloudant_url> <cloudant_user> <cloudant_password> <cloudant_db> <cloudant_doc_file>".format(sys.argv[0])
        exit(1)
    else:
        cloudant_url = sys.argv[1]
    cloudant_user = sys.argv[2]
    cloudant_password = sys.argv[3]
    cloudant_db = sys.argv[4]
    cloudant_doc_file = sys.argv[5]

exit_code = 0
refresh_flag = True

with open(cloudant_doc_file) as doc:
    docs = json.load(doc)

for doc in docs["docs"]:
    response, data = get_request(cloudant_url+"/"+cloudant_db+"/"+doc["_id"], cloudant_user, cloudant_password)
    if response == 200:
        design_doc = json.loads(data)
        #if "version" in design_doc:
        #    if int(design_doc["version"]) < int(doc["version"]):
        #        refresh_flag = True
        #else:
        #    refresh_flag = True

        if refresh_flag:
            doc["_rev"] = design_doc["_rev"]
            payload = json.dumps(doc)
            response = put_request(cloudant_url+"/"+cloudant_db+"/"+doc["_id"], cloudant_user, cloudant_password,payload)
            if response != 201:
                print "Failed to update document {}".format(doc["_id"])
                exit_code = 2
            print "Refreshed document {}".format(doc["_id"])

    else:
        payload = json.dumps(doc)
        response = put_request(cloudant_url+"/"+cloudant_db+"/"+doc["_id"], cloudant_user, cloudant_password,payload)
        if response != 201:
            print "Failed to create document {}".format(doc["_id"])
            exit_code = 2
        print "Created document {}".format(doc["_id"])

if exit_code == 0:
    print "Refreshed DB with new documents"
else:
    print "Failed to refresh / Partially refresh DB"

exit(exit_code)