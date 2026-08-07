# Konzept Scheduler
Dies ist das in Repository für den Scheduler sowie im gleichen Zug in dieser README auch das in Aufgabe 10.1 geforderte Konzept.

## Task Verwaltung
Jeden der 3 anderen Tasks wird ein Register in der Registerbank des Schedulers zugewisen.
In diesen Registern wird der Stackpointer gespeichert und von dort auch geladen.
Das weitere Vorgehen ist im _Scheduler_ beschrieben.

## Scheduling-Periode
Die Scheduling-Periode beträgt 2,5 ms.
Somit ist die Echtzeitanforderung von 10 ms für den Reaktions-Task gegeben, da jeder Task maximal 2,5 ms verwendet, was summiert bei 4 Tasks 10 ms sind.
Es wird Timer 0 mit Modus 1 verwendet.
Timer 0 muss bei jedem Aufruf eines Tasks neu gesetzt werden auf F63C_16 | 1111-0110-0011-1100_2 | 63.036_10.

## Einflussparameter
- Hitze
- "Sortiertheit" des externen RAMs

## Tasks

### Scheduler
#### Info
- Stackpointer (Init): 80_16
- Registerbank: 00_2 | 0_10
- Register für SP: R4 | 04_16
- Sitzt in der Interrupt Routine von Timer 0, unserem Scheduler-Periode-Timer
- schaltet die Registerbänke für die Tasks um
    - ggf. auch Stacks falls gewünscht
- Beim Aufruf des Schedulers wird PC des Tasks auf den Stack des Tasks gespeichert.
    - Der Scheduler muss sobald er Aufgerufen wird wie in _SFR-Behandlung bei Taskwechsel_ angegeben, die genannten SFR auf dem Stack speichern, den Stackpointer des vorherigen Tasks in der Task Struktur speichern, auf seinen eigenen Ändern und vor dem Aufruf eines neuen Tasks den aktuellen SP speichern, den SP auf den Stack des jeweiligen Tasks setzen und die SFR laden, bevor mit reti retuniert wird
    - ACHTUNG: bei dem ersten Aufruf von den Tasks sind PSW und PC nicht in den Stacks gesetzt. Hier wäre die Überlegung das in der Initialisierung zu machen.
- Ablauf des Schedulers
    - Pushen der SFR auf den Stack des alten Tasks
    - wechseln der Registerbank
    - laden des Scheduler Stacks
    - Poppen der SFR vom Scheduler Stack
    - Nächsten Task auswählen
        - Dies funktioniert indem wir im A-Register des Schedulers unsere Adresse des Registers mit dem SP des nächsten Tasks haben
        - Der Wert von A wird dann in SP geladen
        - Alle weiteren Werte werden vom Stack geladen (Auch PSW wodurch die Registerbänke gesetzt werden.)
    - Pushen der SFR auf den Scheduler Stack
    - Popen der SFR vom Stack des neuen Tasks
- !Amys Aufgabe!

### Uhr
#### Info
- Registerbank: 01_2 | 1_10
- Stackpointer (Init): A0_16
- Register für SP: R5 | 05_16
- Timer 2 wird für die Uhr verwendet um alle 50 ms ausgelesen zu werden
    - Der Interrupt wird dabei nicht verwendet; das Interrupt-Bit wird eigenständig ausgelesen
    - Ist der Interrupt bit nicht gesetzt, wird direkt wieder an den Scheduler abgegeben (Scheduler/Timer 0 Interrupt-Bit setzen)
- Uhrzeit in den Registern speichern

### Reaktions-Task
#### Info
- Registerbank: 10_2 | 2_10
- Stackpointer (Init): C0_16
- Register für SP: R6 | 06_16
- Ports müssen festgelegt werden
    - Port 1 als Eingabe
    - P3.2 und P3.3 als Ausgabe 
- Anliegender Wert an Port 1 speichern und bei erneutem Aufruf vergleichen
    - Wert gleich: Abgeben an den Scheduler
    - Wert ungleich: Programm weiter ausführen

### Berechnungs-Task
#### Info
- Registerbank: 11_2 | 3_10
- Stackpointer (Init): E0_16
- Register für SP: R7 | 07_16
- Die Info speichern wo wir gerade sind beim Sortieren damit wir nicht immer neu anfangen müssen
    - Registerbänke?
- Sortieralgorithmus
    - Bubble-Sort
- !Ollis Aufgabe!

## Initialisierung der Stacks
Bei einem Interrupt wird der PC in folgender Reihenfolge auf den Stack abgelegt:
1. Lowbyte
2. Highbyte

Um die Stacks zu initialisieren müssen abseits des PC, der Automatisch beim Aufruf des Interrupts abgelegt wird, auch andere Register zusätzlich abgelegt werden.
Dazu gehören:
- Akkumulator
- B-Register
- PSW-Register
- DPTR-Register

Der PC im Stack wird bei der Initialisierung auf die Label der jeweiligen Programme gesetzt.
Alle anderen Register werden auf 0_16 initialisiert.

## SFR-Behandlung bei Taskwechsel
Beim Aufruf des Scheduler wird durch die Interruptbehandlung der jeweilige PC automatisch auf den Stack gespeichert.
Dies reicht jedoch für einen Task-Wechsel nicht aus, da auch die Spezialfunktionsregister (SFR) ...
- Akkumulator
- B-Register
- PSW-Register
- DPTR-Register
 ... zwischengespeichert werden müssen.

Um dies zu erreichen muss der Scheduler dafür sorgen das diese zwischengespeichert werden.

## Initialisierung
In der Initialisierung müssen verschiedene Werte gesetz werden.
Am Ende muss das Interrupt-bit für Timer 0 gesetzt werden.

### Stackpointer
Zu aller erst wird der Stackpointer (SP) auf den Stack des Schedulers gesetzt.
In unserem Fall beginnt der Stack des Schedulers bei 80h, weshalb der Stack auf 7Fh gesetzt wird.

### Timer 0
Timer 0 muss auf den Modus 1 (16-bit) geschalten werden.
Dann wird er geladen mit F63Ch und gestartet.

### Timer 2
Timer 2 wird im Nachlademodus betrieben.
Dafür muss einerseits Timer 2 und die Nachladeregister von Timer 2 geladen werden.
Beide werden mit dem Wert 3CB0h geladen.
Als letztes wird Timer 2 gestartet.

### Interrupts
Es wird der Interrupt für Timer 0 eingeschalten.
Es werden global die Interrupts freigeschalten.

### Scheduler-Task
Um den Scheduler-Task vorzubereiten muss in A der Wert 04h geschrieben werden.
Durch A wird der nächste Task bestimmt, in dem Fall der Task dessen SP in Register 7 steht.

### Uhr-Task
Der SP des Uhr-Task beginnt bei A0h.
Auf den Stack der Uhr werden die folgenden Werte geschrieben:
- Lowbyte Programmlabel
- Highbyte Programmlabel
- Akkumulator (00h)
- B-Register (00h)
- PSW-Register (08h)
- Lowbyte DPTR (00h)
- Highbyte DPTR (00h)
Der Stackpointer ist dementsprechend am Ende bei A6h und wird in Register 5 gespeichert.

### Reaktions-Task
Der SP des Reaktions-Task beginnt bei C0h.
Auf den Stack des Reaktions-Task werden die folgenden Werte geschrieben:
- Lowbyte Programmlabel
- Highbyte Programmlabel
- Akkumulator (00h)
- B-Register (00h)
- PSW-Register (10h)
- Lowbyte DPTR (00h)
- Highbyte DPTR (00h)
Der Stackpointer ist dementsprechend am Ende bei C6h und wird in Register 6 gespeichert.

### Berechnungs-Task
Der SP des Berechnungs-Task beginnt bei E0h.
Auf den Stack des Berechnungs-Task werden die folgenden Werte geschrieben:
- Lowbyte Programmlabel
- Highbyte Programmlabel
- Akkumulator (00h)
- B-Register (00h)
- PSW-Register (18h)
- Lowbyte DPTR (00h)
- Highbyte DPTR (00h)
Der Stackpointer ist dementsprechend am Ende bei E6h und wird in Register 7 gespeichert.

