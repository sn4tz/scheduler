#cpu = 89S8252

SortXRam:
	movx A, @DPTR
	mov R0, A
	
	 inc DPTR 
	movx A, @DPTR
	mov R1, A
	
	subb A, R0 ; Carry = 1, wenn R0 > A, also unsortiert -> tauschen	
	jnc SortXRam

	dec DPL
	mov A, DPL
	cjne A, #FFh, Skip
	dec DPH
	
	Skip:
 	mov A, R1
	movx @DPTR, A
	inc DPTR
	mov A, R0
	movx @DPTR, A
	
	mov A, DPH
	cjne A, #FFh, SortXRam
	mov A, DPL
	cjne A, #FFh, SortXRam
	inc DPTR
	sjmp SortXRam



	