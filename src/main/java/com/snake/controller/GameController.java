package com.snake.controller;

import org.springframework.core.io.ClassPathResource;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

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
            return new String(Files.readAllBytes(Paths.get(resource.getURI())), StandardCharsets.UTF_8);
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
            return ResponseEntity.internalServerError().body("{\"status\":\"error\",\"message\":\"" + e.getMessage() + "\"}");
        }
    }
}
