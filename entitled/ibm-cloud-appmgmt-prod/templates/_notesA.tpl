{{- define "icam.notes.a" -}}
{{- $flags := dict "advanced" "" -}}
{{- if (hasKey .Values "ibm-cem") -}}
  {{- $cemValues := index .Values "ibm-cem" -}}
  {{- $productName := index $cemValues "productName" }}
    {{- if (eq $productName "IBM Cloud App Management Advanced") -}}
      {{- $_ := set $flags "advanced" "--advanced" -}}
    {{- end -}}
{{- end -}}
{{- $productTags := dict "advanced" true -}}
{{- if (hasKey .Values "tags") -}}
  {{- $tags := index .Values "tags" -}}
  {{- if (hasKey $tags "advanced") -}}
    {{- $advancedTag := index $tags "advanced" -}}
    {{- if (eq $advancedTag false) -}}
      {{- $_ := set $productTags "advanced" false -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $notAdvancedProductConfig := not $productTags.advanced -}}
{{- if (and $flags.advanced $notAdvancedProductConfig) }}

WARNING: Not deploying advanced services. You are entitled to the advanced services.
If you wish to deploy them, add the `tags.advanced=true` key and upgrade the release.

{{ end -}}

{{- if not .Release.IsUpgrade }}

Please run the post-install-setup.sh script provided in the chart's ibm_cloud_pak/pak_extensions in order to
finish the administrative tasks necessary to access the IBM Cloud Application Management Dashboard.

Example usage:
<path to ibm-cloud-appmgmt-prod>/ibm_cloud_pak/pak_extensions/post-install-setup.sh --releaseName {{ .Release.Name }} --namespace {{ .Release.Namespace }} --instanceName ibmcloudappmgmt {{ $flags.advanced }}

The dashboard URL will be displayed at the end of the post_install_setup.sh script. Login with user credentials associated with the subscription.

{{ end -}}

To view the dashboard URL, please look in the serviceinstance information.  Example usage:
kubectl describe serviceinstance ibmcloudappmgmt -n {{ .Release.Namespace }} | grep Dashboard

The IBM Cloud Application Management Dashboard is also accessible from the IBM Cloud Private UI.  Search for the serviceinstance under Workloads, Brokered Services and then select Launch.
{{- end -}}
