# MULTISTAGE Build
FROM gradle:6.0.1-jdk11 AS builder
WORKDIR /opt/java/
COPY . /opt/java/

ARG RATINGS_SERVICE
ARG ENABLE_RATINGS
ARG SERVICE_VERSION
ARG STAR_COLOR
ENV RATINGS_SERVICE ${RATINGS_SERVICE:-http://ratings:8081}
ENV ENABLE_RATINGS ${ENABLE_RATINGS:-true}
ENV SERVICE_VERSION ${SERVICE_VERSION:-v1}
ENV SERVICE_VERSION ${STAR_COLOR:-red}

RUN gradle clean build

# MULTISTAGE Run
FROM websphere-liberty:19.0.0.12-kernel-java8-ibmjava

# Copy .jar file from build stage
COPY --from=builder /opt/java/build/libs/java.war /opt/ibm/wlp/usr/servers/defaultServer/apps/reviews.war
# Copy server configuration
COPY config/server.xml /opt/ibm/wlp/usr/servers/defaultServer/

RUN /opt/ibm/wlp/bin/installUtility install  --acceptLicense /opt/ibm/wlp/usr/servers/defaultServer/server.xml

CMD ["/opt/ibm/wlp/bin/server", "run", "defaultServer"]
