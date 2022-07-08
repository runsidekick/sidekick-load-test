FROM maven:3.6.1-jdk-8-alpine AS BUILD
WORKDIR /usr/src/app
COPY ../pom.xml .
COPY petclinic-app/pom.xml petclinic-app/
RUN mvn dependency:go-offline -B
WORKDIR /usr/src/app/petclinic-app
COPY petclinic-app/src src
RUN mvn clean package -DskipTests

FROM openjdk:8
RUN mkdir -p /app
COPY --from=BUILD /usr/src/app/petclinic-app/target/petclinic-app-1.0.0.jar /app/petclinic-app.jar
ADD sidekick-agent-bootstrap.jar /app/sidekick-agent-bootstrap.jar
WORKDIR /app
EXPOSE 8080
ENTRYPOINT [ "java", "-Dspring.profiles.active=sidekick", "-javaagent:sidekick-agent-bootstrap.jar", "-verbose:gc", "-Xloggc:/app/log/gc.log", "-XX:+PrintGCTimeStamps", "-XX:+PrintGCDateStamps", "-jar", "petclinic-app.jar" ]
