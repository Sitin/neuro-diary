import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

int DEF_WIDTH = 1280;
int DEF_HEIGHT = 720;

Table table;
int i = 0;
int rowCount;
int frameN = 0;
int fpe;
float radius;
float scale;
float att;
float outerRadius;
float innerRadius;
int frameID = 0;

Minim minim;
AudioPlayer song;

String datetime() {
  return table.getRow(i).getString("TS"); 
}

float att() {
  return table.getRow(i).getFloat("EEGATT"); 
}

float lastAtt() {
  if (i > 0) {
    return table.getRow(i-1).getFloat("EEGATT");
  } else {
    return 0.0;
  }
}

boolean hasMore() {
  return i < rowCount-1;
}

void next() {
  if (hasMore()) {
    if (frameN == fpe) {
      i++;
      frameN = 0;
    } else {
      frameN++;
    }    
  } else {
    i = 0;    
  }
} 

float getScale() {
  if (height > width) {
    return width / 100;
  } else {
    return height / 100;
  }
}

void setupViewPort() {
  size(DEF_WIDTH, DEF_HEIGHT);
  if (frame != null) {
    frame.setResizable(true);
  }
  
  fpe = 15;
  frameRate(fpe * 2);
}

void setupMinim() {
  minim = new Minim(this);
  song = minim.loadFile("data/session.mp3");
  song.play();
}

void setupTable() {
  table = loadTable("data/attention.csv", "header");  
  rowCount = table.getRowCount();  

  println(rowCount + " total rows in table");
}

void setup() {
  setupViewPort();
  setupMinim();
  setupTable(); 
}

void calculateFrame() {
  scale = getScale() / 2;
  att = lastAtt() + (att() - lastAtt()) / fpe * frameN;
  innerRadius = att * scale;
}

void drawCircleWave() {
  int buffSize = song.bufferSize();
  float step = TWO_PI / (buffSize - 1);
  float start = 0;
  float end = step;
  float left;
  float right;
  float arcRadius;
  
  for(int i = 0; i < buffSize - 1; i++) {
      left = innerRadius / 20 + song.left.get(i) * scale * 100;
      right = innerRadius / 20 + left + song.right.get(i) * scale * 100;
    
      fill(0x30, 0x03, 0x40);
      arc(width/2, height/2, innerRadius + left, innerRadius + left, start, end);
      fill(0x36, 0xA9, 0xCF);
      arc(width/2, height/2, innerRadius + right, innerRadius + right, start, end);
      start = end;
      end += step;
  }
}

void drawCircles() {
  noStroke();
  drawCircleWave();
  fill(0x06, 0x08, 0x1B);
  ellipse(width/2, height/2, innerRadius, innerRadius);
}

void draw() {
  calculateFrame();
  
  background(0x32, 0x31, 0x54);
  noStroke();
  
  drawCircles();

  next();
  
  text(datetime(), 25, height - 25);
  
//  saveFrame("data/movie/solaris-" + frameID++ + ".tif");
}
