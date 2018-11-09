

#include p18f87k22.inc
    extern  ADC_Setup, ADC_Read
    extern  LCD_Setup, LCD_Write_Message, LCD_Write_Hex
    extern  measure_loop, Hex_setup
    
rst code 0x0000 ; reset vector 
    
    goto start
int_hi code 0x0008 ; high vector, no low vector 
    btfss   INTCON,TMR0IF ; check that this is timer0 interrupt 
    retfie  FAST ; if not then return 
    incf    LATD ; increment PORTD
    bcf	    INTCON,TMR0IF ; clear interrupt flag 
    retfie  FAST ; fast return from interrupt
    
    
main code 
start 
    ;call    ADC_Setup	; setup ADC
    ;call    LCD_Setup	; setup LCD
    call    Hex_setup
    clrf    TRISD ; Set PORTD as all outputs 
    clrf    LATD ; Clear PORTD outputs 
    movlw   b'10000100' ; Set timer0 to 16-bit, Fosc/4/256 
    movwf   T0CON ; = 62.5KHz clock rate, approx 1sec rollover 
    bsf	    INTCON,TMR0IE ; Enable timer0 interrupt 
    bsf	    INTCON,GIE ; Enable all interrupts 


    call    measure_loop 
     
     
loop1sec
    call    measure_loop
    bra	    loop1sec
    
    
    goto $ ; Sit in infinite loop

    end
 
 
