{{- define "initSql.basic" }}
execute function admin ('modify chunk extendable', 1);
execute function admin('STORAGEPOOL ADD', '$BASEDIR/data/spaces', 0,0,'64MB',1);
{{- end }}



{{- define "initSql.dbspaces" }}
{{- with .Values.systemSetup.dbspaces.datadbs }}
{{- if .enabled }}
execute function admin('create dbspace', '{{ .name }}', '$BASEDIR/data/spaces/{{ .name }}.1', '{{ .size }}', '0', '{{ .pagesize }}');
{{- end }}
{{- end }}
{{- end }}

{{- define "initSql.sbspaces" }}
{{- with .Values.systemSetup.dbspaces.sbspace }}
{{- if .enabled }}
execute function admin('create sbspace', '{{ .name }}', '$BASEDIR/data/spaces/{{ .name }}.1', '20M', '0');
execute function admin('onmode', 'wf', 'SBSPACENAME={{ .name }}');
execute function admin('onmode', 'wm', 'SBSPACENAME={{ .name }}');
{{- end }}
{{- end }}
{{- end }}



{{- define "initSql.ts" }}
{{- with .Values.systemSetup.ts }}
{{- if .create }}
create database {{ .database }} with log;

-- Needed to avoid autoregistration
execute function sysbldprepare('TimeSeries*', 'create');

create procedure tscreatevti(vti_tabname lvarchar, tabname lvarchar, calendar lvarchar, origin datetime year to fraction(5), type lvarchar)

define v_sql lvarchar;

let v_sql="execute procedure tscreatevirtualtab('" || vti_tabname || 
          "', '" ||tabname || "', 'calendar(" || calendar || 
          "), origin(" || origin || "), irregular')"  ;

execute immediate v_sql; 
end procedure;

create row type {{ .table }}_data_t
(
  tstamp datetime year to fraction(5),
  json_data bson
);


create table {{ .table }}_t
(
  id varchar(255) not null primary key,
  properties bson,
  data timeseries({{ .table }}_data_t)
);

-- Use of wrapper.  Can specify current - (1 day), etc.
--execute procedure tscreatevti('tstab_v' , 'tstab', 'ts_1min',current, 'irregular');

execute procedure tscreatevirtualtab('{{ .table }}' , '{{ .table }}_t', 'calendar(ts_1min), origin(%Y-%m-%d 00:00:00.00000),irregular'); 
{{- end }}
{{- end }}
{{- end  }}



{{- define "initSql.userdb" }}
{{- with .Values.systemSetup.userdb }}
{{- if .create }}
create database {{ .database }} in {{ .dbspace }} with log;
{{- end }}
{{- end }}
{{- end  }}