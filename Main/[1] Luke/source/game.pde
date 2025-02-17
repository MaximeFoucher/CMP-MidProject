import processing.sound.*;  // Sound 라이브러리 임포트

SoundFile backgroundMusic;
SoundFile eatSound;
SoundFile gameOverSound;
boolean loadingDone = false;  // 로딩 완료 여부

int gridSize = 20;  // 그리드 크기
int cols, rows;     // 그리드의 가로, 세로 크기
int playerX, playerY;  // 플레이어의 위치
int playerDirX = 1, playerDirY = 0;  // 플레이어의 방향
int speed = 10;  // 기본 속도
int maxSpeed = 20;  // 최대 속도
int frameCounter = 0;  // 속도 제어를 위한 프레임 카운터
int score = 0;  // 점수 변수

color[] colors = {color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), color(255, 255, 0)};
color currentColor;  // 현재 플레이어의 색상
ArrayList<Flower> flowers;  // 꽃을 저장하는 배열
boolean gameOver = false;
boolean hasPlayedGameOverSound = false;  // 게임 오버 사운드가 이미 재생되었는지 확인하는 변수
int safeDistance = 100;  // 꽃이 캐릭터로부터 떨어져 생성되는 최소 거리
int borderMargin = 50;  // 화면 가장자리 여백

PImage characterImg;
PImage flowerImg;
PImage backgroundImg;  // 배경 이미지 변수

// 재시작 버튼 위치 및 크기 설정
int restartButtonX, restartButtonY, restartButtonW, restartButtonH;

void setup() {
  size(600, 600, P3D);  // 화면 크기를 600x600으로 조정
  cols = width / gridSize;
  rows = height / gridSize;
  
  characterImg = loadImage("resources/character.png");  // 캐릭터 이미지 로드
  flowerImg = loadImage("resources/flower.png");  // 꽃 이미지 로드
  backgroundImg = loadImage("resources/background.png");  // 배경 이미지 로드
  
  // 재시작 버튼 위치와 크기
  restartButtonW = 150;
  restartButtonH = 50;
  restartButtonX = (width - restartButtonW) / 2;
  restartButtonY = height / 2 + 50;
  
  // 사운드 파일 로드 (백그라운드 스레드에서 로드)
  thread("loadSounds");

  initGame();  // 게임 초기화
}

void loadSounds() {
  backgroundMusic = new SoundFile(this, "resources/background.mp3");  // 배경 음악 로드
  eatSound = new SoundFile(this, "resources/eat.wav");  // 먹을 때 효과음 로드
  gameOverSound = new SoundFile(this, "resources/gameover.wav");  // 게임 오버 효과음 로드
  backgroundMusic.loop();  // 배경 음악 루프 재생
  loadingDone = true;  // 로딩 완료
}

void initGame() {
  // 플레이어 초기 위치 및 색상
  playerX = cols / 2 * gridSize;
  playerY = rows / 2 * gridSize;
  playerDirX = 1;
  playerDirY = 0;
  currentColor = randomColor();
  
  speed = 10;  // 기본 속도 초기화
  frameCounter = 0;
  score = 0;
  gameOver = false;  // 게임 오버 상태 초기화
  hasPlayedGameOverSound = false;  // 게임 오버 사운드 초기화
  
  // 꽃을 저장할 리스트 초기화
  flowers = new ArrayList<Flower>();
  spawnFlowers();  // 초기 꽃 생성
}

// 매 프레임마다 호출
void draw() {
  if (!loadingDone) {
    drawLoadingScreen();  // 로딩 화면 표시
    return;
  }
  
  // 배경 이미지 그리기
  image(backgroundImg, 0, 0, width, height);  // 배경 이미지 크기에 맞춰 화면 전체에 그리기
  
  if (gameOver) {
    displayGameOver();
    return;
  }
  
  // 점수 표시
  displayScore();
  
  // 프레임 수에 따라 플레이어가 움직이도록 속도 제어
  frameCounter++;
  if (frameCounter >= 60 / speed) {
    frameCounter = 0;
    movePlayer();
  }
  
  // 플레이어 그리기
  drawCharacter();
  
  // 꽃 그리기
  for (Flower flower : flowers) {
    flower.show();
  }
  
  // 게임 오버 체크
  if (checkCollision()) {
    gameOver = true;
  }
  
  // 게임 오버 사운드 재생 (게임 오버가 처음 발생했을 때만 재생)
  if (gameOver && !hasPlayedGameOverSound) {
    gameOverSound.play();  // 게임 오버 사운드 재생
    hasPlayedGameOverSound = true;  // 사운드가 재생되었음을 기록
  }
}

// 로딩 화면을 그리는 함수
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

// 게임 오버 시 화면에 최종 점수와 재시작 버튼 표시
void displayGameOver() {
  hint(DISABLE_DEPTH_TEST);  // 깊이 테스트 비활성화

  // 게임 오버 메시지
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(255, 0, 0);
  text("Game Over", width / 2, height / 2 - 50);
  
  // 최종 점수 표시
  fill(0);
  textSize(24);
  text("Final Score: " + score, width / 2, height / 2);
  
  // 재시작 버튼 그리기
  fill(100, 100, 255);  // 버튼 색
  stroke(0);  // 테두리 색
  strokeWeight(2);  // 테두리 두께
  rect(restartButtonX, restartButtonY, restartButtonW, restartButtonH, 10);

  // 텍스트 정렬 (중앙에서 세로 정렬 정확하게)
  float textY = restartButtonY + (restartButtonH / 2) + (textAscent() - textDescent()) / 2;
  textY -= 1;

  // 버튼 텍스트 그리기
  fill(255);  // 텍스트 색상
  textSize(20);
  textAlign(CENTER);  // 수평 가운데 정렬
  text("Restart", restartButtonX + restartButtonW / 2, textY);  // 세로 중앙에 텍스트 그리기
  
  hint(ENABLE_DEPTH_TEST);  // 깊이 테스트 다시 활성화
}



// 점수를 화면 상단에 표시
void displayScore() {
  fill(0);
  textSize(24);
  textAlign(LEFT, TOP);
  text("Score: " + score, 10, 10);  // 화면 좌측 상단에 점수 표시
}

// 플레이어 그리기 (현재 색상 적용)
void drawCharacter() {
  tint(currentColor);  // 현재 플레이어 색상으로 캐릭터 이미지를 틴트
  image(characterImg, playerX, playerY, gridSize, gridSize);  // 캐릭터 이미지를 플레이어 위치에 맞춰 그리기
  noTint();  // 다른 이미지에 영향을 주지 않도록 틴트 해제
}

// 방향키 입력 처리
void keyPressed() {
  if (gameOver) return;  // 게임 오버 시 방향키 무시
  
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

// 무작위 색 반환
color randomColor() {
  return colors[int(random(colors.length))];
}

// 플레이어 움직임 처리
void movePlayer() {
  playerX += playerDirX * gridSize;
  playerY += playerDirY * gridSize;
  
  // 화면 밖으로 나가면 게임 오버
  if (playerX < 0 || playerX >= width || playerY < 0 || playerY >= height) {
    gameOver = true;
    return;
  }
  
  // 꽃을 먹었는지 확인
  for (int i = flowers.size() - 1; i >= 0; i--) {
    Flower flower = flowers.get(i);
    if (flower.x == playerX && flower.y == playerY) {
      if (flower.c == currentColor) {
        flowers.remove(i);  // 먹은 꽃 제거
        currentColor = randomColor();  // 색 변경
        if (speed < maxSpeed) {  // 최대 속도 이하일 때만 속도 증가
          speed++;  // 속도 증가
        }
        score++;  // 점수 증가
        spawnFlowers();  // 모든 꽃의 위치를 랜덤으로 재생성
        
        eatSound.play();  // 꽃 먹었을 때 효과음 재생
      } else {
        gameOver = true;  // 색이 맞지 않으면 게임 오버
      }
      break;
    }
  }
}

// 새로운 꽃을 화면에 배치 (플레이어 주변에 생성되지 않도록, 기존 꽃과 중복되지 않도록)
void spawnFlowers() {
  flowers.clear();  // 기존 꽃 리스트 초기화
  
  // 플레이어와 같은 색의 꽃 추가
  boolean playerFlowerSpawned = false;
  int attempts = 0;  // 최대 시도 횟수
  
  while (!playerFlowerSpawned && attempts < 100) {  // 최대 100번 시도
    Flower playerFlower = new Flower(currentColor);
    
    // 꽃이 유효한 위치에 생성될 때까지 반복
    if (dist(playerFlower.x, playerFlower.y, playerX, playerY) >= safeDistance && 
        playerFlower.x > borderMargin && playerFlower.x < width - borderMargin &&
        playerFlower.y > borderMargin && playerFlower.y < height - borderMargin &&
        !isFlowerAtLocation(playerFlower.x, playerFlower.y)) {  // 중복 위치 확인
      flowers.add(playerFlower);
      playerFlowerSpawned = true;  // 꽃이 성공적으로 생성됨
    }
    attempts++;
  }

  // 추가적인 꽃 생성 (각 색상당 1개씩)
  for (int i = 0; i < 3; i++) {  // 꽃의 수를 조절 (총 4개의 꽃 생성)
    Flower flower;
    boolean validFlower = false;
    attempts = 0;  // 최대 시도 횟수 초기화

    // 꽃이 유효한 위치에 생성될 때까지 반복
    while (!validFlower && attempts < 100) {  // 최대 100번 시도
      flower = new Flower(randomColor());
      
      if (dist(flower.x, flower.y, playerX, playerY) >= safeDistance && 
          flower.x > borderMargin && flower.x < width - borderMargin &&
          flower.y > borderMargin && flower.y < height - borderMargin &&
          !isFlowerAtLocation(flower.x, flower.y)) {  // 중복 위치 확인
        flowers.add(flower);
        validFlower = true;  // 꽃이 성공적으로 생성됨
      }
      attempts++;
    }
  }
}

// 특정 위치에 꽃이 이미 있는지 확인하는 함수
boolean isFlowerAtLocation(int x, int y) {
  for (Flower flower : flowers) {
    if (flower.x == x && flower.y == y) {
      return true;  // 해당 위치에 이미 꽃이 존재
    }
  }
  return false;  // 해당 위치에 꽃이 없음
}

// 플레이어의 충돌 여부 체크
boolean checkCollision() {
  for (Flower flower : flowers) {
    if (flower.x == playerX && flower.y == playerY) {
      return true;  // 충돌 발생
    }
  }
  return false;  // 충돌 없음
}

// Flower 클래스
class Flower {
  int x, y;  // 꽃의 위치
  color c;  // 꽃의 색상
  
  Flower(color flowerColor) {
    this.c = flowerColor;
    // 꽃의 랜덤 위치 생성
    this.x = int(random(borderMargin, width - borderMargin) / gridSize) * gridSize;
    this.y = int(random(borderMargin, height - borderMargin) / gridSize) * gridSize;
  }
  
  void show() {
    tint(c);  // 꽃 색상으로 틴트 적용
    image(flowerImg, x, y, gridSize, gridSize);  // 꽃 이미지 그리기
    noTint();  // 이후 그리기에 영향을 주지 않도록 틴트 해제
  }
}

// 마우스 클릭 시 재시작
void mousePressed() {
  // 재시작 버튼 영역 내 클릭
  if (gameOver && mouseX > restartButtonX && mouseX < restartButtonX + restartButtonW &&
      mouseY > restartButtonY && mouseY < restartButtonY + restartButtonH) {
    initGame();  // 게임 초기화
  }
}
