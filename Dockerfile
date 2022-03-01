FROM ubuntu:latest

RUN apt-get update && apt-get install -y openjdk-8-jdk

WORKDIR /usr/local/bin/

COPY target/webapp.jar .

#CMD ["/bin/bash"]

ENTRYPOINT ["java", "-jar", "webapp.jar"]
