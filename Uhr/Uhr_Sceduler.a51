UhrInit:
	mov R4, #14h
	mov R5, #00h
	mov R6, #00h
	mov R7, #00h

Uhr:
	jnb TF2, UhrEnde
	clr TF2
	
	djnz R4, UhrEnde ; Check 20 * 50 ms
	mov R4, #14h
	inc R5
	
	cjne R5, #3Ch, UhrEnde	
	mov R5, #00h
	inc R6
	
	cjne R6, #3Ch, UhrEnde
	mov R6, #00h
	inc R7
	
	cjne R7, #18h, UhrEnde
	mov R7, #00h
	
	UhrEnde:
		setb TF0
		sjmp Uhr