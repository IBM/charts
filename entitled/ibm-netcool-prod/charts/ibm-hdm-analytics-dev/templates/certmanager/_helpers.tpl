{{/*
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725Q09
#
# (C) Copyright IBM Corp.
#
# 2020 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
########################################################################
*/}}


{{- include "sch.config.init" (list . "ibm-hdm-analytics-dev.sch.chart.config.values") -}}

{{ define "ibm-hdm-analytics-dev.certmanager.component.name" -}}
certmanager
{{- end }}

{{ define "ibm-hdm-analytics-dev.certmanager.rootCaIssuer.name" -}}
{{- $compName := "root-ca" -}}
{{- $rootCaIssuertName := include "sch.names.fullCompName" (list . $compName) -}}
{{- $rootCaIssuertName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.certmanager.selfsigningIssuer.name" -}}
{{- $compName := "selfsigning-issuer" -}}
{{- $selfsigningIssuerName := include "sch.names.fullCompName" (list . $compName) -}}
{{- $selfsigningIssuerName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.certmanager.rootCaCertificate.name" -}}
{{- $compName := "root-ca" -}}
{{- $rootCaCertificatetName := include "sch.names.fullCompName" (list . $compName) -}}
{{- $rootCaCertificatetName -}}
{{- end }}

{{ define "ibm-hdm-analytics-dev.certmanager.rootCaCertificateIssuerRef.name" -}}
{{- $rootCaCertificatetIssuerRefName :=  include "ibm-hdm-analytics-dev.certmanager.selfsigningIssuer.name" . -}}
{{- $rootCaCertificatetIssuerRefName -}}
{{- end }}
