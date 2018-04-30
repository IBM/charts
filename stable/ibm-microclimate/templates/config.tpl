{{- define "override_config_map" }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ template "jenkins.fullname" . }}
data:
  user_config.xml: |-
    <?xml version='1.0' encoding='UTF-8'?>
    <user>
      <fullName>admin</fullName>
      <description></description>
      <properties>
        <jenkins.security.ApiTokenProperty>
          <apiToken>{AQAAABAAAAAwSTU69OS1ao84T1ELN3Nb+UNbeU+n29OVrqX69YoNHEW0jAO53lgXrllwn8eIcNwteXMGP/MOxhhWanY2woXh8w==}</apiToken>
        </jenkins.security.ApiTokenProperty>
        <com.cloudbees.plugins.credentials.UserCredentialsProvider_-UserCredentialsProperty plugin="credentials@2.1.16">
          <domainCredentialsMap class="hudson.util.CopyOnWriteMap$Hash">
            <entry>
              <com.cloudbees.plugins.credentials.domains.Domain>
                <specifications/>
              </com.cloudbees.plugins.credentials.domains.Domain>
              <java.util.concurrent.CopyOnWriteArrayList/>
            </entry>
          </domainCredentialsMap>
        </com.cloudbees.plugins.credentials.UserCredentialsProvider_-UserCredentialsProperty>
        <hudson.tasks.Mailer_-UserProperty plugin="mailer@1.20">
          <emailAddress></emailAddress>
        </hudson.tasks.Mailer_-UserProperty>
        <hudson.model.MyViewsProperty>
          <primaryViewName></primaryViewName>
          <views>
            <hudson.model.AllView>
              <owner class="hudson.model.MyViewsProperty" reference="../../.."/>
              <name>all</name>
              <filterExecutors>false</filterExecutors>
              <filterQueue>false</filterQueue>
              <properties class="hudson.model.View$PropertyList"/>
            </hudson.model.AllView>
          </views>
        </hudson.model.MyViewsProperty>
        <org.jenkinsci.plugins.displayurlapi.user.PreferredProviderUserProperty plugin="display-url-api@2.2.0">
          <providerId>default</providerId>
        </org.jenkinsci.plugins.displayurlapi.user.PreferredProviderUserProperty>
        <hudson.model.PaneStatusProperties>
          <collapsed/>
        </hudson.model.PaneStatusProperties>
        <org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl>
          <authorizedKeys></authorizedKeys>
        </org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl>
        <hudson.search.UserSearchProperty>
          <insensitiveSearch>true</insensitiveSearch>
        </hudson.search.UserSearchProperty>
      </properties>
    </user>
  config.xml: |-
    <?xml version='1.0' encoding='UTF-8'?>
    <hudson>
      <disabledAdministrativeMonitors/>
      <version>{{ .Values.Master.ImageTag }}</version>
      <numExecutors>0</numExecutors>
      <mode>NORMAL</mode>
      <useSecurity>{{ .Values.Master.UseSecurity }}</useSecurity>
      <authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy">
        <denyAnonymousReadAccess>true</denyAnonymousReadAccess>
      </authorizationStrategy>
      <securityRealm class="hudson.security.LegacySecurityRealm"/>
      <disableRememberMe>false</disableRememberMe>
      <projectNamingStrategy class="jenkins.model.ProjectNamingStrategy$DefaultProjectNamingStrategy"/>
      <workspaceDir>${JENKINS_HOME}/workspace/${ITEM_FULLNAME}</workspaceDir>
      <buildsDir>${ITEM_ROOTDIR}/builds</buildsDir>
      <markupFormatter class="hudson.markup.EscapedMarkupFormatter"/>
      <jdks/>
      <viewsTabBar class="hudson.views.DefaultViewsTabBar"/>
      <myViewsTabBar class="hudson.views.DefaultMyViewsTabBar"/>
      <clouds>
        <org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud plugin="kubernetes@{{ template "jenkins.kubernetes-version" . }}">
          <name>kubernetes</name>
          <templates>
{{- if .Values.Agent.Enabled }}
            <org.csanchez.jenkins.plugins.kubernetes.PodTemplate>
              <inheritFrom></inheritFrom>
              <name>default</name>
              <instanceCap>2147483647</instanceCap>
              <idleMinutes>0</idleMinutes>
              <label>{{ .Release.Name }}-{{ .Values.Agent.Component }}</label>
              <nodeSelector>
                {{- $local := dict "first" true }}
                {{- range $key, $value := .Values.Agent.NodeSelector }}
                  {{- if not $local.first }},{{- end }}
                  {{- $key }}={{ $value }}
                  {{- $_ := set $local "first" false }}
                {{- end }}</nodeSelector>
                <nodeUsageMode>NORMAL</nodeUsageMode>
              <volumes>
{{- range $index, $volume := .Values.Agent.volumes }}
                <org.csanchez.jenkins.plugins.kubernetes.volumes.{{ $volume.type }}Volume>
{{- range $key, $value := $volume }}{{- if not (eq $key "type") }}
                  <{{ $key }}>{{ $value }}</{{ $key }}>
{{- end }}{{- end }}
                </org.csanchez.jenkins.plugins.kubernetes.volumes.{{ $volume.type }}Volume>
{{- end }}
              </volumes>
              <containers>
                <org.csanchez.jenkins.plugins.kubernetes.ContainerTemplate>
                  <name>jnlp</name>
                  <image>{{ .Values.Agent.Image }}:{{ .Values.Agent.ImageTag }}</image>
{{- if .Values.Agent.Privileged }}
                  <privileged>true</privileged>
{{- else }}
                  <privileged>false</privileged>
{{- end }}
                  <alwaysPullImage>{{ .Values.Agent.AlwaysPullImage }}</alwaysPullImage>
                  <workingDir>/home/jenkins</workingDir>
                  <command></command>
                  <args>${computer.jnlpmac} ${computer.name}</args>
                  <ttyEnabled>false</ttyEnabled>
                  <resourceRequestCpu>{{.Values.Agent.Cpu}}</resourceRequestCpu>
                  <resourceRequestMemory>{{.Values.Agent.Memory}}</resourceRequestMemory>
                  <resourceLimitCpu>{{.Values.Agent.Cpu}}</resourceLimitCpu>
                  <resourceLimitMemory>{{.Values.Agent.Memory}}</resourceLimitMemory>
                  <envVars>
                    <org.csanchez.jenkins.plugins.kubernetes.ContainerEnvVar>
                      <key>JENKINS_URL</key>
                      <value>http://{{ template "jenkins.fullname" . }}:{{.Values.Master.ServicePort}}{{ default "" .Values.Master.JenkinsUriPrefix }}</value>
                    </org.csanchez.jenkins.plugins.kubernetes.ContainerEnvVar>
                  </envVars>
                </org.csanchez.jenkins.plugins.kubernetes.ContainerTemplate>
              </containers>
              <envVars/>
              <annotations/>
{{- if .Values.Agent.ImagePullSecret }}
              <imagePullSecrets>
                <org.csanchez.jenkins.plugins.kubernetes.PodImagePullSecret>
                  <name>{{ .Values.Agent.ImagePullSecret }}</name>
                </org.csanchez.jenkins.plugins.kubernetes.PodImagePullSecret>
              </imagePullSecrets>
{{- else }}
              <imagePullSecrets/>
{{- end }}
              <nodeProperties/>
            </org.csanchez.jenkins.plugins.kubernetes.PodTemplate>
{{- end -}}
          </templates>
          <serverUrl>https://kubernetes.default</serverUrl>
          <skipTlsVerify>false</skipTlsVerify>
          <namespace>{{ .Release.Namespace }}</namespace>
          <jenkinsUrl>http://{{ template "jenkins.fullname" . }}:{{.Values.Master.ServicePort}}{{ default "" .Values.Master.JenkinsUriPrefix }}</jenkinsUrl>
          <jenkinsTunnel>{{ template "jenkins.fullname" . }}-agent:50000</jenkinsTunnel>
          <containerCap>10</containerCap>
          <retentionTimeout>5</retentionTimeout>
          <connectTimeout>0</connectTimeout>
          <readTimeout>0</readTimeout>
        </org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud>
      </clouds>
      <quietPeriod>5</quietPeriod>
      <scmCheckoutRetryCount>0</scmCheckoutRetryCount>
      <views>
        <hudson.model.AllView>
          <owner class="hudson" reference="../../.."/>
          <name>All</name>
          <filterExecutors>false</filterExecutors>
          <filterQueue>false</filterQueue>
          <properties class="hudson.model.View$PropertyList"/>
        </hudson.model.AllView>
      </views>
      <primaryView>All</primaryView>
      <slaveAgentPort>50000</slaveAgentPort>
      <label></label>
      <nodeProperties/>
      <globalNodeProperties>
        <hudson.slaves.EnvironmentVariablesNodeProperty>
          <envVars serialization="custom">
            <unserializable-parents/>
            <tree-map>
              <default>
                <comparator class="hudson.util.CaseInsensitiveComparator"/>
              </default>
              <int>8</int>
              <string>BUILD</string>
              <string>{{ .Values.Pipeline.Build }}</string>
              <string>DEPLOY</string>
              <string>{{ .Values.Pipeline.Deploy }}</string>
              <string>TEST</string>
              <string>{{ .Values.Pipeline.Test }}</string>
              <string>DEBUG</string>
              <string>{{ .Values.Pipeline.Debug }}</string>
              <string>NAMESPACE</string>
              <string>{{ .Values.Pipeline.TargetNamespace }}</string>
              <string>DEFAULT_DEPLOY_BRANCH</string>
              <string>{{ .Values.Pipeline.DeployBranch }}</string>
              <string>REGISTRY</string>
              <string>{{ .Values.Pipeline.Registry.Url }}</string>
              <string>REGISTRY_SECRET</string>
              <string>{{ .Values.Pipeline.Registry.Secret }}</string>
            </tree-map>
          </envVars>
        </hudson.slaves.EnvironmentVariablesNodeProperty>
      </globalNodeProperties>
      <noUsageStatistics>true</noUsageStatistics>
    </hudson>
{{- if .Values.Master.ScriptApproval }}
  scriptapproval.xml: |-
    <?xml version='1.0' encoding='UTF-8'?>
    <scriptApproval plugin="script-security@1.27">
      <approvedScriptHashes/>
      <approvedSignatures>
{{- range $key, $val := .Values.Master.ScriptApproval }}
        <string>{{ $val }}</string>
{{- end }}
      </approvedSignatures>
      <aclApprovedSignatures/>
      <approvedClasspathEntries/>
      <pendingScripts/>
      <pendingSignatures/>
      <pendingClasspathEntries/>
    </scriptApproval>
{{- end }}
  apply_config.sh: |-
    mkdir -p /usr/share/jenkins/ref/secrets/;
    echo "false" > /usr/share/jenkins/ref/secrets/slave-to-master-security-kill-switch;
    cp -n /var/jenkins_config/config.xml /var/jenkins_home;
    cp -n /var/jenkins_config/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml /var/jenkins_home;
{{- if .Values.Master.UseSecurity }}
    mkdir -p /var/jenkins_home/users/admin;
    cp -n /var/jenkins_config/user_config.xml /var/jenkins_home/users/admin/config.xml;
{{- end }}
{{- if .Values.Master.InstallPlugins }}
    cp /var/jenkins_config/plugins.txt /var/jenkins_home;
    rm -rf /usr/share/jenkins/ref/plugins/*.lock
    /usr/local/bin/install-plugins.sh `echo $(cat /var/jenkins_home/plugins.txt)`;
{{- end }}
{{- if .Values.Master.ScriptApproval }}
    cp -n /var/jenkins_config/scriptapproval.xml /var/jenkins_home/scriptApproval.xml;
{{- end }}
{{- if .Values.Master.InitScripts }}
    mkdir -p /var/jenkins_home/init.groovy.d/;
    cp -n /var/jenkins_config/*.groovy /var/jenkins_home/init.groovy.d/
{{- end }}
{{- if .Values.Master.CredentialsXmlSecret }}
    cp -n /var/jenkins_credentials/credentials.xml /var/jenkins_home;
{{- end }}
{{- if .Values.Master.SecretsFilesSecret }}
    cp -n /var/jenkins_secrets/* /usr/share/jenkins/ref/secrets;
{{- end }}
{{- if .Values.Master.Jobs }}
    for job in $(ls /var/jenkins_jobs); do
      mkdir -p /var/jenkins_home/jobs/$job
      cp -n /var/jenkins_jobs/$job /var/jenkins_home/jobs/$job/config.xml
    done
{{- end }}
{{- range $key, $val := .Values.Master.InitScripts }}
  init{{ $key }}.groovy: |-
{{ $val | indent 4 }}
{{- end }}
  plugins.txt: |-
{{- if .Values.Master.InstallPlugins }}
{{- range $index, $val := .Values.Master.InstallPlugins }}
{{ $val | indent 4 }}
{{- end }}
{{- end }}
  org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml: |-
    <?xml version='1.0' encoding='UTF-8'?>
    <org.jenkinsci.plugins.workflow.libs.GlobalLibraries plugin="workflow-cps-global-lib@2.9">
      <libraries>
        <org.jenkinsci.plugins.workflow.libs.LibraryConfiguration>
          <name>MicroserviceBuilder</name>
          <retriever class="org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever">
            <scm class="jenkins.plugins.git.GitSCMSource" plugin="git@3.7.0">
              <id>msb.lib</id>
              <remote>{{ .Values.Pipeline.Template.RepositoryUrl }}</remote>
              <credentialsId>github-oauth-userpass</credentialsId>
              <traits>
                <jenkins.plugins.git.traits.BranchDiscoveryTrait/>
              </traits>
            </scm>
          </retriever>
          <defaultVersion>{{ .Values.Pipeline.Template.Version }}</defaultVersion>
          <implicit>true</implicit>
          <allowVersionOverride>true</allowVersionOverride>
          <includeInChangesets>true</includeInChangesets>
        </org.jenkinsci.plugins.workflow.libs.LibraryConfiguration>
      </libraries>
    </org.jenkinsci.plugins.workflow.libs.GlobalLibraries>
{{ end }}
