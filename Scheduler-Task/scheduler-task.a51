scheduler:
	; push SFR old task
	push E0h	; push A
	push F0h	; push B
	push D0h	; push PSW
	push 82h	; push DPL
	push 83h	; push DPH

	; select registerbank scheduler
	clr RS1
	clr RS0

	; temporarly save SP of old task
	mov R3, SP
	
	; set SP of scheduler
	mov SP, R4

	; pop SFR scheduler task
	pop 83h		; pop DPH
	pop 82h		; pop DPL
	pop D0h 	; pop PSW
	pop F0h		; pop B
	pop E0h		; pop A

	; permanently save SP of old task
	mov R0, A
	mov @R0, 03h	; copy from R3 to indirect R0 

	; select new Task
	dec A
	cjne A, #03h, notFirstTimeRun
  	mov A, #07h
  notFirstTimeRun:
	cjne A, #04h, validRegister
		mov A, #07h
	validRegister:

	; push SFR scheduler task
	push E0h	; push A
	push F0h	; push B
	push D0h	; push PSW
	push 82h	; push DPL
	push 83h	; push DPH

	; set SP of new task
	mov R0, A
	mov SP, @R0

	; pop SFR new task
	pop 83h		; pop DPH
	pop 82h		; pop DPL
	pop D0h 	; pop PSW
	pop F0h		; pop B
	pop E0h		; pop A

	; reset Timer 0
	mov TL0, #3Ch
	mov TH0, #F6h

	reti
