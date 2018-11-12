#include p18f87k22.inc

    global  ADC_Setup, Read_x,Read_y , Read_z
    
acs0	udata_acs   ; reserve data space in access ram
count  res 1
carry  res 4
  
ADC    code
    
ADC_Setup
    movlw   0x03
    movwf   count
    bsf	    TRISA,RA0	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL0   ; set A0 to analog
    
    bsf	    TRISA,RA1	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL1   ; set A1 to analog
    
    bsf	    TRISA,RA2	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL2   ; set A2 to analog    
  
    movlw   0x20	    ; Select 4.096V positive reference
    movwf   ADCON1	    ; 0V for -ve reference and -ve input
    movlw   0xF6	    ; Right justified output
    movwf   ADCON2	    ; Fosc/64 clock and acquisition times
    return

Read_x
    movlw   0x01	    ; select AN0 for measurement
    movwf   ADCON0	    ; and turn ADC on
    
    bsf	    ADCON0,GO	    ; Start conversion
    call    adc_loop
    return

Read_y
    movlw   0x05	    ; select AN0 for measurement
    movwf   ADCON0	    ; and turn ADC on
    
    bsf	    ADCON0,GO	    ; Start conversion
    call    adc_loop
    return
Read_z
    movlw   0x09	    ; select AN0 for measurement
    movwf   ADCON0	    ; and turn ADC on
    
    bsf	    ADCON0,GO	    ; Start conversion
    call    adc_loop
    return
    
adc_loop
    btfsc   ADCON0,GO	    ; check to see if finished
    bra	    adc_loop
    call    reduce
    return

reduce			    ; Read data in 12-bits, reduces to 8-bits in ADRESL
    lfsr    FSR0, carry     ; carry adressed stored here
   
    movlw   0x07
    cpfsgt  ADRESH	    ; skip if High > 7
    call    updatecarry0
    movlw   0x08
    cpfsgt  ADRESH		    ; skip if High < 8
    call    updatecarry1	    ; Carry = 1 , High = High - 8
    
    movlw   0x03
    cpfsgt  ADRESH	    ; skip if High > 3
    call    updatecarry0
    movlw   0x04
    cpfsgt  ADRESH		    ; skip if High < 4
    call    updatecarry1	    ; Carry = 1 , High = High - 4
    
    movlw  0x01
    cpfsgt  ADRESH	    ; skip if High > 1
    call    updatecarry0
    movlw   0x02
    cpfsgt  ADRESH		    ; skip if High < 2
    call    updatecarry1	    ; Carry = 1 , High = High - 2
    
    movlw  0x00
    cpfsgt  ADRESH	    ; skip if High > 0
    call    updatecarry0
    movlw   0x01
    cpfsgt  ADRESH		    ; skip if High < 1
    call    updatecarry1	    ; Carry = 1 , High = High - 1
    
 loop4times 
				    
    movff   POSTDEC0 , TABLAT
    clrc			    ; Clear carry
    decfsz  TABLAT		    ; Skip if tablat zero
    setc			    ; Set carry if tablat != 0
    
    rrcf     ADRESL		    ; Rotate right with carry
    decfsz  count
    bra     loop4times
    return		; Return the new 8 bit measurement in ADRESL
    
updatecarry0   
    movlw   0x00
    movwf   POSTINC0	; Update carry as 1, move to next carry
    return
    
 updatecarry1		; Subtraction stored in W
    subwf   ADRESH	; Subtract W from high
    movlw   0x01
    movwf   POSTINC0	; Update carry as 1, move to next carry
    return	   
    
    end