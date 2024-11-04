# 🐍 Modern Snake Game

A modern implementation of the classic Snake game built with Spring Boot and HTML5 Canvas, featuring real-time leaderboard, multiple difficulty levels, and smooth animations.

![Snake Game Preview](src/main/resources/static/images/apple.png)

## ✨ Features

### 🎮 Game Features
- Multiple difficulty levels (Easy, Medium, Hard)
- Smooth snake animations and visual effects
- Real-time score tracking
- Pause functionality (Press 'P')
- Mobile-responsive design with touch controls
- Player profiles with nicknames

### 🏆 Leaderboard System
- Persistent leaderboard stored in JSON
- One high score per player
- Top 10 scores display
- Score tracking by difficulty level
- Real-time updates

### 🎨 Visual Effects
- Smooth snake movement animations
- Wave effect when eating food
- Scaling animations for growth
- Responsive grid system
- Modern UI design with gradients

## 🏗️ Architecture

### Frontend
- HTML5 Canvas for game rendering
- Modern CSS3 with Flexbox
- Vanilla JavaScript with ES6+ features
- Responsive design for mobile support

### Backend
- Spring Boot for server-side logic
- RESTful API for leaderboard management
- JSON file storage for persistence
- Thymeleaf templating engine

## 🚀 Getting Started

### Prerequisites
- Docker and Docker Compose
- Java 17 (for local development)
- Maven (for local development)

### 🐳 Docker Setup (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/snake-game.git
   cd snake-game
   ```

2. Build and run with Docker Compose:
   ```bash
   docker-compose up -d --build
   ```

3. Access the game:
   ```
   http://localhost:8080/game
   ```

### 🛠️ Local Development Setup

1. Build the project:
   ```bash
   ./mvnw clean install
   ```

2. Run the application:
   ```bash
   ./mvnw spring-boot:run
   ```

3. Access the game at `http://localhost:8080/game`

## 🎮 How to Play

1. Enter your nickname and select difficulty level
2. Use arrow keys (desktop) or touch controls (mobile) to control the snake
3. Eat apples to grow and score points
4. Avoid walls and your own tail
5. Press 'P' to pause the game
6. Try to get on the leaderboard!

## 🔧 Game Controls

### Desktop
- ⬆️ Up Arrow: Move Up
- ⬇️ Down Arrow: Move Down
- ⬅️ Left Arrow: Move Left
- ➡️ Right Arrow: Move Right
- P: Pause Game

### Mobile
- Touch controls available on screen
- Responsive buttons for all directions

## 🏗️ Project Structure

```
snake-game/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/snake/
│   │   │       ├── controller/
│   │   │       │   └── GameController.java
│   │   │       └── SnakeApplication.java
│   │   └── resources/
│   │       ├── static/
│   │       │   ├── images/
│   │       │   │   └── apple.png
│   │       │   └── leaderboard.json
│   │       └── templates/
│   │           └── game.html
├── Dockerfile
├── docker-compose.yml
└── pom.xml
```

## 🔒 Security Features

- Non-root user in Docker container
- Resource limits and monitoring
- Secure volume management
- Health checks implementation

## ⚙️ Configuration

### Docker Environment Variables
```yaml
SPRING_PROFILES_ACTIVE: prod
SERVER_PORT: 8080
TZ: UTC
JAVA_OPTS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0
```

### Resource Limits
```yaml
limits:
  memory: 512M
reservations:
  memory: 256M
```

## 🔍 Monitoring

- Health checks every 30 seconds
- Log rotation with 10MB max size
- Container resource monitoring
- Application metrics via Spring Boot

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Classic Snake game inspiration
- Spring Boot framework
- Docker community
- Open source community
