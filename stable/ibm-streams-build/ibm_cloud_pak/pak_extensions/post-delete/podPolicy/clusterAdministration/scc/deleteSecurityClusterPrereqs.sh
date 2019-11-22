#!/bin/bash
# begin_generated_IBM_copyright_prolog                             
#                                                                  
# This is an automatically generated copyright prolog.             
# After initializing,  DO NOT MODIFY OR MOVE                       
# **************************************************************** 
# Licensed Materials - Property of IBM                             
# 5724-Y95                                                         
# (C) Copyright IBM Corp.  2018, 2019    All Rights Reserved.      
# US Government Users Restricted Rights - Use, duplication or      
# disclosure restricted by GSA ADP Schedule Contract with          
# IBM Corp.                                                        
#                                                                  
# end_generated_IBM_copyright_prolog                               
################################################################
#
#
# This script can be run after all releases are deleted from the cluster. 
#

# Delete the SecurityContextConstraint and ClusterRole for all releases of this chart.
kubectl delete scc ibm-streams-build-scc
kubectl delete clusterrole ibm-streams-build-sec-cr