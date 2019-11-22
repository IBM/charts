{{/* Tivoli EIF Probe Virtualization (Part 2) Rules file */}}
{{- define "probeTivoliEIFRules-virtualization-pt2" }}
# ------------------------------------------------------------------
# This is part 2 of two rules files that are intended to be included 
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
#
# This example is intended as a starting point and will need to be 
# customized to meet individual customer needs. 
#
# This ITM virtualization integration must be used as part of a full 
# ITM integration. The itm_event.rules file must have been included in 
# the master tivoli_eif.rules file. 
# ------------------------------------------------------------------

log(DEBUG, "<<<<< Entering.... ITM Virtualization Rules File (Part 2) ..... >>>>>")


# ------------------------------------------------------------------
# Handle specific ITM situation events
# ------------------------------------------------------------------
if ( exists( $situation_name ) )
{
	# ------------------------------------------------------------ 
	# If the default virtual management situation names used below 
	# are changed in ITM then this rules file will also need the 
	# corresponding changes made.
	# ------------------------------------------------------------

	# ------------------------------------------------------------
	# Handle our virtual machine situations.
	# ------------------------------------------------------------
	switch($situation_name)
	{
	case "KVM_Server_VMotion_Event":
		if (nmatch($vm_name,""))
		{
			# -- The Virtual Machine has been moved to a new host
			genevent( vmstatus_target, @VMHostName, $vm_name, @HyperHostName, $server_hostname )
			@Summary = $event
			@Node = $server_hostname
			@NodeAlias = $server_hostname
		}
	# -- Normally we would only need one situation to cover these two VM Up and Down states.
	# -- However, we want to populate our vmstatus table when ITM starts so we must make sure
	# -- one of these situations is active at all times. 
	case "KVM_VM_Down":
		if (nmatch($vm_name,""))
		{
			# -- The Virtual Machine is offline. Lots of things might fail as a result. 
			# -- We are making this an error on the host system rather than the VM, this is
			# -- because this could be a root cause of lots of VM faults and we want out
			# -- automations to pick this up.
			@Node = $vm_server_name
			@NodeAlias = $vm_server_name
			@Service = $vm_name
				
			if ( int(@Type) == 1 OR int(@Type) == 20 )
			{
				genevent( vmstatus_target, @VMHostName, $vm_name, @HyperHostName, $vm_server_name, @VMStatus, 0 )
				@Summary = "The virtual machine " + $vm_name + " running on " + $vm_server_name + " is offline. The power status is: " + $power_status + ". Running: " + $guestos_name
			}
			else
			{
				@Summary = "Problem resolved. The virtual machine " + $vm_name + " running on " + $vm_server_name + " is running again. The power status is: " + $power_status + ". Running: " + $guestos_name
			}
		}	
		else
		{
			# -- The resolution may not have the vm_name slot set, however the 
			# -- alert will still have Node and Service set from above.
			if ( int(@Type) == 2 OR int(@Type) == 21 )
			{
				@Summary = "Problem resolved. The virtual machine is running again." 		
			}
		}
	case "KVM_VM_Up":
		if (nmatch($vm_name,""))
		{
			# -- The Virtual Machine is online. Lots of things might be fixed as a result.

			# -- If for some reason you do not want to discard this situation then uncomment these 
			# @Node = $vm_server_name
			# @NodeAlias = $vm_server_name
		 	# @Service = $vm_name
			
			# -- Normal type meanings reversed here								
			if (int(@Type) == 1 OR int(@Type) == 20)
			{
				genevent( vmstatus_target, @VMHostName, $vm_name, @HyperHostName, $vm_server_name, @VMStatus, 1 )
				# @Summary = "The virtual machine " + $vm_name + " running on " + $vm_server_name + " is powered on. Running: " + $guestos_name		
			}

		}
		# -- This is a reverse situation and provides no information in alerts.status not provided by KVM_VM_Down
		# -- it may also confuse a user so discard.
		discard	
	case "KVM_Server_Datastore_Free_Low" :
		if (nmatch($server_hostname,""))
		{
			# -- We are running out of disk space on our hypervisor host. This is unlikey to
			# -- be a root cause of any VM problems as the disk space has already been assigned
			# -- to the VM but it could prevent additional VMs from being created.
			@Node = $server_hostname
			@NodeAlias = $server_hostname
			if (int(@Type) == 1 OR int(@Type) == 20)
			{
				@Summary = "Disk space low on " + $name + " used by hypervisor host " + $server_hostname
			}
			else
			{
				@Summary = "Disk space OK on " + $name + " used by hypervisor host " + $server_hostname
			}
		}
	case "KVM_VM_Host_Memory_Util_High" | "KVM_Server_Memory_Util_High" | "KVM_VM_Guest_Memory_Util_High":
		if (nmatch($vm_server_name,""))
		{
			# -- We are running out of memory on our hypervisor host or the VMs share 
			# -- of it.  This could be a root cause of VM problems as it could cause 
			# -- memory alloc problems on our VM and applications to fail.
			@Node = $vm_server_name
			@NodeAlias = $vm_server_name
			# -- We will change the AlertGroup to make it easy to associate with VM errors
			@AlertGroup = "Memory Allocation Status"
			if (int(@Type) == 1 OR int(@Type) == 20)
			{
				@Summary = "Free memory low on " + $vm_server_name 
			}
			else
			{
				@Summary = "Free memory OK on " + $vm_server_name 
			}
			# -- This could be associated with the server or it might have been triggered by a VM.
			if(exists($vm_name))
			{
				# -- If the hypervisor host is running out of memory it can be first 
				# -- reported by just one VM, more than one VM or the server. We will
				# -- update the Summary and the Service but keep these all as one single
				# -- error in alerts.status. If you have limited the memory on individual
				# -- VMs then you may wish to split this into separate errors.
				@Summary = @Summary + ". Reported for VM: " + $vm_name
				@Service = $vm_name 
			}
		}
		else
		{
			# -- The resolution may not have the vm_server_name slot set, however the 
			# -- alert will still have Node and Service set from above.
			if (int(@Type) == 2 OR int(@Type) == 21)
			{
				@Summary = "Free memory now OK" 
			}
		}

	case "KVM_Server_CPU_Util_High" | "KVM_VM_CPU_Util_High" | "KVM_Cluster_CPU_Util_High":
		if (nmatch($vm_server_name,""))
		{
			# -- We are running out of processing power on our hypervisor host or the VMs
			# -- share of it. This could be a root cause of VM problems as it could cause 
			# -- slow VM response times and therefore a range of timeout problems.
			@Node = $vm_server_name
			@NodeAlias = $vm_server_name
			# -- We will change the AlertGroup to make it easy to associate with VM errors
			@AlertGroup = "CPU Status"
			if (int(@Type) == 1 OR int(@Type) == 20)
			{
				@Summary = "CPU use high on " + $vm_server_name 
			}
			else
			{
				@Summary = "CPU use OK on " + $vm_server_name 
			}
			if(exists($vm_name))
			{
				# -- If the hypervisor host is running out of CPU it can be first 
				# -- reported by just one VM, more than one VM or the server. We will
				# -- update the Summary and the Service but keep these all as one single
				# -- error in alerts.status. If you have limited the number of CPUs to
				# -- be less than the number on the hypervisor host then you may wish
				# -- to separate this into two errors.
				@Summary = @Summary + ". Reported for VM: " + $vm_name
				@Service = $vm_name 
			}
		}
		else
		{
			# -- The resolution may not have the vm_server_name slot set, however the 
			# -- alert will still have Node and Service set from above.
			if (int(@Type) == 2 OR int(@Type) == 21)
			{
				@Summary = "CPU use now OK" 
			}
		}

	# -- Add more specific situation handling here...
	default:
		# -- Use what we have already defined for all situations
	}
}

log(DEBUG, "<<<<< Leaving..... ITM Virtualization Rules File (Part 2) ..... >>>>>")

{{- end }}