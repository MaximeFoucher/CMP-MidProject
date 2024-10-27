import java.io.File;
PImage backgroundImage; // Background image variable

void setup() {
  size(600, 400);
  textSize(24);
  textAlign(CENTER, CENTER);
  
  // Load background image
  backgroundImage = loadImage("background.jpg"); 
}

void draw() {
  // Display the background image
  if (backgroundImage != null) {
    image(backgroundImage, 0, 0, width, height);
  } else {
    background(200); // Fallback background color
  }

  // Menu title with shadow effect
  fill(0, 50); // Shadow
  text("Game Main Menu", width / 2 + 2, 52);
  fill(255); // White text
  text("Game Main Menu", width / 2, 50);

  // Draw each button
  drawButton("Spring", width / 2, 150, overButton(width / 2, 150));
  drawButton("Summer", width / 2, 200, overButton(width / 2, 200));
  drawButton("Autumn", width / 2, 250, overButton(width / 2, 250));
  drawButton("Winter", width / 2, 300, overButton(width / 2, 300));
}

void drawButton(String label, float x, float y, boolean hovered) {
  rectMode(CENTER);
  
  // Button colors with hover effect
  if (hovered) {
    fill(120, 180, 255); // Lighter color for hover
  } else {
    fill(100, 150, 255); // Default color
  }
  
  // Button with rounded corners
  rect(x, y, 150, 40, 10);
  
  // Text with shadow for a 3D effect
  fill(0, 50); // Shadow color
  text(label, x + 1, y + 1);
  fill(255); // White text color
  text(label, x, y);
}

void mousePressed() {
  // Launch the associated game when button is clicked
  if (overButton(width / 2, 150)) {
    launchGame("Luke.bat");
  } else if (overButton(width / 2, 200)) {
    launchGame("Maxime.bat");
  } else if (overButton(width / 2, 250)) {
    launchGame("Antoine.bat");
  } else if (overButton(width / 2, 300)) {
    launchGame("Hasnain.bat");
  }
}

boolean overButton(float x, float y) {
  // Check if the mouse is over a button
  return mouseX > x - 75 && mouseX < x + 75 && mouseY > y - 20 && mouseY < y + 20;
}

void launchGame(String gamePath) {
  try {
    String folderPath = sketchPath(""); // Current sketch path
    String exePath = sketchPath(gamePath); // Full path to the executable
    File gameFile = new File(exePath);
    
    if (gameFile.exists()) {
      // Execute the file with cmd commands
      Runtime.getRuntime().exec("cmd /c cd \"" + folderPath + "\" && start \"\" \"" + gameFile.getAbsolutePath() + "\"");
    } else {
      println("Game executable not found: " + exePath);
    }
  } catch (Exception e) {
    e.printStackTrace();
  }
}
