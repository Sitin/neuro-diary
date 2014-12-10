import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import java.io.File;
import java.io.FileNotFoundException;

int DEF_WIDTH = 1280;
int DEF_HEIGHT = 720;

//int DEF_WIDTH = 1920;
//int DEF_HEIGHT = 1080;

int FPE = 15;
int FPS = FPE * 2;
int renderFPS = 10;

Table table;
String csvFileName = "data/attention.csv";
int rowCount;

Minim minim;
MultiChannelBuffer sampleBuffer;
String audioFileName = "data/session.wav";
float sampleRate;
float audioLength;
int bufferSize;
float leftChannel[];
float rightChannel[];
int audioEventsPerFrame;

String outputDir = "./data/sequence";
String movieExtension = "tif";

void setBackgroundColor() {
  background(0x32, 0x31, 0x54);
}

void setAttentionColor() {
  fill(0x06, 0x08, 0x1B);
}

void setLeftChannelColor() {
  fill(0x30, 0x03, 0x40);
}

void setRightChannelColor() {
  fill(0x36, 0xA9, 0xCF);
}

void setDebugTextColor() {
  fill(32, 31, 54);
}

void checkStopCondition() {
  
}

void delete(File f) throws IOException {
  if (f.isDirectory()) {
    for (File c : f.listFiles())
      delete(c);
  }
  if (!f.delete())
    throw new FileNotFoundException("Failed to delete file: " + f);
}

void prepareFileSystem() {
  try {
    delete(new File(outputDir));
  } catch (IOException e) {
    println("Unable to delete '" + outputDir + "' dicectory.");
    println(e);
  }  
}

void setupViewPort() {
  size(DEF_WIDTH, DEF_HEIGHT);
  if (frame != null) {
    frame.setResizable(true);
  }  
  frameRate(renderFPS);
}

float getScale() {
  if (height > width) {
    return width / 200;
  } else {
    return height / 200;
  }
}

int frameN() {
  return frameCount - 1;
}

int eventN() {
  return floor(frameN() / float(FPE));
}

int frameInEvent() {
  return frameN() % FPE;
}

int filmSecond() {
  return eventN() / 2;
}

int frameInSecond() {
  return (eventN() % 2) * FPE + frameInEvent();
}

String frameId() {
  return filmSecond() + "-" + frameInSecond();
}

String outputFileName() {
  return String.format("%05d", frameN());
}

String outputPath() {
  return outputDir + "/" + outputFileName() + "." + movieExtension;
}

float transitionScore() {
  return  frameInEvent() / float(FPE);
}

int audioFrameStart() {
  return frameN() * audioEventsPerFrame;
}

int audioFrameEnd() {
  return audioFrameStart() + audioEventsPerFrame;
}

void setupMinim() {
  minim = new Minim(this);
  
  sampleBuffer = new MultiChannelBuffer( 1, 1024 );
  sampleRate = minim.loadFileIntoBuffer( audioFileName, sampleBuffer );
  audioEventsPerFrame = int(sampleRate / FPS);
}

void setupTable() {
  table = new Table();  
  table = loadTable(csvFileName, "header");  
  rowCount = table.getRowCount();
  println(rowCount + " total rows in table");
}

void analizeSampleBuffer() {
  bufferSize = sampleBuffer.getBufferSize();
  audioLength = bufferSize / sampleRate; 
  
  println(sampleRate + " frames per second");
  println(bufferSize + " frames");
  println(audioLength + " seconds");
  
  leftChannel = sampleBuffer.getChannel(0);
  rightChannel = sampleBuffer.getChannel(1);
}

void setup() {
  setupViewPort();
  setupMinim();
  setupTable();
  analizeSampleBuffer();
  prepareFileSystem();
}

float recentAttention() {
  return attentionAt(eventN() - 1);
}

float nextAttention() {
  try {
    return attentionAt(eventN());
  } catch (ArrayIndexOutOfBoundsException e) {
    exit();
    return 0;
  }
}

float smoothAttention() {
  float start = recentAttention();
  float end = nextAttention();
  return start + (end - start) * transitionScore();
}

float attentionAt(int eventN) throws ArrayIndexOutOfBoundsException {
  return eventN >= 0 ? table.getRow(eventN).getInt("EEGATT") : 0;
}

String datetimeAt(int eventN) throws ArrayIndexOutOfBoundsException {
  return eventN >= 0 ? table.getRow(eventN).getString("TS") : ""; 
}

String datetime() {
  try {
    return datetimeAt(eventN());
  } catch (ArrayIndexOutOfBoundsException e) {
    exit();
    return "";
  }
}

void debug() {
  setDebugTextColor();
  
  int y = 25;  
  text("Frame: " + frameN(), 25, y += 25);
  text("Event: " + eventN(), 25, y += 25);
  
  y += 25;
  text("DateTime: " + datetime(), 25, y += 25);  
  text("ATT: " + smoothAttention(), 25, y += 25);
  text("ATT radius: " + attentionRadius(), 25, y += 25);  
  text("Last ATT: " + recentAttention(), 25, y += 25);
  text("Next ATT: " + nextAttention(), 25, y += 25);
  
  y += 25;
  text("FPS: " + float(frameN()) / second(), 25, y += 25);  
  text("Film time: " + float(frameN()) / FPS, 25, y += 25);
  text("Render time: " + float(millis()) / 1000, 25, y += 25);
  text("Frame ID: " + frameId(), 25, y += 25);
  text("Output path: " + outputPath(), 25, y += 25);
  
  y += 25;
  text("Audio frame start: " + audioFrameStart(), 25, y += 25);
  text("Audio frame end: " + audioFrameEnd(), 25, y += 25);
}

float attentionRadius() {
  return smoothAttention() * getScale();
}

void drawCircleWave() {
  int firstFrame = audioFrameStart();
  int lastFrame = audioFrameEnd();
  float attentionRadius = attentionRadius();
  float step = TWO_PI / (audioEventsPerFrame - 1);
  float start = 0;
  float end = step;
  float left;
  float right;
  boolean timeToStop = false;
  
  if (lastFrame > bufferSize) {
    lastFrame = bufferSize;
    timeToStop = true;
  }
  
  for(int i = firstFrame; i < lastFrame + 1; i++) {
      left = attentionRadius / 20 + leftChannel[i] * getScale() * 100;
      right = attentionRadius / 20 + left + rightChannel[i] * getScale() * 100;
    
      setLeftChannelColor();
      arc(width/2, height/2, attentionRadius + left, attentionRadius + left, start, end);
      setRightChannelColor();
      arc(width/2, height/2, attentionRadius + right, attentionRadius + right, start, end);
      start = end;
      end += step;
  }
  
  if (timeToStop) {
    exit();
  }
}

void drawAttentionCircle() {
  setAttentionColor();
  ellipse(width/2, height/2, attentionRadius(), attentionRadius());
}

void renderFrame() {
  drawCircleWave();
  drawAttentionCircle();
  
  debug();
}

void draw() {
  checkStopCondition();
  
  setBackgroundColor();
  noStroke();
  
  renderFrame();
  
  saveFrame(outputPath());
}
