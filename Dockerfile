# Stage 1: Download and cache Maven dependencies
FROM eclipse-temurin:17-jdk-alpine as dependencies
WORKDIR /workspace/app
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn
RUN chmod +x mvnw
# Download dependencies only (this layer will be cached)
RUN ./mvnw dependency:go-offline -B

# Stage 2: Build the application
FROM dependencies as build
COPY src src
# Build with cached dependencies
RUN ./mvnw package -DskipTests -B \
    && mkdir -p target/extracted \
    && java -Djarmode=layertools -jar target/*.jar extract --destination target/extracted

# Stage 3: Create optimized runtime image
FROM eclipse-temurin:17-jre-alpine as runtime
WORKDIR /app

# Install necessary runtime packages
RUN apk add --no-cache tzdata curl

# Create non-root user for security
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy layers from build stage in the correct order for better caching
COPY --from=build --chown=spring:spring /workspace/app/target/extracted/dependencies/ ./
COPY --from=build --chown=spring:spring /workspace/app/target/extracted/spring-boot-loader/ ./
COPY --from=build --chown=spring:spring /workspace/app/target/extracted/snapshot-dependencies/ ./
COPY --from=build --chown=spring:spring /workspace/app/target/extracted/application/ ./

# Runtime configuration
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/game || exit 1

# Start the application with optimized JVM settings
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.JarLauncher"]
