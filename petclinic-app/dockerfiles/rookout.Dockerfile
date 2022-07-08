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
RUN curl -L "https://repository.sonatype.org/service/local/artifact/maven/redirect?r=central-proxy&g=com.rookout&a=rook&v=LATEST" -o rook.jar
ENV JAVA_TOOL_OPTIONS="-javaagent:./rook.jar -DROOKOUT_TOKEN=<rook_out_token> -DROOKOUT_LABELS=env:dev"
ENTRYPOINT [ "java", "-Dspring.profiles.active=rookout","-verbose:gc", "-Xloggc:/app/log/gc.log", "-XX:+PrintGCTimeStamps", "-XX:+PrintGCDateStamps",  "-jar", "petclinic-app.jar" ]
