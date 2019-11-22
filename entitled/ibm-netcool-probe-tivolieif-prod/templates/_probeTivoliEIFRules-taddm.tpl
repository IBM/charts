{{/* Tivoli EIF Probe TADDM Rules file */}}
{{- define "probeTivoliEIFRules-taddm" }}
#######################################################################
#
# Licensed Materials - Property of IBM
#
# 5725-Q09
#
# (C) Copyright IBM Corp. 2018, 2019. All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication
# or disclosure restricted by GSA ADP Schedule Contract
# with IBM Corp.
#
#######################################################################
#
# This rules file has been developed in accordance to the
# IBM Netcool/OMNIbus Rules Files Best Practices.
#
# It is intended to be added as an 'include' file to the Probe for Tivoli EIF
# main rules file 'tivoli_eif.rules'.
# 
# Events are received from IBM Tivoli Application Dependency
# Discovery Manager (TADDM).
# The events represent configuration changes that were detected during
# a TADDM discovery run.
#
#######################################################################
#
#    tivoli_eif_taddm.rules
#
#    Build version: 5.50.37
#
#######################################################################

case "TADDM":

	log(DEBUG, "<<<<< Entering... tivoli_eif_taddm.rules >>>>>")

	# We cannot capture events that do not contain a GUID slot.

	if (!exists($guid))
	{
		log(ERROR, "TADDM event does not contain a GUID slot. Event discarded.")
		discard
	}

	@Manager = %Manager + " on " + hostname()
	@Agent = "TADDM OMP Change Event Module"

	# Set Class to TADDM

	@Class = 87721

	# Store key to TADDM object

      	@AlertKey = $guid

	# Construct a unique event Identifier
	#
	# GUID .......... globally unique id for the config item (CI)
	# CHANGE_TYPE ... Indicates the type of change detected.
	# ATTRIBUTE_NAME  Is optional and may not be populated for each event.
	# OLD_VALUE ..... optional - not provided with every event.
	# NEW_VALUE ..... optional - not provided with every event.

	@Identifier = $guid + ":" + $change_type + ":" + $attribute_name + ":" + $old_value + ":" + $new_value

	# EventId: Identifier for the generic type of event.
	#          We set it to 'TADDM'-<OBJECT_TYPE>-<CHANGE_TYPE>'

	if (exists($source))
	{
		@EventId = $source
	}

	# Node: TADDM object name

	if (exists($object_name))
	{
		@Node = $object_name
	}

	# AlertGroup: TADDM object type

	if (exists($class_name))
	{
		@AlertGroup = $class_name
		@EventId = @EventId + '-' + $class_name
	}

	# Prefix Summary with config change type.

	if (length($change_type) > 0)
	{
		@EventId = @EventId + '-' + $change_type
		@Summary = $change_type
	}

	# Extend the Summary if more optional info was received.

	if (length($attribute_name) > 0)
	{
		@Summary = @Summary + " " + $attribute_name
	}

	if ((length($new_value) > 0) && (length($old_value) == 0))
	{
		@Summary = @Summary + " " + $new_value
	}
	else if ((length($new_value) == 0) && (length($old_value) > 0))
	{
		@Summary = @Summary + " " + $old_value
	}
	else if ((length($old_value) > 0) && (length($new_value) > 0))
	{
		@Summary = @Summary + " from " + $old_value + " to " + $new_value
	}

	# Use the URL column to hold the address for TADDM
	# This value will be prefixed to the URLs in
	# event list tools that click across to TADDM

	@URL = "http://" + $host + ":" + $port

	# Event time stamps

	if (exists( $change_time ) )
	{
		@FirstOccurrence = datetotime( $change_time, "yyyy-MM-d@HH:mm:ssZ" )
		@LastOccurrence = @FirstOccurrence
	}

	# Assign Severity.

	if (exists( $severity ) )
	{
		@Severity = $severity
	}
	else
	{
		# Severity not received in event.
		# Set it to "Indeterminate" (purple)
		@Severity = 1
	}

	# Set BSM_Identity for integration with TBSM.

	if (length($origin) > 0)
	{
		# The GUID of the primary containing object.
		@BSM_Identity = $origin
	}
	else
	{
		# Default: GUID of the object related to this event.
		@BSM_Identity = $guid
	}

	# ExpireTime is not set.
	# Events will remain in ObjectServer forever.
	# If required, the line below can be uncommented to set an expire time.
	# In the line below, the ExpireTime is set to 1 week.

	# @ExpireTime = 7 * 24 * 60 * 60

	# Capture 'details'. Only use in debug environment.

	# details($*)

	log(DEBUG, "<<<<< Leaving... tivoli_eif_taddm.rules >>>>>")

{{- end }}