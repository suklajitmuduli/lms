FROM openjdk:8-jdk-alpine

RUN mkdir -p /app

COPY ./target/api-lms-*.jar /app/app.jar

ENTRYPOINT ["java","-jar","/app/app.jar", "--spring.profiles.active=awsmumbai"]