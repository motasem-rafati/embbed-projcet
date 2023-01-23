#line 1 "C:/Users/iGeeK/Desktop/pro/MyProject.c"


unsigned char EIEdge = 0;
unsigned int CounterRF = 0;
unsigned int Period = 0;
unsigned int count=0;
unsigned int count2=0;
unsigned char pump=0;
unsigned char Distance = 100;
unsigned int Delay_Counter = 0;
unsigned int angle;
 unsigned char HL=0;

void CalculateDistance(void);
void Delayms(unsigned int Time) ;
void CCPPWM_init(void);


void Interrupt(void)
{


 if(INTCON & 0x02)
 {
 if(EIEdge == 0)
 {

 TMR0 = 6;

 CounterRF = 0;
 OPTION_REG = OPTION_REG & 0xBF;

 EIEdge++;
 }
 else
 {



 Period = (CounterRF * 250) + (TMR0 - 6);

 Distance = (17 * Period)/1000;




 OPTION_REG = OPTION_REG | 0x40;

 EIEdge = 0;
 }
 INTCON = INTCON & 0xFD;
 }


 if(INTCON & 0x04)
 {
 TMR0 = 6;
 if(count==10000){
 pump=1;
 count=0;
 }


 CounterRF++;
 Delay_Counter++;
 INTCON = INTCON & 0xFB;
 count++;

 }
 if(PIR1&0x04){
 if(HL){
 CCPR1H= angle >>8;
 CCPR1L= angle;
 HL=0;
 CCP1CON=0x09;
 TMR1H=0;
 TMR1L=0;
 }
 else{
 CCPR1H= (40000 - angle) >>8;
 CCPR1L= (40000 - angle);
 CCP1CON=0x08;
 HL=1;
 TMR1H=0;
 TMR1L=0;

 }

 PIR1=PIR1&0xFB;
 }


}


void main()
{
 TRISB = 0xFF;
 TRISC = 0x00;
 PORTC = 0x00;
 TRISD = 0x00;
 PORTD = 0x00;


 T1CON=0x01;
 INTCON = 0xF0;
 OPTION_REG = 0x40;


PIE1=PIE1|0x04;
 TMR1H=0;
TMR1L=0;
 CCPR1H=2000>>8;
CCPR1L=2000;
angle=1100;
 CCPPWM_init(void);
 while(1)
 {
 CalculateDistance();
 angle=1200;



 if(Distance < 10 )
 {
 PORTD = 0x00;
 CCPR2L=0;
 Delayms(500);
 PORTD = 0x50;
 Delayms(1);
 CCPR2L=150;
 Delayms(1000);

 }
 else
 {
 PORTD = 0x30;
 Delayms(1);
 PORTD = 0x38;
 Delayms(1);
 if(pump){
 for( count2=0 ;count2 < 1000 ; count2++){
 CalculateDistance();
 if(Distance < 10 ) {
 PORTD = 0x50;
 Delayms(1000);
 }
 else {
 PORTD=0xB8;
 Delayms(1);
 PORTD=0xB0;
 Delayms(1);
 }
 }
 pump=0;
 }

 angle=3500;

 }
 }

}

void CCPPWM_init(void){
 T2CON = 0x27;
 CCP2CON = 0x0C;
 PR2 = 250;
 CCPR2L=150 ;
}

void Delayms(unsigned int Time)
{
 TMR0 = 6;


 Delay_Counter = 0;
 Time = Time * 4;

 while (Delay_Counter < Time);
}

void CalculateDistance(void)
{
unsigned char i;
 PORTC = PORTC | 0x01;
for(i=0 ;i<22 ;i++);
 PORTC = PORTC & 0xFE;
}
