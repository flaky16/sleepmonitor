#include p18f87k22.inc

    global  ADC_Setup, Read_x,Read_y , Read_z
    
ADC    code
    
ADC_Setup
    bsf	    TRISA,RA0	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL0   ; set A0 to analog
    
    bsf	    TRISA,RA1	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL1   ; set A1 to analog
    
    bsf	    TRISA,RA2	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL2   ; set A2 to analog    
  
    movlw   0x30	    ; Select 4.096V positive reference
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
    return

    end