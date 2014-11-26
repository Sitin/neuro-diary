Table table;
int i = 0;
int rowCount;
float radius;
float scale;
float med;
float att;

float med() {
  return table.getRow(i).getFloat("EEGMED"); 
}

float att() {
  return table.getRow(i).getFloat("EEGATT"); 
}

boolean hasMore() {
  return i < rowCount-1;
}

void next() {
  if (hasMore()) {
    i++;    
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

void setup() {
  size(800, 800);
  if (frame != null) {
    frame.setResizable(true);
  }
  
  frameRate(10);
  
  table = loadTable("../output/sample.csv", "header");  
  rowCount = table.getRowCount();  

  println(rowCount + " total rows in table"); 
}

void draw() {
  scale = getScale();
  att = att();
  med = med();
  
  background(65);
  noStroke();
  
  fill(127);
  ellipse(width/2, height/2, med * scale, med * scale);  
  
  fill(255);
  ellipse(med * scale, height - att * scale, 10, 10);
  
  ellipse(med * scale, height - att * scale, 10, 10);
  next();
}
