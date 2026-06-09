# Build Stage
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
# Download dependencies first to cache them
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

# Run Stage
FROM tomcat:10.1-jdk17
# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*
# Copy WAR file to Tomcat webapps
COPY --from=build /app/target/bookstore.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
