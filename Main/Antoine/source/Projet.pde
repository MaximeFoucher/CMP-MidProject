PImage feuille_jaune, feuille_rouge, ecureuil, fond;  
float[] x, y, rot, speed;  
int[] feuilleType;        
int numFeuilles = 6;      
float speedMultiplier = 0.7;  

boolean dragging = false; 
int draggedIndex = -1;    
int score = 0;             
boolean gameOver = false;  

boolean ecureuilPresent = false; 
float ecureuilX, ecureuilY;      
float ecureuilSpeed;             

void setup() {
  size(800, 457);
  
  feuille_jaune = loadImage("data/feuilleJAUNE.png");
  feuille_rouge = loadImage("data/feuilleROUGE.png");
  ecureuil = loadImage("data/ecureuil.png");
  fond = loadImage("data/fond.png");


  x = new float[numFeuilles];
  y = new float[numFeuilles];
  rot = new float[numFeuilles];
  speed = new float[numFeuilles];
  feuilleType = new int[numFeuilles];
  
  for (int i = 0; i < numFeuilles; i++) {
    resetLeaf(i);
  }
}

void draw() {
  background(fond);
  
  fill(255);
  textSize(20);
  text("Score : " + score, 10, 30);

  if (gameOver) {
    textSize(40);
    fill(255, 0, 0);
    text("Game Over!", width / 2 - 100, height / 2);
    return; 
  }

  speedMultiplier += 0.0001; 

  for (int i = 0; i < numFeuilles; i++) {
    pushMatrix();
    
    translate(x[i], y[i]);
    rotate(rot[i]);

    imageMode(CENTER);
    if (feuilleType[i] == 0) {
      image(feuille_jaune, 0, 0, 50, 50); 
    } else {
      image(feuille_rouge, 0, 0, 50, 50);  
    }

    popMatrix();
    
    if (i != draggedIndex) {
      y[i] += speed[i] * speedMultiplier; 
      rot[i] += 0.02;                      
    }
    
    if (y[i] > height - 25) {  
      gameOver = true; 
    }
  }

  if (dragging && draggedIndex != -1) {
    x[draggedIndex] = mouseX;
    y[draggedIndex] = mouseY;
  }
  
  if (!ecureuilPresent) {
    if (random(1) < 0.001) {  
      ecureuilPresent = true;
      ecureuilX = random(150, width-150);  
      ecureuilY = -50;               
      ecureuilSpeed = random(3, 6);  
    }
  } else {
    imageMode(CENTER);
    image(ecureuil, ecureuilX, ecureuilY, 60, 60); 
    ecureuilY += ecureuilSpeed; 

    if (ecureuilY > height + 50) {
      ecureuilPresent = false;  
    }

    if (dist(mouseX, mouseY, ecureuilX, ecureuilY) < 30) {
      gameOver = true;  
    }
  }
}

void mousePressed() {
  for (int i = 0; i < numFeuilles; i++) {
    if (dist(mouseX, mouseY, x[i], y[i]) < 25) {
      dragging = true;  
      draggedIndex = i;  
      break;
    }
  }
}

void mouseReleased() {
  if (dragging && draggedIndex != -1) {
    if (x[draggedIndex] < 150 && y[draggedIndex] > 230) {  
      if (feuilleType[draggedIndex] == 1) {  
        score++;          
        resetLeaf(draggedIndex); 
      } else {  
        gameOver = true; 
      }
    } else if (x[draggedIndex] > width-150  && y[draggedIndex] > 230) { 
      if (feuilleType[draggedIndex] == 0) {  
        score++;        
        resetLeaf(draggedIndex); 
      } else {  
        gameOver = true;  
      }
    }
  }
  
  dragging = false;  
  draggedIndex = -1; 
}

void resetLeaf(int i) {
  x[i] = random(150, width-150);    
  y[i] = -50;               
  rot[i] = random(TWO_PI);   
  speed[i] = random(0.5, 1.5); 
  feuilleType[i] = int(random(2));  
}
