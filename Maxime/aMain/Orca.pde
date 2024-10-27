//Maxime FOUCHER
class Orca {
  PImage img1, img2, img3;

  int x;
  int y;
  int frameIndex = 0;
  int delay = 200;
  int lastChangeTime;
  int velocity = (int)random(5, 15);
  int returnx, returny, returnsize1, returnsize2;
  
   // Y Position for upper orcas
  int SPECIFIC_Y_POSITION = height / 4;
  float SPECIFIC_Y_CHANCE = 0.15; // 15% chance for an upper orca


  Orca() {
    img1 = loadImage("orque1.png");
    img2 = loadImage("orque2.png");
    img3 = loadImage("orque3.png");

    x = width + 200;
    
    
    // to make an upper orca (with the pourcent chance or another
    if (random(1) < SPECIFIC_Y_CHANCE) {
      y = SPECIFIC_Y_POSITION; // Y position
    } else {
      y = height / 2; // Normal y position
    }
    
    
    lastChangeTime = millis();
  }

  void DrawOrca() {
    // if the time since the last orca is enought
    if (millis() - lastChangeTime > delay) {
      frameIndex++;  // change image
      lastChangeTime = millis();  // change the last time orca
    }

    PImage currentImage; // to altern between all sprite
    if (frameIndex % 3 == 0) {
      currentImage = img1;
    } else if (frameIndex % 3 == 1) {
      currentImage = img2;
    } else {
      currentImage = img3;
    }
    image(currentImage, x, y, 200, 100);

    x -= velocity;

    returnx = x+105;
    returny = y+55;
    returnsize1 = 180;
    returnsize2 = 80;
    
  }

  int[] getBounds() { // for the hit box
    return new int[] { returnx, returny, returnsize1, returnsize2 };
  }

  boolean isOffScreen() {
    return x < -150; // return true if orca is outside the screen
  }
}
