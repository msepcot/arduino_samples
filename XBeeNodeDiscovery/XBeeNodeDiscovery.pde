/*
 Created 23 November 2009
 By Michael J Sepcot (michael.sepcot@gmail.com)
 
 === Xbee Node Discovery ===
 
 In this project we setup our Xbee module with a Node Identifier and query
 for other nodes in our vicinity. Record the number of responses to our
 Node Discover command and flash the results on the LED on pin 13.
 
 == The Circuit ==
 
 This project makes use of the LED connected from digital pin 13 to ground
 found on most Arudino boards and the XBee Shield and Module.
 
 Information about the Xbee Shield and Arduino connections can be found here:
 
   http://www.arduino.cc/en/Main/ArduinoXbeeShield
 
 Information about the Xbee Module can be found here:
 
   http://www.digi.com/products/wireless/zigbee-mesh/xbee-zb-module.jsp
 
 == External Library ==
 
 This project makes use of the xbee-arduino library for communicating with
 Xbees in API mode. More information can be found here:
 
   http://code.google.com/p/xbee-arduino/
 
*/

#include <XBee.h>
#define DEBUG  // if defined, print debug info to serial

XBee xbee = XBee();
AtCommandRequest request = AtCommandRequest();
AtCommandResponse response = AtCommandResponse();

uint8_t SH[] = {'S','H'};  // Serial Number High
uint8_t SL[] = {'S','L'};  // Serial Number Low
uint8_t NI[] = {'N','I'};  // Node Identifier
uint8_t CH[] = {'C','H'};  // Operating Channel
uint8_t OP[] = {'O','P'};  // Operating Extended PAN ID
uint8_t OI[] = {'O','I'};  // Operating PAN ID
uint8_t ND[] = {'N','D'};  // Node Discover
uint8_t NT[] = {'N','T'};  // Node Discover Timeout

uint8_t NAME[] = {'M','I','C','H','A','E','L'};  // set the name of the node

int ledPin =  13;
int timeout = 5000;  // default value of NT (if NT command fails)

void setup() {
  pinMode(ledPin, OUTPUT);
  xbee.begin(9600);
  delay(1000);
}

void loop() {
  int nodeCount = 0;
  
  Serial.println("=== SETINTG UP NODE IDENTIFIER ===");
  request.setCommand(NI);
  request.setCommandValue(NAME);
  request.setCommandValueLength(sizeof(NAME));
  sendAtCommand();
  request.clearCommandValue();
  
  #ifdef DEBUG
  Serial.println("=== DEBUG INFO ===");
  request.setCommand(SH);
  sendAtCommand();
  request.setCommand(SL);
  sendAtCommand();
  request.setCommand(NI);
  sendAtCommand();
  request.setCommand(CH);
  sendAtCommand();
  request.setCommand(OI);
  sendAtCommand();
  request.setCommand(OP);
  sendAtCommand();
  #endif
  
  Serial.println("=== Node Discovery ===");
  
  // get the Node Discover Timeout (NT) value and set to timeout
  request.setCommand(NT);
  Serial.print("Sending command to the XBee ");
  xbee.send(request);
  Serial.println("");
  if (xbee.getResponse().getApiId() == AT_COMMAND_RESPONSE) {
    xbee.getResponse().getAtCommandResponse(response);
    if (response.isOk()) {
      if (response.getValueLength() > 0) {
        // NT response range should be from 0x20 - 0xFF, but
        // I see an inital byte set to 0x00, so grab the last byte
        timeout = response.getValue()[response.getValueLength() - 1] * 100;
      }
    }
  }
  
  request.setCommand(ND);
  Serial.print("Sending command to the XBee ");
  xbee.send(request);
  Serial.println("");
  
  while(xbee.readPacket(timeout)) {
    // should be receiving AT command responses
    if (xbee.getResponse().getApiId() == AT_COMMAND_RESPONSE) {
      xbee.getResponse().getAtCommandResponse(response);
      if (response.isOk()) {
        nodeCount++;
      }
    }
  }
  
  Serial.print("Results: ");
  Serial.print(nodeCount, DEC);
  Serial.println(" node(s) responded.");
  Serial.println("");
  
  // flash results
  delay(2000);  // wait 2 seconds for the user to look at the board...
  for(int i = 0; i < nodeCount; i++) {
    digitalWrite(ledPin, HIGH);  // set the LED on
    delay(500);
    digitalWrite(ledPin, LOW);   // set the LED off
    delay(500);
  }
  
  // hit the Arduino reset button to start the sketch over
  while(1) {};
}

void sendAtCommand() {
  Serial.print("Sending command to the XBee ");
  
  // send the command
  xbee.send(request);
  Serial.println("");
  
  // wait up to 1 second for the status response
  // we are just using this function for local queries, should be quick
  if (xbee.readPacket(1000)) {
    // got a response!
    
    // should be an AT command response
    if (xbee.getResponse().getApiId() == AT_COMMAND_RESPONSE) {
      xbee.getResponse().getAtCommandResponse(response);
      
      if (response.isOk()) {
        Serial.print("Command [");
        Serial.print(response.getCommand()[0]);
        Serial.print(response.getCommand()[1]);
        Serial.println("] was successful!");
        
        if (response.getValueLength() > 0) {
          Serial.print("Command value length is ");
          Serial.println(response.getValueLength(), DEC);
          
          Serial.print("Command value: ");
          for (int i = 0; i < response.getValueLength(); i++) {
            Serial.print(response.getValue()[i], HEX);
            Serial.print(" ");
          }
          Serial.println("");
        }
      } 
      else {
        Serial.print("Command return error code: ");
        Serial.println(response.getStatus(), HEX);
      }
    } else {
      Serial.print("Expected AT response but got ");
      Serial.println(xbee.getResponse().getApiId(), HEX);
    }   
  } else {
    // command failed
    if (xbee.getResponse().isError()) {
      Serial.print("Error reading packet.  Error code: ");  
      Serial.println(xbee.getResponse().getErrorCode(), DEC);
    } 
    else {
      Serial.println("No response from radio");  
    }
  }
  Serial.println("");
}
