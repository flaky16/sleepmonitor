
#include p18f87k22.inc
    extern ADC_Setup, ADC_Read
   


;rst	code	0    ; reset vector
;	goto	setup
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	;call	UART_Setup	; setup UART
	;call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	
	movlw   0x00	    ; PORTE all outputs
	movwf	TRISE
	movlw   0x00	    ; PORTD all outputs
	movwf	TRISD

	goto	start
	
	; ******* Main programme ****************************************
	
start	
	call ADC_Read
	
	
	goto start
	
	
	
end

