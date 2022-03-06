#include "p18f4550.inc"

; CONFIG1L
  CONFIG  PLLDIV = 1            ; PLL Prescaler Selection bits (No prescale (4 MHz oscillator input drives PLL directly))
  CONFIG  CPUDIV = OSC1_PLL2    ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2])
  CONFIG  USBDIV = 1            ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes directly from the primary oscillator block with no postscale)

; CONFIG1H
  CONFIG  FOSC = INTOSC_XT      ; Oscillator Selection bits (Internal oscillator, XT used by USB (INTXT))
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOR = ON              ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown-out Reset Voltage bits (Minimum setting 2.05V)
  CONFIG  VREGEN = OFF          ; USB Voltage Regulator Enable bit (USB voltage regulator disabled)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = ON           ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer 1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = OFF            ; MCLR Pin Disabled bit (MCLR pin disabled; RE3 input pin enabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Single-Supply ICSP Enable bit (Single-Supply ICSP enabled)
  CONFIG  ICPRT = OFF           ; Dedicated In-Circuit Debug/Programming Port (ICPORT) Enable bit (ICPORT disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) is not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) is not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) is not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) is not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) is not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM is not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) is not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) is not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) is not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) is not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) are not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) is not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM is not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) is not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) is not protected from table reads executed in other blocks)

  
  i equ	0x30
  j equ	0x31
  dur	equ 0x32
org 0x00
	GOTO init_uC

org 0x08
intrerupere:
	BCF INTCON,GIE,0;dezactivez GIE
	;nu ma intereseaza STATUS si ACM
	BTFSS PIR1,TMR1IF,0;TMR1IF se afla in reg PIR1
	RETFIE
interupere_T1:
	BCF PIR1,TMR1IF,0
	CLRF TMR1H,0
	CLRF TMR1L,0
	RETFIE

org 0x100
init_uC:
	BCF BSR,0,0
	BCF BSR,1,0
	BCF BSR,2,0
	BCF BSR,3,0
	;ma asigur ca ma aflu in bank0
	BCF RCON,IPEN,0;b7:IPEN=0(prioritatea intreruperilor dezactivata)(vectorul de intrerupere este 0x08)(info din datasheet)
	MOVLW b'01100110'
	MOVWF OSCCON,0	;OSC intern 4MHZ
	MOVLW b'11110001'
	MOVWF TRISB,0;RB3->RB1 output,restul INPUT
	MOVLW D'0'
	MOVWF TRISC,0;PORTC OUTPUT
	MOVWF TRISD,0;PORTD OUTPUT
	MOVLW b'00001111'
	MOVWF ADCON1,0;Toti pinii sunt digitali
	BSF INTCON,GIE,0;b7:GIE=1
	BSF INTCON,PEIE,0;b6:PEIE=1;timer1 intrerupere periferica
	BSF PIE1,TMR1IE,0;b0:TMR1IE=1;intrerupere timer1 on
	BCF PIR1,TMR1IF,0;b0:TMR1IF=0
	MOVLW b'00000100';TMR1 are PS 1:1,sursa clk este osc intern(OSC/4)(T1 este off,il pornim atunci cand avem pe pinul echo 1L si il oprim din nou cand pe pinul echo este 0L)
	MOVWF T1CON,0;
	;Timer1 este pe 16biti
	CLRF TMR1H,0
	CLRF TMR1L,0
	MOVLW b'00000100'
	MOVWF T2CON,0;TMR2 este on (folosit pentru perioada semnalului PWM) PS 1:1,post-scaler:1:1
	MOVLW D'100'
	MOVWF PR2,0;PR2->perioada semnal PWM
	MOVLW b'10001100'
	MOVWF CCP1CON,0;Explic mai jos cum am configurat acest registru pt control bloc ECCP
	MOVLW D'255'
	MOVWF CCPR1L,0;PWM duty cycle=100%(control register for duty cycle PWM)
main:
    CLRF TMR1H,0
    CLRF TMR1L,0
    BSF PORTB,1,0
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP;10us delay
    BCF PORTB,1,0
    
	
loopRB0este0:
    BTFSS PORTB,0,0
    GOTO loopRB0este0
    
    BSF T1CON,TMR1ON,0
loopRB0este1:
    BTFSC PORTB,0,0
    GOTO loopRB0este1
    
    BCF T1CON,TMR1ON,0
    MOVLW D'0'
    SUBWF TMR1H,0,0
    BTFSC STATUS,Z,0
    GOTO melodie
    BSF STATUS,C,0
    MOVLW D'2'
    SUBWF TMR1H,0,0
    BTFSC STATUS,0,0
    goto altfel
    MOVLW D'38'
    SUBWF TMR1L,0,0
    BTFSC STATUS,0,0
    goto altfel
 
    
melodie:
    NOP
    MOVLW D'0'
    MOVWF CCPR1L,0
    MOVLW D'255'
	MOVWF dur,1
DOp1_1:
	BSF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO DOp1_1

	MOVLW D'6'
	MOVWF dur,1
DOp2_1:
	BSF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO DOp2_1
	
	CALL delay_1ms

	MOVLW D'255'
	MOVWF dur,1
FAp1_1:
	BSF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO FAp1_1

	MOVLW D'94'
	MOVWF dur,1
FAp2_1:
	BSF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO FAp2_1
	
	CALL delay_1ms
	
	MOVLW D'255'
	MOVWF dur,1
MIp1_1:
	BSF PORTB,3,0
	CALL delay_MI
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_MI
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO MIp1_1

	MOVLW D'74'
	MOVWF dur,1
MIp2_1:
	BSF PORTB,3,0
	CALL delay_MI
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_MI
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO MIp2_1
	
	CALL delay_1ms

	MOVLW D'255'
	MOVWF dur,1
DOp1_2:
	BSF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO DOp1_2

	MOVLW D'6'
	MOVWF dur,1
DOp2_2:
	BSF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO DOp2_2
	
	CALL delay_1ms
	
	MOVLW D'255'
	MOVWF dur,1
REp1_1:
	BSF PORTB,3,0
	CALL delay_RE
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_RE
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO REp1_1

	MOVLW D'22'
	MOVWF dur,1
REp2_1:
	BSF PORTB,3,0
	CALL delay_RE
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_RE
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO REp2_1
	
	CALL delay_1ms
	
	MOVLW D'255'
	MOVWF dur,1
MIp1_2:
	BSF PORTB,3,0
	CALL delay_MI
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_MI
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO MIp1_2

	MOVLW D'74'
	MOVWF dur,1
MIp2_2:
	BSF PORTB,3,0
	CALL delay_MI
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_MI
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO MIp2_2
	
	CALL delay_1ms

	MOVLW D'255'
	MOVWF dur,1
FAp1_2:
	BSF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO FAp1_2

	MOVLW D'94'
	MOVWF dur,1
FAp2_2:
	BSF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO FAp2_2
	
	CALL delay_1ms
	
	MOVLW D'255'
	MOVWF dur,1
DOp1_3:
	BSF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO DOp1_3

	MOVLW D'6'
	MOVWF dur,1
DOp2_3:
	BSF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO DOp2_3
	
	CALL delay_1ms
	
	MOVLW D'255'
	MOVWF dur,1
DOp1_4:
	BSF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO DOp1_4

	MOVLW D'6'
	MOVWF dur,1
DOp2_4:
	BSF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_DO
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO DOp2_4
	
	CALL delay_1ms
	
	MOVLW D'255'
	MOVWF dur,1
SIp1:
	BSF PORTB,3,0
	CALL delay_SI
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_SI
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO SIp1

	MOVLW D'238'
	MOVWF dur,1
SIp2:
	BSF PORTB,3,0
	CALL delay_SI
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_SI
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO SIp2
	
	CALL delay_1ms
	
	MOVLW D'255'
	MOVWF dur,1
LAp1:
	BSF PORTB,3,0
	CALL delay_LA
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_LA
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO LAp1

	MOVLW D'185'
	MOVWF dur,1
LAp2:
	BSF PORTB,3,0
	CALL delay_LA
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_LA
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO LAp2
	
	CALL delay_1ms
	
	MOVLW D'255'
	MOVWF dur,1
FAp1_3:
	BSF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO FAp1_3

	MOVLW D'94'
	MOVWF dur,1
FAp2_3:
	BSF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO FAp2_3
	
	CALL delay_1ms
	
	MOVLW D'255'
	MOVWF dur,1
SOLp1_1:
	BSF PORTB,3,0
	CALL delay_SOL
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_SOL
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO SOLp1_1

	MOVLW D'137'
	MOVWF dur,1
SOLp2_1:
	BSF PORTB,3,0
	CALL delay_SOL
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_SOL
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO SOLp2_1
	
	CALL delay_1ms
	
	MOVLW D'255'
	MOVWF dur,1
SOLp1_2:
	BSF PORTB,3,0
	CALL delay_SOL
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_SOL
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO SOLp1_2

	MOVLW D'137'
	MOVWF dur,1
SOLp2_2:
	BSF PORTB,3,0
	CALL delay_SOL
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_SOL
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO SOLp2_2
	
	CALL delay_1ms
	
	MOVLW D'255'
	MOVWF dur,1
FAp1_4:
	BSF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO FAp1_4

	MOVLW D'94'
	MOVWF dur,1
FAp2_4:
	BSF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF PORTB,3,0
	CALL delay_FA
	NOP
	NOP
	DECFSZ dur,1,1
	GOTO FAp2_4
	GOTO main
    
altfel:
    MOVLW D'255'
    MOVWF CCPR1L,0
    goto main
    
    
   delay_DO:
	MOVLW D'10'
	MOVWF i,1
Loopi_DO:
	MOVLW D'37'
	MOVWF j,1
Loopj_DO:
	NOP
	NOP
	DECFSZ j,1,1
	GOTO Loopj_DO
	DECFSZ i,1,1
	GOTO Loopi_DO
	NOP
	NOP
	NOP
	RETURN

delay_FA:
	MOVLW D'5'
	MOVWF i,1
Loopi_FA:
	MOVLW D'93'
	MOVWF j,1
Loopj_FA:
	DECFSZ j,1,1
	GOTO Loopj_FA
	DECFSZ i,1,1
	GOTO Loopi_FA
	RETURN
	
delay_MI:
	MOVLW D'11'
	MOVWF i,1
Loopi_MI:
	MOVLW D'44'
	MOVWF j,1
Loopj_MI:
	DECFSZ j,1,1
	GOTO Loopj_MI
	DECFSZ i,1,1
	GOTO Loopi_MI
	RETURN
	
delay_RE:
	MOVLW D'7'
	MOVWF i,1
Loopi_RE:
	MOVLW D'79'
	MOVWF j,1
Loopj_RE:
	DECFSZ j,1,1
	GOTO Loopj_RE
	DECFSZ i,1,1
	GOTO Loopi_RE
	RETURN
	
delay_SI:
	MOVLW D'6'
	MOVWF i,1
Loopi_SI:
	MOVLW D'54'
	MOVWF j,1
Loopj_SI:
	DECFSZ j,1,1
	GOTO Loopj_SI
	DECFSZ i,1,1
	GOTO Loopi_SI
	RETURN
	
delay_LA:
	MOVLW D'4'
	MOVWF i,1
Loopi_LA:
	MOVLW D'92'
	MOVWF j,1
Loopj_LA:
	DECFSZ j,1,1
	GOTO Loopj_LA
	DECFSZ i,1,1
	GOTO Loopi_LA
	RETURN
	
delay_SOL:
	MOVLW D'3'
	MOVWF i,1
Loopi_SOL:
	MOVLW D'104'
	MOVWF j,1
Loopj_SOL:
	NOP
	DECFSZ j,1,1
	GOTO Loopj_SOL
	DECFSZ i,1,1
	GOTO Loopi_SOL
	RETURN
	
delay_1ms:
	MOVLW D'10'
	MOVWF i,1
Loopi_1ms:
	MOVLW D'19'
	MOVWF j,1
Loopj_1ms:
	NOP
	NOP
	DECFSZ j,1,1
	GOTO Loopj_1ms
	DECFSZ i,1,1
	GOTO Loopi_1ms
	RETURN
	end
