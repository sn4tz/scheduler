# Konzept Scheduler
Dies ist das in Repository für den Scheduler sowie im gleichen Zug in dieser README auch das in Aufgabe 10.1 geforderte Konzept.

## Task Struktur
Die Task-Struktur ist in dem Format "NAME:BIT" aufgebaut, wobei "BIT" die Anzahl der benötigten Bits widerspiegelt.

ID: 2
Registerbank: 2
Stackpointer (Init): 8

Die Task-Strukturen sollen in den Registern des Scheduler gespeichert werden.
Dabei sind immer 2 Register einem Task zugeordnet.
Setzt man diese Register zusammen, ergeben sich im Highbyte die ID mit Bit-Positionen 3 und 2 sowie Registerbank mit Bit-Position 1 und 0.
Im Lowbyte befindet sich der Stackpointer.

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
#### Struktur
ID: 00_2 | 0_10
Registerbank: 00_2 | 0_10
Stackpointer (Init): 80_16

#### Info
- Sitzt in der Interrupt Routine von Timer 0, unserem Scheduler-Periode-Timer
- schaltet die Registerbänke für die Tasks um
    - ggf. auch Stacks falls gewünscht
- setzt den Interrupt-Bit und Überlauf-Bit 
- Beim Aufruf des Schedulers werden PSW und PC des Tasks auf den Stack des Tasks gespeichert.
    - Der Scheduler muss sobald er Aufgerufen wird den Stackpointer des vorherigen Tasks speichern, auf seinen eigenen Ändern und vor dem Aufruf eines neuen Tasks den aktuellen SP speichern und den SP auf den Stack des jeweiligen Tasks setzen, bevor mit reti retuniert wird
    - ACHTUNG: bei dem ersten Aufruf von den Tasks sind PSW und PC nicht in den Stacks gesetzt. Hier wäre die Überlegung das in der Initialisierung zu machen.
- !Amys Aufgabe!

### Uhr
#### Struktur
ID: 01_2 | 1_10
Registerbank: 01_2 | 1_10
Stackpointer (Init): A0_16

#### Info
- Timer 2 wird für die Uhr verwendet um alle 50 ms ausgelesen zu werden
    - Der Interrupt wird dabei nicht verwendet; das Interrupt-Bit wird eigenständig ausgelesen
    - Ist der Interrupt bit nicht gesetzt, wird direkt wieder an den Scheduler abgegeben (Scheduler/Timer 0 Interrupt-Bit setzen)
- Uhrzeit in den Registern speichern

### Reaktions-Task
#### Struktur
ID: 10_2 | 2_10
Registerbank: 10_2 | 2_10
Stackpointer (Init): C0_16

#### Info
- Ports müssen festgelegt werden
    - Port 1 als Eingabe
    - P3.2 und P3.3 als Ausgabe 
- Anliegender Wert an Port 1 speichern und bei erneutem Aufruf vergleichen
    - Wert gleich: Abgeben an den Scheduler
    - Wert ungleich: Programm weiter ausführen

### Berechnungs-Task
#### Struktur
ID: 11_2 | 3_10
Registerbank: 11_2 | 3_10
Stackpointer (Init): E0_16

#### Info
- Die Info speichern wo wir gerade sind beim Sortieren damit wir nicht immer neu anfangen müssen
    - Registerbänke?
- Sortieralgorithmus
    - Bubble-Sort
- !Ollis Aufgabe!
