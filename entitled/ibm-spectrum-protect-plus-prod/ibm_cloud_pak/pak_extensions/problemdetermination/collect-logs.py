#!/usr/bin/python
# ----------------------------------------------------------------------------------------------
# (c) Copyright IBM Corporation 2017, 2019. All Rights Reserved.
#
# IBM Spectrum Protect Family Software
#
# Licensed materials provided under the terms of the IBM International Program
# License Agreement. See the Software licensing materials that came with the
# IBM Program for terms and conditions.
#
# U.S. Government Users Restricted Rights:  Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# ----------------------------------------------------------------------------------------------
# ===================================================================================================
#  BaaS: Service Manager - baas_collect_logs.py                                        v1.02
# ===================================================================================================
#
# Purpose: Collect debug log from Spectrum Protect Plus (a helper script invoked by baas_install.sh -l)
#
# Usage: baas_collect_logs.py [host IP] [sppadmin] [spppassword] [output-file-name.zip]
#
# Requirements:
#
# - Python 3.6
#
# Notes:
#
#  - If no response is received from Spectrum Protect Plus after 3 minutes the script returns an error
#
# ===================================================================================================

# Modules

import sys
import os
import base64
import string
import json
import ssl
import time
import sys
import datetime
import http.client
import urllib.request, urllib.error, urllib.parse

# Functions

if hasattr(ssl, '_create_unverified_context'):
    ssl._create_default_https_context = ssl._create_unverified_context

def getpost1minsinmilisecs():
    orig = datetime.datetime.fromtimestamp(time.time())
    new = orig + datetime.timedelta(minutes=1)
    millis = int(round(time.mktime(new.timetuple()) * 1000))
    return millis

def makegetrest(inurl):
    req = urllib.request.Request(inurl)
    req.add_header('x-endeavour-sessionid', sessionid)
    rawdata = urllib.request.urlopen(req).read()
    response = json.loads(rawdata)
    return response

def makegetrestraw(inurl):
    req = urllib.request.Request(inurl)
    req.add_header('x-endeavour-sessionid', sessionid)
    req.add_header('x-endeavour-locale', 'en_US')
    rawdata = urllib.request.urlopen(req).read()
    return rawdata

def makedeleterest(inurl):
    opener = urllib.request.build_opener(urllib.request.HTTPHandler)
    request = urllib.request.Request(inurl)
    request.add_header('x-endeavour-sessionid', sessionid)
    request.add_header('x-endeavour-locale', 'en_US')

    request.get_method = lambda: 'DELETE'
    returncode = opener.open(request).getcode()
    print(("Printing content of rawdata: ", returncode))
    return returncode

# Generic function for PUT calls
def makeput(inurl, data):
    print(("Calling PUT url = %s" % inurl))
    opener = urllib.request.build_opener(urllib.request.HTTPHandler)
    request = urllib.request.Request(inurl, json.dumps(data), headers={'Content-type': 'application/json', 'Accept': 'application/json', 'x-endeavour-locale': 'en-US'})
    request.add_header('x-endeavour-sessionid', sessionid)
    request.get_method = lambda: 'PUT'
    returncode = opener.open(request).getcode()
    print(("Printing content of rawdata: ", returncode))
    return returncode

def makepost(inurl, data):
    print(("Calling POST url = %s" % inurl))
    req = urllib.request.Request(inurl, json.dumps(data), headers={'Content-type': 'application/json', 'Accept': 'application/json', 'x-endeavour-locale': 'en_US'})
    req.add_header('x-endeavour-sessionid', sessionid)
    response = urllib.request.urlopen(req)
    rawresponse = response.read()
    jsondata = json.loads(rawresponse)
    return jsondata

def prettyprint(indata):
    print((json.dumps(indata, sort_keys=True, indent=4, separators=(',', ': '))))

def getsessionid():
    url = "/api/endeavour/session"
    # base64 encode the username and password
    authstring = f'{username}:{password}'
    authbytes = base64.encodestring(str(authstring).encode('utf-8'))
    auth = authbytes.replace(b'\n', b'').decode('utf-8')
    # print 'auth: ', auth
    webservice = http.client.HTTPSConnection(host)
    # write your headers
    webservice.putrequest("POST", url)
    webservice.putheader("Host", host)
    webservice.putheader("User-Agent", "Python http auth")
    webservice.putheader("Content-type", "application/json")
    webservice.putheader("Authorization", "Basic %s" % auth)
    webservice.putheader("x-endeavour-locale", "en_US")
    webservice.endheaders()
    # get the response
    response = webservice.getresponse()
    # print "Response: ", response.status, response.reason
    res = response.read()
    # print 'Content: ', res
    returndata = json.loads(res)
    # print "getsessionid: "
    # prettyprint(returndata)
    return (returndata)

# ======
#  Main
# ======

# Get arguments from command line
if len(sys.argv) != 5 :
    print("Usage: baas_collect_logs.py [host IP] [sppadmin] [spppassword] [output-file-name.zip]")
    sys.exit(1)
else:
    host     = sys.argv[1]
    username = sys.argv[2]
    password = sys.argv[3]
    logfile  = sys.argv[4]
    directory = os.path.dirname(logfile)
    if directory != '' and not os.path.exists(directory):
      os.makedirs(directory)
# Get the session id for ecx authentication
sessionresponse = getsessionid()
try:
    sessionid = sessionresponse['sessionid']
except Exception as e:
    print("ERROR: Invalid CDM/SPP REST API session id. Check correct credentials for baasadmin and baaspassword!")
    sys.exit(2)

# Collect SPP Log
try:
    file = open(logfile, "wb+")
except Exception as e:
    print(("ERROR: Could not open %s as log file output. Please check file path and space availability." % (logfile)))
    sys.exit(3)

try:
    file.write(makegetrestraw(str("https://"+host+"/api/endeavour/log/download/diagnostics")))
except Exception as e:
    file.close()
    print(("Unexpected error:", sys.exc_info()[0]))
    print(e)
    print(("ERROR: Could fetch log data from host at %s. Please check network connectivity." % (host)))
    sys.exit(4)

file.close()

