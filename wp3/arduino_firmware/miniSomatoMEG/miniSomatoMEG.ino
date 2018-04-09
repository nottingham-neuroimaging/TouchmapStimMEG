#include <SPI.h>

const int frequency_length = 3;
const int stim_length = 4;  //will be delivered in milliseconds

int frequency = 100;
int stim_ms = 0000;
int piezoPin = 7;
unsigned long ti = 0;
unsigned long period = 0;
unsigned long stim_us = 0;

void setup() {
  Serial.begin(9600);
  Serial.setTimeout(5);
  Serial.println("Arduino miniSomatoMEG: Ready");
  SPI.begin();
  pinMode(piezoPin, OUTPUT);
}//close setup

void serialEvent()
{
  //reset_pot();
  char input_1[frequency_length + 1];
  char input_2[stim_length + 1];
  while (Serial.available())
  {
    byte size = Serial.readBytes(input_1, frequency_length);
    // Add the final 0 to end the C string
    input_1[size] = 0;
    size = Serial.readBytes(input_2, stim_length);
    // Add the final 0 to end the C string
    input_2[size] = 0;
  }
  //Serial.println(input_1);
  frequency = atoi(input_1);

  //Serial.println(input_2);
  stim_ms = atoi(input_2);
  stim_us = 1000 * (long)stim_ms; //convert ms to us
  period = floor(1000000 / (long)frequency); // in microseconds
  ti = micros();
}

void loop() {
  while ((micros() - ti) <= stim_us) {
    go_pwm(piezoPin, period, ti);
  }
  digitalWrite(piezoPin, LOW);
}

void go_pwm(int Pin, unsigned long T, unsigned long t) {
  unsigned long now = micros() - t;
  if (now % T <= 0.5 * T) {
    digitalWrite(Pin, HIGH);
  } else {
    digitalWrite(Pin, LOW);
  }
}


