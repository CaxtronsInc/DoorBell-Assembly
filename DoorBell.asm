DoorBell-Assembly
=================
#include <P16F84A.inc>
  list p=16f84
	__CONFIG _XT_OSC & _WDT_OFF & _PWRTE_OFF & _CP_OFF

    ERRORLEVEL      -302        ;Eliminate bank warning
	ERRORLEVEL		-305		;Eliminate bank warning

	CBLOCK 0x0C                 ; Address to start using General Purpose Registers
		Waveform_Delay_1
		Waveform_Delay_2
		Pulse_Delay_1
		Pulse_Delay_2
		Note_Delay_1
		Note_Delay_2
		Temp_Delay_1
		Temp_Delay_2
		Temp_Delay_3
		Tone_Choice
		Text_Pressed_Bool
		Tone_Choice_Check
		Loop_Count
		Loop_Count2
		Loop_Count3
		Tone_to_Play
		CHAR_TABLE 
		System_Text
		Note_to_Play
		temp_var
		If_Statement_Result		; 00000001 if True, 00000000 if False
		LCD_mode			; 001 - Test, 010 - Set, 100 - Set Success
		GPR1                    ; Countdown Register
		DATA1                   ; Temp data store for 4 bit mode
		DATA2                   ; Temp data store for 4 bit mode
		DELAYGPR1               ; 
		DELAYGPR2               ; 
		DELAYGPR3               ; 
		offset
	ENDC 

E EQU 3                         ; Used for PORTB, 'Enable' Line
RS EQU 1                        ; Used for PORTB, 'Register Select' Line

SETIO  							; This rountine sets up the microcontrollers Inputs and Outputs
	BSF     STATUS, RP0         ; Bank 1
	movlw	b'11111111'			; Set W as all inputs
	movwf	TRISA				; Set PORTA as W (all inputs)
	CLRF    TRISB               ; Set all of PORTB to outputs
	BCF     STATUS, RP0         ; Bank 0
	CLRF    PORTA               ; Initialize PORTA by clearing output data latches
	CLRF    PORTB               ; Initialize PORTB by clearing output data latches
	BSF     PORTB, E            ; Enable Pin (Active Low). Must be set initially and held high until data is to be clocked in by lowering

MAIN_PROGRAM
	bsf		PORTB, 2
    CALL    INITIALISE_LCD      ; 
    CALL    CLEAR_DISPLAY_DOUBLE       ; Clear Display
	movlw	b'00000100'
	movwf	LCD_mode
	Call 	PRINT_SYSTEM
	CALL	GOTO_LINE2
	movlw	b'00000101'
	movwf	LCD_mode
	Call 	PRINT_SYSTEM

	Clrf	LCD_mode
	Call 	Reset_Loop_Counter
	movlw 	d'25'
	Call 	Play_Silence
	Call 	REFRESH_LCD_DISPLAY		;Refresh the LCD

	movlw	0x01
	movwf	EEADR
	movlw	0x00
	Call 	WRITE_TO_EEPROM

	goto 	Test_Button_1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LOOKUP TABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PLAY_TONE

	bsf		Text_Pressed_Bool, 0
	Movf    Tone_to_Play, W
    ADDWF   PCL, F
	goto	Classic
	goto	Jones
	goto	starwars
	goto	harrypotter
	goto	pirates
play_tone_end
	RETURN

PRINT_SYSTEM
	BSF     PORTB, RS
	bcf		CHAR_TABLE, 0
	Movf    LCD_mode, W

	Call 	GET_SYSTEM_LINEPOSITION
    MOVWF   GPR1                ; Move Working Register to General Purpose Register
	CALL 	TYPE_IT
	RETURN

GET_SYSTEM_LINEPOSITION
	BSF     PORTB, RS
    ADDWF   PCL,F
	RETLW   D'118'
	RETLW   D'129'
	RETLW   D'140'
	RETLW   D'0'
	RETLW   D'85'
	RETLW   D'101'
	RETURN

PRINT_TONE
	BSF     PORTB, RS
	bsf		CHAR_TABLE, 0
	Movf    Tone_Choice, W
	Call 	GET_TONE_LINEPOSITION
    MOVWF   GPR1                ; Move Working Register to General Purpose Register
	CALL 	TYPE_IT
	RETURN

GET_TONE_LINEPOSITION
    ADDWF   PCL,F
	RETLW   D'0'
	RETLW   D'17'
	RETLW   D'34'
	RETLW   D'51'
	RETLW   D'68'
	RETURN

REFRESH_LCD_DISPLAY
	Call 	CLEAR_DISPLAY_DOUBLE
	CALL 	PRINT_TONE
	CALL	GOTO_LINE2
	CALL 	PRINT_SYSTEM
	RETURN

CHARACTER_TABLE ; This routine holds all the words needed for the LCD display
        ADDWF   PCL,F
        RETLW   A'<'	;0
       	RETLW   A' '
        RETLW   A'C'
        RETLW   A'l'
        RETLW   A'a'
        RETLW   A's'
		RETLW	A's'
		RETLW   A'i'
        RETLW   A'c'
        RETLW   A' '
		RETLW	A'T'
		RETLW   A'o'
		RETLW   A'n'
		RETLW   A'e'
        RETLW   A' '
        RETLW   A'>'
        RETLW   H'0'
        RETLW   A'<'	;17
        RETLW   A'I'
        RETLW   A'n'
        RETLW   A'd'
        RETLW   A'i'
		RETLW	A'a'
		RETLW   A'n'
        RETLW   A'a'
        RETLW   A' '
		RETLW	A'J'
		RETLW   A'o'
		RETLW   A'n'
		RETLW   A'e'
        RETLW   A's'
       	RETLW   A' '
        RETLW   A'>'
        RETLW   H'0' 
        RETLW   A'<'	;34
        RETLW   A' '
       	RETLW   A' '
        RETLW   A'S'
        RETLW   A't'
        RETLW   A'a'
        RETLW   A'r'
		RETLW	A' '
		RETLW   A'W'
        RETLW   A'a'
        RETLW   A'r'
		RETLW	A's'
		RETLW   A' '
		RETLW   A' '
		RETLW   A' '
        RETLW   A'>'
        RETLW   H'0' 
        RETLW   A'<'	;51
       	RETLW   A' '
        RETLW   A'H'
        RETLW   A'a'
        RETLW   A'r'
        RETLW   A'r'
		RETLW	A'y'
		RETLW   A' '
        RETLW   A'P'
        RETLW   A'o'
		RETLW	A't'
		RETLW   A't'
		RETLW   A'e'
		RETLW   A'r'
        RETLW   A' '
        RETLW   A'>'
        RETLW   H'0' 
        RETLW   A'<'	;68
		RETLW   A' '
        RETLW   A' '
       	RETLW   A' '
        RETLW   A'P'
        RETLW   A'i'
        RETLW   A'r'
        RETLW   A'a'
		RETLW	A't'
		RETLW   A'e'
        RETLW   A's'
        RETLW   A' '
		RETLW	A' '
		RETLW   A' '
		RETLW   A' '
        RETLW   A'>'
        RETLW   H'0' 
	    RETLW   A' '	;85
        RETLW   A'C'
        RETLW   A'A'
        RETLW   A'X'
        RETLW   A'T'
        RETLW   A'R'
        RETLW   A'O'
        RETLW   A'N'
        RETLW   A' '
        RETLW   A'D'
        RETLW   A'"'
        RETLW   A'B'
        RETLW   A'E'
        RETLW   A'L'
		RETLW	A'L'
        RETLW   H'0'
		RETLW	A' '	;101
        RETLW   A'M'	
        RETLW   A'o'
        RETLW   A'v'
		RETLW	A'i'
		RETLW   A'e'
        RETLW   A's'
        RETLW   A' '
		RETLW	A'E'
		RETLW   A'd'
        RETLW   A'i'
        RETLW   A't'
		RETLW	A'i'
		RETLW	A'o'
		RETLW	A'n'
		RETLW	A' '
        RETLW   H'0'
        RETLW   A' '	;118
       	RETLW   A' '
        RETLW   A' '
        RETLW   A' '
        RETLW   A' '
		RETLW	A'T'
		RETLW   A'e'
        RETLW   A's'
        RETLW   A't'
		RETLW	A'?'
        RETLW   H'0'
        RETLW   A' '	;129
       	RETLW   A' '
        RETLW   A' '
        RETLW   A' '
        RETLW   A' '
        RETLW   A' '
		RETLW	A'S'
		RETLW   A'e'
        RETLW   A't'
        RETLW   A'?'
        RETLW   H'0'
        RETLW   A' '	;140
       	RETLW   A' '
        RETLW   A' '
        RETLW   A' '
        RETLW   A'T'
        RETLW   A'o'
		RETLW	A'n'
		RETLW   A'e'
        RETLW   A' '
        RETLW   A'S'
		RETLW	A'e'
		RETLW   A't'
		RETLW   A'!'
        RETLW   H'0'
	Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BUTTON CHECKING LOOP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Test_Button_1
	btfss	PORTA,0	
	goto 	Test_Button_2
	goto	Test_Button_1_Pressed

Test_Button_2
	btfss 	PORTA,1
	goto 	Test_Button_3
	goto	Test_Button_2_Pressed

Test_Button_3
	btfsc 	PORTA,2
	goto 	Test_Button_4
	goto	Test_Button_3_Pressed

Test_Button_4
	btfss 	PORTA,3
	goto 	Loop_Counter
	goto	Test_Button_4_Pressed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BUTTON 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Test_Button_1_Pressed
	Call Reset_Loop_Counter			;Reset the LCD shut down timer
	
	btfss	PORTB, 2
	goto	Test_Button_1_Wake

	incf	Tone_Choice				;Increment the selected tone
	Call	List_Position_Check
	movlw 	d'1'					;Play the button feedback tone
	Call 	Play_Note_A5_FB			;Play the button feedback tone

Test_Button_1_Wake
	bsf		PORTB, 2				;Turn on the LCD Backlight
	Clrf	LCD_mode				;Set LCD to "Test?" mode
	Call 	REFRESH_LCD_DISPLAY		;Refresh the LCD

Test_Button_1_Wait					;Wait for the Button to be released
	btfss 	PORTA,0	
	goto 	Test_Button_2
	Call	DELAY_1mS
	goto 	Test_Button_1_Wait

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BUTTON 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Test_Button_2_Pressed
	Call 	Reset_Loop_Counter		;Reset the LCD shut down timer

	btfss	PORTB, 2
	goto	Test_Button_2_Wake
	
	bsf		PORTB, 2				;Turn on the LCD Backlight

	movlw	b'00000100'
	decf	Tone_Choice				;Deccrement the selected tone
	btfsc 	Tone_Choice,7
	movwf	Tone_Choice

	movlw 	d'1'					
	Call 	Play_Note_F5_FB			;Play the button feedback tone

Test_Button_2_Wake
	bsf		PORTB, 2
	Clrf	LCD_mode				;Set LCD to "Test?" mode
	Call 	REFRESH_LCD_DISPLAY		;Refresh the LCD

Test_Button_2_Wait					;Wait for the Button to be released
	btfss 	PORTA,1	
	goto 	Test_Button_3
	Call	DELAY_1mS
	goto 	Test_Button_2_Wait

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BUTTON 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Test_Button_3_Pressed
	Call Reset_Loop_Counter			;Reset the LCD shut down timer

	btfss 	LCD_mode,0				;If LCD is in "Test?" mode, play the tone
	Call	Test_Choice

	btfsc 	LCD_mode,0				;If LCD is in "Set?" mode, Set the tone
	goto	Save_Choice

	btfss 	PORTA,2	
	goto 	Test_Button_4
	Call	DELAY_1mS
	
Test_Button_3_Wait
	btfss 	PORTA,2	
	goto 	Test_Button_4
	Call	DELAY_1mS
	goto 	Test_Button_3_Wait


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BUTTON 4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Test_Button_4_Pressed
	
	movlw	0x01				
	movwf	EEADR
	Call	READ_FROM_EEPROM		
	movwf	Tone_to_Play			;Load the saved tone from memory
	Call 	PLAY_TONE

Test_Button_4_Wait
	btfss 	PORTA,3	
	goto 	Loop_Counter
	Call	DELAY_1mS
	goto 	Test_Button_4_Wait

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LOOP COUNTER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Loop_Counter
	decfsz	Loop_Count, f
	goto 	Test_Button_1
	goto 	Time_Out_Length
Time_Out_Length
	decfsz	Loop_Count2, f
	goto	Loop_Count_Reset
	goto	Time_Out_Length2
Time_Out_Length2
	decfsz	Loop_Count3, f
	goto	Loop_Count2_Reset
	goto 	Shut_Down
Loop_Count_Reset
    MOVLW    0xFF
    MOVWF    Loop_Count
	goto 	Test_Button_1
Loop_Count2_Reset
    MOVLW    0xFF
    MOVWF    Loop_Count
	goto 	Loop_Count_Reset
Shut_Down
	Call 	CLEAR_DISPLAY_DOUBLE
	bcf    	PORTB, 2
	clrf	PORTB
	goto 	Test_Button_1
Reset_Loop_Counter
	movlw    0xFF
    movwf    Loop_Count
    movlw    0xFF
    movwf    Loop_Count2
    movlw    0x05
    movwf    Loop_Count3
	Return

Test_Choice
	btfss	PORTB, 2
	goto	Test_Button_3_Test_Wake

	bsf		PORTB, 2
	movlw 	b'00000001'
	movwf	LCD_mode
	Call 	REFRESH_LCD_DISPLAY

	movf	Tone_Choice,W			;Play chosen tone
	movwf	Tone_to_Play
	Call 	PLAY_TONE

Test_Button_3_Test_Wake
	bsf		PORTB, 2
	Call 	REFRESH_LCD_DISPLAY

	goto Test_Button_3_Wait	

Save_Choice
	btfss	PORTB, 2
	goto	Test_Button_3_Save_Wake

	bsf		PORTB, 2
	movlw 	b'00000010'
	movwf	LCD_mode
	Call 	REFRESH_LCD_DISPLAY

	;Save choice
	movlw	0x01
	movwf	EEADR
	movfw	Tone_Choice
	Call 	WRITE_TO_EEPROM

	clrf	LCD_mode

	goto Test_Button_3_Wait	

Test_Button_3_Save_Wake
	bsf		PORTB, 2
	Call 	REFRESH_LCD_DISPLAY

	goto Test_Button_3_Wait	

List_Position_Check
	btfss 	Tone_Choice,0
	return
	btfsc 	Tone_Choice,1
	return
	btfss 	Tone_Choice,2
	return
	clrf	Tone_Choice	
	return

Classic
	movlw d'12'
	Call Play_Note_A5
	movlw d'12'
	Call Play_Note_F4
	goto play_tone_end

Jones
	movlw d'5'
	Call Play_Note_B3
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_C4
	movlw d'1'
	Call Play_Silence
	movlw d'7'
	Call Play_Note_D4
	movlw d'1'
	Call Play_Silence
	movlw d'15'
	Call Play_Note_G4
	movlw d'1'
	Call Play_Silence

	movlw d'5'
	Call Play_Note_A3
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_B3
	movlw d'1'
	Call Play_Silence
	movlw d'23'
	Call Play_Note_C4
	movlw d'1'
	Call Play_Silence

	movlw d'5'
	Call Play_Note_D4
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_E4
	movlw d'1'
	Call Play_Silence
	movlw d'7'
	Call Play_Note_F#4
	movlw d'1'
	Call Play_Silence
	movlw d'15'
	Call Play_Note_C5
	movlw d'1'
	Call Play_Silence

	movlw d'5'
	Call Play_Note_E4
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_F#4
	movlw d'1'
	Call Play_Silence
	movlw d'8'
	Call Play_Note_G4
	movlw d'8'
	Call Play_Note_A4
	movlw d'8'
	Call Play_Note_B4
	goto play_tone_end

starwars

	movlw d'1'
	Call Play_Note_D4
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_D4
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_D4
	movlw d'1'
	Call Play_Silence

	movlw d'10'
	Call Play_Note_G4
	movlw d'2'
	Call Play_Silence
	movlw d'12'
	Call Play_Note_D5


	movlw d'1'
	Call Play_Note_C5
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_B4
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_A4
	movlw d'1'
	Call Play_Silence

	movlw d'10'
	Call Play_Note_G5
	movlw d'2'
	Call Play_Silence
	movlw d'6'
	Call Play_Note_D5

	movlw d'1'
	Call Play_Note_C5
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_B4
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_A4
	movlw d'1'
	Call Play_Silence

	movlw d'10'
	Call Play_Note_G5
	movlw d'2'
	Call Play_Silence
	movlw d'6'
	Call Play_Note_D5

	movlw d'1'
	Call Play_Note_C5
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_B4
	movlw d'1'
	Call Play_Silence
	movlw d'1'
	Call Play_Note_C5
	movlw d'1'
	Call Play_Silence

	movlw d'12'
	Call Play_Note_A4
	goto play_tone_end

harrypotter

	movlw d'4'
	Call Play_Note_B3

	movlw d'6'
	Call Play_Note_E4
	movlw d'2'
	Call Play_Note_G4
	movlw d'4'
	Call Play_Note_F#4

	movlw d'8'
	Call Play_Note_E4
	movlw d'4'
	Call Play_Note_B4

	movlw d'8'
	Call Play_Note_D5
	movlw d'4'
	Call Play_Note_C#5

	movlw d'8'
	Call Play_Note_C5
	movlw d'4'
	Call Play_Note_G#4

	movlw d'6'
	Call Play_Note_C5
	movlw d'2'
	Call Play_Note_B4
	movlw d'4'
	Call Play_Note_A#4


	movlw d'8'
	Call Play_Note_B3
	movlw d'4'
	Call Play_Note_G4

	movlw d'20'
	Call Play_Note_E4
	goto play_tone_end

pirates
	movlw d'2'
	Call Play_Note_B3
	movlw d'2'
	Call Play_Note_D4

	movlw d'3'
	Call Play_Note_E4
	movlw d'1'
	Call Play_Silence
	movlw d'3'
	Call Play_Note_E4
	movlw d'1'
	Call Play_Silence
	movlw d'2'
	Call Play_Note_E4
	movlw d'2'
	Call Play_Note_F#4

	movlw d'3'
	Call Play_Note_G4
	movlw d'1'
	Call Play_Silence
	movlw d'3'
	Call Play_Note_G4
	movlw d'1'
	Call Play_Silence
	movlw d'2'
	Call Play_Note_G4
	movlw d'2'
	Call Play_Note_A4

	movlw d'3'
	Call Play_Note_F#4
	movlw d'1'
	Call Play_Silence
	movlw d'4'
	Call Play_Note_F#4
	movlw d'2'
	Call Play_Note_E4
	movlw d'1'
	Call Play_Note_D4
	movlw d'1'
	Call Play_Silence

	movlw d'2'
	Call Play_Note_D4
	movlw d'3'
	Call Play_Note_E4

	goto play_tone_end

Play_Note_A3
	movwf Note_Delay_1
	movlw 0xC6
	movwf Waveform_Delay_1
	movlw 0x02
	movwf Waveform_Delay_2
	movlw d'14'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_A#3
	movwf Note_Delay_1
	movlw 0xAC
	movwf Waveform_Delay_1
	movlw 0x02
	movwf Waveform_Delay_2
	movlw d'14'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_B3
	movwf Note_Delay_1
	movlw 0x94
	movwf Waveform_Delay_1
	movlw 0x02
	movwf Waveform_Delay_2
	movlw d'15'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_C4
	movwf Note_Delay_1
	movlw 0x7D
	movwf Waveform_Delay_1
	movlw 0x02
	movwf Waveform_Delay_2
	movlw d'16'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_C#4
	movwf Note_Delay_1
	movlw 0x68
	movwf Waveform_Delay_1
	movlw 0x02
	movwf Waveform_Delay_2
	movlw d'17'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_D4
	movwf Note_Delay_1
	movlw 0x53
	movwf Waveform_Delay_1
	movlw 0x02
	movwf Waveform_Delay_2
	movlw d'18'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_D#4
	movwf Note_Delay_1
	movlw 0x41
	movwf Waveform_Delay_1
	movlw 0x02
	movwf Waveform_Delay_2
	movlw d'19'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_E4
	movwf Note_Delay_1
	movlw 0x2E
	movwf Waveform_Delay_1
	movlw 0x02
	movwf Waveform_Delay_2
	movlw d'20'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_F4
	movwf Note_Delay_1
	movlw 0x1E
	movwf Waveform_Delay_1
	movlw 0x02
	movwf Waveform_Delay_2
	movlw d'22'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_F#4
	movwf Note_Delay_1
	movlw 0x0D
	movwf Waveform_Delay_1
	movlw 0x02
	movwf Waveform_Delay_2
	movlw d'23'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_G4
	movwf Note_Delay_1
	movlw 0xFE
	movwf Waveform_Delay_1
	movlw 0x01
	movwf Waveform_Delay_2
	movlw d'24'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_G#4
	movwf Note_Delay_1
	movlw 0xF0
	movwf Waveform_Delay_1
	movlw 0x01
	movwf Waveform_Delay_2
	movlw d'26'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_A4
	movwf Note_Delay_1
	movlw 0xE2
	movwf Waveform_Delay_1
	movlw 0x02
	movwf Waveform_Delay_2
	movlw d'27'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_A#4
	movwf Note_Delay_1
	movlw 0xD6
	movwf Waveform_Delay_1
	movlw 0x01
	movwf Waveform_Delay_2
	movlw d'29'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_B4
	movwf Note_Delay_1
	movlw 0xC9
	movwf Waveform_Delay_1
	movlw 0x01
	movwf Waveform_Delay_2
	movlw d'31'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_C5
	movwf Note_Delay_1
	movlw 0xBE
	movwf Waveform_Delay_1
	movlw 0x01
	movwf Waveform_Delay_2
	movlw d'32'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_C#5
	movwf Note_Delay_1
	movlw 0xB4
	movwf Waveform_Delay_1
	movlw 0x01
	movwf Waveform_Delay_2
	movlw d'34'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_D5
	movwf Note_Delay_1
	movlw 0xA9
	movwf Waveform_Delay_1
	movlw 0x01
	movwf Waveform_Delay_2
	movlw d'36'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_D#5
	movwf Note_Delay_1
	movlw 0xA0
	movwf Waveform_Delay_1
	movlw 0x01
	movwf Waveform_Delay_2
	movlw d'39'
	movwf Pulse_Delay_1
	Call Play_Note
	return
Play_Note_E5
	movwf Note_Delay_1
	movlw 0xFC
	movwf Waveform_Delay_1
	movlw 0x00
	movwf Waveform_Delay_2
	movlw d'41'
	movwf Pulse_Delay_1
	Call Play_HIGH_Note
	return
Play_Note_F5
	movwf Note_Delay_1
	movlw 0xEE
	movwf Waveform_Delay_1
	movlw 0x00
	movwf Waveform_Delay_2
	movlw d'43'
	movwf Pulse_Delay_1
	Call Play_HIGH_Note
	return
Play_Note_F#5
	movwf Note_Delay_1
	movlw 0xE1
	movwf Waveform_Delay_1
	movlw 0x00
	movwf Waveform_Delay_2
	movlw d'46'
	movwf Pulse_Delay_1
	Call Play_HIGH_Note
	return
Play_Note_G5
	movwf Note_Delay_1
	movlw 0xD4
	movwf Waveform_Delay_1
	movlw 0x00
	movwf Waveform_Delay_2
	movlw d'47'
	movwf Pulse_Delay_1
	Call Play_HIGH_Note
	return
Play_Note_G#5
	movwf Note_Delay_1
	movlw 0xC8
	movwf Waveform_Delay_1
	movlw 0x00
	movwf Waveform_Delay_2
	movlw d'52'
	movwf Pulse_Delay_1
	Call Play_HIGH_Note
	return
Play_Note_A5
	movwf Note_Delay_1
	movlw 0xBD
	movwf Waveform_Delay_1
	movlw 0x00
	movwf Waveform_Delay_2
	movlw d'55'
	movwf Pulse_Delay_1
	Call Play_HIGH_Note
	return
Play_Silence
	movwf Note_Delay_1
	movlw 0xBD
	movwf Waveform_Delay_1
	movlw 0x00
	movwf Waveform_Delay_2
	movlw d'55'
	movwf Pulse_Delay_1
	Call Play_SILENCE_Note
	return

;FEEDBACK NOTES
Play_Note_A5_FB
	movwf Note_Delay_1
	movlw 0xBD
	movwf Waveform_Delay_1
	movlw 0x00
	movwf Waveform_Delay_2
	movlw d'110'
	movwf Pulse_Delay_1
	Call Play_HIGH_FB_Note
	return
Play_Note_F5_FB
	movwf Note_Delay_1
	movlw 0xEE
	movwf Waveform_Delay_1
	movlw 0x00
	movwf Waveform_Delay_2
	movlw d'87'
	movwf Pulse_Delay_1
	Call Play_HIGH_FB_Note
	return


;**********************
;*     Call Note      *
;**********************

Play_Note
Delay_LOW_Note
		movf	Pulse_Delay_1,W
		movwf	Temp_Delay_3
Delay_LOW_Pulse
			btfsc 	PORTA,0
			goto 	Test_Button_1_Pressed

			btfsc 	PORTA,1 
			goto 	Test_Button_2_Pressed

			;Check to see if button 3 has been let go
			btfss 	PORTA,2 
			bcf		Text_Pressed_Bool, 0
	
			;If button 3 hasn't been let go, don't check button 3
			btfsc	Text_Pressed_Bool, 0
			goto 	LOW_Skip_Button_3_Check

			;Button 3 has been let go, so check if it has been pressed again
			btfsc 	PORTA,2 
			goto 	Test_Button_3_Pressed	
LOW_Skip_Button_3_Check
			bsf		PORTB, 0
			;movlw	b'00000001'	;Prepare the command for the LED
			;movwf	PORTB		;Turn on the LED
		
			movf	Waveform_Delay_1,W
			movwf 	Temp_Delay_1
			movf	Waveform_Delay_2,W
			movwf	Temp_Delay_2		
Delay_LOW_1
			decfsz	Temp_Delay_1, f
			goto	$+2
			decfsz	Temp_Delay_2, f
			goto	Delay_LOW_1
			
			bcf		PORTB, 0
			;movlw	b'00000000'
			;movwf	PORTB
		
			movf	Waveform_Delay_1,W
			movwf	Temp_Delay_1
			movf	Waveform_Delay_2,W
			movwf	Temp_Delay_2
Delay_LOW_2
			decfsz	Temp_Delay_1, f
			goto	$+2
			decfsz	Temp_Delay_2, f
			goto	Delay_LOW_2

			decfsz	Temp_Delay_3, f
			goto	Delay_LOW_Pulse
		decfsz	Note_Delay_1, f
		goto	Delay_LOW_Note
	return

Play_HIGH_Note
Delay_HIGH_Note
		movf	Pulse_Delay_1,W
		movwf	Temp_Delay_3
Delay_HIGH_Pulse
			btfsc 	PORTA,0	
			goto 	Test_Button_1_Pressed

			btfsc 	PORTA,1 
			goto 	Test_Button_2_Pressed

			;Check to see if button 3 has been let go
			btfss 	PORTA,2 
			bcf		Text_Pressed_Bool, 0
	
			;If button 3 hasn't been let go, don't check button 3
			btfsc	Text_Pressed_Bool, 0
			goto 	HIGH_Skip_Button_3_Check

			;Button 3 has been let go, so check if it has been pressed again
			btfsc 	PORTA,2 
			goto 	Test_Button_3_Pressed	
HIGH_Skip_Button_3_Check
			bsf		PORTB, 0
		
			movf	Waveform_Delay_1,W
			movwf 	Temp_Delay_1
Delay_HIGH_1
			decfsz	Temp_Delay_1, f
			goto	Delay_HIGH_1
			
			bcf		PORTB, 0
		
			movf	Waveform_Delay_1,W
			movwf	Temp_Delay_1
Delay_HIGH_2
			decfsz	Temp_Delay_1, f
			goto	Delay_HIGH_2

			decfsz	Temp_Delay_3, f
			goto	Delay_HIGH_Pulse

		decfsz	Note_Delay_1, f
		goto	Delay_HIGH_Note

	return

Play_SILENCE_Note
Delay_SILENCE_Note
		movf	Pulse_Delay_1,W
		movwf	Temp_Delay_3
Delay_SILENCE_Pulse
			bcf		PORTB,0
		
			movf	Waveform_Delay_1,W
			movwf 	Temp_Delay_1
Delay_SILENCE_1
			decfsz	Temp_Delay_1, f
			goto	Delay_SILENCE_1
			
			bcf		PORTB,0

		
			movf	Waveform_Delay_1,W
			movwf	Temp_Delay_1
Delay_SILENCE_2
			decfsz	Temp_Delay_1, f
			goto	Delay_SILENCE_2

			decfsz	Temp_Delay_3, f
			goto	Delay_SILENCE_Pulse

		decfsz	Note_Delay_1, f
		goto	Delay_SILENCE_Note

	return
	
;*************************
;*     Call FB Note      *
;*************************

Play_HIGH_FB_Note
Delay_HIGH_FB_Note
Delay_HIGH_FB_Pulse
	bcf		PORTB,0

	movf	Waveform_Delay_1,W
	movwf 	Temp_Delay_1
Delay_HIGH_FB_1
	decfsz	Temp_Delay_1, f
	goto	Delay_HIGH_FB_1
	
	bsf		PORTB,0

	movf	Waveform_Delay_1,W
	movwf	Temp_Delay_1
Delay_HIGH_FB_2
	decfsz	Temp_Delay_1, f
	goto	Delay_HIGH_FB_2

	decfsz	Pulse_Delay_1, f
	goto	Delay_HIGH_FB_Pulse

	decfsz	Note_Delay_1, f
	goto	Delay_HIGH_FB_Note
	return

WRITE_TO_EEPROM
	movwf	EEDATA				; Populate EEPROM with data to write
	bsf 	STATUS,RP0 			; Bank 1
	bsf 	EECON1, b'00000100' ; enable EEPROM writes
	movlw 	0x55 				; begin writing
	movwf 	EECON2
	movlw 	0xAA
	movwf 	EECON2
	bsf 	EECON1, b'00000010'	; Write data
	bcf 	STATUS,RP0 			; Bank 0
	return

READ_FROM_EEPROM
	bsf 	STATUS,RP0 			; Bank 1
	bsf 	EECON1, b'00000001' ; read the data
	bcf 	STATUS,RP0 			; Bank 0
	movf 	EEDATA,W
	return

;*************************
;*     LCD ROUTINES      *
;*************************

INITIALISE_LCD  ; This routine initialises the LCD so that it is ready to display characters
        BCF     PORTB, RS           ; Register Select (0=Command, 1=Character) 
        MOVLW   B'00110010'         
        CALL    FOUR_BIT_MODE       ; Send upper nibble, followed by lower nibble
        MOVLW   B'00101000'         ; Function Set (Command): 4-Bit Mode, 2 Line, 5x7 Dot Matrix
        CALL    FOUR_BIT_MODE       ; Send upper nibble, followed by lower nibble
        MOVLW   B'00001100'         ; Display On/Off & Cursor (Command): Display On, Cursor Underline ON, Cursor Blink ON
        CALL    FOUR_BIT_MODE       ; Send upper nibble, followed by lower nibble
        RETURN       
CLEAR_DISPLAY_DOUBLE
        BCF     PORTB, RS           ; Register Select (0=Command, 1=Character)        
        MOVLW   B'00000001'         ; Clear Display (Command): 
        CALL    FOUR_BIT_MODE       ; Send upper nibble, followed by lower nibble
        BCF     PORTB, RS           ; Register Select (0=Command, 1=Character)        
        MOVLW   B'00000001'         ; Clear Display (Command): 
        CALL    FOUR_BIT_MODE       ; Send upper nibble, followed by lower nibble
        RETURN   
FOUR_BIT_MODE
        MOVWF   DATA1               ; Move byte to GPR to store it
        ANDLW   B'11110000'         ; 
        MOVWF   DATA2               ; 
		bsf		W, 2
        MOVF    PORTB, W            ; 
        ANDLW   B'00001111'         ; 
        IORWF   DATA2, W            ; 
		bsf		W, 2
        MOVWF   PORTB   
        CALL    TOGGLE_E            ; 
        
        SWAPF   DATA1, F            ; 
        MOVF    DATA1, W            ; 
        ANDLW   B'11110000'         ; 
        MOVWF   DATA2               ; 
		bsf		W, 2
        MOVF    PORTB, W            ; 
        ANDLW   B'00001111'         ; 
        IORWF   DATA2, W            ; 
		bsf		W, 2
        MOVWF   PORTB               ; 
        CALL    TOGGLE_E            ; 
        RETURN
TOGGLE_E  ; This routine is called when a command/character is ready to be entered into the LCD
        BCF     PORTB, E            ; Data is enter on the falling edge, therefore we clear the E line to enter data
        CALL    DELAY_1mS           ; Wait
        CALL    DELAY_1mS           ; Wait
        BSF     PORTB, E            ; Set E line ready for next data string
        RETURN       
GOTO_LINE1
		BCF		PORTB,RS
		MOVLW   B'00000010' 
		CALL	FOUR_BIT_MODE
		RETURN
GOTO_LINE2
		BCF		PORTB,RS
		MOVLW	 b'11000000'
		CALL	FOUR_BIT_MODE
		RETURN
TYPE_IT 
		movlw  	high CHARACTER_TABLE
	   	movwf  	PCLATH
	   	movf   	GPR1,w
	   	addlw  	CHARACTER_TABLE
	   	BTFSC 	STATUS,C
	    incf  	PCLATH,f
        MOVF    GPR1, W             ; Move GPR1 to the Working Register. This number will be the line number of the table we will start printing from (+1)
        CALL    CHARACTER_TABLE     ; Call 'CHARACTER_TABLE' to get character
        MOVWF   DATA1               ; Move Charater byte to GPR
        XORLW   B'00000000'         ; Is this the last line of the charater table? XOR the ASCII Character with '0' (The 'XORLW' intruction affects the 'Zero' bit or the Status Register)
        BTFSC   STATUS, Z           ; Test 'Zero' bit of Status Register
        GOTO    $+4                 ; If the ASCII Character returned is a zero, we have already finished printing the word. This is what the H'0' after every string of characters in the lookup table is. So we skip 5 instructions to the RETURN
        CALL    FOUR_BIT_MODE       ; Enter charater to LCD in 4 bit mode
        INCF    GPR1                ; Increment GPR to print next ASCII Character
        GOTO    TYPE_IT                 ; Do it again
        RETURN

; DELAY ROUTINES
; Actual delay = 0.001 seconds = 1000 cycles
DELAY_1mS
        MOVLW    0xC6                ;
        MOVWF    DELAYGPR1           ;
        MOVLW    0x01                ;
        MOVWF    DELAYGPR2           ;
DELAY_1mS_0                          ;
        DECFSZ   DELAYGPR1, f        ;
        GOTO     $+2                 ;
        DECFSZ   DELAYGPR2, f        ;
        GOTO     DELAY_1mS_0         ; 993 cycles
        GOTO     $+1                 ;
        NOP                          ; 3 cycles
        RETURN                       ; 4 cycles (including call)

	end
