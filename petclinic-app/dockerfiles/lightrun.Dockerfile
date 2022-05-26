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
WORKDIR /app
EXPOSE 8080
ENV LIGHTRUN_KEY=6f8e9878-fe56-4f19-acd1-44e9d5b298d9
RUN bash -c "$(curl -L "https://app.lightrun.com/download/company/d067f4eb-3bb0-4fe4-9bd7-900bc0e996ef/install-agent.sh?platform=openjdk:8")"
ENTRYPOINT [ "java", "-agentpath:./agent/lightrun_agent.so", "-Dspring.profiles.active=lightrun", "-verbose:gc", "-Xloggc:/app/log/gc.log", "-XX:+PrintGCTimeStamps", "-XX:+PrintGCDateStamps", "-jar", "petclinic-app.jar" ]
