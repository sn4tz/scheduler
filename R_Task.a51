#cpu = 89S8252

clr c
clr rs0 
setb rs1 ;Wechselt in die zweite Bank

	mov a, r0
	
	cjne a, P1, Comp_P1 ;Vergleich ob sich was zur vorherigen Eingabe geändert hat
	sjmp ende

Comp_P1:
			
			clr P3.2 ;Voherige Ausgaben clearen
			clr P3.3	

			mov a, p1 ;Laden des Ports in den Akku
			mov r0, a ;Sichern des Inputs
	
	cjne a, #100, L1 ;Vergleicht ob A kleiner 100, wenn wird Carry gesetzt
	
		L1: 
			jc kleiner
	
	cjne a, #199, L2	;Vergleicht ob A kleiner 199 ist, wenn wird Carry gesetzt -- Dementsprechend muss bei keinem Carry A < 199 sein
	
		L2: 
			jnc groesser
		
	cjne a, #0, L3
	
		L3:
			jc error
			
	cjne a, #255, L4
		
		L4:
			jnc error
			
	ende:
		end
	
	kleiner:
		setb P3.3
		sjmp ende
		
	groesser:
		setb P3.2
		sjmp ende
	
	error:			;Falls kleiner als 0 oder größer als 255 springt er in den Error-Zustand und verbleibt dort
		setb P3.2
		setb P3.3
		sjmp error