// Prey have 8 friendly neighbor cells
// Predators have 6 friendly neighbor cells
// These four vectors define the birth and survival conditions in terms of
// the number of live friendly neighbors.
int[] preySurvivalFromFriendly = {2, 3};
int[] preyBirthFromFriendly = {3};

int[] predatorSurvivalFromFriendly = {2, 3};
int[] predatorBirthFromFriendly = {3};

// Prey have 4 foe neighbor cells
// Predators have 2 foe neighbor cells
// The next two vectors are the same as above, but for foe neighbors
int[] preySurvivalFromFoe = {0, 1, 2, 3};
int[] predatorBirthFromFoe = {2};

int speed = 15;
boolean paused = true;

int seedPredatorDensity = 30;
int seedPreyDensity = 30;
int defaultSeedSize = 50;
int habSize = 200;

int deadPredator = 0xFF222222;
int livePredator = 0xFFDE8EAE;

int deadPrey = 0xFF444444;
int livePrey = 0xFF6EDE7E;

int predatorWidth = 3;
int preyWidth = 9;
int totalWidth = predatorWidth + preyWidth;

boolean[][] habitat;
boolean[][] nextHabitat;


void settings() {
  size(totalWidth * (habSize / 2), totalWidth * (habSize / 2));
}

void setup() {
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

  populateHabitat(defaultSeedSize);
}

void draw() {
  if (!paused) iterateHabitat();

  background(0);
  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      if (isHorizontalPredator(i, j)) {
        fill(deadPredator);
        if (isLive(i, j)) fill(livePredator);
        rect(totalWidth * (i + 1) / 2, totalWidth * j / 2 + preyWidth, preyWidth, predatorWidth);
      } else if (isVerticalPredator(i, j)) {
        fill(deadPredator);
        if (isLive(i,j)) fill(livePredator);
        rect(totalWidth * i / 2 + preyWidth, totalWidth * (j + 1) / 2, predatorWidth, preyWidth);
      } else if (isPrey(i, j)) {
        fill(deadPrey);
        if (isLive(i,j)) fill(livePrey);
        rect(totalWidth * i / 2, totalWidth * j / 2, preyWidth, preyWidth);
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
    populateHabitat(defaultSeedSize);
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

boolean valueWithin(int[] array, int value) {
  for (int arrayValue : array) {
    if (value == arrayValue) {
      return true;
    }
  }
  return false;
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

        if (isLive(i, j) && valueWithin(predatorSurvivalFromFriendly, liveFriends)
          || !isLive(i, j) && valueWithin(predatorBirthFromFriendly, liveFriends)) nextHabitat[i][j] = true;
        else nextHabitat[i][j] = false;

      } else if (isVerticalPredator(i, j)) {
        int liveFriends = 0;
        if (isLive(i - 1, j - 1)) liveFriends++;
        if (isLive(i - 1, j + 1)) liveFriends++;
        if (isLive(i + 1, j + 1)) liveFriends++;
        if (isLive(i + 1, j - 1)) liveFriends++;
        if (isLive(i, j - 2)) liveFriends++;
        if (isLive(i, j + 2)) liveFriends++;

        if (isLive(i, j) && valueWithin(predatorSurvivalFromFriendly, liveFriends)
          || !isLive(i, j) && valueWithin(predatorBirthFromFriendly, liveFriends)) nextHabitat[i][j] = true;
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

        if (isLive(i, j) && valueWithin(preySurvivalFromFriendly, liveFriends)
          || !isLive(i, j) && valueWithin(preyBirthFromFriendly, liveFriends)) nextHabitat[i][j] = true;
        else nextHabitat[i][j] = false;
      }

      if (isVerticalPredator(i, j)) {
        int liveFoes = 0;
        if (isLive(i, j + 1)) liveFoes++;
        if (isLive(i + 2, j + 1)) liveFoes++;

        if (valueWithin(predatorBirthFromFoe, liveFoes)) nextHabitat[i][j] = true;
      }
      if (isHorizontalPredator(i, j)) {
        int liveFoes = 0;
        if (isLive(i + 1, j)) liveFoes++;
        if (isLive(i + 1, j + 2)) liveFoes++;

        if (valueWithin(predatorBirthFromFoe, liveFoes)) nextHabitat[i][j] = true;
      }

      if (isPrey(i, j)) {
        int liveFoes = 0;
        if (isLive(i, j - 1)) liveFoes++;
        if (isLive(i - 2, j + 1)) liveFoes++;
        if (isLive(i - 1, j - 2)) liveFoes++;
        if (isLive(i - 1, j)) liveFoes++;

        if (!valueWithin(preySurvivalFromFoe, liveFoes)) nextHabitat[i][j] = false;
      }
    }
  }


  boolean[][] triangleSwap = habitat;
  habitat = nextHabitat;
  nextHabitat = triangleSwap;

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

void setLive(int x, int y) {
  if (x < 0) x = habSize + x;
  else if (x >= habSize) x = x - habSize;

  if (y < 0) y = habSize + y;
  else if (y >= habSize) y = y - habSize;

  habitat[x][y] = true;
}

boolean isHorizontalPredator(int x, int y) {
  return x % 2 == 1 && y % 2 == 0;
}

boolean isVerticalPredator(int x, int y) {
  return x % 2 == 0 && y % 2 == 1;
}

boolean isPredator(int x, int y) {
  return isHorizontalPredator(x, y) || isVerticalPredator(x, y);
}

boolean isPrey(int x, int y) {
  return x % 2 == 0 && y % 2 == 0;
}

void injectGlider(int x, int y) {
  setLive(x, y);
  setLive(x, y - 2);
  setLive(x, y - 4);
  setLive(x - 2, y);
  setLive(x - 4, y - 2);
}

void injectShip(int x, int y) {
  setLive(x, y + 2);
  setLive(x + 2, y + 2);
  setLive(x + 4, y + 2);
  setLive(x + 6, y + 2);
  setLive(x + 8, y + 2);
  setLive(x, y + 4);
  setLive(x + 10, y + 4);
  setLive(x, y + 6);
  setLive(x + 2, y + 8);
  setLive(x + 10, y + 8);
  setLive(x + 6, y + 10);
}

void injectPredatorBar(int x) {
  for (int y = 1; y < habSize; y += 2) {
    setLive(x, y);
  }
}

void populateHabitat(int seedSize) {
  for (int i = 0 ; i < habSize ; i++) {
    for (int j = 0 ; j < habSize ; j++) {
      habitat[i][j] = false;
    }
  }

  int seedStart = habSize / 2 - seedSize / 2;
  int seedEnd = habSize / 2 + seedSize / 2;

  if (seedEnd - seedStart < seedSize) {
    // Above math always results in even valued start and end due to division flooring, so
    // get back to the right size if necessary.
    seedStart -= 1;
  }
  println("populating size " + (seedEnd - seedStart) + " from " + seedStart + " to " + seedEnd);

  for (int i = seedStart; i < seedEnd; i++) {
    for (int j = seedStart; j < seedEnd; j++) {
        if (isPredator(i, j)) {
          if (random(100) <= seedPredatorDensity) habitat[i][j] = true;
        } else {
          if (random(100) <= seedPreyDensity) habitat[i][j] = true;
        }
    }
  }

  injectGlider(habSize - 2, habSize - 2);
  injectShip(habSize / 2, 2);
  injectPredatorBar(habSize * 3 / 4);
}
