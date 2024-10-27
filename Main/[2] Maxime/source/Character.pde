//Maxime FOUCHER 
class Character {
  PImage img1, img2;
  int x;
  int y;
  int lastY;
  boolean image1 = true;
  boolean image2 = false;
  int imgWidth = 100;
  int imgHeight = 150;
  int upperLimit;
  int lowerLimit;
  int returnx, returny, returnsize1, returnsize2;

  Character() {
    img1 = loadImage("character1.png");
    img2 = loadImage("character2.png");
    img1.resize(imgWidth, imgHeight);
    img2.resize(imgWidth, imgHeight);


    // Initialisation position
    x = width / 5;
    y = height / 2;
    lastY = y;

    upperLimit = imgHeight / 6;
    lowerLimit = height - imgHeight*3/2;
  }

  void DrawCharacter() { // different image if the character go down or up (sprite)
    if (y > lastY) {
      image1 = true;
      image2 = false;
    } else if (y < lastY) {
      image1 = false;
      image2 = true;
    }

    if (image1) {
      image(img1, x, y);
    } else {
      image(img2, x, y);
    }

    lastY = y;

    returnx = x+55;
    returny = y+80;
    returnsize1 = 70;
    returnsize2 = 100;

  }

  int[] getBounds() { // to do the hitbox
    return new int[] { returnx, returny, returnsize1, returnsize2 };
  }


  void move(int deltaY) { // to moove
    if ((y + deltaY) >= upperLimit && (y + deltaY) <= lowerLimit) {
      y += deltaY;
    }
  }
}
