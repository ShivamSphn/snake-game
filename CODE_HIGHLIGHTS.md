# Important Code Parts - Snake Game

## 1. Project Setup and Dependencies

### Maven Configuration (pom.xml)
```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.7.0</version>
    <relativePath/>
</parent>

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-thymeleaf</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-websocket</artifactId>
    </dependency>
</dependencies>
```

### Docker Configuration (Dockerfile)
```dockerfile
# Stage 1: Build environment
FROM maven:3.8.4-openjdk-17-slim as builder
WORKDIR /build
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN chmod +x mvnw
RUN --mount=type=cache,target=/root/.m2 ./mvnw dependency:go-offline -B
COPY src src
RUN --mount=type=cache,target=/root/.m2 ./mvnw package -DskipTests -B

# Stage 2: Runtime environment
FROM eclipse-temurin:17-jre-slim
WORKDIR /app
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
```

### Docker Compose Configuration (docker-compose.yml)
```yaml
version: '3.8'
services:
  snake-game:
    build: 
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - JAVA_OPTS=-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC
    deploy:
      resources:
        limits:
          memory: 768M
          cpus: '1'
```

## 2. Backend Implementation

### Main Application (SnakeApplication.java)
```java
@SpringBootApplication
public class SnakeApplication {
    public static void main(String[] args) {
        SpringApplication.run(SnakeApplication.class, args);
    }
}
```

### Game Controller (GameController.java)
```java
@Controller
public class GameController {
    @GetMapping("/game")
    public String game() {
        return "game";
    }

    @GetMapping("/leaderboard.json")
    @ResponseBody
    public String getLeaderboard() throws IOException {
        try {
            ClassPathResource resource = new ClassPathResource("static/leaderboard.json");
            return new String(Files.readAllBytes(Paths.get(resource.getURI())), 
                            StandardCharsets.UTF_8);
        } catch (IOException e) {
            return "{\"scores\":[]}";
        }
    }

    @PostMapping("/leaderboard.json")
    @ResponseBody
    public ResponseEntity<String> updateLeaderboard(@RequestBody String leaderboardData) {
        try {
            ClassPathResource resource = new ClassPathResource("static/leaderboard.json");
            Path path = Paths.get(resource.getURI());
            Files.write(path, leaderboardData.getBytes(StandardCharsets.UTF_8));
            return ResponseEntity.ok().body("{\"status\":\"success\"}");
        } catch (IOException e) {
            return ResponseEntity.internalServerError()
                   .body("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}");
        }
    }
}
```

## 3. Frontend Implementation

### Core Game Classes

#### Tile Class
```javascript
class Tile {
    constructor(x, y) {
        this.x = x;
        this.y = y;
        this.scale = 1;
        this.targetScale = 1;
    }
}
```

#### LeaderboardManager Class
```javascript
class LeaderboardManager {
    constructor() {
        this.scores = new Map();
        this.loadScores();
    }

    async loadScores() {
        try {
            const response = await fetch('/leaderboard.json');
            const data = await response.json();
            this.scores.clear();
            data.scores.forEach(entry => {
                const existingScore = this.scores.get(entry.nickname);
                if (!existingScore || entry.score > existingScore.score) {
                    this.scores.set(entry.nickname, entry);
                }
            });
            this.updateLeaderboardDisplay();
        } catch (error) {
            console.error('Error loading leaderboard:', error);
            this.scores.clear();
        }
    }
}
```

### Game Logic

#### Game Initialization
```javascript
function initGame() {
    snake = Array(3).fill().map((_, i) => new Tile(5 - i, 5));
    food = new Tile(10, 10);
    velocityX = 1;
    velocityY = 0;
    score = 0;
    gameOver = false;
    isPaused = false;
    foodAnimation = 0;
    
    setDifficulty();
    placeFood();
    if (gameLoop) clearInterval(gameLoop);
    gameLoop = setInterval(update, gameSpeed);
}
```

#### Game Update Logic
```javascript
function update() {
    if (gameOver || isPaused) return;

    // Update snake scales
    snake.forEach(segment => {
        segment.scale += (segment.targetScale - segment.scale) * 0.2;
    });

    // Move snake body
    for (let i = snake.length - 1; i > 0; i--) {
        snake[i] = new Tile(snake[i-1].x, snake[i-1].y);
        snake[i].scale = snake[i-1].scale;
        snake[i].targetScale = 1;
    }

    // Move snake head
    const newHead = new Tile(
        snake[0].x + velocityX,
        snake[0].y + velocityY
    );
    newHead.scale = snake[0].scale;
    newHead.targetScale = 1.2;
    snake[0] = newHead;
}
```

### Drawing Functions

#### Snake Drawing
```javascript
function drawSnakeSegment(x, y, isHead, scale) {
    ctx.save();
    ctx.translate(x * tileSize + tileSize/2, y * tileSize + tileSize/2);
    ctx.scale(scale, scale);
    ctx.translate(-(x * tileSize + tileSize/2), -(y * tileSize + tileSize/2));

    if (isHead) {
        // Snake head
        ctx.fillStyle = '#4ecca3';
        ctx.beginPath();
        ctx.roundRect(x * tileSize, y * tileSize, tileSize - 2, tileSize - 2, 8);
        ctx.fill();
        
        // Eyes
        ctx.fillStyle = '#1a1a2e';
        let eyeX1, eyeX2, eyeY;
        if (velocityX === 1) {
            eyeX1 = x * tileSize + tileSize - 8;
            eyeX2 = eyeX1;
            eyeY = y * tileSize + 6;
        }
        // ... eye positioning logic
    }
}
```

#### Food Drawing
```javascript
function drawApple(x, y) {
    ctx.save();
    if (foodAnimation > 0) {
        ctx.translate(x * tileSize + tileSize/2, y * tileSize + tileSize/2);
        ctx.scale(1 + foodAnimation * 0.3, 1 + foodAnimation * 0.3);
        ctx.translate(-(x * tileSize + tileSize/2), -(y * tileSize + tileSize/2));
        foodAnimation = Math.max(0, foodAnimation - 0.1);
    }
    // Apple body
    ctx.fillStyle = '#ff2e63';
    ctx.beginPath();
    ctx.arc(x * tileSize + tileSize/2, y * tileSize + tileSize/2, 
            tileSize/2 - 2, 0, Math.PI * 2);
    ctx.fill();
    // Leaf
    ctx.fillStyle = '#4ecca3';
    ctx.beginPath();
    ctx.ellipse(x * tileSize + tileSize/2, y * tileSize + 2, 
                tileSize/6, tileSize/4, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
}
```

### Game Controls

#### Keyboard Controls
```javascript
function handleKeydown(e) {
    if (gameOver) return;

    if (e.key === 'p' || e.key === 'P') {
        togglePause();
        return;
    }

    if (isPaused) return;

    switch(e.key) {
        case 'ArrowUp':
            if (velocityY !== 1) {
                velocityX = 0;
                velocityY = -1;
            }
            break;
        case 'ArrowDown':
            if (velocityY !== -1) {
                velocityX = 0;
                velocityY = 1;
            }
            break;
        case 'ArrowLeft':
            if (velocityX !== 1) {
                velocityX = -1;
                velocityY = 0;
            }
            break;
        case 'ArrowRight':
            if (velocityX !== -1) {
                velocityX = 1;
                velocityY = 0;
            }
            break;
    }
}
```

### Responsive Design CSS
```css
@media (max-width: 768px) {
    canvas {
        max-width: 90vw;
        max-height: 90vw;
    }
    #mobileControls {
        display: flex;
    }
    .menu {
        width: 90vw;
    }
    #leaderboard {
        width: 90vw;
    }
}
```

These code snippets represent the core functionality of the Snake Game, including:
- Project configuration and setup
- Backend API endpoints
- Game logic and state management
- Drawing and animation functions
- User input handling
- Responsive design implementation
