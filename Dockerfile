FROM oberthur/docker-ubuntu-java:jdk8_full_8.131.11

ENV SWARM_VERSION=3.3 \
  GRADLE_VERSION=3.5 \
  SBT_VERSION=0.13.15 \
  MAVEN_VERSION=3.5.0 \
  ANT_VERSION=1.10.1 \
  ANT_HOME=/usr/share/ant \
  GRADLE_HOME=/usr/share/gradle \
  SBT_HOME=/usr/share/sbt \
  MAVEN_HOME=/usr/share/maven \
  NPM_CONFIG_LOGLEVEL=info \
  _JAVA_OPTIONS="-Dsbt.log.noformat=true" \
  DOCKER_PATH=/opt/docker/bin

ENV PATH="$PATH:$DOCKER_PATH"

RUN apt-get update && apt-get install curl -y \
  && curl -o /opt/swarm-client-${SWARM_VERSION}-jar-with-dependencies.jar http://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.jar
COPY swarm_slave.sh /usr/bin/swarm_slave.sh
RUN chmod +x /usr/bin/swarm_slave.sh && mkdir -p /etc/supervisor/conf.d
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY cassandra.sources.list /etc/apt/sources.list.d/cassandra.sources.list

RUN curl -L http://debian.datastax.com/debian/repo_key | apt-key add - \

  # Make sure the package repository is up to date.
  && apt-get update \
  && apt-get install -y git supervisor openssh-client zip unzip wget bzip2 nodejs npm gitstats python-yaml python-jinja2 cassandra-tools rsync mariadb-client  \
  && npm install npm -g \
  && npm install -g bower \
  && ln -s /usr/bin/nodejs /usr/bin/node \

  # install gradle
  && curl -L https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-all.zip > /usr/share/gradle-$GRADLE_VERSION-all.zip \
  && unzip -d /usr/share/ /usr/share/gradle-$GRADLE_VERSION-all.zip \
  && ln -s /usr/share/gradle-$GRADLE_VERSION /usr/share/gradle \
  && rm /usr/share/gradle-$GRADLE_VERSION-all.zip \
  && ln -s /usr/share/gradle/bin/gradle /usr/bin/gradle \

  # adding RSYNC MC
  && apt-get install -y mc rsync \

  # adding BUILD-TOOLS
  && apt-get install -y build-essential \

  # adding docker-in-docker
  && mkdir -p $DOCKER_PATH \
  && apt-get install -y iptables kmod libnfnetlink0 module-init-tools \
  && echo "#!/bin/bash\n/bin/true" > $DOCKER_PATH/docker-in-docker.sh \

  # clean all cache to clean space
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean \
  && apt-get -y autoremove \

  # install maven
  && curl -fsSL http://apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \

  # install ant
  && curl -fsSL http://archive.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-ant-$ANT_VERSION /usr/share/ant \
  && ln -s /usr/share/ant/bin/ant /usr/bin/ant \

	# install sbt
  && mkdir -p $SBT_HOME \
  && curl -L https://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$SBT_VERSION/sbt-launch.jar > $SBT_HOME/sbt-launch.jar
  COPY sbt /usr/bin/sbt
  RUN chmod a+x /usr/bin/sbt \
  && sbt exit \
  && rm -fr /tmp/* \

  # install git flow
  && apt-get update && apt-get install -y git-flow --allow-unauthenticated  \

  # clean all cache to clean space
  && apt-get purge -y unzip \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean \
  && apt-get -y autoremove

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
