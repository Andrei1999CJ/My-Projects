/*
 * File:   main.c
 * Author: cojoc
 *
 * Created on 03 ianuarie 2021, 10:54
 */


// PIC18F4550 Configuration Bit Settings

// 'C' source line config statements

// CONFIG1L
#pragma config PLLDIV = 1       // PLL Prescaler Selection bits (No prescale (4 MHz oscillator input drives PLL directly))
#pragma config CPUDIV = OSC1_PLL2// System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2])
#pragma config USBDIV = 1       // USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes directly from the primary oscillator block with no postscale)

// CONFIG1H
#pragma config FOSC = INTOSC_XT // Oscillator Selection bits (Internal oscillator, XT used by USB (INTXT))
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
#pragma config IESO = OFF       // Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

// CONFIG2L
#pragma config PWRT = OFF       // Power-up Timer Enable bit (PWRT disabled)
#pragma config BOR = ON         // Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
#pragma config BORV = 3         // Brown-out Reset Voltage bits (Minimum setting 2.05V)
#pragma config VREGEN = OFF     // USB Voltage Regulator Enable bit (USB voltage regulator disabled)

// CONFIG2H
#pragma config WDT = OFF        // Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
#pragma config WDTPS = 32768    // Watchdog Timer Postscale Select bits (1:32768)

// CONFIG3H
#pragma config CCP2MX = ON      // CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
#pragma config PBADEN = ON      // PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
#pragma config LPT1OSC = OFF    // Low-Power Timer 1 Oscillator Enable bit (Timer1 configured for higher power operation)
#pragma config MCLRE = OFF       // MCLR Pin Enable bit (MCLR pin disabled; RE3 input pin enabled)

// CONFIG4L
#pragma config STVREN = ON      // Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
#pragma config LVP = ON         // Single-Supply ICSP Enable bit (Single-Supply ICSP enabled)
#pragma config ICPRT = OFF      // Dedicated In-Circuit Debug/Programming Port (ICPORT) Enable bit (ICPORT disabled)
#pragma config XINST = OFF      // Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

// CONFIG5L
#pragma config CP0 = OFF        // Code Protection bit (Block 0 (000800-001FFFh) is not code-protected)
#pragma config CP1 = OFF        // Code Protection bit (Block 1 (002000-003FFFh) is not code-protected)
#pragma config CP2 = OFF        // Code Protection bit (Block 2 (004000-005FFFh) is not code-protected)
#pragma config CP3 = OFF        // Code Protection bit (Block 3 (006000-007FFFh) is not code-protected)

// CONFIG5H
#pragma config CPB = OFF        // Boot Block Code Protection bit (Boot block (000000-0007FFh) is not code-protected)
#pragma config CPD = OFF        // Data EEPROM Code Protection bit (Data EEPROM is not code-protected)

// CONFIG6L
#pragma config WRT0 = OFF       // Write Protection bit (Block 0 (000800-001FFFh) is not write-protected)
#pragma config WRT1 = OFF       // Write Protection bit (Block 1 (002000-003FFFh) is not write-protected)
#pragma config WRT2 = OFF       // Write Protection bit (Block 2 (004000-005FFFh) is not write-protected)
#pragma config WRT3 = OFF       // Write Protection bit (Block 3 (006000-007FFFh) is not write-protected)

// CONFIG6H
#pragma config WRTC = OFF       // Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) are not write-protected)
#pragma config WRTB = OFF       // Boot Block Write Protection bit (Boot block (000000-0007FFh) is not write-protected)
#pragma config WRTD = OFF       // Data EEPROM Write Protection bit (Data EEPROM is not write-protected)

// CONFIG7L
#pragma config EBTR0 = OFF      // Table Read Protection bit (Block 0 (000800-001FFFh) is not protected from table reads executed in other blocks)
#pragma config EBTR1 = OFF      // Table Read Protection bit (Block 1 (002000-003FFFh) is not protected from table reads executed in other blocks)
#pragma config EBTR2 = OFF      // Table Read Protection bit (Block 2 (004000-005FFFh) is not protected from table reads executed in other blocks)
#pragma config EBTR3 = OFF      // Table Read Protection bit (Block 3 (006000-007FFFh) is not protected from table reads executed in other blocks)

// CONFIG7H
#pragma config EBTRB = OFF      // Boot Block Table Read Protection bit (Boot block (000000-0007FFh) is not protected from table reads executed in other blocks)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.


#include <xc.h>
#define _XTAL_FREQ 4000000
unsigned int d,nr;

void init_uC()
{
    IPEN=0;//prioritate intreruperi dezactivata
    OSCCON=0b01100110;//OSC intern=4MHz
    TRISB=0b11110001;//RB3->RB1=output,restul input
    TRISC=0x00;//PORTC output
    TRISD=0x00;//PORTD output
    ADCON1=0x0F;//Toti pinii sunt digitali
    GIE=1;//Global interrupt enabled
    PEIE=1;
    TMR1IE=1;//Intrerupere timer1 activa
    TMR1IF=0;
    T1CON=0b00001100;
    TMR1H=0;
    TMR1L=0;
    T2CON=0b00000100;
    PR2=100;
    CCP1CON=0b10001100;
    CCPR1L=0xFF;

}

void __interrupt() etti()
{
    if(TMR1IF)
    {
        TMR1IF=0;
        TMR1H=0;
        TMR1L=0;
    }

}

void main(void) 
{
    init_uC();
    while(1)
    {
         RB1=1;
        __delay_us(10);
        RB1=0;
        while (RB0==0);
            TMR1ON = 1;
        while (RB0==1);
            TMR1ON = 0;
        nr=TMR1L+(TMR1H<<8);
        d=(nr*0.034)/2;
        TMR1H=0;
        TMR1L=0;
        if(d<5)
        {
            CCPR1L=0x00;
            for(d=261;d>0;d--)//nota DO octava 4(dureaza aprox 1 sec)
            {
            	RB3=1;//dureaza 1915us
            	__delay_us(1914);
                RB3=0;//dureaza 1915us
                __delay_us(1905);
            }
            __delay_us(1000);
            for(d=349;d>0;d--)//nota FA octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1432us
                __delay_us(1431);
                RB3=0;//dureaza 1432us
                __delay_us(1423);
            }
            __delay_us(1000);
            for(d=329;d>0;d--)//nota MI octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1519us
                __delay_us(1518);
                RB3=0;//dureaza 1519us
                __delay_us(1510);
            }
            __delay_us(1000);
            for(d=261;d>0;d--)//nota DO octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1915us
                __delay_us(1914);
                RB3=0;//dureaza 1915us
                __delay_us(1906);
            }
            __delay_us(1000);
            for(d=277;d>0;d--)//nota RE octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1706us
                __delay_us(1705);
                RB3=0;//dureaza 1706us
                __delay_us(1697);
            }
            __delay_us(1000);
            for(d=293;d>0;d--)//nota MI octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1519us
                __delay_us(1518);
                RB3=0;//dureaza 1519us
                __delay_us(1510);
            }
            __delay_us(1000);
            for(d=349;d>0;d--)//nota FA octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1432us
                __delay_us(1431);
                RB3=0;//dureaza 1432us
                __delay_us(1423);
            }
            __delay_us(1000);
            for(d=261;d>0;d--)//nota DO octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1915us
                __delay_us(1914);
                RB3=0;//dureaza 1915us
                __delay_us(1905);
            }
            __delay_us(1000);
            for(d=261;d>0;d--)//nota DO octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1915us
                __delay_us(1914);
                RB3=0;//dureaza 1915us
                __delay_us(1905);
            }
            __delay_us(1000);
            for(d=493;d>0;d--)//nota SI octava 4(dureaza aprox 1 sec)		{
            {
                RB3=1;//dureaza 1014us
                __delay_us(1013);
                RB3=0;//dureaza 1014us
                __delay_us(1005);
            }
            __delay_us(1000);
            for(d=440;d>0;d--)//nota LA octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1136us
                __delay_us(1135);
                RB3=0;//dureaza 1136us
                __delay_us(1127);
            }
            __delay_us(1000);
            for(d=349;d>0;d--)//nota FA octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1432us
                __delay_us(1431);
                RB3=0;//dureaza 1432us
                __delay_us(1423);
            }
            __delay_us(1000);
            for(d=392;d>0;d--)//nota SOL octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1275us
                __delay_us(1274);
                RB3=0;//dureaza 1275us
                __delay_us(1266);
            }
            __delay_us(1000);
            for(d=392;d>0;d--)//nota SOL octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1275us
                __delay_us(1274);
                RB3=0;//dureaza 1275us
                __delay_us(1266);
            }
            __delay_us(1000);
            for(d=349;d>0;d--)//nota FA octava 4(dureaza aprox 1 sec)
            {
                RB3=1;//dureaza 1432us
                __delay_us(1431);
                RB3=0;//dureaza 1432us
                __delay_us(1423);
            }
            __delay_us(1000);
        }
        else
            CCPR1L=0xFF;
    	
    }
}
