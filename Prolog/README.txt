=== lmc.pl ===
Autori: Tropeano Pietro 829757
Testato su: SWI-Prolog versione 7.6.4

Il LMC (Little Man Computer) è un semplice modello di computer creato per scopi
didattici. Esso possiede 100 celle di memoria (numerate da 0 a 99) ognuna delle
quali può contenere un numero da 0 a 999 (estremi inclusi). LMC possiede un
numero limitato di tipi di istruzioni ed un equivalente assembly altrettanto
semplificato.


== Descrizione ==

L'implementazione del progetto non impone limitazioni sulla estensione del file
di input, questo significa che sono ammessi file .lmc come file .txt o di
qualsiasi altra estensione esistente, si specifica che il file dovrà comunque
essere formattato correttamente affinchè possa essere correttamente eseguito.

Informazioni sufficienti per la realizzazione di file in assembly
semplificato possono essere trovate all'indirizzo:
https://it.wikipedia.org/wiki/Little_man_computer

N.B.

L'istruzione:
ADD 3
è equivalente a:
	adD            3 // questo è un commento

Si può quindi osservare che il linguaggio è case insesitive.
è possibile aggiungere spazi a piacere, questi non influiscono sul
codice macchina prodotto.

Un file assembler prodotto secondo le specifiche viene interpretato in codice
macchina e successivamente eseguito.

Il file assembly non deve contenere più di 100 istruzioni.

ATTENZIONE 

Non vi è distinzione tra dati e istruzioni: a seconda del momento il contenuto
di una cella può essere interpretato come una istruzione o come un dato.

Un LMC è composto dai seguenti componenti:
	1. Una memoria di 100 celle numerate tra 0 e 99.
	2. Un registro accumulatore (inizialmente 0).
	3. Un program counter (inizialmente 0) punta alla istruzione da eseguire.
	4. Una coda di input Contenente tutti i valori forniti in input al LMC 
	   (i valori devono essere compresi tra 0 e 999)
	5. Una coda di output contenente tutti i valori forniti in output dal LMC
	6. Un flag, inizialmente a 0, le istruzioni aritmetiche possono alterare il
	   suo valore. Se il flag è a 1 indica che l'ultima operazione aritmetica
	   ha un prodotto maggiore di 999 o minore di 0. Un flag assente indica che
	   il prodotto dell'ultima operazione ha risultato compreso tra 0 e 999.
	   
Le etichette o label servono a semplificare la stesura del codice e 
identificano la cella di memoria dove verrà salvata l'istruzione associata.


== Come eseguire il proprio codice assembler ==

Per eseguire il proprio codice assembler in ambiente prolog seguire l'esempio:

?- lmc_run("path_to_file", [input], Output).

path_to_file è l'indirizzo del file in formato assembly da consultare,
l'indirizzo può essere relativo (a partire dalla directory corrente del file
lmc.pl) o anche assoluto.

input è la lista (in ordine cronologico) di valori presenti nella coda di input

Output vedrà ad essa associata la coda di output dello stato finale del LMC.
