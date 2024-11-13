# Stage 1: Build environment
FROM maven:3.8.4-openjdk-17 AS builder

# Set working directory
WORKDIR /build

# Copy Maven files first for better layer caching
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Make mvnw executable
RUN chmod +x mvnw

# Download dependencies (this layer will be cached)
RUN --mount=type=cache,target=/root/.m2 ./mvnw dependency:go-offline -B

# Copy source code
COPY src src

# Build the application
RUN --mount=type=cache,target=/root/.m2 ./mvnw package -DskipTests -B

# Stage 2: Runtime environment
FROM openjdk:17-slim

# Set working directory
WORKDIR /app

# Install curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring

# Set ownership and permissions
RUN mkdir -p /app/logs && \
    chown -R spring:spring /app

# Copy the built artifact from builder stage
COPY --from=builder --chown=spring:spring /build/target/*.jar app.jar

# Switch to non-root user
USER spring:spring

# Set healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/game || exit 1

# Set JVM options as environment variable
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC -Djava.security.egd=file:/dev/./urandom"

# Run the application
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar app.jar" ]
