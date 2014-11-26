Table table;
int i = 0;
int rowCount;
float radius;

float med() {
  return table.getRow(i).getFloat("EEGMED"); 
}

boolean hasMore() {
  return i < rowCount;
}

float nextMed() {
  float med;
  if (hasMore()) {
    med = med();
    i++;
    return med;    
  } else {
    return 0.0;
  }
}

float nextRadius() {
  return getScale() * nextMed();
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
  
  table = loadTable("../output/sample.csv", "header");  
  rowCount = table.getRowCount();  

  println(rowCount + " total rows in table"); 
}

void draw() {
  radius = nextRadius();
  background(65);
  noStroke();
  fill(255);  
  ellipse(width/2, height/2, radius, radius);
  
  // Loop
  if (!hasMore()) {
    i = 0;
  }
}
