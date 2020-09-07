{{- define "ibm-ea-asm-normalizer.generate_kafka_ssl_helper"}}
echo "Executing command to generate kakfa certificates..." &&
echo -e "#!/bin/bash \n
. /opt/kafka/bin/generate_certificate.sh \n
OUTPUT_DIR=\"/opt/secureconfig\" \n
generate_service_certificate_and_stores TEST_SERVICE \${CA_CERTIFICATE} \${CA_KEY} \${OUTPUT_DIR} \n
generate_kafka_client_properties /opt/secureconfig" > /tmp/generate_certificate.sh &&

cat /tmp/generate_certificate.sh &&
chmod +x /tmp/generate_certificate.sh &&
echo "Generating the certificates..." &&
/tmp/generate_certificate.sh &&

echo "group.id=${KAFKA_GROUP_ID}" >> /opt/secureconfig/secure.properties &&
echo "bootstrap.servers=${ASM_KAFKA_IN_HOSTNAME}:${ASM_KAFKA_IN_PORT}" >> /opt/secureconfig/secure.properties &&
echo "ssl.endpoint.identification.algorithm=" >> /opt/secureconfig/secure.properties &&

echo "bootstrap.servers=${KAFKA_OUT_BOOTSTRAP_SERVERS}" > /tmp/producer.config &&
echo "Executing kafka mirror maker for secure connection on-prems" &&
/opt/kafka/bin/kafka-mirror-maker.sh \
 --consumer.config /opt/secureconfig/secure.properties \
 --producer.config /tmp/producer.config \
 --abort.on.send.failure true \
 --whitelist ${KAFKA_TOPIC_NAME}
{{- end }}
