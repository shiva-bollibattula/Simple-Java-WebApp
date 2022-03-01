FROM tomcat
COPY target/webapp.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD apache-tomcat-8.0.20/bin/startup.sh && tail -f apache-tomcat-8.0.20/logs/catalina.out