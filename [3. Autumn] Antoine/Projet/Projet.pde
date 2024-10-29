// Antoine BROSSEAU 202432482

PImage feuille_jaune, feuille_rouge, ecureuil, fond;  // Images for the yellow leaf, red leaf, squirrel, and background
float[] x, y, rot, speed;  // Arrays to store positions, rotations, and speeds of leaves
int[] feuilleType;         // Array to store the type of each leaf (0 for yellow, 1 for red)
int numFeuilles = 6;       // Total number of leaves
float speedMultiplier = 0.7;  // Speed multiplier to increase leaf speed over time

boolean dragging = false;  // Indicates if a leaf is being dragged
int draggedIndex = -1;     // Index of the leaf being dragged
int score = 0;             // Player's score
boolean gameOver = false;  // Indicates if the game is over

boolean ecureuilPresent = false;  // Squirrel presence on screen
float ecureuilX, ecureuilY;       // Position of the squirrel
float ecureuilSpeed;              // Speed of the squirrel

void setup() {
  size(800, 457);  // Set canvas size
  
  feuille_jaune = loadImage("data/feuilleJAUNE.png");
  feuille_rouge = loadImage("data/feuilleROUGE.png");
  ecureuil = loadImage("data/ecureuil.png");
  fond = loadImage("data/fond.png");

  // Initialize arrays for leaves
  x = new float[numFeuilles];
  y = new float[numFeuilles];
  rot = new float[numFeuilles];
  speed = new float[numFeuilles];
  feuilleType = new int[numFeuilles];
  
  // Set initial position, rotation, and type for each leaf
  for (int i = 0; i < numFeuilles; i++) {
    resetLeaf(i);
  }
}

void draw() {
  background(fond);  // Draw background image

  fill(255);
  textSize(20);
  text("Score : " + score, 10, 30);  // Display score

  if (gameOver) {
    textSize(40);
    fill(255, 0, 0);
    text("Game Over!", width / 2 - 100, height / 2);
    return;  // End the game if gameOver is true
  }

  speedMultiplier += 0.0001;  // Gradually increase leaf falling speed

  // Loop through each leaf
  for (int i = 0; i < numFeuilles; i++) {
    pushMatrix();
    
    translate(x[i], y[i]);
    rotate(rot[i]);  // Rotate and position each leaf

    imageMode(CENTER);
    if (feuilleType[i] == 0) {
      image(feuille_jaune, 0, 0, 50, 50);  // Draw yellow leaf if type is 0
    } else {
      image(feuille_rouge, 0, 0, 50, 50);  // Draw red leaf if type is 1
    }

    popMatrix();
    
    if (i != draggedIndex) {
      y[i] += speed[i] * speedMultiplier;  // Move leaf down if not being dragged
      rot[i] += 0.02;                      // Rotate the leaf slightly
    }
    
    if (y[i] > height - 25) {  // Check if leaf hits the bottom of the screen
      gameOver = true; 
    }
  }

  if (dragging && draggedIndex != -1) {
    x[draggedIndex] = mouseX;
    y[draggedIndex] = mouseY;  // Update dragged leaf's position with the mouse
  }
  
  if (!ecureuilPresent) {
    if (random(1) < 0.001) {  // Randomly create squirrel
      ecureuilPresent = true;
      ecureuilX = random(150, width-150);  
      ecureuilY = -50;               
      ecureuilSpeed = random(3, 6);  
    }
  } else {
    imageMode(CENTER);
    image(ecureuil, ecureuilX, ecureuilY, 60, 60);  // Draw squirrel
    ecureuilY += ecureuilSpeed;  // Move squirrel down the screen

    if (ecureuilY > height + 50) {
      ecureuilPresent = false;  // Remove squirrel when it moves off screen
    }

    if (dist(mouseX, mouseY, ecureuilX, ecureuilY) < 30) {
      gameOver = true;  // End the game if the player clicks the squirrel
    }
  }
}

void mousePressed() {
  for (int i = 0; i < numFeuilles; i++) {
    if (dist(mouseX, mouseY, x[i], y[i]) < 25) {
      dragging = true;  
      draggedIndex = i;  // Start dragging the leaf if the mouse is close enough
      break;
    }
  }
}

void mouseReleased() {
  if (dragging && draggedIndex != -1) {
    // Check if the leaf is released in the scoring zone on the left
    if (x[draggedIndex] < 150 && y[draggedIndex] > 230) {  
      if (feuilleType[draggedIndex] == 1) {  
        score++;          
        resetLeaf(draggedIndex);  // Reset leaf if it scores
      } else {  
        gameOver = true;  // End game if the wrong leaf is placed
      }
    } 
    // Check if the leaf is released in the scoring zone on the right
    else if (x[draggedIndex] > width-150  && y[draggedIndex] > 230) { 
      if (feuilleType[draggedIndex] == 0) {  
        score++;        
        resetLeaf(draggedIndex); 
      } else {  
        gameOver = true;  
      }
    }
  }
  
  dragging = false;  
  draggedIndex = -1;  // Stop dragging the leaf
}

void resetLeaf(int i) {
  x[i] = random(150, width-150);    // Randomize leaf position horizontally
  y[i] = -50;                       // Start the leaf above the screen
  rot[i] = random(TWO_PI);          // Randomize leaf rotation
  speed[i] = random(0.5, 1.5);      // Set a random falling speed
  feuilleType[i] = int(random(2));  // Randomly assign leaf type (yellow or red)
}
