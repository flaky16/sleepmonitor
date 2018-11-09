

	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex			    ; external LCD subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	extern measure_loop , Hex_setup
	
acs0	udata_acs	
check1sec res 1

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Hello World!\n"	; message, plus carriage return
	constant    myTable_l=.2	; length of data
	
int_hi code 0x0008 ; high vector, no low vector 
    btfss   INTCON,TMR0IF ; check that this is timer0 interrupt 
    retfie  FAST ; if not then return 
    incf    LATD ; increment PORTD
    bcf	    INTCON,TMR0IF ; clear interrupt flag 
    retfie  FAST ; fast return from interrupt
    
main	code
	
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	call    Hex_setup
	goto	start
	
	; ******* Main programme ****************************************
start 	
	clrf    TRISD ; Set PORTD as all outputs 
    clrf    LATD ; Clear PORTD outputs 
    movlw   b'10000111' ; Set timer0 to 16-bit, Fosc/4/256 
    movwf   T0CON ; = 62.5KHz clock rate, approx 1sec rollover 
    bsf	    INTCON,TMR0IE ; Enable timer0 interrupt 
    bsf	    INTCON,GIE ; Enable all interrupts 
    movlw   0x00
    movwf   TRISE

loop
    btfss   PORTD, RD0
    call    rd00
    
    btfsc   PORTD, RD0
    call    rd01
   ; movlw  0x00
    ;movwf  ADRESH
   ; movff  PORTD, ADRESL
    ;movff PORTD, ADRESH
    

    bra loop
    
rd00
    call measure_loop
loop1sec0
    movlw 0x04
    movwf PORTE
    btfss   PORTD, RD0
    bra loop1sec0
 
    return
    
    
 rd01
    call measure_loop
 loop1sec1
 
    movlw 0x05
    movwf PORTE
    btfsc   PORTD, RD0
    bra loop1sec1
    return
    
    end

