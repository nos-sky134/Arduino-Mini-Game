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
 *  The player(an circle) to move left if the pot value is 0 and right if the pot is moved to its highest value (425) 
 *  Pressing the button will cause the Player to shoot a rectangular bullet that moves up the screen, the bullet will disappear when it when reaches the top of the screen or hits an enemy
 *  Hiting an enemy will cause the hit counter on the upper right part of the screen to increase
 *  Hiting an enemy will cause the enemy that got hit to dissapear 
 *  Getting a hit will also cause the RGB LED to change colours depending on the number of hits (1=red, 2=orange, 3=yellow, 4= green, dead= blue)
 *  If at least one enemy get to move to the bottom of the screen, all the eneies will disappear and a text that will appear in the middle of the screen that says “You Lose”
 *  If you manage to kill all the enemies before you get to the bottom of the screen, then the text at the middle of the screen will say “You win!”
 * Players can only shoot one bullet at a time, but they could aim by pressing the button again while the bullet is still moving up,
 * This will cause the bullet to shift left or right to the players current position 
 *
 *  You could still shoot after wining/losing 
 *  NOTE: When you run processing, you might get an error that "Error, disabling serialEvent() for COM3 null", just pull the Arduino out and plug it in again
 *  NOTE: The RGB led I'm using might be different than the LED you are using, (I'm using a common cathode) if the colours are diffrernt or the LED does not light up, try a different connfiguraton 
 **********************************************************************************************************************************
 
 */
int redPin = 11;
int greenPin = 10;
int bluePin = 9;

int pot_pin = A0;   // Initializing the Potentiometer pin

int buttonPin = 13;

int pot_output;     // Declaring a variable for potentiometer output

int buttonValue = 0;

void setup ( ) {

  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  Serial.begin(9600);       // Starting the serial communication at 9600 baud rate
  //test function 
  //test(); 
}

//don't touch anything when running this test
void test() {
  int diff;
  int absDiff=0;
  int potArray[3];    //stores a bunch of POT values to see if there is a large difference bwtween them
  blinkColour();    //checks all three colours on the LED are working correctly by blinking them

  for (int i = 0; i < 3; i++) {
    potArray[i] = analogRead (pot_pin);   //read from the pot
    delay(500);   //wait a bit
  }

  diff = potArray[0] - potArray[1];
  checkDifference(diff);
  diff = potArray[1] - potArray[2];
  checkDifference(diff);
  diff = potArray[2] - potArray[0];
  checkDifference(diff);
  //if there is a large difference in the Pot values, then it should print that something is wrong

  buttonValue = digitalRead(buttonPin);
  if(buttonValue){    //check if the button is grounded or not 
    //what would've been printed if there was no processing
    //Serial.println("button is not connected");
    }
}

void checkDifference(int diff) {
  int absDiff;
  absDiff = abs(diff);
  if (absDiff > 4) {
    //what would've been printed if there was no processing
    //Serial.println("Pot is not connected");
  }
}


void loop ( ) {

  pot_output = analogRead (pot_pin); // Reading from the potentiometer

  int mapped_output = map (pot_output, 0, 1023, 0, 425); // Map the output of potentiometer to 0-425 to be read by the Processing IDE
  buttonValue = digitalRead(buttonPin);

  Serial.print (mapped_output);     // Sending the mapped POT value to Processing IDE

  Serial.print (" ");     // Space helps me tell when the numbers end and the button state begins  
  if (buttonValue) {
    Serial.println ("true");     // Sends "True" if button is pressed,
  }
  else {
    Serial.println ("false");     // Sends "False" if button is not pressed,
  }


  if (Serial.available ( ) > 1) {   // Check if the Processing IDE has send a value or not
    char state = Serial.read();    // Reading the data received and saving in the state variable
    if (state == '0') {     // If received data is '0', then turn off led
      setColor(0, 0, 0);  // no colour
    }
    if ( state == '1')            // If received data is '1',
    {
      setColor(255, 0, 0);  // red
    }
    if ( state == '2')            // If received data is '2',
    {
      setColor(255, 50, 0); //orange
    }
    if ( state == '3')            // If received data is '3',
    {
      setColor(255, 255, 0); //yellow
    }
    if ( state == '4')            // If received data is '4',
    {
      setColor(0, 255, 0);  // green
    }
    if ( state == 'D')            // If received data is 'D' (for dead),
    {
      setColor(0, 0, 255);  // blue=dead
    }
  }
  delay(10);
}

//used to check if the LEDs are working
void blinkColour() {
  setColor(255, 0, 0); // Red
  delay(100);
  setColor(0, 255, 0); // Green
  delay(100);
  setColor(0, 0, 255); // Blue
  delay(100);
  setColor(0, 0, 0);
}

void setColor(int red, int green, int blue)
{
#ifdef COMMON_ANODE
  red = 255 - red;
  green = 255 - green;
  blue = 255 - blue;
#endif
  analogWrite(redPin, red);
  analogWrite(greenPin, green);
  analogWrite(bluePin, blue);
}
