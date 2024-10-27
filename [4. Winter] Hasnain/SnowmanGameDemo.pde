//Hasnain Saroya - 202432591
//import sound library
import processing.sound.*;

//add all sounds to game 
SoundFile backgroundMusic;
SoundFile catchIceSound;
SoundFile catchSnowflakeSound;

//add all images to game
PImage backgroundImg;
PImage snowmanImg;
PImage meltedSnowmanImg;
PImage iceImg;
PImage snowflakeImg;

//initialize variables
float snowmanX;
float snowmanY;
float snowmanSpeed;
float snowmanSize = 100;
float snowmanHealth;
int score;
boolean gameOver = false;
boolean loading = false; //track if game started

//create threshold for amount of objects that can fall
int maxFallingObjects = 50;
//create two different types of objects that can fall - ice and snowflake
float[] objectX = new float[maxFallingObjects];
float[] objectY = new float[maxFallingObjects];
//check which type of object is falling
boolean[] isIce = new boolean[maxFallingObjects];
float objectSpeed = 2; //object falling speed
int numFallingObjects = 5; //start with this number of objects falling
int maxObjectsAllowed = 20; //max amount of of objects that can fall 
int increaseRate = 300; //increase objects every 300 frames

// object sizes
float iceSize = 40;
float snowflakeSize = 50;

// time variables
int gameTime = 0;

// particle system variables
ArrayList<Particle> particles = new ArrayList<Particle>();
int maxParticles = 100;

//create window size for game
void setup() {
  size(600, 600);
  
  // Load images into game
  backgroundImg = loadImage("snowBG.png");
  snowmanImg = loadImage("snowman.png");
  meltedSnowmanImg = loadImage("meltedSnowman.png");
  iceImg = loadImage("IceCube.png");
  snowflakeImg = loadImage("snowflake.png");
  
  // load music into game
  backgroundMusic = new SoundFile(this, "backgroundMusic.mp3");
  catchIceSound = new SoundFile(this, "catchSnowSound.mp3"); //play sound when ice is caught
  catchSnowflakeSound = new SoundFile(this, "catchSnowFlakeSound.mp3"); //play sound when snowflake is caught

 //loop background music so that it doesn't stop mid-game.
  backgroundMusic.loop();  
  
  //initialize the snowman with default settings
  snowmanX = width / 2;
  snowmanY = height - 50;
  snowmanSpeed = 3;
  snowmanHealth = 100;
  score = 0;
  
  //initialize the objects falling
  for (int i = 0; i < maxFallingObjects; i++) {
    resetFallingObject(i);
  }
}

void draw() {

  gameTime++;
  
  //controls the falling objects
  if (gameTime % increaseRate == 0 && numFallingObjects < maxObjectsAllowed) {
    numFallingObjects++; // increase falling objects
  }

  // Draw background image
  image(backgroundImg, 0, 0, width, height);

  //indicates to create particles and allow snowman to move when game is active
  if (!gameOver) {
    moveSnowman();
    drawSnowman(snowmanX, snowmanY, snowmanSize);
    generateParticles(snowmanX, snowmanY);
    updateParticles();
  }
 else {
   
    drawMeltedSnowman(snowmanX, snowmanY, snowmanSize); //causes the game to end
  }

  //updates the falling objects
  for (int i = 0; i < numFallingObjects; i++) {
    if (isIce[i]) {
      image(iceImg, objectX[i], objectY[i], iceSize, iceSize); // draw ice cubes
    } else {
      image(snowflakeImg, objectX[i], objectY[i], snowflakeSize, snowflakeSize); // draw snowflakes
    }
    
    objectY[i] += objectSpeed; 
    
    //check when the objects collide with the snowman
    if (!gameOver && dist(objectX[i], objectY[i], snowmanX, snowmanY) < snowmanSize / 2) {
      if (isIce[i]) {
        snowmanHealth += 5; //add to snowman health when ice is caught
        snowmanSpeed += 0.5; //add to snowman speed when ice is caught
        playCatchIceSound(); //play sound when ice is caught 
      } else {
        score += 10; //add extra points to score when snowflake is caught
        playCatchSnowflakeSound(); //play sound when snowflake is caught
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

  
  snowmanSpeed = constrain(snowmanSpeed, 1, 10); // check snowmans speed - cannot exceed 10
  snowmanHealth = constrain(snowmanHealth, 0, 100); //check snowmans health does not exceed 100
  
  // Display score and health
  fill(0);
  textSize(18);
  text("Score: " + score, 10, 30);
  text("Health: " + snowmanHealth, 10, 50);

  //check whether the snowman has melted
  if (snowmanHealth <= 0 && !gameOver) {
    gameOver = true; 
  }

   //displays game over screen
  if (gameOver) {
    textSize(32);
    fill(255, 0, 0);
    text("Game Over", width / 2 - 80, height / 2);
  }
}

//used to control how the snowman is moved by the player
void moveSnowman() {
  if (keyPressed) {
    if (keyCode == LEFT) {
      snowmanX -= snowmanSpeed;
    } else if (keyCode == RIGHT) {
      snowmanX += snowmanSpeed;
    }
  }
  snowmanX = constrain(snowmanX, snowmanSize / 2, width - snowmanSize / 2); //stay in the bounds of game
}

// Draw the normal snowman
void drawSnowman(float x, float y, float size) {
  image(snowmanImg, x - size / 2, y - size, size, size); 
}

//draw melted snowman
void drawMeltedSnowman(float x, float y, float size) {
  image(meltedSnowmanImg, x - size / 2, y - size, size, size); 
}

//reset the position of object once it falls out of frame
void resetFallingObject(int i) {
  objectX[i] = random(20, width - 20); //create a random position
  objectY[i] = random(-200, -20);  //start at top of screen
  isIce[i] = random(1) > 0.3;     //30% chance it is a snowflake
}

//manages the particles
class Particle {
  float x, y, size;
  float life; // lifespan of particle
  color c;

  Particle(float x, float y) {
    this.x = x;
    this.y = y;
    this.size = random(4, 8); // Random size
    this.life = 255; //starting life
    this.c = color(255, random(200, 255), random(200, 255)); //specifies color 
  }

  //updates particle - moves it slightly whilst adding a fade effect
  void update() {
    this.y += random(-1, 1); 
    this.x += random(-1, 1); 
    this.life -= 4;
  }

  //prints the particle
  void display() {
    noStroke();
    fill(this.c, this.life); //gives it the faded look
    ellipse(this.x, this.y, this.size, this.size);
  }

  //checks whether particle is still valid
  boolean isDead() {
    return this.life <= 0;
  }
}

//checks snowman position and prints a particle accordingly
void generateParticles(float x, float y) {
  for (int i = 0; i < 5; i++) { 
    if (particles.size() < maxParticles) {
      particles.add(new Particle(x, y)); //create new particle
    }
  }
}

//update and print particles 
void updateParticles() {
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isDead()) {
      particles.remove(i); //get rid of dead particles
    }
  }
}

//play ice sound
void playCatchIceSound() {
  catchIceSound.play(); 
}

//play snowflake sound
void playCatchSnowflakeSound() {
  catchSnowflakeSound.play(); }
