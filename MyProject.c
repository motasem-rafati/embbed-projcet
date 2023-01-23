// ========================================================== Variables ====================================================

unsigned char EIEdge = 0;              //to control External Interrupt raising and falling edge
unsigned int CounterRF = 0;            // Increased by one every 250uS ues to calculate Distance
unsigned int Period = 0;              // Used to measure the Distance for the ultrasonic sensor
unsigned int count=0;                 // count for pump
unsigned int count2=0;
unsigned char pump=0;                 // for the pump to be ON or OFF
unsigned char Distance = 100;         // Distance between the car and the wall in cm
unsigned int Delay_Counter = 0;       // Counter to generate a delay
unsigned int angle;
  unsigned char HL=1;
// ========================================================== functions  ==========================================================
void CalculateDistance(void);
void Delayms(unsigned int Time) ;
void CCPPWM_init(void);

// ========================================================== Interrupts ==========================================================
void Interrupt(void)
{

 // * RB0 External Interrupt *
 if(INTCON & 0x02)
 {
  if(EIEdge == 0)   // True when a raising edge triggers RB0
  {                                // (start counting!)

   TMR0 = 6;                       // Load 6 in timer0, so it will over-flow after 250 counts
                                   // Timer0 over-flow Interrupt every 250uS
   CounterRF = 0;            // initializing with zero
   OPTION_REG = OPTION_REG & 0xBF; // Interrupt edge select bit = 0
                                   // External interrupt will trigger at the next incoming falling edge
   EIEdge++;        // increase the counter by one to get into "else" at the next incoming falling edge
  }
  else                             // True when a falling edge triggers RB0
  {                                // stop counting and calculate the overall Period and Distance



   Period = (CounterRF * 250) + (TMR0 - 6); // Overall Period = Over-flow Counts * 250uS + (Timer0 value in uS - 6us)
                                   //  The speed of sound=0.034
   Distance = (17 * Period)/1000;  // Distance = (The speed of sound) * (Period in uS)
                                   // Since the Distance is measured twice (back and forth) --> Distance must be divided by 2
                                   // Distance = (0.017 cm/uS)        * (Period in uS)


   OPTION_REG = OPTION_REG | 0x40; // Interrupt edge select bit = 1
                                   // External interrupt will trigger at the next incoming raising edge
   EIEdge = 0;                    // next incoming raising edge
  }
  INTCON = INTCON & 0xFD;          // Clear INTF
 }

 // * Timer0 over-flow Interrupt *
 if(INTCON & 0x04)
 {
  TMR0 = 6;                        // Load 6 in timer0, so it will over-flow after 250 counts
          if(count==10000){   //  10000*250us=2.5S
           pump=1;             // ready to pump
           count=0;
          }


  CounterRF++;               // Increase the over-flow counts by one
  Delay_Counter++;           // Increase the delay counts by one
  INTCON = INTCON & 0xFB;    // Clear T0IF
      count++;               // incress every 250us

 }
  if(PIR1&0x04){//CCP1 interrupt  RC2 for servo
   if(HL){ //high
     CCPR1H= angle >>8;
     CCPR1L= angle;
     HL=0;//next time low
     CCP1CON=0x09;//next time Falling edge
     TMR1H=0;
     TMR1L=0;
   }
   else{  //low
     CCPR1H= (40000 - angle) >>8;
     CCPR1L= (40000 - angle);
     CCP1CON=0x08; //next time rising edge
     HL=1; //next time High
     TMR1H=0;
     TMR1L=0;

   }

 PIR1=PIR1&0xFB;
 }


}
// ========================================================== Main ==========================================================

void main()
{
 TRISB = 0xFF;                     // PORTB as an input
 TRISC = 0x00;                     // PORTC as an output
 PORTC = 0x04;                     // PORTC as LOW
 TRISD = 0x00;                     // PORTD as an output
 PORTD = 0x00;                     // PORTD as LOW
TMR1H=0;
TMR1L=0;
    OPTION_REG = 0x40;                // Interrupt edge select bit = 1
                                   // External interrupt will trigger at the raising edge
                                   // Prescaler rate for Timer0 is 1:2
 T1CON=0x01;//TMR1 On Fosc/4 (inc 0.5uS) with 0 prescaler (TMR1 overflow after 0xFFFF counts ==65535)==> 32.767ms
 INTCON = 0xF0;                    // GIE, T0IE,T1IE,INTE, and RBIE are enabled

PIE1=PIE1|0x04;// Enable CCP1 interrupts

CCPR1H=2000>>8;
CCPR1L=2000;
angle=1100; //600us initially == 1000*0.5=500
 //CCPPWM_init(void);     //we did't use it, had problem with servo for some reason
 while(1)
 {

  CalculateDistance();
        angle=1200;

                angle=3500;


  if(Distance < 10 )
  {
      PORTD = 0x00;     //stop everythings

       Delayms(500);
   PORTD = 0x52;          //RD3 SPEED OFF ,RD1 ON, RD4 led on RD 5 OFF RD6 BACKWARD
              Delayms(1);

   Delayms(2500);   //  time to go back

  }
  else
  {


            PORTD = 0xBA;     //RD1 ON, RD3 speed ON,RD4 leds RD5 forward RD6 off ,RD7 PUMP OFF

           if(pump){        //will pump water every 2.5sec
           for( count2=0 ;count2 < 1000 ; count2++){
             CalculateDistance();
             if(Distance < 10 ) {
                          PORTD = 0x00;
                              Delayms(500);
                          PORTD = 0x52;          //RD3 SPEED OFF RD4 led on RD 5 OFF RD6 BACKWARD
                             Delayms(2500);   //  time to go back
                                        }
                                        else {
                PORTD=0x3A;// PUMP RD7 ON RD56 FORWARD RD3 ON
                    Delayms(1);


                  }
                }
              pump=0;   //rest to 0 to wait 2.5S
           }



  }
 }

}
// ========================================================== PWM function ==========================================================
/*void CCPPWM_init(void){ //Configure CCP2 for motor 2  RC1
  T2CON = 0x27;//enable Timer2 at Fosc/4 with 1:16 prescaler (8 uS percount 2000uS to count 250 counts)
  CCP2CON = 0x0C;//enable PWM for CCP2
  PR2 = 250;     // 250 counts =8uS *250 =2ms period
   CCPR2L=50  ; //60% duty cycle
}                      */
// ========================================================== mS delay function ==========================================================
void Delayms(unsigned int Time) // A delay function that receives its time in milli-seconds
{
 TMR0 = 6;                            // Load 6 in timer0, so it will over-flow after 250 counts
                                      // Timer0 over-flow Interrupt every 250uS

 Delay_Counter = 0;                   // Start counting from zero
 Time = Time * 4;                     // 1mS = 4 * 250uS
                                      // Timer0 will over-flow every 250uS
 while (Delay_Counter < Time);       // Stuck here for "Time" in mS
}
// ========================================================== ultrasonic function ==========================================================
void CalculateDistance(void)
{ // The ultrasonic sensor TRIG pin needs to be triggered for 10uS at least
unsigned char i;
 PORTC = PORTC | 0x01;                        // RC0 = 1
for(i=0 ;i<22 ;i++);                          //ultrasonic TRIG need 10us delay 22*0.5us=11us
 PORTC = PORTC & 0xFE;                        // RC0 = 0
}