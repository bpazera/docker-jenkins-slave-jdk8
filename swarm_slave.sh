#!/bin/bash
exec java -jar /opt/swarm-client-$SWARM_VERSION-jar-with-dependencies.jar \
     -disableClientsUniqueId -username $JENKINS_USERNAME -password $JENKINS_PASSWORD \
		 -mode ${JENKINS_MODE:-exclusive} -name $JENKINS_SLAVE_NAME -executors ${JENKINS_EXEC_NR:-1} \
		 -master ${JENKINS_URL:-127.0.0.1} -fsroot $JENKINS_FS_ROOT -labels "${JENKINS_LABELS:-swarm}"
