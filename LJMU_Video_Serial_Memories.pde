import processing.video.*;
import processing.serial.*;

String movieFiles[] = {
  "movie0.mp4", 
  "movie1.mp4", 
  "movie2.mp4", 
  "movie3.mp4", 
  "movie4.mp4"
};

Serial mPort;
Movie mMovie;

void setup() {
  size(640, 480);
  smooth();
  background(0);

  for (String s : Serial.list ()) {
    if (s.contains("tty") && s.contains("usbmodem")) {
      mPort = new Serial(this, s, 57600);
      println(s);
      break;
    }
  }
  mMovie = new Movie(this, dataPath(movieFiles[0]));
  mMovie.jump(mMovie.duration());
}

void draw() {
  if (mMovie.available()) {
    mMovie.read();
  }

  int triggeredIndex = movieFiles.length;
  while (mPort.available () >= 3) {
    // check for message header (0xDEAD)
    int h = mPort.read();
    boolean sawFirstHeaderByte = false;
    while (h == 0xDE) {
      h = mPort.read();
      sawFirstHeaderByte = true;
    }
    if ((h == 0xAD) && (sawFirstHeaderByte)) {
      triggeredIndex = mPort.read();
      println(triggeredIndex+" was triggered");
    }
  }


  if (abs(mMovie.time() - mMovie.duration()) < 0.1) {
    fill(0, 4);
    noStroke();
    rect(0, 0, width, height);
    if (triggeredIndex < movieFiles.length) {
      File f = new File(dataPath(movieFiles[triggeredIndex]));
      if (f.exists ()) {
        mMovie = new Movie(this, dataPath(movieFiles[triggeredIndex]));
        mMovie.play();
      }
    }
  } else {
    background(0);
    image(movie, 0, 0);
  }
}

