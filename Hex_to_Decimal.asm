#include p18f87k22.inc
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Top, LCD_Write_Hex		    ; external LCD subroutines
	extern  ADC_Setup, Read_x,Read_y , Read_z		    ; external ADC routines
	global  measure_loop , Hex_setup
	
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
multiplicationhigh1  res 1 ; reserve one byte for high bits of 16 bit by 8 bit multiplication
multiplicationlow1  res 1 ; reserve one byte for low bits of 16 bit by 8 bit multiplication
multiplicationhigh2  res 1 
multiplicationlow2  res 1

resultlow res 1
resultmiddle res 1
resulthigh res 1
result1low res 1
result1middle res 1
result1high res 1
result2low res 1
result2middle res 1
result2high res 1
result3low res 1
result3lowermiddle res 1
result3uppermiddle res 1
result3high res 1

hexvoltagehigh res 1
hexvoltagelow res 1
 
khigh res 1
klow res 1
 
voltage1 res 1
voltage2 res 1
voltage3 res 1
voltage4 res 1
 
	
hex	code
	; ******* Programme FLASH read Setup Code ***********************
Hex_setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	return
	
	
measure_loop		;displaying port d
	;call	ADC_Read
	;movf	ADRESH,W
	movlw   0x00
	movwf	hexvoltagehigh
	movf	PORTD,W
	movwf	hexvoltagelow

	
	
	
	movf hexvoltagelow,W
	movwf 0x20
	movf hexvoltagehigh,W
	movwf 0x21
	movlw 0x34
	movwf 0x22
	movlw 0x8A
	movwf klow
	movlw 0x41
	movwf khigh
	
	
	call multiply16by16
	movf result3high,W
	movwf voltage1
	movf result3uppermiddle,W
	movwf 0x22
	movf result3lowermiddle,W
	movwf 0x21
	movf result3low, W
	movwf 0x20
	call multiply8by24
	movf result3high,W
	movwf voltage2
	movf result3uppermiddle, W
	movwf 0x22
	movf result3lowermiddle, W
	movwf 0x21
	movf result3low, W
	movwf 0x20
	call multiply8by24
	movf result3high,W
	movwf voltage3
	movf result3uppermiddle, W
	movwf 0x22
	movf result3lowermiddle, W
	movwf 0x21
	movf result3low, W
	movwf 0x20
	call multiply8by24
	movf result3high,W
	movwf voltage4
	
	call LCD_Top
	
	movf	voltage1,W
	call	LCD_Write_Hex	
	movf	voltage2,W
	call	LCD_Write_Hex	
	movf	voltage3,W
	call	LCD_Write_Hex	
	movf	voltage4,W
	call	LCD_Write_Hex	
	
	return
	
	
multiply8by24
	movlw 0x0A
	call multiply8by16
	movlw 0x0A
	mulwf 0x22
	movff PRODH, multiplicationhigh1
	movff PRODL, multiplicationlow1
	movff resultlow, result3low
	movff resultmiddle, result3lowermiddle
	movf resulthigh,W
	addwfc multiplicationlow1, 0, 0
	movwf result3uppermiddle
	movlw 0x0
	addwfc multiplicationhigh1, 0, 0
	movwf result3high
	;call	LCD_Write_Hex
	movf	result3uppermiddle,W
	;call	LCD_Write_Hex
	movf	result3lowermiddle,W
	;call	LCD_Write_Hex
	movf	result3low,W
	;call	LCD_Write_Hex
	return
	
multiply16by16
	movf klow,W
	call multiply8by16
	movff resultlow, result1low
	movff resultmiddle, result1middle
	movff resulthigh, result1high
	movf khigh,W
	call multiply8by16
	movff resultlow, result2low
	movff resultmiddle, result2middle
	movff resulthigh, result2high
	movff result1low, result3low
	movf result1middle,W
	addwfc result2low, 0, 0
	movwf result3lowermiddle
	movf result1high,W
	addwfc result2middle, 0, 0
	movwf result3uppermiddle
	movlw 0x0
	addwfc result2high, 0, 0
	movwf result3high
	;call	LCD_Write_Hex
	movf	result3uppermiddle,W
	;call	LCD_Write_Hex
	movf	result3lowermiddle,W
	;call	LCD_Write_Hex
	movf	result3low,W
	;call	LCD_Write_Hex
	return
	
	
	

multiply8by16
	mulwf 0x20
	movff PRODH, multiplicationhigh1
	movff PRODL, multiplicationlow1
	mulwf 0x21
	movff PRODH, multiplicationhigh2
	movff PRODL, multiplicationlow2
	movff multiplicationlow1, resultlow
	movf multiplicationhigh1,W
	addwfc multiplicationlow2, 0, 0
	movwf resultmiddle
	movlw 0x0
	addwfc multiplicationhigh2, 0, 0
	movwf resulthigh
	movf	resulthigh,W
	;call	LCD_Write_Hex
	movf	resultmiddle,W
	;call	LCD_Write_Hex
	movf	resultlow,W
	;call	LCD_Write_Hex
	return
	

	
	

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

	end


