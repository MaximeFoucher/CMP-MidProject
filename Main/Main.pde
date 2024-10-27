import java.io.File;

void setup() {
  size(600, 400);
  textSize(24);
  textAlign(CENTER, CENTER);
}

void draw() {
  background(200);
  text("Game Main Menu", width / 2, 50);
  
  // 각 게임 버튼
  drawButton("Spring", width / 2, 150);
  drawButton("Summer", width / 2, 200);
  drawButton("Autumn", width / 2, 250);
  drawButton("Winter", width / 2, 300);
}

void drawButton(String label, float x, float y) {
  fill(100, 150, 255);
  rectMode(CENTER);
  rect(x, y, 150, 40, 10);
  fill(255);
  text(label, x, y);
}

void mousePressed() {
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
  return mouseX > x - 75 && mouseX < x + 75 && mouseY > y - 20 && mouseY < y + 20;
}

// 게임 exe 파일 실행
void launchGame(String gamePath) {
  try {
    // 스케치 폴더 경로에서 실행
    String folderPath = sketchPath(""); // 현재 스케치 경로
    String exePath = sketchPath(gamePath); // 실행 파일 전체 경로
    File gameFile = new File(exePath);
    
    if (gameFile.exists()) {
      // cmd 명령어로 해당 폴더로 이동 후 exe 실행
      Runtime.getRuntime().exec("cmd /c cd \"" + folderPath + "\" && start \"\" \"" + gameFile.getAbsolutePath() + "\"");
    } else {
      println("Game executable not found: " + exePath);
    }
  } catch (Exception e) {
    e.printStackTrace();
  }
}
