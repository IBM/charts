{{/* Tivoli EIF Probe Virtualization (Part 1) Rules file */}}
{{- define "probeTivoliEIFRules-virtualization-pt1" }}
# ----------------------------------------------------------------
# --
# --	Licensed Materials - Property of IBM
# --
# --	5725-Q09
# --
# --	(C) Copyright IBM Corp. 2018, 2019. All Rights Reserved
# --
# --	US Government Users Restricted Rights - Use, duplication
# --	or disclosure restricted by GSA ADP Schedule Contract
# --	with IBM Corp.
# 
# --
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# This is part 1 of two rules files that are intended to be included 
# in the main tivoli_eif.rules file for use with the Tivoli EIF probe. 
# A suitable version of this file is provided in the 
# .../extensions/eifrules directory. Both parts must be included in 
# the tivoli_eif.rules file.
#
# This is an example rules file and is designed to be used to send ITM
# situation data from a hypervisor ITM agent (such as the VMware VI 
# agent) to an OMNIbus ObjectServer. This is used to provide root cause 
# and severity classification of alerts based on the relationship
# between hypervisor host faults and the virtual machine faults. This
# rules file is only compatible with OMNIbus 7.3.0 and later.  
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Part 1 just create the targets we will be sending events to.
# The first target declaration does an implict settarget.
#
# NOTE: Assumes ObjectServer name is NCOMS please edit if different.
# ------------------------------------------------------------------
{{- if .Values.netcool.backupServer }}
alerts_target = registertarget( "AGG_V", "", "alerts.status", "alerts.details" )
vmstatus_target = registertarget( "AGG_V", "", "custom.vmstatus", "" )
{{ else }}
alerts_target = registertarget( "{{ .Values.netcool.primaryServer }}", "", "alerts.status", "alerts.details" )
vmstatus_target = registertarget( "{{ .Values.netcool.primaryServer }}", "", "custom.vmstatus", "" )
{{- end }}



{{- end }}