FROM armbuild/ubuntu

RUN apt-get update && apt-get install -y wget software-properties-common && apt-get clean

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

RUN \
	add-apt-repository -y ppa:webupd8team/java; \
	apt-get update; \
	apt-get install -y oracle-java8-installer; \
	apt-get clean; \
	rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN useradd -m -d /logstash-2.0.0 logstash

USER logstash

RUN \
	cd /; \
	wget -q -O /tmp/logstash.tar.gz https://download.elastic.co/logstash/logstash/logstash-2.0.0.tar.gz; \
	tar -zxf /tmp/logstash.tar.gz; \
	rm /tmp/logstash.tar.gz

# fix libjffi problem on arm
RUN \
    apt-get install -y ant git gcc make; \
    cd /tmp; \
    git clone --depth 1 https://github.com/jnr/jffi.git; \
    cd jffi; \
    ant jar; \
    cp -f build/jni/libjffi-1.2.so /logstash-2.0.0/vendor/jruby/lib/jni/arm-Linux/; \
    cd; \
    rm -Rf /tmp/jffi

USER root

ADD conf /conf

ENV ES_HEAP_SIZE 512M

ENTRYPOINT ["/logstash-2.0.0/bin/logstash", "agent", "-f", "/conf/logstash.conf"]
