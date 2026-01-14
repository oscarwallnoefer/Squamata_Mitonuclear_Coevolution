# Squamata_Mitonuclear_Coevolution

cose da fare:

a. modificare metodi: io ho usato -l 100. Quindi ho tenuto per le analisi di ERC solo i geni che, trimmati, misuravano più di 100 aminoacidi.

b. riorganizzare tutto in github. É troppo pericoloso continuare in questo modo, non ci si capisce nulla. Ridurre il numero di file, tenere solo lo stretto necessario. 

c. rifare interproscan sia per ERC che per AU. L'errore è in run_longest.sh. Invece di prendere la sequenza più lunga (tail), prende la più corta (head). Tenere come background solo i geni presenti nel network più grande.

d. aggiungi check intermedi nelle pipeline. Ci sono troppi passaggi. 

e. rifare i GO terms con il background nuovo. Rifare i plot dei GO term.

f. modificare i plot sulle lunghezze nei materiali supplementari. 

A questo punto hai l'occasione di sincerarti che l'input dei go term contenga solo geni > 100aa. NB: Devi prenderli da Gb_alns! Non da HOG_seqs (perché qui ci sono le sequenze ancora grezze)

Rifari albero nucleare tenendo solo le 31 specie condivise. 








