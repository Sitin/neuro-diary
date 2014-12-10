import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import java.io.File;
import java.io.FileNotFoundException;

boolean DEBUG = true;

String ____LINE____ = "---------------------------------";

//int START_FRAME = 11600;
//int START_FRAME = 8640;
int START_FRAME = 0;

int DEF_WIDTH = 1280;
int DEF_HEIGHT = 720;

//int DEF_WIDTH = 1920;
//int DEF_HEIGHT = 1080;

int FPE = 15;
int FPS = FPE * 2;
int renderFPS = 10;

int MUSIC_END_THRESHOLD = 10;

String CHARACTERISTIC = "MED";

Table table;
String csvFileName = "data/session.csv";
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

void setCharacteristicColor() {
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
  boolean sessionEndCondition = eventN() >= table.getRowCount() - 1;
  boolean musicEndCondition = (audioFrameEnd() - bufferSize) >= MUSIC_END_THRESHOLD;
  boolean timeToStop = sessionEndCondition || musicEndCondition;
  
  if (timeToStop) {
    reportRenderingStop();
    exit();
  }
}

void delete(File f) throws IOException, FileNotFoundException {
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
  return START_FRAME + frameCount - 1;
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
}

void analizeSampleBuffer() {
  bufferSize = sampleBuffer.getBufferSize();
  audioLength = bufferSize / sampleRate; 
  
  leftChannel = sampleBuffer.getChannel(0);
  rightChannel = sampleBuffer.getChannel(1);
}

void setup() {
  setupViewPort();
  setupMinim();
  setupTable();
  analizeSampleBuffer();
  prepareFileSystem();
  reportSetupStatus();
}

float recentCharacteristic() {
  return characteristicAt(eventN() - 1);
}

float nextCharacteristic() {
  return characteristicAt(eventN());
}

float smoothCharacteristic() {
  float start = recentCharacteristic();
  float end = nextCharacteristic();
  return start + (end - start) * transitionScore();
}

float characteristicAt(int eventN) {
  return eventN >= 0 ? table.getRow(eventN).getInt("EEG" + CHARACTERISTIC) : 0;
}

String datetimeAt(int eventN) {
  return eventN >= 0 ? table.getRow(eventN).getString("TS") : ""; 
}

String datetime() {
  return datetimeAt(eventN());
}

void debug() {
  if (!DEBUG) {
    return;
  }
  
  setDebugTextColor();
  
  int y = 25;  
  text("Frame: " + frameN(), 25, y += 25);
  text("Event: " + eventN(), 25, y += 25);
  
  y += 25;
  text("DateTime: " + datetime(), 25, y += 25);  
  text(CHARACTERISTIC + ": " + smoothCharacteristic(), 25, y += 25);
  text(CHARACTERISTIC + " radius: " + characteristicRadius(), 25, y += 25);  
  text("Last " + CHARACTERISTIC + ": " + recentCharacteristic(), 25, y += 25);
  text("Next " + CHARACTERISTIC + ": " + nextCharacteristic(), 25, y += 25);
  
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

void reportSetupStatus() {
  println(____LINE____);
  println(rowCount + " total rows in table");
  println(sampleRate + " frames per second");
  println(bufferSize + " frames");
  println(audioLength + " seconds");
  println(____LINE____);
  println("First frame: " + frameN());
  println("First audio frame: " + audioFrameStart());
  println(____LINE____);
  println("Rendering...");
}

void reportRenderingStop() {
  println(____LINE____);
  println("Rendering completed in " + float(millis()) / 1000 + " seconds.");
  println(____LINE____);
  println("Events processed: " + (eventN() - 1));
  println("Frames rendered: " + (frameN() - 1));
  println("Audio frames visualized: " + (audioFrameStart() - 1));
  println(____LINE____);
  println("Rows total: " + table.getRowCount());
  println("Buffer size:" + bufferSize);
  println(____LINE____);
}

float characteristicRadius() {
  return smoothCharacteristic() * getScale();
}

void drawCircleWave() {
  boolean timeToStop = false;
  
  int firstFrame = audioFrameStart();
  int lastFrame = audioFrameEnd();
  
  float characteristicRadius = characteristicRadius();
  float step = TWO_PI / (audioEventsPerFrame - 1);
  
  if (lastFrame >= bufferSize) {
    lastFrame = bufferSize - 1;
    step = TWO_PI / (lastFrame - firstFrame - 1);
  }
  
  float start = 0;
  float end = step;
  float left;
  float right;
  
  for(int i = firstFrame; i < lastFrame + 1; i++) {
      left = characteristicRadius / 20 + leftChannel[i] * getScale() * 100;
      right = characteristicRadius / 20 + left + rightChannel[i] * getScale() * 100;
    
      setLeftChannelColor();
      arc(width/2, height/2, characteristicRadius + left, characteristicRadius + left, start, end);
      setRightChannelColor();
      arc(width/2, height/2, characteristicRadius + right, characteristicRadius + right, start, end);
      start = end;
      end += step;
  }
}

void drawCharacteristicCircle() {
  setCharacteristicColor();
  ellipse(width/2, height/2, characteristicRadius(), characteristicRadius());
}

void renderFrame() {
  setBackgroundColor();
  noStroke();
  
  drawCircleWave();
  drawCharacteristicCircle();
  
  debug();
}

void draw() {
  checkStopCondition();
  
  renderFrame();
  
  saveFrame(outputPath());
}
