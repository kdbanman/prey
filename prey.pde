/*
- prey cells 5x5, predator cells 2x5 or 5x2

*/

boolean[][] habitat;
boolean[][] nextHabitat;
boolean triangleSwap;
int speed;
int habSize;
boolean paused;

void setup() {
  paused = true;
  habSize = 200;
  size(7 * (habSize / 2), 7 * (habSize / 2));
  speed = 32;
  frameRate(speed);
  noStroke();
  
  habitat = new boolean[habSize][habSize];
  nextHabitat = new boolean[habSize][habSize];
  
  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      habitat[i][j] = false;
      nextHabitat[i][j] = false;
    }
  }
  
  populateHabitat();
}

void draw() {
  if (!paused) iterateHabitat();
  
  background(0);
  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      if (isHorizontalPredator(i, j)) {
        fill(0xFF444444);
        if (isLive(i, j)) fill(0xFFFFFFFF);
        rect(7 * (i + 1) / 2, 7 * j / 2 + 5, 5, 2);
      } else if (isVerticalPredator(i, j)) {
        fill(0xFF444444);
        if (isLive(i,j)) fill(0xFFFFFFFF);
        rect(7 * i / 2 + 5, 7 * (j + 1) / 2, 2, 5);
      } else if (isPrey(i, j)) {
        fill(0xFF222222);
        if (isLive(i,j)) fill(0xFFCDCDCD);
        rect(7 * i / 2, 7 * j / 2, 5, 5);
      }
    }
  }
}

void speedup() {
  speed = min(120, speed * 2);
  frameRate(speed);
  println("speed up " + speed);
}
void speeddown() {
  speed = max(1, speed / 2);
  frameRate(speed);
  println("speed down " + speed);
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  } else if (key == RETURN || key == ENTER) {
    populateHabitat();
  } else if (key == '[') {
    speeddown();
  } else if (key == ']') {
    speedup();
  } else if (key == CODED) {
    if (keyCode == UP) {
      speedup();
    } else if (keyCode == DOWN) {
      speeddown();
    }
  }
}

void iterateHabitat() {
  
  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      if (isHorizontalPredator(i, j)) {
        int liveFriends = 0;
        if (isLive(i - 1, j - 1)) liveFriends++;
        if (isLive(i - 1, j + 1)) liveFriends++;
        if (isLive(i + 1, j + 1)) liveFriends++;
        if (isLive(i + 1, j - 1)) liveFriends++;
        if (isLive(i - 2, j)) liveFriends++;
        if (isLive(i + 2, j)) liveFriends++;
        
        if (isLive(i, j) && (liveFriends == 2 || liveFriends == 3)
          || !isLive(i, j) && liveFriends == 3) nextHabitat[i][j] = true;
        else nextHabitat[i][j] = false;
        
      } else if (isVerticalPredator(i, j)) {
        int liveFriends = 0;
        if (isLive(i - 1, j - 1)) liveFriends++;
        if (isLive(i - 1, j + 1)) liveFriends++;
        if (isLive(i + 1, j + 1)) liveFriends++;
        if (isLive(i + 1, j - 1)) liveFriends++;
        if (isLive(i, j - 2)) liveFriends++;
        if (isLive(i, j + 2)) liveFriends++;
        
        if (isLive(i, j) && (liveFriends == 2 || liveFriends == 3)
          || !isLive(i, j) && liveFriends == 3) nextHabitat[i][j] = true;
        else nextHabitat[i][j] = false;
        
      } else if (isPrey(i, j)) {
        int liveFriends = 0;
        if (isLive(i - 2, j - 2)) liveFriends++;
        if (isLive(i - 2, j + 2)) liveFriends++;
        if (isLive(i + 2, j + 2)) liveFriends++;
        if (isLive(i + 2, j - 2)) liveFriends++;
        if (isLive(i, j + 2)) liveFriends++;
        if (isLive(i, j - 2)) liveFriends++;
        if (isLive(i - 2, j)) liveFriends++;
        if (isLive(i + 2, j)) liveFriends++;
        
        if (isLive(i, j) && (liveFriends == 2 || liveFriends == 3)
          || !isLive(i, j) && (liveFriends == 3)) nextHabitat[i][j] = true;
        else nextHabitat[i][j] = false;
      }
      
      if (isVerticalPredator(i, j)) {
        if (isLive(i, j + 1) && isLive(i + 2, j + 1)) nextHabitat[i][j] = true;
      }
      if (isHorizontalPredator(i, j)) {
        if (isLive(i + 1, j) && isLive(i + 1, j + 2)) nextHabitat[i][j] = true;
      }
      
      if (isPrey(i, j)) {
        // prey cannot spawn into predation zones, so this comes after spawn cycle
        int livePredators = 0;
        if (isLive(i, j - 1)) livePredators++;
        if (isLive(i - 2, j + 1)) livePredators++;
        if (isLive(i - 1, j - 2)) livePredators++;
        if (isLive(i - 1, j)) livePredators++;
        
        if (livePredators == 4) nextHabitat[i][j] = false;
      }
    }
  }
  
  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      habitat[i][j] = nextHabitat[i][j];
    }
  }
  
  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      nextHabitat[i][j] = false;
    }
  }
}

boolean isLive(int x, int y) {
  if (x < 0) x = habSize + x;
  else if (x >= habSize) x = x - habSize;
  
  if (y < 0) y = habSize + y;
  else if (y >= habSize) y = y - habSize;
  
  return habitat[x][y];
}

boolean isHorizontalPredator(int x, int y) {
  return x % 2 == 1 && y % 2 == 0;
}

boolean isVerticalPredator(int x, int y) {
  return x % 2 == 0 && y % 2 == 1;
}

boolean isPrey(int x, int y) {
  return x % 2 == 0 && y % 2 == 0;
}

void populateHabitat() {
  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      habitat[i][j] = false;
    }
  }
  
  for (int i = habSize / 7 ; i < 6 * habSize / 7 ; i++) {
    for (int j = habSize / 4 ; j < 3 * habSize / 4 ; j++) {
        if (random(100) < 30) habitat[i][j] = true;
    }
  }
  
  habitat[habSize - 2][habSize - 2] = true;
  habitat[habSize - 2][habSize - 4] = true;
  habitat[habSize - 2][habSize - 6] = true;
  habitat[habSize - 4][habSize - 2] = true;
  habitat[habSize - 6][habSize - 4] = true;
}
