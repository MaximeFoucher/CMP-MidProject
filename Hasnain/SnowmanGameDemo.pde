import processing.sound.*;

SoundFile backgroundMusic;
SoundFile catchIceSound;
SoundFile catchSnowflakeSound;

PImage backgroundImg;
PImage snowmanImg;
PImage meltedSnowmanImg;
PImage iceImg;
PImage snowflakeImg;

float snowmanX;
float snowmanY;
float snowmanSpeed;
float snowmanSize = 100;
float snowmanHealth;
int score;
boolean gameOver = false;
boolean loading = false;

int maxFallingObjects = 50;
float[] objectX = new float[maxFallingObjects];
float[] objectY = new float[maxFallingObjects];
boolean[] isIce = new boolean[maxFallingObjects];
float objectSpeed = 2;
int numFallingObjects = 5;  
int maxObjectsAllowed = 20;  
int increaseRate = 300;      

// Object sizes
float iceSize = 40;
float snowflakeSize = 50;

// Time variables
int gameTime = 0;

// Particle system variables
ArrayList<Particle> particles = new ArrayList<Particle>();
int maxParticles = 100;

void setup() {
  size(600, 600);
  
  // Load images
  backgroundImg = loadImage("snowBG.png");
  snowmanImg = loadImage("snowman.png");
  meltedSnowmanImg = loadImage("meltedSnowman.png");
  iceImg = loadImage("IceCube.png");
  snowflakeImg = loadImage("snowflake.png");
  

  backgroundMusic = new SoundFile(this, "backgroundMusic.mp3");
  catchIceSound = new SoundFile(this, "catchSnowSound.mp3");
  catchSnowflakeSound = new SoundFile(this, "catchSnowFlakeSound.mp3");


  backgroundMusic.loop();  
  

  snowmanX = width / 2;
  snowmanY = height - 50;
  snowmanSpeed = 3;
  snowmanHealth = 100;
  score = 0;
  

  for (int i = 0; i < maxFallingObjects; i++) {
    resetFallingObject(i);
  }
}

void draw() {

  gameTime++;
  
  
  if (gameTime % increaseRate == 0 && numFallingObjects < maxObjectsAllowed) {
    numFallingObjects++; // increase falling objects
  }

  // Draw background image
  image(backgroundImg, 0, 0, width, height);


  if (!gameOver) {
    moveSnowman();
    drawSnowman(snowmanX, snowmanY, snowmanSize);
    generateParticles(snowmanX, snowmanY);
    updateParticles();
  }
 else {
   
    drawMeltedSnowman(snowmanX, snowmanY, snowmanSize);
  }

  
  for (int i = 0; i < numFallingObjects; i++) {
    if (isIce[i]) {
      image(iceImg, objectX[i], objectY[i], iceSize, iceSize); // draw ice cubes
    } else {
      image(snowflakeImg, objectX[i], objectY[i], snowflakeSize, snowflakeSize); // draw snowflakes
    }
    
    objectY[i] += objectSpeed; 
    

    if (!gameOver && dist(objectX[i], objectY[i], snowmanX, snowmanY) < snowmanSize / 2) {
      if (isIce[i]) {
        snowmanHealth += 5;
        snowmanSpeed += 0.5;
        playCatchIceSound(); 
      } else {
        score += 10; 
        playCatchSnowflakeSound(); 
      }
      resetFallingObject(i); 
    }
    

    if (objectY[i] > height) {
      if (!gameOver && isIce[i]) {
        snowmanHealth -= 10;
        snowmanSpeed -= 0.5;
      }
      resetFallingObject(i);
    }
  }


  snowmanSpeed = constrain(snowmanSpeed, 1, 10);
  snowmanHealth = constrain(snowmanHealth, 0, 100);
  
  // Display score and health
  fill(0);
  textSize(18);
  text("Score: " + score, 10, 30);
  text("Health: " + snowmanHealth, 10, 50);


  if (snowmanHealth <= 0 && !gameOver) {
    gameOver = true; 
  }

 
  if (gameOver) {
    textSize(32);
    fill(255, 0, 0);
    text("Game Over", width / 2 - 80, height / 2);
  }
}


void moveSnowman() {
  if (keyPressed) {
    if (keyCode == LEFT) {
      snowmanX -= snowmanSpeed;
    } else if (keyCode == RIGHT) {
      snowmanX += snowmanSpeed;
    }
  }
  snowmanX = constrain(snowmanX, snowmanSize / 2, width - snowmanSize / 2); 
}

// Draw the normal snowman
void drawSnowman(float x, float y, float size) {
  image(snowmanImg, x - size / 2, y - size, size, size); 
}


void drawMeltedSnowman(float x, float y, float size) {
  image(meltedSnowmanImg, x - size / 2, y - size, size, size); 
}


void resetFallingObject(int i) {
  objectX[i] = random(20, width - 20); 
  objectY[i] = random(-200, -20);      
  isIce[i] = random(1) > 0.3;          
}


class Particle {
  float x, y, size;
  float life; // lifespan of particle
  color c;

  Particle(float x, float y) {
    this.x = x;
    this.y = y;
    this.size = random(4, 8); // Random size
    this.life = 255; 
    this.c = color(255, random(200, 255), random(200, 255)); 
  }


  void update() {
    this.y += random(-1, 1); 
    this.x += random(-1, 1); 
    this.life -= 4;
  }


  void display() {
    noStroke();
    fill(this.c, this.life); 
    ellipse(this.x, this.y, this.size, this.size);
  }


  boolean isDead() {
    return this.life <= 0;
  }
}


void generateParticles(float x, float y) {
  for (int i = 0; i < 5; i++) { 
    if (particles.size() < maxParticles) {
      particles.add(new Particle(x, y)); 
    }
  }
}


void updateParticles() {
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isDead()) {
      particles.remove(i); 
    }
  }
}


void playCatchIceSound() {
  catchIceSound.play(); 
}


void playCatchSnowflakeSound() {
  catchSnowflakeSound.play(); }
