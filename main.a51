; 06/08/2026 21:22:44

#cpu = 89S8252	; @12 MHz


ajmp Initialisierung

Timer 0:	; Timer 0 Interrupt
	ajmp scheduler

Initialisierung:
mov SP, # 7Fh	; Stackbeginn
orl TMOD, # 01h	; Timer 0 als 16-Bit Timer. 
; Die Überlauffrequenz des Timer 0 beträgt 15,25879 Hz, die Periodendauer 65,536 ms.
mov TL0, # 3Ch
mov TH0, # F6h
setb TR0	; Timer 0 läuft.
; Timer 2:
; Timer 2 ist ein 16-Bit Aufwärtszähler mit automatischer Nachladung aus den Reload-Registern bei Überlauf. Die Überlauffrequenz beträgt 20 Hz, die Periodendauer 50 ms.
mov RCAP2L, # B0h
mov RCAP2H, # 3Ch
mov TL2, # B0h
mov TH2, # 3Ch
setb TR2	; Timer 2 läuft.

; Interrupts
setb ET0	; Timer 0 Interrupt freigeben
setb EA	; globale Interruptfreigabe


; Uhr
mov DPTR, #UhrInit	; kopiere Adresse des Uhr-Labels in DPTR

mov SP, #9Fh	;wechsel in Uhr Stack
mov E0h, #00h
mov F0h, #08h

push DPL	; pushe Lowbyte der Adresse des Uhr-Labels 
push DPH		; kopiere Highbyte der Adresse des Uhr-Labels
push E0h			; schreibe Init-Wert für A auf Uhr Stack
push E0h			; schreibe Init-Wert für B auf Uhr Stack
push F0h			; schreibe Init-Wert für PSW auf Uhr Stack
push E0h			; schreibe Init-Wert für DPH auf Uhr Stack
push E0h			; schreibe Init-Wert für DPL auf Uhr Stack

mov R5, SP		; schreibe Uhr SP in Register 5

; Reaktions-Task
mov DPTR, #reaktionsTask		; kopiere Adresse des Reaktions-Task-Labels in DPTR

mov SP, #BFh
mov E0h, #00h
mov F0h, #10h

push DPL		; kopiere Lowbyte der Adresse des Reaktions-Task-Labels auf den Stack der Uhr
push DPH		; kopiere Highbyte der Adresse des Reaktions-Task-Labels auf den Stack der Uhr
push E0h			; schreibe Init-Wert für A auf Stack
push E0h			; schreibe Init-Wert für B auf Stack
push F0h			; schreibe Init-Wert für PSW auf Stack
push E0h			; schreibe Init-Wert für DPH auf Stack
push E0h 		; schreibe Init-Wert für DPL auf Stack

mov R6, SP		; schreibe SP in Register 6

; Berechnungs-Task
mov DPTR, #SortXRam		; kopiere Adresse des Berechnungs-Task-Labels in DPTR

mov SP, #DFh
mov E0h, #00h
mov F0h, #18h

push DPL		; kopiere Lowbyte der Adresse des Berechnungs-Task-Labels auf den Stack der Uhr
push DPH		; kopiere Highbyte der Adresse des Berechnungs-Task-Labels auf den Stack der Uhr
push E0h		; schreibe Init-Wert für A auf Stack
push E0h		; schreibe Init-Wert für B auf Stack
push F0h		; schreibe Init-Wert für PSW auf Stack
push E0h		; schreibe Init-Wert für DPH auf Stack
push E0h 		; schreibe Init-Wert für DPL auf Stack

mov R7, SP		; schreibe SP in Register 7

; Scheduler
mov A, #04h
mov R4, #86h ; copy SP after first call of scheduler into scheduler SP permanent storage
mov SP, #7Fh

setb TF0

end
; * * * Hauptprogramm Ende * * *

#Include 'Z:\embeddedsystems\einfuehrungsaufgaben\aufgabe10\Scheduler-Task\scheduler-task.a51'
#Include 'Z:\embeddedsystems\einfuehrungsaufgaben\aufgabe10\Uhr\Uhr_Sceduler.a51'
#Include 'Z:\embeddedsystems\einfuehrungsaufgaben\aufgabe10\R-Task\R_Task.a51'
#Include 'Z:\embeddedsystems\einfuehrungsaufgaben\aufgabe10\C-Task\C-Task.a51'


