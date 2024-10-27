/*
 * ────────────────────────────────────────────────────────────────────────────────
 * Project: Interactive Game with Sound Effects and Visual Elements
 * Description: This code creates an interactive game with a colorful grid, sound effects,
 *              and visual animations. Players navigate a character to collect items while
 *              avoiding incorrect matches to maintain a high score.
 *
 * Created by: Luke KIM / KIM JUN YOUNG - 201920765
 * Date: October 10, 2024
 * ────────────────────────────────────────────────────────────────────────────────
 */

import processing.sound.*;  // Import Sound library

SoundFile backgroundMusic;
SoundFile eatSound;
SoundFile gameOverSound;
boolean loadingDone = false;  // Loading status

int gridSize = 20;  // Grid size
int cols, rows;     // Grid dimensions (width and height)
int playerX, playerY;  // Player position
int playerDirX = 1, playerDirY = 0;  // Player direction
int speed = 10;  // Default speed
int maxSpeed = 20;  // Maximum speed
int frameCounter = 0;  // Frame counter to control speed
int score = 0;  // Score variable

color[] colors = {color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), color(255, 255, 0)};
color currentColor;  // Current player color
ArrayList<Flower> flowers;  // Array to store flowers
boolean gameOver = false;
boolean hasPlayedGameOverSound = false;  // Flag to check if the game over sound has already been played
int safeDistance = 100;  // Minimum distance from character when spawning flowers
int borderMargin = 50;  // Margin for edges of the screen

PImage characterImg;
PImage flowerImg;
PImage backgroundImg;  // Background image variable

// Restart button position and size
int restartButtonX, restartButtonY, restartButtonW, restartButtonH;

void setup() {
  size(600, 600, P3D);  // Set screen size to 600x600
  cols = width / gridSize;
  rows = height / gridSize;
  
  characterImg = loadImage("resources/character.png");  // Load character image
  flowerImg = loadImage("resources/flower.png");  // Load flower image
  backgroundImg = loadImage("resources/background.png");  // Load background image
  
  // Set restart button position and size
  restartButtonW = 150;
  restartButtonH = 50;
  restartButtonX = (width - restartButtonW) / 2;
  restartButtonY = height / 2 + 50;
  
  // Load sound files (background thread loading)
  thread("loadSounds");

  initGame();  // Initialize game
}

void loadSounds() {
  backgroundMusic = new SoundFile(this, "resources/background.mp3");  // Load background music
  eatSound = new SoundFile(this, "resources/eat.wav");  // Load eating sound effect
  gameOverSound = new SoundFile(this, "resources/gameover.wav");  // Load game over sound effect
  backgroundMusic.loop();  // Loop background music
  loadingDone = true;  // Loading complete
}

void initGame() {
  // Initialize player position and color
  playerX = cols / 2 * gridSize;
  playerY = rows / 2 * gridSize;
  playerDirX = 1;
  playerDirY = 0;
  currentColor = randomColor();
  
  speed = 10;  // Reset default speed
  frameCounter = 0;
  score = 0;
  gameOver = false;  // Reset game over state
  hasPlayedGameOverSound = false;  // Reset game over sound flag
  
  // Initialize the list to store flowers
  flowers = new ArrayList<Flower>();
  spawnFlowers();  // Spawn initial flowers
}

// Called every frame
void draw() {
  if (!loadingDone) {
    drawLoadingScreen();  // Display loading screen
    return;
  }
  
  // Draw background image
  image(backgroundImg, 0, 0, width, height);  // Draw background image covering the screen
  
  if (gameOver) {
    displayGameOver();
    return;
  }
  
  // Display score
  displayScore();
  
  // Control player movement based on frame count and speed
  frameCounter++;
  if (frameCounter >= 60 / speed) {
    frameCounter = 0;
    movePlayer();
  }
  
  // Draw player
  drawCharacter();
  
  // Draw flowers
  for (Flower flower : flowers) {
    flower.show();
  }
  
  // Check for game over condition
  if (checkCollision()) {
    gameOver = true;
  }
  
  // Play game over sound (only when game over occurs for the first time)
  if (gameOver && !hasPlayedGameOverSound) {
    gameOverSound.play();  // Play game over sound
    hasPlayedGameOverSound = true;  // Mark sound as played
  }
}

// Function to draw loading screen
void drawLoadingScreen() {
  background(0);
  textAlign(CENTER, CENTER);
  fill(0, 255, 255);
  textSize(30);
  text("Loading...", width / 2, height - 50);

  pushMatrix();
  translate(width / 2, height / 2, 0);
  rotateY(frameCount * 0.01);
  rotateX(frameCount * 0.01);
  stroke(0, 255, 255);
  noFill();
  strokeWeight(3);
  box(150);
  popMatrix();
}

// Display final score and restart button on game over
void displayGameOver() {
  hint(DISABLE_DEPTH_TEST);  // Disable depth testing

  // Game over message
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(255, 0, 0);
  text("Game Over", width / 2, height / 2 - 50);
  
  // Display final score
  fill(0);
  textSize(24);
  text("Final Score: " + score, width / 2, height / 2);
  
  // Draw restart button
  fill(100, 100, 255);  // Button color
  stroke(0);  // Border color
  strokeWeight(2);  // Border thickness
  rect(restartButtonX, restartButtonY, restartButtonW, restartButtonH, 10);

  // Text alignment (vertically centered)
  float textY = restartButtonY + (restartButtonH / 2) + (textAscent() - textDescent()) / 2;
  textY -= 1;

  // Draw button text
  fill(255);  // Text color
  textSize(20);
  textAlign(CENTER);  // Center horizontal alignment
  text("Restart", restartButtonX + restartButtonW / 2, textY);  // Draw text centered vertically
  
  hint(ENABLE_DEPTH_TEST);  // Re-enable depth testing
}

// Display score in the top-left corner of the screen
void displayScore() {
  fill(0);
  textSize(24);
  textAlign(LEFT, TOP);
  text("Score: " + score, 10, 10);  // Display score at the top left
}

// Draw player with current color
void drawCharacter() {
  tint(currentColor);  // Tint character image with current color
  image(characterImg, playerX, playerY, gridSize, gridSize);  // Draw character image at player position
  noTint();  // Clear tint for other images
}

// Handle arrow key inputs
void keyPressed() {
  if (gameOver) return;  // Ignore arrow keys when game over
  
  if (keyCode == UP && playerDirY == 0) {
    playerDirX = 0;
    playerDirY = -1;
  } else if (keyCode == DOWN && playerDirY == 0) {
    playerDirX = 0;
    playerDirY = 1;
  } else if (keyCode == LEFT && playerDirX == 0) {
    playerDirX = -1;
    playerDirY = 0;
  } else if (keyCode == RIGHT && playerDirX == 0) {
    playerDirX = 1;
    playerDirY = 0;
  }
}

// Return a random color
color randomColor() {
  return colors[int(random(colors.length))];
}

// Handle player movement
void movePlayer() {
  playerX += playerDirX * gridSize;
  playerY += playerDirY * gridSize;
  
  // End game if player moves out of bounds
  if (playerX < 0 || playerX >= width || playerY < 0 || playerY >= height) {
    gameOver = true;
    return;
  }
  
  // Check if player eats a flower
  for (int i = flowers.size() - 1; i >= 0; i--) {
    Flower flower = flowers.get(i);
    if (flower.x == playerX && flower.y == playerY) {
      if (flower.c == currentColor) {
        flowers.remove(i);  // Remove eaten flower
        currentColor = randomColor();  // Change color
        if (speed < maxSpeed) {  // Increase speed if below max
          speed++;  
        }
        score++;  // Increase score
        spawnFlowers();  // Respawn all flowers
        
        eatSound.play();  // Play eating sound effect
      } else {
        gameOver = true;  // End game if color does not match
      }
      break;
    }
  }
}

// Spawn new flowers, ensuring they don't spawn too close to the player or overlap with existing flowers
void spawnFlowers() {
  flowers.clear();  // Clear current flower list
  
  // Add flower with player color
  boolean playerFlowerSpawned = false;
  int attempts = 0;  // Max number of spawn attempts
  
  while (!playerFlowerSpawned && attempts < 100) {  // Attempt up to 100 times
    Flower playerFlower = new Flower(currentColor);
    
    // Check for valid spawn position
    if (dist(playerFlower.x, playerFlower.y, playerX, playerY) >= safeDistance && 
        playerFlower.x > borderMargin && playerFlower.x < width - borderMargin &&
        playerFlower.y > borderMargin && playerFlower.y < height - borderMargin &&
        !isFlowerAtLocation(playerFlower.x, playerFlower.y)) {  // Check for overlapping positions
      flowers.add(playerFlower);
      playerFlowerSpawned = true;  // Successfully spawned player flower
    }
    attempts++;
  }

  // Spawn additional flowers (one of each color)
  for (int i = 0; i < 3; i++) {  // Control number of flowers (4 total)
    Flower flower;
    boolean validFlower = false;
    attempts = 0;  // Reset max attempts

    // Repeat until a valid spawn position is found
    while (!validFlower && attempts < 100) {  // Attempt up to 100 times
      flower = new Flower(randomColor());
      
      if (dist(flower.x, flower.y, playerX, playerY) >= safeDistance && 
          flower.x > borderMargin && flower.x < width - borderMargin &&
          flower.y > borderMargin && flower.y < height - borderMargin &&
          !isFlowerAtLocation(flower.x, flower.y)) {  // Check for overlapping positions
        flowers.add(flower);
        validFlower = true;  // Successfully spawned flower
      }
      attempts++;
    }
  }
}

// Check if a flower already exists at a given location
boolean isFlowerAtLocation(int x, int y) {
  for (Flower flower : flowers) {
    if (flower.x == x && flower.y == y) {
      return true;  // Flower exists at this location
    }
  }
  return false;  // No flower at this location
}

// Check for player collision with flowers
boolean checkCollision() {
  for (Flower flower : flowers) {
    if (flower.x == playerX && flower.y == playerY) {
      return true;  // Collision detected
    }
  }
  return false;  // No collision
}

// Flower class
class Flower {
  int x, y;  // Flower position
  color c;  // Flower color
  
  Flower(color flowerColor) {
    this.c = flowerColor;
    // Generate random position for flower
    this.x = int(random(borderMargin, width - borderMargin) / gridSize) * gridSize;
    this.y = int(random(borderMargin, height - borderMargin) / gridSize) * gridSize;
  }
  
  void show() {
    tint(c);  // Apply tint with flower color
    image(flowerImg, x, y, gridSize, gridSize);  // Draw flower image
    noTint();  // Clear tint for other drawings
  }
}

// Restart game on mouse click
void mousePressed() {
  // Check if click is within restart button area
  if (gameOver && mouseX > restartButtonX && mouseX < restartButtonX + restartButtonW &&
      mouseY > restartButtonY && mouseY < restartButtonH + restartButtonY) {
    initGame();  // Reinitialize game
  }
}
