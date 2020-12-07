{{- define "db2u.sysctls" }}
  # Compute all IPC setting required by Db2 using memory resource limit in Gi
  {{- $ram_GB := float64 (trimSuffix "Gi" .Values.limit.memory) }}
  {{- $ram_BYTES := mul $ram_GB 1073741824 }}
  {{- $IPCMNI_LIMIT := mul 32 1024 }}
  {{- $shmmax := $ram_BYTES }}
  {{- $shmmni := min ( mul 256 $ram_GB ) $IPCMNI_LIMIT }}
  {{- $msgmni := min ( mul 1024 $ram_GB ) $IPCMNI_LIMIT }}
  {{- $msgmax := 65536 }}
  {{- $msgmnb := $msgmax }}
  sysctls:
  - name: kernel.shmmni
    value: "{{ $shmmni }}"
  - name: kernel.shmmax
    value: "{{ $shmmax }}"
  - name: kernel.shmall
  # Handle pagesize diffs in platforms using arch
  {{- if eq .Values.arch "x86_64" }}
    value: "{{ mul 2 ( div $ram_BYTES 4096  ) }}"
  {{- else if eq .Values.arch "ppc64le" }}
    value: "{{ mul 2 ( div $ram_BYTES 65536 ) }}"
  {{- end }}
  - name: kernel.sem
    value: "250 256000 32 {{ $shmmni }}"
  - name: kernel.msgmni
    value: "{{ $msgmni }}"
  - name: kernel.msgmax
    value: "{{ $msgmax }}"
  - name: kernel.msgmnb
    value: "{{ $msgmnb }}"
{{- end }}

