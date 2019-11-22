# begin_generated_IBM_copyright_prolog                             
#                                                                  
# This is an automatically generated copyright prolog.             
# After initializing,  DO NOT MODIFY OR MOVE                       
# **************************************************************** 
# Licensed Materials - Property of IBM                             
# 5724-Y95                                                         
# (C) Copyright IBM Corp.  2018, 2018    All Rights Reserved.      
# US Government Users Restricted Rights - Use, duplication or      
# disclosure restricted by GSA ADP Schedule Contract with          
# IBM Corp.                                                        
#                                                                  
# end_generated_IBM_copyright_prolog  
{{/* affinity - https://kubernetes.io/docs/concepts/configuration/assign-pod-node/ 

    #If you specify multiple nodeSelectorTerms associated with nodeAffinity types,
    #then the pod can be scheduled onto a node if one of the nodeSelectorTerms is satisfied.
    #
    #If you specify multiple matchExpressions associated with nodeSelectorTerms,
    #then the pod can be scheduled onto a node only if all matchExpressions can be satisfied.
    #
    #valid operators: In, NotIn, Exists, DoesNotExist, Gt, Lt
*/}}

{{- define "zookeeper.nodeaffinity" }}
nodeAffinity:
{{- include "zookeeper.nodeAffinityRequiredDuringScheduling" . | indent 2}}
{{- end }}

{{- define "zookeeper.nodeAffinityRequiredDuringScheduling" }}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
  - matchExpressions:
    - key: beta.kubernetes.io/arch
      operator: In
      values:
      - amd64
{{- end }}
