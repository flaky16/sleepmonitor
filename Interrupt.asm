;

	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex	, LCD_Top	    ; external LCD subroutines
	extern  ADC_Setup, Read_x,Read_y , Read_z		    ; external ADC routines
	extern measure_loop , Hex_setup
	
acs0	udata_acs	
check1sec res 1
temporary   res 1
x_0	res 1
y_0	res 1
z_0	res 1

x_t	res 1
y_t	res 1
z_t	res 1

x_max	res 1
y_max	res 1
z_max	res 1
delay_ res 1 	
;values	res 4


rst	code	0    ; reset vector
	goto	setup
	
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
    movwf   PORTD
    lfsr    FSR1 , 0x300
    lfsr    FSR2 , 0x300
   ; movlw   0xFF
   ; movwf   0x303

loop
    call    initialize_second
    
    btfss   PORTD, RD0		; Skip if RD0 is high (count)
    call    rd00
    call    delay
    movlw   0x04
    lfsr    FSR2 , 0x300
    call    UART_Transmit_Message    
    
    call    initialize_second	; Set V0, Vmax = 0 
    
    btfsc   PORTD, RD0		; Skip if RD0 is low (count)
    call    rd01
    call    delay
    call    delay
    movlw   0x04
    lfsr    FSR2 , 0x300
    call    UART_Transmit_Message 
    call    delay
    call    delay
    
    ;movlw   0x04
    ;cpfseq  PORTD
    bra     loop
    
;    movlw   0x04
;    call    UART_Transmit_Message    
;    movlw   0x04
;    call    UART_Transmit_Message    
;    movlw   0x04
;    call    UART_Transmit_Message    
    
;    bra loop
    
rd00
    call    measure_loop		    ; Display time in LCD
loop1sec0
    call    loop_operations
    btfss   PORTD, RD0		    ; Continue to loop until second has passed
    bra	    loop1sec0
    call    store_data
     
    movff   y_max , PORTE
    return
   
 rd01
    call    measure_loop   
 loop1sec1			    ; Same loop as loop1sec0 
    call    loop_operations
    btfsc   PORTD, RD0		    ; Continue to loop until second has passed
    bra	    loop1sec1
    call    store_data
    
    movff   z_max , PORTE
    return
    
loop_operations
    
    call    Read_x		    ; Get 8-bit number for x at time t
    movf    x_0 , W
    call    find_difference	    ; Get deviation from x_0
    movff   ADRESL , x_t	    ; The difference is stored
    call    update_x_max	    ; Check if x_t > x_max for 1 second interval

    call    Read_y		    ; Get 8-bit number for y at time t
    movf    y_0 , W
    call    find_difference	    ; Get deviation from y_0
    movff   ADRESL , y_t	    ; The difference is stored
    call    update_y_max	    ; Check if y_t > y_max for 1 second interval

    call    Read_y		    ; Get 8-bit number for z at time t
    movf    z_0 , W
    call    find_difference	    ; Get deviation from z_0
    movff   ADRESL , z_t	    ; The difference is stored
    call    update_z_max	    ; Check if z_t > z_max for 1 second interval
    
    return
    
store_data
    ; Store maximum data and the time:
    movff   x_max , POSTINC1
    movff   y_max , POSTINC1
    movff   z_max , POSTINC1
    movlw   0xFF
    movwf   POSTINC1
  
    return
    
initialize_second   
    call    Read_x
    movff   ADRESL , x_0		; Set x_0 for each second interval
    call    Read_y
    movff   ADRESL , y_0		; Set y_0 for each second interval
    call    Read_z
    movff   ADRESL , z_0		; Set z_0 for each second interval
    movlw   0x00
    movwf   x_max			; Set x_max for each second interval
    movwf   y_max			; Set y_max for each second interval
    movwf   z_max			; Set z_max for each second interval
    lfsr    FSR1 , 0x300

    return
    
subtraction				; If x_0 > x_t -> subtract x_t from x_0 (in W)
    movwf   temporary			; Store x_0 in temporary location
    movf    ADRESL, W		    
    subwf   temporary, 0		; Subtr. x_t from x_0, store result in W
    movwf   ADRESL			; Put difference into ADRESL
    return
    
find_difference    ; x_0/y_0/z_0 recorded in W  , returns difference in ADRESL
    cpfseq  ADRESL
    bra	    not_equal
    bra	    if_equal
 not_equal
    cpfsgt  ADRESL
    call    subtraction
    
    cpfslt  ADRESL
    subwf   ADRESL, 1
    bra	    jump_equal
 
if_equal
    movlw   0x00
    movwf   ADRESL
    
jump_equal
    
    return
    
update_x_max
    movf    x_t , W
    cpfsgt  x_max		    ; Compare if current difference is higher than the max differennce
    movff   x_t , x_max		    ; Update x_max for this 1 sec interval
    return    
    
update_y_max
    movf    y_t , W
    cpfsgt  y_max		    ; Compare if current difference is higher than the max differennce
    movff   y_t , y_max		    ; Update y_max for this 1 sec interval
    return    

update_z_max
    movf    z_t , W
    cpfsgt  z_max		    ; Compare if current difference is higher than the max differennce
    movff   z_t , z_max		    ; Update z_max for this 1 sec interval
    return    
    
delay	decfsz	delay_	; decrement until zero
	bra delay
	return    
    end