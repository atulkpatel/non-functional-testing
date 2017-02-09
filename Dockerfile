# A image with apache-jmeter-2.13
FROM atulkpatel/non-functional-base:0.0.1
MAINTAINER Atul Patel <atulkpatel 4t yahoo dot com>

# Copy user.properties
# ADD user.properties $JMETER_PATH/apache-jmeter-$JMETER_VERSION/bin/
ENV JMETER_VERSION 2.13
ENV PLUGINS_VERSION 1.3.1
ENV JMETER_PATH /srv/var/jmeter
ENV PLUGINS_PATH $JMETER_PATH/plugins
ENV NON_FUNC /srv/var/jmeter/non-functional-tests
ENV JMETER_HOME=$NON_FUNC
ENV JMETER_BIN=$JMETER_PATH/apache-jmeter-$JMETER_VERSION/bin

RUN mkdir -p $NON_FUNC/logs
RUN mkdir -p $NON_FUNC/scripts
RUN mkdir -p $NON_FUNC/test-cases/sample-upload-files
 
ADD user.properties $JMETER_BIN/
ADD scripts/perf_jmeter.sh $NON_FUNC/scripts/
ADD scripts/jtlmin.sh $NON_FUNC/scripts/
ADD test-cases/perf_login.jmx $NON_FUNC/test-cases/
ADD test-cases/sample-upload-files/testfile.jpg $NON_FUNC/test-cases/sample-upload-files/
ADD docker-entrypoint.sh /
 
ENTRYPOINT ["/docker-entrypoint.sh"]
