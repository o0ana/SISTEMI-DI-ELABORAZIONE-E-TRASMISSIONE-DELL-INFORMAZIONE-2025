# Reti — Riassunto breve dei 3 Laboratori

## I 3 lab, in ordine

| # | Lab | Argomento |
|---|---|---|
| 1 | **Ping Pong** (4 parti) | Socket TCP/UDP → misurare le prestazioni di una rete |
| 2 | **incApache** (2 parti) | Costruire un mini web server HTTP |
| 3 | **MicroBash** | Costruire una mini shell → gestione processi (fork, pipe) |


---

## 1. Ping Pong

**Idea:** un client "Ping" manda messaggi a un server "Pong", che li rispedisce indietro. Si misura il tempo di andata-ritorno (RTT).

- **Parte 1 (TCP):** connessione affidabile e ordinata. Client si connette, manda `"TCP <dim> <n_rip>\n"`, server risponde `"OK\n"`, poi si scambiano i messaggi numerati (`"1\n"`, `"2\n"`...).
- **Parte 2 (UDP):** stessa cosa ma via UDP (non affidabile → i pacchetti possono perdersi). Serve un **timeout** e un socket **non bloccante** per gestire le perdite.
- **Parte 3 (server multi-client + bash):** il server usa `fork()` per gestire più client insieme (un processo figlio per client). Script bash automatizzano test ripetuti e raccolgono i dati.
- **Parte 4 (modello Banda-Latenza):** formula per stimare le prestazioni della rete:
  $$D(N) = L_0 + N/B$$
  dove $D$ = delay, $N$ = dimensione messaggio, $L_0$ = latenza, $B$ = banda. Si calcolano $L_0$ e $B$ misurando due messaggi (uno piccolo, uno grande).


---

## 2. incApache

**Idea:** costruire un web server che capisce solo HEAD e GET (come Apache ma semplificato).

- **Parte 1:**
  - `GET` chiede un file → risposte possibili: `200 OK`, `404 Not Found`, `304 Not Modified` (se il client ha già la versione aggiornata).
  - `HEAD` = come GET ma senza restituire il contenuto, solo l'header (per debug).
  - **Cookie** per contare le richieste di ogni client.
  - **`chroot()`**: isola il server in una cartella, per sicurezza (non può leggere file fuori dalla document root).
  - Gestisce più client insieme con i **thread** (`pthread`).
- **Parte 2 (pipelining HTTP/1.1):** il client può mandare più richieste senza aspettare le risposte una alla volta; il server deve rispondere **nello stesso ordine** in cui sono arrivate le richieste (un thread per richiesta, ma sincronizzati con `pthread_join()` in ordine).

---

## 3. MicroBash (µbash)

**Idea:** costruire una piccola shell che legge comandi e li esegue.

- Legge righe da input, mostra un prompt con la directory corrente.
- Sintassi semplificata: niente spazi tra `>`/`<` e il nome file (`ls >foo`, non `ls > foo`).
- Un solo comando built-in: **`cd`** (deve essere da solo sulla riga, un solo argomento).
- I comandi possono essere collegati con **pipe** (`|`) e avere redirezioni di input (`<file`) e output (`>file`).
- Le variabili d'ambiente si espandono con `$nome`.
- Uso di: `fork()` (crea processo), `exec()` (esegue il programma), `pipe()` (collega comandi), `wait()` (aspetta i figli), `dup2()` (redirezioni).
- Obbligatorio: controllare sempre errori delle system call, e testare la memoria con **address sanitizer** o **valgrind**.
- Va consegnato un documento con i test fatti (scopo, situazione iniziale, comando, risultato atteso).

---

