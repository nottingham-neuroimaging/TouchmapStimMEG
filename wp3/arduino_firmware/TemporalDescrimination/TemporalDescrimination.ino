#include <SPI.h>

const int delay_length = 5;

int piezoPins[] = {7, 8};

int start_delay=0;

long offset=0;
unsigned long pulse_lifetime = 20*1000; // We are in microseconds now!
unsigned long t1=0;
unsigned long t2=0;
unsigned long now = 0;


void setup() {
  Serial.begin(9600);
  Serial.setTimeout(5);
  Serial.println("Arduino: MEG Temporal Descimination Ready");
  SPI.begin(); 

    pinMode(piezoPins[0], OUTPUT);
    pinMode(piezoPins[1], OUTPUT);
}
 
void serialEvent()
{
   char input_1[delay_length + 1];
   while(Serial.available()) 
   {
      byte size = Serial.readBytes(input_1, delay_length);
      // Add the final 0 to end the C string
      input_1[size] = 0;
      start_delay =atoi(input_1);
   }
   offset = 1000*(long)start_delay;
   Serial.print(offset,DEC);
   Serial.print('\n');
   
   if (offset < 0){
      offset=offset*-1;
      piezoPins[0]=8;
      piezoPins[1]=7;
   }
   else{
      piezoPins[0]=7;
      piezoPins[1]=8;    
   }
   
   t1 = micros();
   t2 = (t1+offset);
   
  

   
   while (micros() < (t2 + 5*pulse_lifetime)) {
    
    now = micros();

    if (now < t1 + pulse_lifetime){
      digitalWrite(piezoPins[0], HIGH);
    } else { 
      digitalWrite(piezoPins[0], LOW);
    }

    if (now > t2 && now < (t2 + pulse_lifetime)){
      digitalWrite(piezoPins[1], HIGH);
    } else { 
      digitalWrite(piezoPins[1], LOW);
    }
    
   }
  digitalWrite(piezoPins[0], LOW);
  digitalWrite(piezoPins[1], LOW);
}

void loop() {
}



