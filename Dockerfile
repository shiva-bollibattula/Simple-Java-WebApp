FROM ubuntu:latest

WORKDIR /opt

RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*
RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.59/bin/apache-tomcat-9.0.59.tar.gz
RUN tar -xzvf apache-tomcat-9.0.59.tar.gz
RUN mv apache-tomcat-9.0.59 tomcat
RUN apt-get install -y openjdk-11-jdk
RUN java -version

COPY target/webapp.war tomcat/webapps/

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]