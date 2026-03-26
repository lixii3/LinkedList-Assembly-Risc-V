# Progetto A.D.E. - Linked List e Gestione Input 🔗

**Autore**: Lia Mongili - Matricola 7157071  
**Linguaggio**: Assembly RISC-V  
**Corso**: Architettura degli Elaboratori

![RISC-V](https://img.shields.io/badge/RISC--V-Assembly-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)

## Descrizione

Implementazione completa di una **linked list** in Assembly RISC-V con parsing di comandi da stringa di input. Il progetto dimostra la gestione dinamica della memoria, manipolazione di puntatori e implementazione di algoritmi classici a basso livello.

## Funzionalità Implementate

### Comandi Base
- **ADD(x)** - Aggiunge un carattere alla coda della lista
- **DEL(x)** - Elimina tutte le occorrenze di un carattere dalla lista
- **PRINT** - Stampa tutti gli elementi della lista (implementazione ricorsiva)
- **SORT** - Ordina la lista in ordine crescente (Bubble Sort ricorsivo)
- **REV** - Inverte l'ordine degli elementi (usando stack push/pop)

### Caratteristiche Avanzate
- **Parsing robusto**: Gestisce spazi, tilde (~) come separatori e comandi maiuscoli/minuscoli
- **Validazione formato**: Verifica la sintassi corretta di ogni comando
- **Gestione memoria**: Allocazione dinamica dei nodi nella memoria
- **Ordinamento intelligente**: Sort per categoria (maiuscole > minuscole > numeri > caratteri speciali)
- **Gestione casi limite**: Lista vuota, un solo elemento, eliminazioni multiple

## Struttura della Linked List

Ogni nodo occupa **5 byte**:
```
[0]: Data (1 byte) - il carattere memorizzato
[1-4]: Puntatore (4 byte) - indirizzo del nodo successivo
```

### Registri Utilizzati
- **s1**: Puntatore alla stringa di input corrente
- **s2**: Puntatore alla TESTA della lista
- **s3**: Puntatore alla CODA della lista  
- **s4**: Numero di nodi nella lista
- **s5**: Prossimo indirizzo libero per allocazione (inizia a 0x20000000)

## Come Eseguire

### Requisiti
- **RARS** (RISC-V Assembler and Runtime Simulator) o
- **VENUS** (Web-based RISC-V simulator) o
- Qualsiasi simulatore RISC-V compatibile

### Esecuzione con RARS

1. **Scarica e installa RARS**:
   ```bash
   # Scarica da: https://github.com/TheThirdOne/rars/releases
   java -jar rars.jar
   ```

2. **Apri il file**:
   - File → Open → Seleziona il file `.asm`

3. **Modifica la stringa di test**:
   - Nella sezione `.data`, scegli una delle stringhe `listInput` commentate o crea la tua
   - Decommenta la stringa desiderata

4. **Assembla ed esegui**:
   - Premi il pulsante "Assemble" (🔧)
   - Premi il pulsante "Run" (▶️)
   - Osserva l'output nella console

### Esecuzione con VENUS (Online)

1. Vai su https://venus.cs61c.org/
2. Incolla il codice nell'editor
3. Modifica la stringa `listInput` desiderata
4. Clicca "Simulate" → "Run"

## Sintassi dei Comandi

### Formato Generale
```
COMANDO1 ~ COMANDO2 ~ COMANDO3 ...
```
I comandi sono separati da tilde (`~`) e possono avere spazi prima/dopo.

### Esempi di Comandi Validi

```assembly
# Aggiungere elementi
ADD(A) ~ ADD(B) ~ ADD(C) ~ PRINT

# Eliminare elementi
ADD(X) ~ ADD(Y) ~ ADD(X) ~ DEL(X) ~ PRINT

# Ordinamento
ADD(z) ~ ADD(A) ~ ADD(5) ~ ADD(!) ~ SORT ~ PRINT

# Inversione
ADD(A) ~ ADD(B) ~ ADD(C) ~ REV ~ PRINT

# Comandi multipli
ADD(1) ~ ADD(a) ~ ADD(B) ~ SORT ~ REV ~ PRINT ~ DEL(B) ~ PRINT
```

### Comandi Non Case-Sensitive (parzialmente)
I comandi principali possono essere scritti in maiuscolo, ma il parser cerca la versione MAIUSCOLA:
- ✅ `ADD(x)` 
- ✅ `PRINT`
- ✅ `SORT`

### Parametri Validi
I caratteri accettati per ADD e DEL devono avere codice ASCII tra **32** (spazio) e **125** (})

## Dettaglio Implementazioni

### 1. ADD(x) - Inserimento in Coda
```
Complessità: O(1)
- Trova il prossimo blocco di memoria libero (5 byte consecutivi)
- Scrive il carattere nel primo byte
- Azzera il puntatore (4 byte)
- Aggiorna i puntatori testa/coda
```

### 2. DEL(x) - Eliminazione Multipla
```
Complessità: O(n)
- Gestisce eliminazione dalla testa (può eliminare più nodi consecutivi)
- Scorre la lista e rimuove tutte le occorrenze
- Aggiorna i puntatori mantenendo l'integrità della lista
- Gestisce correttamente l'eliminazione dell'ultimo nodo
```

### 3. PRINT - Stampa Ricorsiva
```
Complessità: O(n)
Algoritmo:
1. Caso base: nodo == NULL → return
2. Stampa carattere del nodo corrente
3. Stampa spazio
4. Chiamata ricorsiva sul nodo successivo
```

### 4. SORT - Bubble Sort Ricorsivo
```
Complessità: O(n²)
Sistema di ordinamento a 4 livelli:
1. MAIUSCOLE (A-Z) - Categoria 3
2. minuscole (a-z) - Categoria 2  
3. Numeri (0-9) - Categoria 1
4. Caratteri speciali - Categoria 0

All'interno della stessa categoria, ordine per valore ASCII crescente
```

**Esempio di ordinamento**:
```
Input:  z, A, 5, !, b, 1
Output: A b 1 5 ! z  
        ↑ ↑ ↑ ↑ ↑ ↑
        │ │ │ │ │ └─ minuscole dopo maiuscole
        │ │ │ │ └─── carattere speciale
        │ │ └─────── numeri ordinati
        │ └───────── minuscole ordinate
        └─────────── maiuscole prime
```

### 5. REV - Inversione con Stack
```
Complessità: O(n)
Fase 1 (Push): Scorre la lista e pusha tutti i caratteri nello stack
Fase 2 (Pop): Scorre di nuovo la lista e poppa i caratteri, sovrascrivendo i dati
Nota: Non modifica i puntatori, solo i dati dei nodi
```

## Test Cases Inclusi

Il codice include numerosi test commentati nella sezione `.data`:

```assembly
# Test base
"ADD(1) ~ ADD(c) ~ ADD(a) ~ ADD(B) ~ ADD(;) ~ ADD(9) ~ PRINT"

# Test eliminazione
"ADD(1) ~ ADD(c) ~ ADD(a) ~ ADD(B) ~ PRINT ~ DEL(a) ~ DEL(B) ~ PRINT"

# Test lista vuota
"PRINT"

# Test eliminazione testa/coda
"ADD(A) ~ ADD(B) ~ ADD(C) ~ DEL(A) ~ PRINT"
"ADD(A) ~ ADD(B) ~ ADD(C) ~ DEL(C) ~ PRINT"

# Test sort
"ADD(z) ~ ADD(A) ~ ADD(5) ~ ADD(!) ~ SORT ~ PRINT"

# Test reverse
"ADD(A) ~ ADD(B) ~ ADD(C) ~ REV ~ PRINT"

# Test combinati
"ADD(C) ~ ADD(A) ~ ADD(B) ~ SORT ~ REV ~ PRINT"
```

## Esempi di Output

### Esempio 1: Inserimento e stampa
```
Input:  ADD(A) ~ ADD(B) ~ ADD(C) ~ PRINT
Output: A B C
```

### Esempio 2: Sort crescente
```
Input:  ADD(:) ~ ADD(f) ~ ADD(a) ~ ADD(1) ~ ADD(A) ~ ADD(b) ~ SORT ~ PRINT
Output: A a b f 1 :
```

### Esempio 3: Sort + Reverse = Decrescente
```
Input:  ADD(C) ~ ADD(A) ~ ADD(B) ~ SORT ~ REV ~ PRINT
Output: C B A
```

### Esempio 4: Eliminazione multipla
```
Input:  ADD(X) ~ ADD(X) ~ ADD(X) ~ DEL(X) ~ PRINT
Output: (lista vuota - solo newline)
```

## Architettura del Codice

### Sezioni Principali

1. **PARSING** (`parse_listinput`)
   - Loop principale di parsing
   - Riconoscimento comandi
   - Skip di spazi e tilde

2. **VALIDAZIONE** (`check_add`, `check_del`, ecc.)
   - Verifica formato corretto di ogni comando
   - Controllo parametri validi
   - Gestione terminazione comandi

3. **IMPLEMENTAZIONE FUNZIONI**
   - `ADD`: Allocazione e inserimento
   - `DEL`: Ricerca e rimozione
   - `PRINT`: Stampa ricorsiva
   - `SORT`: Ordinamento bubble sort
   - `REV`: Inversione con stack

4. **UTILITY**
   - `get_category`: Classificazione caratteri per sort
   - `find_next_free_addr`: Gestione allocazione memoria
   - `check_valid_end`: Validazione fine comando

## Algoritmi e Tecniche Utilizzate

### Pattern di Programmazione
- **Ricorsione**: PRINT e SORT utilizzano chiamate ricorsive
- **Stack Management**: REV usa push/pop per l'inversione
- **State Machine**: Parser come macchina a stati per riconoscimento comandi
- **Pointer Arithmetic**: Navigazione e manipolazione della linked list

### Gestione Memoria
- Allocazione sequenziale a partire da 0x20000000
- Ricerca di 5 byte consecutivi liberi (tutti zero)
- Nessuna deallocazione implementata (memoria non riutilizzata)

### Ottimizzazioni
- Eliminazione dalla testa ottimizzata (gestisce più nodi consecutivi)
- Bubble sort con early termination (flag swap)
- Validazione preventiva per evitare operazioni inutili

## 🔧 Personalizzazione

### Modificare la Stringa di Input
Nella sezione `.data`, modifica la variabile `listInput`:
```assembly
listInput: .string "TUA_STRINGA_QUI"
```

### Aggiungere Nuovi Comandi
1. Aggiungi una label in `search_command`
2. Crea una funzione `check_tuocomando` per validazione
3. Implementa la logica in una nuova sezione

### Modificare l'Indirizzo di Memoria Iniziale
Cambia il valore in `s5`:
```assembly
li s5, 0x20000000  # Cambia questo indirizzo
```

## Gestione Errori

Il programma gestisce silenziosamente gli errori:
- **Comando non valido**: Salta alla prossima tilde
- **Formato errato**: Ignora il comando e continua
- **Lista vuota**: PRINT stampa solo newline, altre operazioni sono no-op
- **Parametro non valido**: Comando ignorato

## Concetti Didattici Dimostrati

Questo progetto copre numerosi concetti di architettura:
- Gestione della memoria dinamica
- Manipolazione di puntatori
- Strutture dati (linked list)
- Algoritmi di ordinamento a basso livello
- Ricorsione in assembly
- Gestione dello stack
- Parsing di stringhe
- State machines

## Note per Studenti

Questo progetto serve per imparare:
- Come funzionano le linked list a livello di memoria
- Gestione manuale dei puntatori
- Differenza tra passaggio per valore e per riferimento
- Stack frames e ricorsione
- Complessità algoritmica in pratica

## Licenza e Utilizzo

Progetto realizzato per il corso di Architettura degli Elaboratori.  
Utilizzabile a scopo didattico con citazione dell'autore.
