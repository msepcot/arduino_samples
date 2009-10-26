/*
 === Morse Code ===
 
 Encode user input to Morse Code representation and flash.
 
 The circuit:
 * LED connected from digital pin 13 to ground.
 
 * Note: On most Arduino boards, there is already an LED on the board
   connected to pin 13, so you don't need any extra components for this 
   example.
 
 International Morse code is composed of five elements:

   1. short mark, dot or 'dit' (·) - one unit long
   2. longer mark, dash or 'dah' (-) - three units long
   3. intra-character gap (between the dots and dashes within a character) 
      - one unit long
   4. short gap (between letters) - three units long
   5. medium gap (between words) - seven units long

 Character    Code                Character    Code
  A            · -                 0            - - - - -
  B            - · · ·             1            · - - - -
  C            - · - ·             2            · · - - -
  D            - · ·               3            · · · - -
  E            ·                   4            · · · · -
  F            · · - ·             5            · · · · ·
  G            - - ·               6            - · · · ·
  H            · · · ·             7            - - · · ·
  I            · ·                 8            - - - · ·
  J            · - - -             9            - - - - ·
  K            - · -               .            · - · - · -
  L            · - · ·             ,            - - · · - -
  M            - -                 ?            · · - - · ·
  N            - ·                 '            · - - - - ·
  O            - - -               !            - · - · - -
  P            · - - ·             /            - · · - ·
  Q            - - · -             (            - · - - ·
  R            · - ·               )            - · - - · -
  S            · · ·               &            · - · · ·
  T            -                   :            - - - · · ·
  U            · · -               ;            - · - · - ·
  V            · · · -             =            - · · · -
  W            · - -               +            · - · - ·
  X            - · · -             -            - · · · · -
  Y            - · - -             _            · · - - · -
  Z            - - · ·             "            · - · · - ·
  Understood   · · · - ·           $            · · · - · · -
  Invite       - · -               @            · - - · - ·
  End Work     · · · - · -         Wait         · - · · ·
  Start Work   - · - · -           Error        · · · · · · · ·
 
 Created 4 October 2009
 By Michael J Sepcot (michael.sepcot@gmail.com)
 
 */

#define DEBUG                   // if defined, print debug info to serial
#define MAX_LENGTH 128          // serial buffer can hold up to 128 bytes
#define UNIT_DELAY 100          // size of one unit (dot) in milliseconds

int ledPin =  13;               // LED connected to digital pin 13

// The setup() method runs once, when the sketch starts
void setup() {
  pinMode(ledPin, OUTPUT);      // sets the digital pin as output
  Serial.begin(9600);           // opens serial port, sets data rate to 9600 bps
}

// The loop() method runs over and over again, as long as the Arduino has power
void loop() {
  char message[MAX_LENGTH + 1]; // plus one for NULL termination bit
  int messageSize = 0;          // characters in message
  
  while (!Serial.available());  // wait for input
  delay(10);                    // slight delay for the serial buffer to fill up
  while (Serial.available() && messageSize < MAX_LENGTH) {
    int c = Serial.read();      // read the incoming byte
    if (c == 13) break;         // break at Carriage Return
    message[messageSize++] = c; // add character to message
  }
  message[messageSize] = 0;     // NULL terminate the message
  
  #ifdef DEBUG
  Serial.print(message);
  Serial.print(": ");
  #endif
  
  for(int position = 0; position < messageSize; position++) {
    int* morseCode = morseCodeSequence(message[position]);
    if (morseCode == NULL) break;
    
    if (message[position] == ' ') {
      delay(UNIT_DELAY * 7);                 // medium gap
      continue;                              // skip to the next character
    } else if (position > 0 && message[position - 1] != ' ') {
     delay(UNIT_DELAY * 3);                  // short gap 
    }
    
    int flash = 0;
    do {
      if (morseCode[flash] == 0) break;      // end of array
      if (flash > 0) delay(UNIT_DELAY);      // intra-character gap
      
      #ifdef DEBUG
      if (morseCode[flash] == 1) {
        Serial.print(". ");
      } else if (morseCode[flash] == 3) {
        Serial.print("- ");
      }
      #endif
      
      digitalWrite(ledPin, HIGH);            // set the LED on
      delay(UNIT_DELAY * morseCode[flash]);  // wait for appropriate timing
      digitalWrite(ledPin, LOW);             // set the LED off
      
      flash++;
    } while(true);
    free(morseCode);
    
    #ifdef DEBUG
    Serial.print("  ");
    #endif
  }
  #ifdef DEBUG
  Serial.println();
  #endif
}

// The morseCodeSequence function takes a character as input and returns a
// memory allocated integer array (0 terminated) representing the delay of
// characters units (dot = 1, dash = 3). We return the error sequence (8 dots)
// for an unknown character.
int* morseCodeSequence(char c) {
  int *array = (int *)calloc(9, sizeof(int)); // allocate and initialize memory
  if (array == NULL) return NULL;             // check if allocation succeeded
  
  if (c > 96 && c < 123) c = c - 32;          // upcase
  
  switch(c) {
    case 'A':
      array[0] = 1;
      array[1] = 3;
      break;
    case 'B':
      array[0] = 3;
      array[1] = 1;
      array[2] = 1;
      array[3] = 1;
      break;
    case 'C':
      array[0] = 3;
      array[1] = 1;
      array[2] = 3;
      array[3] = 1;
      break;
    case 'D':
      array[0] = 3;
      array[1] = 1;
      array[2] = 1;
      break;
    case 'E':
      array[0] = 1;
      break;
    case 'F':
      array[0] = 1;
      array[1] = 1;
      array[2] = 3;
      array[3] = 1;
      break;
    case 'G':
      array[0] = 3;
      array[1] = 3;
      array[2] = 1;
      break;
    case 'H':
      array[0] = 1;
      array[1] = 1;
      array[2] = 1;
      array[3] = 1;
      break;
    case 'I':
      array[0] = 1;
      array[1] = 1;
      break;
    case 'J':
      array[0] = 1;
      array[1] = 3;
      array[2] = 3;
      array[3] = 3;
      break;
    case 'K':
      array[0] = 3;
      array[1] = 1;
      array[2] = 3;
      break;
    case 'L':
      array[0] = 1;
      array[1] = 3;
      array[2] = 1;
      array[3] = 1;
      break;
    case 'M':
      array[0] = 3;
      array[1] = 3;
      break;
    case 'N':
      array[0] = 3;
      array[1] = 1;
      break;
    case 'O':
      array[0] = 3;
      array[1] = 3;
      array[2] = 3;
      break;
    case 'P':
      array[0] = 1;
      array[1] = 3;
      array[2] = 3;
      array[3] = 1;
      break;
    case 'Q':
      array[0] = 3;
      array[1] = 3;
      array[2] = 1;
      array[3] = 3;
      break;
    case 'R':
      array[0] = 1;
      array[1] = 3;
      array[2] = 1;
      break;
    case 'S':
      array[0] = 1;
      array[1] = 1;
      array[2] = 1;
      break;
    case 'T':
      array[0] = 3;
      break;
    case 'U':
      array[0] = 1;
      array[1] = 1;
      array[2] = 3;
      break;
    case 'V':
      array[0] = 1;
      array[1] = 1;
      array[2] = 1;
      array[3] = 3;
      break;
    case 'W':
      array[0] = 1;
      array[1] = 3;
      array[2] = 3;
      break;
    case 'X':
      array[0] = 3;
      array[1] = 1;
      array[2] = 1;
      array[3] = 3;
      break;
    case 'Y':
      array[0] = 3;
      array[1] = 1;
      array[2] = 3;
      array[3] = 3;
      break;
    case 'Z':
      array[0] = 3;
      array[1] = 3;
      array[2] = 1;
      array[3] = 1;
      break;
    case '0':
      array[0] = 3;
      array[1] = 3;
      array[2] = 3;
      array[3] = 3;
      array[4] = 3;
      break;
    case '1':
      array[0] = 1;
      array[1] = 3;
      array[2] = 3;
      array[3] = 3;
      array[4] = 3;
      break;
    case '2':
      array[0] = 1;
      array[1] = 1;
      array[2] = 3;
      array[3] = 3;
      array[4] = 3;
      break;
    case '3':
      array[0] = 1;
      array[1] = 1;
      array[2] = 1;
      array[3] = 3;
      array[4] = 3;
      break;
    case '4':
      array[0] = 1;
      array[1] = 1;
      array[2] = 1;
      array[3] = 1;
      array[4] = 3;
      break;
    case '5':
      array[0] = 1;
      array[1] = 1;
      array[2] = 1;
      array[3] = 1;
      array[4] = 1;
      break;
    case '6':
      array[0] = 3;
      array[1] = 1;
      array[2] = 1;
      array[3] = 1;
      array[4] = 1;
      break;
    case '7':
      array[0] = 3;
      array[1] = 3;
      array[2] = 1;
      array[3] = 1;
      array[4] = 1;
      break;
    case '8':
      array[0] = 3;
      array[1] = 3;
      array[2] = 3;
      array[3] = 1;
      array[4] = 1;
      break;
    case '9':
      array[0] = 3;
      array[1] = 3;
      array[2] = 3;
      array[3] = 3;
      array[4] = 1;
      break;
    case '.':
      array[0] = 1;
      array[1] = 3;
      array[2] = 1;
      array[3] = 3;
      array[4] = 1;
      array[5] = 3;
      break;
    case ',':
      array[0] = 3;
      array[1] = 3;
      array[2] = 1;
      array[3] = 1;
      array[4] = 3;
      array[5] = 3;
      break;
    case '?':
      array[0] = 1;
      array[1] = 1;
      array[2] = 3;
      array[3] = 3;
      array[4] = 1;
      array[5] = 1;
      break;
    case '\'':
      array[0] = 1;
      array[1] = 3;
      array[2] = 3;
      array[3] = 3;
      array[4] = 3;
      array[5] = 1;
      break;
    case '!':
      array[0] = 3;
      array[1] = 1;
      array[2] = 3;
      array[3] = 1;
      array[4] = 3;
      array[5] = 3;
      break;
    case '/':
      array[0] = 3;
      array[1] = 1;
      array[2] = 1;
      array[3] = 3;
      array[4] = 1;
      break;
    case '(':
      array[0] = 3;
      array[1] = 1;
      array[2] = 3;
      array[3] = 3;
      array[4] = 1;
      break;
    case ')':
      array[0] = 3;
      array[1] = 1;
      array[2] = 3;
      array[3] = 3;
      array[4] = 1;
      array[5] = 3;
      break;
    case '&':
      array[0] = 1;
      array[1] = 3;
      array[2] = 1;
      array[3] = 1;
      array[4] = 1;
      break;
    case ':':
      array[0] = 3;
      array[1] = 3;
      array[2] = 3;
      array[3] = 1;
      array[4] = 1;
      array[5] = 1;
      break;
    case ';':
      array[0] = 3;
      array[1] = 1;
      array[2] = 3;
      array[3] = 1;
      array[4] = 3;
      array[5] = 1;
      break;
    case '=':
      array[0] = 3;
      array[1] = 1;
      array[2] = 1;
      array[3] = 1;
      array[4] = 3;
      break;
    case '+':
      array[0] = 1;
      array[1] = 3;
      array[2] = 1;
      array[3] = 3;
      array[4] = 1;
      break;
    case '-':
      array[0] = 3;
      array[1] = 1;
      array[2] = 1;
      array[3] = 1;
      array[4] = 1;
      array[5] = 3;
      break;
    case '_':
      array[0] = 1;
      array[1] = 1;
      array[2] = 3;
      array[3] = 3;
      array[4] = 1;
      array[5] = 3;
      break;
    case '"':
      array[0] = 1;
      array[1] = 3;
      array[2] = 1;
      array[3] = 1;
      array[4] = 3;
      array[5] = 1;
      break;
    case '$':
      array[0] = 1;
      array[1] = 1;
      array[2] = 1;
      array[3] = 3;
      array[4] = 1;
      array[5] = 1;
      array[6] = 3;
      break;
    case '@':
      array[0] = 1;
      array[1] = 3;
      array[2] = 3;
      array[3] = 1;
      array[4] = 3;
      array[5] = 1;
      break;
    default: // error sequence
      for(int i = 0; i < 8; i++) array[i] = 1;
      break;
  }
  
  return array;
}
