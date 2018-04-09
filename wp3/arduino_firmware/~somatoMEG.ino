#include <SPI.h>

const int frequency_length = 3;
const int slave_length = 2;
const int channel_length = 2;
const int resistor_length = 3;
const int stim_length = 4;

int frequency = 100;
int channel = 01;
int resistor_level = 000;
int stim_ms = 0000;
//char strValue[word_length+1];
int slaveSelectPin = 99;
int index = 0;
int input_byte = 0;
int piezoPin = 8;
unsigned long ti = 0;
unsigned long period = 0;
unsigned long stim_us = 0;

void setup() {
  Serial.begin(9600);
  Serial.setTimeout(5);
  Serial.println("Arduino somatoMEG: Ready");
  SPI.begin();
  reset_pot();
  pinMode(piezoPin, OUTPUT);


}//close setup

void serialEvent()
{
  //reset_pot();
  char input_1[frequency_length + 1];
  char input_2[slave_length + 1];
  char input_3[channel_length + 1];
  char input_4[resistor_length + 1];
  char input_5[stim_length + 1];
  while (Serial.available())
  {
    byte size = Serial.readBytes(input_1, frequency_length);
    // Add the final 0 to end the C string
    input_1[size] = 0;
    size = Serial.readBytes(input_2, slave_length);
    // Add the final 0 to end the C string
    input_2[size] = 0;
    size = Serial.readBytes(input_3, channel_length);
    // Add the final 0 to end the C string
    input_3[size] = 0;
    size = Serial.readBytes(input_4, resistor_length);
    // Add the final 0 to end the C string
    input_4[size] = 0;
    size = Serial.readBytes(input_5, stim_length);
    // Add the final 0 to end the C string
    input_5[size] = 0;
  }
  //Serial.println(input_1);
  frequency = atoi(input_1);

  //Serial.println(input_2);
  slaveSelectPin = atoi(input_2);

  //Serial.println(input_3);
  channel = atoi(input_3);

  //Serial.println(input_4);
  resistor_level = atoi(input_4);

  //Serial.println(input_5);
  stim_ms = atoi(input_5);
  stim_us = 1000 * (long)stim_ms; //convert ms to us
  period = floor(1000000 / (long)frequency); // in microseconds
  ti = micros();
}

void loop() {
  digitalPotWrite(slaveSelectPin, channel, resistor_level);
  while ((micros() - ti) <= stim_us) {
    go_pwm(piezoPin, period, ti);
  }
  digitalWrite(piezoPin, LOW);
  digitalPotWrite(slaveSelectPin, channel, 000);
}

void digitalPotWrite(int slaveSelectPin, int address, int value) {
  digitalWrite(slaveSelectPin, LOW);
  SPI.transfer(address);
  SPI.transfer(value);
  digitalWrite(slaveSelectPin, HIGH);
}

void reset_pot() {
  int pinSelector[] = {3, 5, 6, 9, 10};
  for (int i = 0; i < sizeof(pinSelector); i++) {
    slaveSelectPin = pinSelector[i];
    pinMode(slaveSelectPin, OUTPUT);
    for (int j = 0; j < 6; j++) {
      digitalWrite(slaveSelectPin, LOW);
      SPI.transfer(j);
      SPI.transfer(0);
      digitalWrite(slaveSelectPin, HIGH);
    }
  }
}

void go_pwm(int Pin, unsigned long T, unsigned long t) {
  unsigned long now = micros() - t;
  if (now % T <= 0.5 * T) {
    digitalWrite(Pin, HIGH);
  } else {
    digitalWrite(Pin, LOW);
  }
}


