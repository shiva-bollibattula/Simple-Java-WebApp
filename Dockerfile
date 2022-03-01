FROM openjdk:8u131-jdk-alpine

EXPOSE 8080

WORKDIR /user/local/bin

COPY target/webapp.jar webapp.jar

ENV JAVA_OPTS="-Dspring.profiles.active=docker-demo"

CMD ["java","-Dspring.profiles.active=docker-demo", "-jar", "webapp.jar"]