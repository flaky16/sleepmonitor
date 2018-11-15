

	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex			    ; external LCD subroutines
	extern  ADC_Setup, Read_x,Read_y , Read_z		    ; external ADC routines
	extern measure_loop , Hex_setup
	
acs0	udata_acs	
check1sec res 1

x_0	res 1
y_0	res 1
z_0_H	res 1
z_0_L	res 1
	

x_t	res 1

x_max	res 1
;max_values  res 0x40
	
;tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
;myArray res 0x80    ; reserve 128 bytes for message data

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
    movlw   0x00
    movwf   TRISF
    movlw   0x00
    movwf   PORTF
    lfsr    FSR1 , 0x100

loop
    
    call    initialize_1second
    
    btfss   PORTD, RD0		; Skip if RD0 is high (count)
    call    rd00
    
    
    call    initialize_1second	; Set V0, Vmax = 0 
    

    btfsc   PORTD, RD0		; Skip if RD0 is low (count)
    call    rd01
    
    movlw   0x1F
    cpfsgt  PORTD 
    bra loop

    lfsr    FSR2, 0x100
    call    UART_Transmit_Message    
    
    bra loop
rd00
    call measure_loop		    ; Display time
    
loop1sec0
    call    Read_x		    ; Get 8-bit number for x current
   
    movf    x_0 , W
    cpfseq  ADRESL
    bra there
    
    bra here
 there
    movf    x_0 , W	
    
    cpfsgt  ADRESL
    call    subtraction
    
    cpfslt  ADRESL
    subwf   ADRESL, 1
    
    
    bra later
    
here
    movlw   0x00
    movwf   ADRESL
    
later
    
    movff   ADRESL , x_t	    ; The difference is stored
  
    movf   x_t , W
    cpfsgt  x_max		    ; Compare if current difference is higher than the max differennce
    movff   x_t , x_max		    ; Update x_max for this 1 sec interval
    
    

    btfss   PORTD, RD0
    bra loop1sec0
    
    movff   x_max , POSTINC1
    movff   PORTD , POSTINC1
    
    movff   x_max , PORTE
    
    return
    

    
 rd01
 
    call measure_loop
    
 loop1sec1
    call    Read_x		    ; Get 8-bit number for x current
   
    movf    x_0 , W
    cpfseq  ADRESL
    bra there1
    bra here1
 there1
    movf    x_0 , W	
    
    cpfsgt  ADRESL
    call    subtraction
    
    cpfslt  ADRESL
    subwf   ADRESL, 1
    
    
    bra later1
    
here1
    movlw   0x00
    movwf   ADRESL
    
later1
    
    movff   ADRESL , x_t	    ; The difference is stored
  
    movf   x_t , W
    cpfsgt  x_max		    ; Compare if current difference is higher than the max differennce
    movff   x_t , x_max		    ; Update x_max for this 1 sec interval
   

    btfsc   PORTD, RD0
    bra loop1sec1
    
    movff   x_max , POSTINC1
    movff   PORTD , POSTINC1
    
    movff   x_max , PORTE
    
    return
    
    
initialize_1second   
    call    Read_x
    movff   ADRESL , x_0
    movlw   0x00
    movwf   x_max


    return
    
subtraction
    movf    ADRESL, W
    subwf   x_0, 0
    movwf   ADRESL
    return
    
    ;    movff   x_0_H , W
;    subwf   ADRESH
;   
;    movff   x_0_L  , W	    
;    subwf   ADRESL		; Take difference with initial Vx
;    movff   ADRESL , x_t_L	 ; store difference
;    movff   x_t_L , W
;    
;    cpfsgt  x_max_L		 ; Compare if current difference is higher than the max differennce
;    movff   x_t_L , x_max_L	; Update x_max for this 1 sec interval
;    
    
    end

