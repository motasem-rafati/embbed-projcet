
_Interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;MyProject.c,19 :: 		void Interrupt(void)
;MyProject.c,23 :: 		if(INTCON & 0x02)
	BTFSS      INTCON+0, 1
	GOTO       L_Interrupt0
;MyProject.c,25 :: 		if(EIEdge == 0)   // True when a raising edge triggers RB0
	MOVF       _EIEdge+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_Interrupt1
;MyProject.c,28 :: 		TMR0 = 6;                       // Load 6 in timer0, so it will over-flow after 250 counts
	MOVLW      6
	MOVWF      TMR0+0
;MyProject.c,30 :: 		CounterRF = 0;            // initializing with zero
	CLRF       _CounterRF+0
	CLRF       _CounterRF+1
;MyProject.c,31 :: 		OPTION_REG = OPTION_REG & 0xBF; // Interrupt edge select bit = 0
	MOVLW      191
	ANDWF      OPTION_REG+0, 1
;MyProject.c,33 :: 		EIEdge++;        // increase the counter by one to get into "else" at the next incoming falling edge
	INCF       _EIEdge+0, 1
;MyProject.c,34 :: 		}
	GOTO       L_Interrupt2
L_Interrupt1:
;MyProject.c,40 :: 		Period = (CounterRF * 250) + (TMR0 - 6); // Overall Period = Over-flow Counts * 250uS + (Timer0 value in uS - 6us)
	MOVF       _CounterRF+0, 0
	MOVWF      R0+0
	MOVF       _CounterRF+1, 0
	MOVWF      R0+1
	MOVLW      250
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Mul_16X16_U+0
	MOVLW      6
	SUBWF      TMR0+0, 0
	MOVWF      R2+0
	CLRF       R2+1
	BTFSS      STATUS+0, 0
	DECF       R2+1, 1
	MOVF       R2+0, 0
	ADDWF      R0+0, 1
	MOVF       R2+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      R0+1, 1
	MOVF       R0+0, 0
	MOVWF      _Period+0
	MOVF       R0+1, 0
	MOVWF      _Period+1
;MyProject.c,42 :: 		Distance = (17 * Period)/1000;  // Distance = (The speed of sound) * (Period in uS)
	MOVLW      17
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVLW      232
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      _Distance+0
;MyProject.c,47 :: 		OPTION_REG = OPTION_REG | 0x40; // Interrupt edge select bit = 1
	BSF        OPTION_REG+0, 6
;MyProject.c,49 :: 		EIEdge = 0;                    // next incoming raising edge
	CLRF       _EIEdge+0
;MyProject.c,50 :: 		}
L_Interrupt2:
;MyProject.c,51 :: 		INTCON = INTCON & 0xFD;          // Clear INTF
	MOVLW      253
	ANDWF      INTCON+0, 1
;MyProject.c,52 :: 		}
L_Interrupt0:
;MyProject.c,55 :: 		if(INTCON & 0x04)
	BTFSS      INTCON+0, 2
	GOTO       L_Interrupt3
;MyProject.c,57 :: 		TMR0 = 6;                        // Load 6 in timer0, so it will over-flow after 250 counts
	MOVLW      6
	MOVWF      TMR0+0
;MyProject.c,58 :: 		if(count==10000){   //  10000*250us=2.5S
	MOVF       _count+1, 0
	XORLW      39
	BTFSS      STATUS+0, 2
	GOTO       L__Interrupt25
	MOVLW      16
	XORWF      _count+0, 0
L__Interrupt25:
	BTFSS      STATUS+0, 2
	GOTO       L_Interrupt4
;MyProject.c,59 :: 		pump=1;             // ready to pump
	MOVLW      1
	MOVWF      _pump+0
;MyProject.c,60 :: 		count=0;
	CLRF       _count+0
	CLRF       _count+1
;MyProject.c,61 :: 		}
L_Interrupt4:
;MyProject.c,64 :: 		CounterRF++;               // Increase the over-flow counts by one
	INCF       _CounterRF+0, 1
	BTFSC      STATUS+0, 2
	INCF       _CounterRF+1, 1
;MyProject.c,65 :: 		Delay_Counter++;           // Increase the delay counts by one
	INCF       _Delay_Counter+0, 1
	BTFSC      STATUS+0, 2
	INCF       _Delay_Counter+1, 1
;MyProject.c,66 :: 		INTCON = INTCON & 0xFB;    // Clear T0IF
	MOVLW      251
	ANDWF      INTCON+0, 1
;MyProject.c,67 :: 		count++;               // incress every 250us
	INCF       _count+0, 1
	BTFSC      STATUS+0, 2
	INCF       _count+1, 1
;MyProject.c,69 :: 		}
L_Interrupt3:
;MyProject.c,70 :: 		if(PIR1&0x04){//CCP1 interrupt
	BTFSS      PIR1+0, 2
	GOTO       L_Interrupt5
;MyProject.c,71 :: 		if(HL){ //high
	MOVF       _HL+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_Interrupt6
;MyProject.c,72 :: 		CCPR1H= angle >>8;
	MOVF       _angle+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;MyProject.c,73 :: 		CCPR1L= angle;
	MOVF       _angle+0, 0
	MOVWF      CCPR1L+0
;MyProject.c,74 :: 		HL=0;//next time low
	CLRF       _HL+0
;MyProject.c,75 :: 		CCP1CON=0x09;//next time Falling edge
	MOVLW      9
	MOVWF      CCP1CON+0
;MyProject.c,76 :: 		TMR1H=0;
	CLRF       TMR1H+0
;MyProject.c,77 :: 		TMR1L=0;
	CLRF       TMR1L+0
;MyProject.c,78 :: 		}
	GOTO       L_Interrupt7
L_Interrupt6:
;MyProject.c,80 :: 		CCPR1H= (40000 - angle) >>8;
	MOVF       _angle+0, 0
	SUBLW      64
	MOVWF      R3+0
	MOVF       _angle+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      156
	MOVWF      R3+1
	MOVF       R3+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;MyProject.c,81 :: 		CCPR1L= (40000 - angle);
	MOVF       R3+0, 0
	MOVWF      CCPR1L+0
;MyProject.c,82 :: 		CCP1CON=0x08; //next time rising edge
	MOVLW      8
	MOVWF      CCP1CON+0
;MyProject.c,83 :: 		HL=1; //next time High
	MOVLW      1
	MOVWF      _HL+0
;MyProject.c,84 :: 		TMR1H=0;
	CLRF       TMR1H+0
;MyProject.c,85 :: 		TMR1L=0;
	CLRF       TMR1L+0
;MyProject.c,87 :: 		}
L_Interrupt7:
;MyProject.c,89 :: 		PIR1=PIR1&0xFB;
	MOVLW      251
	ANDWF      PIR1+0, 1
;MyProject.c,90 :: 		}
L_Interrupt5:
;MyProject.c,93 :: 		}
L_end_Interrupt:
L__Interrupt24:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _Interrupt

_main:

;MyProject.c,96 :: 		void main()
;MyProject.c,98 :: 		TRISB = 0xFF;                     // PORTB as an input
	MOVLW      255
	MOVWF      TRISB+0
;MyProject.c,99 :: 		TRISC = 0x00;                     // PORTC as an output
	CLRF       TRISC+0
;MyProject.c,100 :: 		PORTC = 0x00;                     // PORTC as LOW
	CLRF       PORTC+0
;MyProject.c,101 :: 		TRISD = 0x00;                     // PORTD as an output
	CLRF       TRISD+0
;MyProject.c,102 :: 		PORTD = 0x00;                     // PORTD as LOW
	CLRF       PORTD+0
;MyProject.c,105 :: 		T1CON=0x01;//TMR1 On Fosc/4 (inc 0.5uS) with 0 prescaler (TMR1 overflow after 0xFFFF counts ==65535)==> 32.767ms
	MOVLW      1
	MOVWF      T1CON+0
;MyProject.c,106 :: 		INTCON = 0xF0;                    // GIE, T0IE,T1IE,INTE, and RBIE are enabled
	MOVLW      240
	MOVWF      INTCON+0
;MyProject.c,107 :: 		OPTION_REG = 0x40;                // Interrupt edge select bit = 1
	MOVLW      64
	MOVWF      OPTION_REG+0
;MyProject.c,110 :: 		PIE1=PIE1|0x04;// Enable CCP1 interrupts
	BSF        PIE1+0, 2
;MyProject.c,111 :: 		TMR1H=0;
	CLRF       TMR1H+0
;MyProject.c,112 :: 		TMR1L=0;
	CLRF       TMR1L+0
;MyProject.c,113 :: 		CCPR1H=2000>>8;
	MOVLW      7
	MOVWF      CCPR1H+0
;MyProject.c,114 :: 		CCPR1L=2000;
	MOVLW      208
	MOVWF      CCPR1L+0
;MyProject.c,115 :: 		angle=1100; //600us initially == 1000*0.5=500
	MOVLW      76
	MOVWF      _angle+0
	MOVLW      4
	MOVWF      _angle+1
;MyProject.c,116 :: 		CCPPWM_init(void);
	CALL       _CCPPWM_init+0
;MyProject.c,117 :: 		while(1)
L_main8:
;MyProject.c,119 :: 		CalculateDistance();
	CALL       _CalculateDistance+0
;MyProject.c,120 :: 		angle=1200;
	MOVLW      176
	MOVWF      _angle+0
	MOVLW      4
	MOVWF      _angle+1
;MyProject.c,124 :: 		if(Distance < 10 )
	MOVLW      10
	SUBWF      _Distance+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main10
;MyProject.c,126 :: 		PORTD = 0x00;     //stop everythings
	CLRF       PORTD+0
;MyProject.c,127 :: 		CCPR2L=0;
	CLRF       CCPR2L+0
;MyProject.c,128 :: 		Delayms(500);
	MOVLW      244
	MOVWF      FARG_Delayms_Time+0
	MOVLW      1
	MOVWF      FARG_Delayms_Time+1
	CALL       _Delayms+0
;MyProject.c,129 :: 		PORTD = 0x50;          //RD3 SPEED OFF RD4 led on RD 5 OFF RD6 BACKWARD
	MOVLW      80
	MOVWF      PORTD+0
;MyProject.c,130 :: 		Delayms(1);
	MOVLW      1
	MOVWF      FARG_Delayms_Time+0
	MOVLW      0
	MOVWF      FARG_Delayms_Time+1
	CALL       _Delayms+0
;MyProject.c,131 :: 		CCPR2L=150;
	MOVLW      150
	MOVWF      CCPR2L+0
;MyProject.c,132 :: 		Delayms(1000);   //  time to go back
	MOVLW      232
	MOVWF      FARG_Delayms_Time+0
	MOVLW      3
	MOVWF      FARG_Delayms_Time+1
	CALL       _Delayms+0
;MyProject.c,134 :: 		}
	GOTO       L_main11
L_main10:
;MyProject.c,137 :: 		PORTD = 0x30;       // RD3 speed off, RD4 leds ,RD5 forward RD6 off ,RD7 PUMP OFF
	MOVLW      48
	MOVWF      PORTD+0
;MyProject.c,138 :: 		Delayms(1);
	MOVLW      1
	MOVWF      FARG_Delayms_Time+0
	MOVLW      0
	MOVWF      FARG_Delayms_Time+1
	CALL       _Delayms+0
;MyProject.c,139 :: 		PORTD = 0x38;     // RD3 speed ON,RD4 leds RD5 forward RD6 off ,RD7 PUMP OFF
	MOVLW      56
	MOVWF      PORTD+0
;MyProject.c,140 :: 		Delayms(1);
	MOVLW      1
	MOVWF      FARG_Delayms_Time+0
	MOVLW      0
	MOVWF      FARG_Delayms_Time+1
	CALL       _Delayms+0
;MyProject.c,141 :: 		if(pump){        //will pump water every 2.5sec
	MOVF       _pump+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main12
;MyProject.c,142 :: 		for( count2=0 ;count2 < 1000 ; count2++){
	CLRF       _count2+0
	CLRF       _count2+1
L_main13:
	MOVLW      3
	SUBWF      _count2+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main27
	MOVLW      232
	SUBWF      _count2+0, 0
L__main27:
	BTFSC      STATUS+0, 0
	GOTO       L_main14
;MyProject.c,143 :: 		CalculateDistance();
	CALL       _CalculateDistance+0
;MyProject.c,144 :: 		if(Distance < 10 ) {
	MOVLW      10
	SUBWF      _Distance+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_main16
;MyProject.c,145 :: 		PORTD = 0x50;          //RD3 SPEED OFF RD4 led on RD 5 OFF RD6 BACKWARD
	MOVLW      80
	MOVWF      PORTD+0
;MyProject.c,146 :: 		Delayms(1000);   //  time to go back
	MOVLW      232
	MOVWF      FARG_Delayms_Time+0
	MOVLW      3
	MOVWF      FARG_Delayms_Time+1
	CALL       _Delayms+0
;MyProject.c,147 :: 		}
	GOTO       L_main17
L_main16:
;MyProject.c,149 :: 		PORTD=0xB8;// PUMP RD7 ON RD56 FORWARD RD3 ON
	MOVLW      184
	MOVWF      PORTD+0
;MyProject.c,150 :: 		Delayms(1);
	MOVLW      1
	MOVWF      FARG_Delayms_Time+0
	MOVLW      0
	MOVWF      FARG_Delayms_Time+1
	CALL       _Delayms+0
;MyProject.c,151 :: 		PORTD=0xB0;  //PUMP RD7 ON RD56 FORWARD RD3 OFF
	MOVLW      176
	MOVWF      PORTD+0
;MyProject.c,152 :: 		Delayms(1);
	MOVLW      1
	MOVWF      FARG_Delayms_Time+0
	MOVLW      0
	MOVWF      FARG_Delayms_Time+1
	CALL       _Delayms+0
;MyProject.c,153 :: 		}
L_main17:
;MyProject.c,142 :: 		for( count2=0 ;count2 < 1000 ; count2++){
	INCF       _count2+0, 1
	BTFSC      STATUS+0, 2
	INCF       _count2+1, 1
;MyProject.c,154 :: 		}
	GOTO       L_main13
L_main14:
;MyProject.c,155 :: 		pump=0;   //rest to 0 to wait 2.5S
	CLRF       _pump+0
;MyProject.c,156 :: 		}
L_main12:
;MyProject.c,158 :: 		angle=3500;
	MOVLW      172
	MOVWF      _angle+0
	MOVLW      13
	MOVWF      _angle+1
;MyProject.c,160 :: 		}
L_main11:
;MyProject.c,161 :: 		}
	GOTO       L_main8
;MyProject.c,163 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_CCPPWM_init:

;MyProject.c,165 :: 		void CCPPWM_init(void){ //Configure CCP2 for motor 2  RC1
;MyProject.c,166 :: 		T2CON = 0x27;//enable Timer2 at Fosc/4 with 1:16 prescaler (8 uS percount 2000uS to count 250 counts)
	MOVLW      39
	MOVWF      T2CON+0
;MyProject.c,167 :: 		CCP2CON = 0x0C;//enable PWM for CCP2
	MOVLW      12
	MOVWF      CCP2CON+0
;MyProject.c,168 :: 		PR2 = 250;     // 250 counts =8uS *250 =2ms period
	MOVLW      250
	MOVWF      PR2+0
;MyProject.c,169 :: 		CCPR2L=150  ; //60% duty cycle
	MOVLW      150
	MOVWF      CCPR2L+0
;MyProject.c,170 :: 		}
L_end_CCPPWM_init:
	RETURN
; end of _CCPPWM_init

_Delayms:

;MyProject.c,172 :: 		void Delayms(unsigned int Time) // A delay function that receives its time in milli-seconds
;MyProject.c,174 :: 		TMR0 = 6;                            // Load 6 in timer0, so it will over-flow after 250 counts
	MOVLW      6
	MOVWF      TMR0+0
;MyProject.c,177 :: 		Delay_Counter = 0;                   // Start counting from zero
	CLRF       _Delay_Counter+0
	CLRF       _Delay_Counter+1
;MyProject.c,178 :: 		Time = Time * 4;                     // 1mS = 4 * 250uS
	RLF        FARG_Delayms_Time+0, 1
	RLF        FARG_Delayms_Time+1, 1
	BCF        FARG_Delayms_Time+0, 0
	RLF        FARG_Delayms_Time+0, 1
	RLF        FARG_Delayms_Time+1, 1
	BCF        FARG_Delayms_Time+0, 0
;MyProject.c,180 :: 		while (Delay_Counter < Time);       // Stuck here for "Time" in mS
L_Delayms18:
	MOVF       FARG_Delayms_Time+1, 0
	SUBWF      _Delay_Counter+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Delayms30
	MOVF       FARG_Delayms_Time+0, 0
	SUBWF      _Delay_Counter+0, 0
L__Delayms30:
	BTFSC      STATUS+0, 0
	GOTO       L_Delayms19
	GOTO       L_Delayms18
L_Delayms19:
;MyProject.c,181 :: 		}
L_end_Delayms:
	RETURN
; end of _Delayms

_CalculateDistance:

;MyProject.c,183 :: 		void CalculateDistance(void)
;MyProject.c,186 :: 		PORTC = PORTC | 0x01;                        // RC0 = 1
	BSF        PORTC+0, 0
;MyProject.c,187 :: 		for(i=0 ;i<22 ;i++);                          //ultrasonic TRIG need 10us delay 22*0.5us=11us
	CLRF       R1+0
L_CalculateDistance20:
	MOVLW      22
	SUBWF      R1+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_CalculateDistance21
	INCF       R1+0, 1
	GOTO       L_CalculateDistance20
L_CalculateDistance21:
;MyProject.c,188 :: 		PORTC = PORTC & 0xFE;                        // RC0 = 0
	MOVLW      254
	ANDWF      PORTC+0, 1
;MyProject.c,189 :: 		}
L_end_CalculateDistance:
	RETURN
; end of _CalculateDistance
