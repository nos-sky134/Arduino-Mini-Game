/*
 * Final Assignment
 * Emily Chen, April 2021
 * 
 * Description:
 * An Arduino project that uses serial communication on COM3 to communicate to Processing and play a simple game of Space Invaders
 * 
 * Circuit:
 * A RGB LED:  
 * red on digital pin 11
 * green on digital pin 10
 * blue on digital pin 9
 *  
 * button (w/ pulled down resistor) on digital pin 13
 *
 * Potentiometer on analog pin A0
 *
 *  Behavior:
 *  When the program is run, a black screen with a white circle, and four white blocks will appear 
 *  The enemies (four white blocks) will appear on the top of the screen
 *  The enemies will slowly move from side to side, when they move close to the either sides of the screen, they will change directions and descend down a little
 *  The player(an circle) to move left if the pot value is 0 and right if the pot is moved to its highest value  
 *  Pressing the button will cause the Player to shoot a rectangular bullet that moves up the screen, the bullet will disappear when it when reaches the top of the screen or hits an enemy
 *  Hiting an enemy will cause the hit counter on the upper right part of the screen to increase
 *  Getting a hit will also cause the RGB LED to change colours depending on the number of hits (1=red, 2=orange, 3=yellow, 4= green, dead= blue)
 *  If the enemies get to move to the bottom of the screen, a text that will appear in the middle of the screen that says “You Lose”
 *  If you manage to kill all the enemies before you get to the bottom of the screen, then the text at the middle of the screen will say “You win!”
 * Players can only shoot one bullet at a time, but they could aim by pressing the button again while the bullet is still moving up,
 * This will cause the bullet to shift left or right to the players current position 
 *
 * You could still shoot after wining/losing 
 *  NOTE: When you run processing, you might get an error that "Error, disabling serialEvent() for COM3 null", just pull the Arduino out and plug it in again
 *  NOTE: The RGB led I'm using might be different than the LED you are using, (I'm using a common cathode) if the colours are diffrernt or the LED does not light up, try a different connfiguraton 
 **********************************************************************************************************************************
 
 */

import processing.serial.*;    // Importing the serial library to communicate with the Arduino 

Serial myPort;      // Initializing a vairable named 'myPort' for serial communication

//enemy variables 
PShape square;
int enemyX=0;
int enemyY=25;
boolean enemySwitch; 
boolean lose= false;

//serial communcation variables 
float potValue;
boolean buttonPress;
String serialPort; 
String buttonString = "false"; 
int pos;    //position of space character 
int posEnd;    //position of end '/n' character 

//bullet and shooting variables 
int Hitcount=0; 
int lazerX=2;
int lazerY=500; 
boolean shootChange;
boolean shootBool;

//make a few enemy objects 
enemy[] allEnemy= new enemy[4];  //stores objects in an array for easy access

void setup ( ) {
  size (500, 500);     // Size of the serial window, you can increase or decrease as you want

  //stores the size and shape of the enemys 
  square = createShape(RECT, 0, 0, 50, 50);
  square.setFill(color(255, 255, 255));
  square.setStroke(false);

  //for each enemy object
  for (int i=0; i<4; i++)
  {
    allEnemy[i]=new enemy(25+ i*100, true);    //set the coordinates of each enemy (100 units apart), and make them alive
  }

  myPort  =  new Serial (this, "COM3", 9600); // Set the com port and the baud rate according to the Arduino IDE

  myPort.bufferUntil ( '\n' );   // Receiving the data from the Arduino IDE
} 

void serialEvent  (Serial myPort) {
  //format of serialPort is: <potValue> <true or false>\n 
  serialPort = myPort.readString();      //save entire string to string serialPort
  pos = serialPort.indexOf(" ");      //find where the numbers ends and the 'true'/'false'begins 
  posEnd = serialPort.indexOf("\n");      //find where the enire string ends 
  potValue  =  float (serialPort.substring(0, pos));      //convert the first few numbers into the int potValue 
  buttonString= serialPort.substring(pos+1, posEnd-1);      //save the word after the space into the buttonString (exclude '\n') 
  buttonPress  =  boolean(buttonString);      //convert the 'false' string to a false boolean or the 'true' string to true boolean
} 

class enemy
{
  int Xposition;     //holds the unique x corindates of each square 
  boolean isAlive;   //records whether the enemys should be drawn or not 

  enemy(int Xpos, boolean alive) { 
    Xposition= Xpos;
    isAlive = alive;
  }

  void drawEnemy() {
    shape(square, Xposition + enemyX, enemyY);    //draws the shape
  }
}

void collisionFunc() {
  for (int i=0; i<4; i++) {    //check the enemys that are still alive 
    if (allEnemy[i].isAlive) {       //Check if the bullet collides with the enemy... 
      if (lazerX<enemyX+ 50+ allEnemy[i].Xposition & lazerX+10>enemyX + allEnemy[i].Xposition) {
        //println("HIT!");    //check if collider is working 
        Hitcount= Hitcount+1;   
        shootBool= false;
        allEnemy[i].isAlive= false;
      }
    }
  }
}


void shoot() 
{
  rect(lazerX, lazerY, 10, 50);    //draws the bullet 
  if (shootBool) {    //if you are shooting
    if (lazerY>0) {    //if the bullet is not out of bounds 
      lazerY= lazerY-7;     //move forwards 
      if (lazerY<enemyY+50) {
        collisionFunc();
      }
    } else {
      shootBool= false;
    }
  }

  if (!shootBool) {    //if you are not shooting, place the bullet out of the screen so we can't see it 
    lazerY=500;
  }
}

void drawEnemy() {
  if (enemyX==100) {     //if enemys move too far to the right 
    enemySwitch= false;  //start moving left 
    enemyY= enemyY + 20;
  }

  if (enemyX==0) {     //if enemys move too far to the left 
    enemySwitch= true;     //start moving right 
    enemyY= enemyY + 20;
  }

  if (enemySwitch) {
    enemyX= enemyX + 1;    //move right
  } else {
    enemyX= enemyX - 1;    //move left
  }
  if (!lose) {
    for (int i=0; i<4; i++) {
      if (allEnemy[i].isAlive) {    //if the enemys are alive 
        allEnemy[i].drawEnemy();    //draw them
      }
    }
  }
}

void ledControl() {
  if (lose) {
    myPort.write ( 'D' ) ;     // If you are dead, don't bother checking your hit count and changing the colours to match that
  } else {
    if (Hitcount==0) {
      myPort.write ( '0' ) ;     // Send a '0' to the Arduino IDE
    }
    if (Hitcount==1) {
      myPort.write ( '1' ) ;       // send a '1' to the Arduino IDE
    }
    if (Hitcount==2) {
      myPort.write ( '2' ) ;       // send a '2' to the Arduino IDE
    }
    if (Hitcount==3) {
      myPort.write ( '3' ) ;     // Send a '3' to the Arduino IDE
    }
    if (Hitcount==4) {
      myPort.write ( '4' ) ;     // Send a '4' to the Arduino IDE
      win();
    }
  }
}

void win() {
  textSize(50);
  text("You Win!", 150, 250);
}


void lose() {
  textSize(50);
  lose= true; 
  text("You Lose!", 150, 250);
}

//prints the number of hits you made 
void hitCounter() {
  textSize(20);
  text("Hits: "+ Hitcount, 20, 30);
}

//checks if you've lost 
void checkLose() {
  int enemyLeft=4-Hitcount;    //number of enemys still alive  
  if (enemyY>350) {    //once your enemys gets to the bottom of the screen
    //check the enemys that are still alive 
    if (enemyLeft>0) {
      lose();    //if there are enemys left, you lose!
    }
  }
}


void draw ( ) {

  background(0, 0, 0);
  noStroke();
  ellipse( 35 + potValue, 450, 50, 50);    //this draws the plauer  
  drawEnemy();
  shoot();
  ledControl();    //send information back to the serial port
  hitCounter();    //print the hits 
  checkLose();    //check if you lost 

  if (buttonPress == true) { // if the button is pressed
    if (shootChange==false) {    //there has been a change in the buttons 
      shootBool= true;    //shoot 
      shootChange= true;     //reset the boolean
      lazerX=int(25 + potValue);
    }
  } 
  if (buttonPress == false) {  // if the button is not pressed
    if (shootChange==true) {    //there hasn just been a change in the buttons 
      shootChange= false;  //reset the boolean
    }
  }
}
