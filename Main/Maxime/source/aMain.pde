//Maxime FOUCHER 
import ddf.minim.*;
import java.util.ArrayList;

Minim minim;
AudioInput input;

PImage img, imgstart;
Orca orca;
Character character;
ArrayList<Orca> orcas = new ArrayList<>();
int lastOrcaTime = 0;
int orcaInterval = 10000;
int nborca = 1;
int score = 0;
int scoretemp = 0;
boolean screenstart = true;
boolean screenloose = false;
int gameStartTime = 0;

void setup() {
  size(1920 / 2, 1080 / 2); // size of screen

  // Initialisation of Minim for audio
  minim = new Minim(this);
  input = minim.getLineIn(Minim.MONO, 512); // input audio mono

  img = loadImage("background.png");
  orcas.add(new Orca());
  character = new Character();
  imgstart = loadImage("getready.png");
}

void draw() {
  fill(255, 255, 0);
  textSize(40);
  if (screenstart) { // if we don't pressed enter
    image(imgstart, 0, 0, width, height); // start screen
    if (screenloose) {
      text("GAME OVER !!", (width - textWidth("GAME OVER !!")) / 2, height / 2);
      text("Score : " + score, (width - textWidth("Score : " + score)) / 2, height * 3 / 5);
    } else {
      text("GET READY !!", (width - textWidth("GET READY !!")) / 2, height / 2);
    }
    text("Press ENTER to Start a New Game", width - textWidth("Press ENTER to Start a New Game") - 20, height - 35); // En bas à droite
  } else { // start game
    image(img, 0, 0, width, height);
    character.DrawCharacter();

    int[] Characterbounds = character.getBounds();

    // input volume
    float volume = input.mix.level();
    float threshold = 0.005; // to adjust to increase or decrease the volume detected

    println("Volume actuel : " + volume);

    if (volume > threshold) { // to moove charcater thanks to volume
      character.move(-10);
    } else {
      character.move(5);
    }

    int timer = (int)((millis() - gameStartTime) / 1000); // start timer of seconds

    if (millis() - lastOrcaTime > orcaInterval) {
      orcas.add(new Orca());
      lastOrcaTime = millis();
      orcaInterval = (int) random(2000, 8000);
      nborca += 1; // counter of pasts orcas
      scoretemp = scoretemp + (int)lastOrcaTime / 1000 * nborca;
    }

    score = timer + scoretemp;

    text("Score : " + score, 10, 40); // the score is time + time past * orcas past

    for (int i = orcas.size() - 1; i >= 0; i--) {
      Orca orca = orcas.get(i);
      orca.DrawOrca(); //draw orcas

      int[] Orcabounds = orca.getBounds();

      if (Characterbounds[0] + Characterbounds[2] / 2 > Orcabounds[0] - Orcabounds[2] / 2 &&
        Characterbounds[0] - Characterbounds[2] / 2 < Orcabounds[0] + Orcabounds[2] / 2 &&
        Characterbounds[1] + Characterbounds[3] / 2 > Orcabounds[1] - Orcabounds[3] / 2 &&
        Characterbounds[1] - Characterbounds[3] / 2 < Orcabounds[1] + Orcabounds[3] / 2) {
        println("Partie perdue !");
        screenloose = true; // says that you the game is over
        screenstart = true; // screen start again
      }

      if (orca.isOffScreen()) {
        orcas.remove(i); // if orcas are outside the screen, delete it
      }
    }
  }
}

void keyPressed() {
  if (key == ENTER) {
    if (screenloose) {
      // if game is over you can start a new game
      screenloose = false;
      score = 0; 
      orcas.clear(); // clear all orcas
    }
    screenstart = false; // start game
    gameStartTime = millis(); // start timer now
    lastOrcaTime = millis(); // start again last orca generate
  }
}

void stop() {
  input.close(); // close audio
  minim.stop();  // stop minim
  super.stop(); // stop all
}
