####################################################################################################################################
#                   PROGETTO A.D.E. : LINKED LIST E GESTIONE INPUT - Lia Mongili - 7157071                                         #
####################################################################################################################################

.data
##################################################################
#                              TEST                              #
##################################################################
    #listInput: .string "ADD(1) ~ add(c) ~ ADD(a) ~ ADD(B) ~ ADD(;) ~    ADD(9) ~PRI~PRINT " #test add
    #listInput: .string "ADD(1) ~ add(c) ~ ADD(a) ~ ADD(B) ~ PRINT ~DEL(a) ~ DEl (B)~~PRINT" #test eliminazione centrale
    #listInput: .string "PRINT" #test lista vuota
    #listInput: .string "ADD(A)~ADD(B)~ADD(C)~DEL(A)~PRINT" #eliminazione alla testa
    #listInput: .string "ADD(A)~ADD(B)~ADD(C)~DEL(C)~PRINT" #eliminazione alla coda
    #listInput: .string "ADD(X)~ADD(X)~ADD(X)~DEL(X)~PRINT" #svuota la lista
    #listInput: .string "ADD(z)~ADD(A)~ADD(5)~ADD(!)~ sort~PRINT~SORT~PRINT" #sort con caratteri misti
    #listInput: .string "ADD(9)~ADD(1)~ADD(5)~ADD(3)~SORT~PRINT" #sort con caratteri della stessa categoria
    #listInput: .string "ADD(A)~ADD(B)~ADD(C)~REV~PRINT" # inversione di base
    #listInput: .string "ADD(X)~REV~PRINT" #inversione con un solo elemento
    #listInput: .string "REV~PRINT" # inversione con lista vuota
    #listInput: .string "ADD(A)~ADD(B)~ADD(C)~REV~REV~PRINT" #doppia inversione
    #listInput: .string "ADD(C)~ADD(A)~ADD(B)~SORT~REV~PRINT" #sort + rev = ordine decrescente
    
    #ESEMPI NELLA RELAZIONE
     #listInput: .string "ADD(1) ~ ADD(a) ~ add(B) ~ ADD(B) ~ ADD ~ ADD(9) ~PRINT~SORT(a)~PRINT~DEL(bb) ~DEL(B) ~PRINT~REV~PRINT" 
    #listInput: .string "ADD(1) ~ ADD(a) ~ ADD(a) ~ ADD(B) ~ ADD(;) ~~PRI~REV~PRINT"
    listInput: .string "ADD(:) ~ ADD(f) ~ ADD (a) ~ADD(1) ~ADD(A) ~ADD(b) ~ ~ del(:) ~PRINT~SORT~REV~PRINT  ~ DEL(f)~Print~ PRINT~ REV PRINT"
    
.text
##################################################################
#                                main                            #
##################################################################
la s1,listInput #  stringa
li s2,0 # testa
li s3,0 # coda
li s4,0 # numero nodi
li s5,0x20000000 # prossimo indirizzo per l'inserimento dei nodi
jal parse_listinput

#fine programma
li a7,10
ecall


##################################################################
#                            PARSING                             #
##################################################################

parse_listinput:
    addi sp,sp,-4
    sw ra,0(sp)

    parsing_loop:
    
        lb t0,0(s1) #carico il carattere corrente
        beqz t0,end_parse

        li t1,32 #spazio
        beq t0,t1,skip_char

        li t1,126 #tilde
        beq t0,t1,skip_char

        jal search_command

    skip_char:
        addi s1,s1,1
        j parsing_loop

    end_parse:
        lw ra,0(sp)
        addi sp,sp,4
        ret

    search_command:   
        addi sp,sp,-4
        sw ra,0(sp)

        lb t0,0(s1) # carica carattere corrente

        li t1,65    #A
        beq t0,t1,add_command

        li t1, 68   #D
        beq t0, t1, del_command

        li t1, 82   #R
        beq t0, t1, rev_command

        li t1, 80   #P
        beq t0, t1, print_command
        
        li t1, 83   #S
        beq t0, t1, sort_command
        
        j invalid_command

    next_command:
        #trova tilde / stringa#
        lb t0,0(s1)
        beqz t0,end_parse

        li t1,126 
        beq t0,t1, skip_char
        addi s1,s1,1
        j next_command
    
    invalid_command:
        j next_command #se il comando non ? avanti, trova la prossima tilde


####################################################################
#        controlli della corretta formattazione dei comandi        #
####################################################################

    add_command:

        jal check_add # ritorna 1 se il comando e' valido, 0 altrimenti
        beqz a1,invalid_command
        jal ADD
        j next_command

    del_command:
        jal check_del
        beqz a1, invalid_command    
        
        jal DEL

        j next_command

    print_command:
        jal check_print
        beqz a1, invalid_command    
        
        jal PRINT

        j next_command

    sort_command:
        jal check_sort
        beqz a1, invalid_command    
        
        jal SORT

        j next_command

    rev_command:
        jal check_rev
        beqz a1, invalid_command    
        
        jal REV

        j next_command

    #VERIFICA del formato -> funzione che ritorna in a1 1 se formato valido e 0 se non valido
    check_add:
        addi sp,sp,-4
        sw ra,0(sp)

        addi s1,s1,1
        lb t0,0(s1)
        li t1,68 #D
        bne t0,t1, invalid_format

        addi s1,s1,1
        lb t0,0(s1)
        li t1,68 #D
        bne t0,t1,invalid_format

        addi s1,s1,1
        lb t0,0(s1)
        li t1,40 # "("
        bne t0,t1, invalid_format

        #controllo se il parametro rientra nel range
        addi s1,s1,1
        lb a0,0(s1) 
        li t1,32
        blt a0,t1,invalid_format
        li t1,125
        bgt a0,t1,invalid_format

        addi s1,s1,1
        lb t0,0(s1)
        li t1,41 # ")"
        bne t0,t1, invalid_format

        #Controllo se termina correttamente il comando
        addi s1,s1,1
        jal check_valid_end
        beqz a1,invalid_format

        li a1,1 # ai = 1 vuol dire successo
        
        lw ra,0(sp)
        addi sp,sp,4
        ret
    
    check_del:
        addi sp,sp,-4
        sw ra,0(sp)

        addi s1,s1,1
        lb t0,0(s1)
        li t1,69 # E 
        bne t0,t1, invalid_format

        addi s1,s1,1
        lb t0,0(s1)
        li t1,76 # L
        bne t0,t1,invalid_format

        addi s1,s1,1
        lb t0,0(s1)
        li t1,40 # "("
        bne t0,t1, invalid_format

        #controllo la validit? del parametro
        addi s1,s1,1
        lb a0,0(s1)
        li t1,32
        blt a0,t1,invalid_format
        li t1,125
        bgt a0,t1,invalid_format

        addi s1,s1,1
        lb t0,0(s1)
        li t1,41 # ")"
        bne t0,t1, invalid_format

        #Controllo se termina correttamente il comando
        addi s1,s1,1
        jal check_valid_end
        beqz a1,invalid_format #se a1=0 -> fromato invalido, va ricercata un altro comando

        li a1,1 #a1 = 1 successo
        
        lw ra,0(sp)
        addi sp,sp,4
        ret

    check_rev:
        addi sp,sp,-4
        sw ra,0(sp)

        addi s1,s1,1
        lb t0,0(s1)
        li t1,69 # E
        bne t0,t1, invalid_format

        addi s1,s1,1
        lb t0,0(s1)
        li t1,86 # V
        bne t0,t1,invalid_format


        #Controllo se termina correttamente il comando
        addi s1,s1,1
        jal check_valid_end
        beqz a1,invalid_format

        li a1,1 # successo
        
        lw ra,0(sp)
        addi sp,sp,4
        ret

    
    
    check_sort:
        addi sp,sp,-4
        sw ra,0(sp)

        addi s1,s1,1
        lb t0,0(s1)
        li t1,79 # O
        bne t0,t1, invalid_format

        addi s1,s1,1
        lb t0,0(s1)
        li t1,82 # R
        bne t0,t1,invalid_format

        addi s1,s1,1
        lb t0,0(s1)
        li t1,84 # T
        bne t0,t1,invalid_format


        #Controllo se termina correttamente il comando
        addi s1,s1,1
        jal check_valid_end
        beqz a1,invalid_format

        li a1,1 # successo
        
        lw ra,0(sp)
        addi sp,sp,4
        ret

    check_print:
        addi sp,sp,-4
        sw ra,0(sp)

        addi s1,s1,1
        lb t0,0(s1)
        li t1,82 # R
        bne t0,t1, invalid_format

        addi s1,s1,1
        lb t0,0(s1)
        li t1,73 # I
        bne t0,t1, invalid_format
        
        addi s1,s1,1
        lb t0,0(s1)
        li t1,78 # N
        bne t0,t1, invalid_format

        addi s1,s1,1
        lb t0,0(s1)
        li t1,84 # T
        bne t0,t1, invalid_format


        #Controllo se termina correttamente il comando
        addi s1,s1,1
        jal check_valid_end
        beqz a1,invalid_format

        li a1,1 # successo
        
        lw ra,0(sp)
        addi sp,sp,4
        ret

    invalid_format:
        li a1,0
        lw ra,0(sp)
        addi sp,sp,4
        ret

    check_valid_end:
        #ritorno in a1 = 1 se il comando termina correttamente
        addi sp, sp, -4
        sw ra, 0(sp)
        
        skip_spaces:
            lb t0, 0(s1)
            li t1, 32
            bne t0, t1, check_end_command
            addi s1, s1, 1
            j skip_spaces
        
        check_end_command:
            # Controllo se fine stringa
            beqz t0, valid_terminator
            
            # Controllo se tilde
            li t1, 126      
            beq t0, t1, valid_terminator
            
            li a1, 0 # a1 = 0 vuol dire che il comando non termina in maniera valida
            j end_check
        
        valid_terminator:
            li a1, 1
        
        end_check:
            lw ra, 0(sp)
            addi sp, sp, 4
            ret

########################################################################################################################################
#                                         --- IMPLEMENTAZIONE DELLE FUNZIONI ---                                                       #
########################################################################################################################################

####################################################################
#                          ADD                                     #
####################################################################
ADD: # parametro in a0 (DATA)

    addi sp,sp,-4       
    sw ra,0(sp)                # Salva il return address nella stack

   jal find_next_free_addr    # Ritorna in a1 il prossimo indirizzo di scrittura 
    
   sb a0,0(a1)                # Scrivi il 'data' nel primo byte del nodo free
   addi a1,a1,1               # in questo modo vado a prendere il byte successivo
   sw zero,0(a1)              # pongo a 0 il puntatore del nuov nodo
   
   addi a1,a1,-1              # ripristino indirizzo nuovo nodo

    beq zero,s4,firstADD       # Se e il primo nodo, salta
    sw a1,1(s3)                # Aggiorna puntatore del nodo che lo precede
    mv s3,a1                   # Aggiorna coda
    addi s4,s4,1               # num nodi ++
    j end_ADD

    firstADD:
        mv s2,a1                   # aggiorna testa
        mv s3,a1                   # aggiorna coda
        addi s4,s4,1               # num nodi ++

    end_ADD:
        lw ra,0(sp)
        addi sp,sp,4
        jr ra


####################################################################
#                           DELETE                                 #
####################################################################
DEL:
    # a0 = carattere da eliminare
    addi sp,sp,-4
    sb ra, 0(sp) # salvo ra
    
    beqz s2, end_DEL # controllo se lista vuota

    check_head_deletion: 
        lb t0,0(s2) # carico il data
        bne t0,a0, del_find_next # controllo se va eliminato

        addi t1,s2,1 # calcolo il puntatore del successivo
        lw t1, 0(t1)  # carica il puntatore al seguente
        mv s2,t1 # il seguente nodo alla testa diventa la nuova testa
        addi s4,s4,-1 # num nodi --

        beqz s2, empty_list # se la lista si svuota aggiorno coda
        j check_head_deletion # controlla se anche la nuova testa deve essere eliminata

    empty_list:

        li s3,0 # coda = null
        j end_DEL

    del_find_next:
        mv t2,s2 # prosegui a partire dalla testa

    del_find_loop:
        addi t3,t2,1 # calcolo l'indirizzo del seguente
        lw t3,0(t3) # carica il puntatore al nodo successivo
        beqz t3,end_DEL # se non ce successivo termino

        lb t4,0(t3) # carica il carattere del nodo successivo
        bne t4,a0,del_go_next # se il carattere non coincide, vai avanti

        addi t5,t3,1  
        lw t5, 0(t5) # carica l'indirizzo del nodo successivo

        addi t6,t2,1 #allinea al puntatore del nodo precedente
        sw t5, 0(t6) # adesso il nodo precedente punta al successivo del corrente (Es: testa -> nodo1 -> nodo2 ora ? testa -> nodo2)

        beq t3,s3,update_last_ptr #se il nodo ? l'ultimo aggiornacla coda

        addi s4,s4,-1 # num nodi --
        j del_find_loop


    update_last_ptr:
        mv s3,t2 # aggiorna la coda
        addi s4,s4,-1 # num nodi--
        j del_find_loop


    del_go_next:
        mv t2,t3 # vado avanti
        j del_find_loop


    end_DEL:
        lw ra,0(sp)
        addi sp,sp,4
        ret

####################################################################
#                           PRINT                                  #
#                      -- ricorsivo --                             #
####################################################################
PRINT:
    beqz s2,end_print
    
    addi sp,sp,-4 #salvo ra
    sw ra, 0(sp)

    mv a0,s2 #passo come parametro la testa
    jal print_recursive

    lw ra,0(sp) 
    addi sp,sp,4 #ripristino il ra
    
    end_print:
        li a0,10
        li a7,11
        ecall
        ret
    
    print_recursive:
        beqz a0, return_print # caso base testa = null
        
        addi sp,sp,-8 # salvo a0 e ra nello stack
        sw ra,0(sp)
        sw a0,4(sp)

        lb a0,0(a0) # carico e stampo il carattere del nodo corrente a0
        li a7,11
        ecall

        li a0,32 # spazio
        li a7,11 
        ecall 

        lw a0,4(sp) # ricarico il puntatore al nodo
        addi a0,a0,1 # prendo il puntatore al successivo
        lw a0,0(a0) # e carico il data del nodo successivo
        
        jal print_recursive
        
        lw ra,0(sp)
        addi sp,sp,8 # ripristino la stack

    return_print:
        ret

####################################################################
#                           REVERSE                                #
#           -- Uso dello stack -> Push and pop --                  #
#               -- Non scambio i puntatori --                      #
####################################################################     
REV:

    addi sp,sp,-4
    sw ra, 0(sp)

    #Se c'e' un nodo solo
    li t0,1
    ble s4,t0,end_rev

    mv t1,s2 # parto dalla testa
    li t2,0 # contatore elementi pushati

    rev_push_phase:
        beqz t1, end_rev_push_phase # se il prossimo nodo e' nullo, termina push
        lb t3, 0(t1) # dato del nodo corrente
        addi sp,sp,-4 # evito problemi di allineamento
        sb t3,0(sp) # push del dato del nodo corrente nello stack

        addi t2,t2,1 # aumento contatore pushati
        addi t4,t1,1 # allineo al puntatore

        lw t1,0(t4) # carico l'indirizzo al successivo
        j rev_push_phase
    
    end_rev_push_phase:
        mv t1,s2 # ricomincio dalla testa per i pop
    
    rev_pop_phase:
        beqz t2, end_rev #se il contatore ? a 0, ho finito
        
        lb t3, 0(sp) # pop
        sb t3,0(t1) #scrivo il data popped nel nodo corrente
        addi sp,sp,4
        addi t2,t2,-1

        addi t4,t1,1 #allineo al puntatore 
        lw t1,0(t4) # carico il  nodo successivo e continuo
        j rev_pop_phase

    end_rev:
        lw ra, 0(sp)        
        addi sp, sp, 4
        ret

####################################################################
#                           SORT                                   #
#                -- BUBBLE SORT ricorsivo --                       #
#               -- Non scambio i puntatori --                      #
#                  -- Ordine Crescente --                          #
####################################################################
SORT:
    addi sp,sp,-4
    sw ra,0(sp)
    
    li t0,1 # numero nodi 
    beq s4,zero, end_sort # se non ci sono nodi
    mv t0,s4 # t0, indice che decrementeremo

    outer_sort:
        beqz t0,end_sort

        mv t1,s2  # parto dalla testa 
        li t2,0 # e metto il flag di scambio a zerro

        inner_sort:
            addi t3,t1,1 # allineo al puntatore
            lw t4, 0(t3) # ptr al successivo
            beqz t4,check_if_swapped # se sei alla fine, controlla se sono avvenuti scambi

            lb t5, 0(t1) # dato corrente
            lb t6, 0(t4) # dato successivo

            addi sp,sp,-8 # salvo i registri temporanei prima della chiamata
            sw t1,0(sp) #nodo corrente
            sb t6,4(sp) #dato successivo
            sb t5,5(sp) #dato corrente
            sb t0,6(sp) #contatore
            
            #t5 - > categoria primo char
            mv a0,t5
            jal get_category
            mv t5,a0 

            #t6 -> categoria secondo char
            mv a0,t6
            jal get_category
            mv t6,a0    

            #ricarico i contenuti originali
            lb t0,6(sp)
            lw t1,0(sp)

            #ORDINAMENTO CRESCENTE:
            # se category(precedente)>category(successivo) -> swap
            bgt t5,t6, swap
            blt t5,t6, no_swap_case

            #se appartengono alla stessa categoria confronto gli ASCII che avevo salvato nello stack
            lb t5,5(sp) 
            lb t6,4(sp)
            bgt t5,t6,swap
            j no_swap_case

        swap:
            #scambio 'data' invece che i puntatori
            #prendo i caratteri che ho salvato nello stack
            lb t5, 5(sp) 
            lb t6, 4(sp)
            
            #swap
            sb t5,0(t4)
            sb t6,0(t1) 
            li t2,1 #swapAvvenuto = true

            addi sp,sp,8 #ripristina lo stack
            mv t1,t4 # passo al successivo
            j inner_sort

        no_swap_case:
            addi sp,sp,8 # non scambio, ripristino la stack per iterazioni successive
            mv t1,t4 # passo al successivo
            j inner_sort # continuo

        check_if_swapped:
            beqz t2, end_sort # se non ho effettuato scambi, allora termino
            addi t0,t0,-1 # decremento il contatore degli scambi da effettuare
            j outer_sort

    end_sort:

        lw ra,0(sp)
        addi sp,sp,4 # ripristino stack
        ret

####################################################################
#          categoria per confronto in sort:                        #
#               3 = MAIUSCOLO     # 2 -> minuscolo                 #
#               1 = numero                                         #
#               0 = carattere speciale                             #
#              -1 = carattere non valido                           #
####################################################################

get_category:
    # parametro in a0, mi restituisce in a0 un intero per la categoria    
    addi sp,sp,-4
    sw ra, 0(sp) # salvo il valore di ra

    #controllo se il carattere sta nel range
    li t0,32
    blt a0,t0,char_not_valid 
    li t0,125
    bgt a0,t0,char_not_valid

    #maiuscola
    li t0,65 # 'A'
    li t1,90 # 'Z'
    blt a0,t0, check_lowercase # potrebbe essere una lettera minuscola
    ble a0,t1, is_uppercase # categoria = maiuscola

    check_lowercase:
        li t0,97 # 'a'
        li t1,122 # 'z'
        blt a0,t0,check_number # potrebbe essere un numero
        ble a0,t1, is_lowercase # categoria = minuscola

    check_number:
        li t0,48 # '0'
        li t1,57 # '9'
        blt a0,t0,is_special # puo essere un carattere speciale
        ble a0,t1, is_number  # categoria = numero
        j is_special


    is_uppercase:
        li a0, 3  # categoria = 3
        j category_found

    is_lowercase:
        li a0, 2  # categoria = 2
        j category_found

    is_number:
        li a0, 1  # categoria = 1
        j category_found

    is_special:
        li a0, 0  # categoria = 0
        j category_found

    char_not_valid:
        li a0,-1  # se char non valido

    category_found:
        lw ra,0(sp)
        addi sp,sp,4
        ret

####################################################################
#           CALCOLA IL PROSSIMO I NDIRIZZO LIBERO                  #   
####################################################################  
find_next_free_addr: #ritorno in a1
    li t0,5 #devo trovare 5 byte

    check_bytes:
        lb t1,0(s5) #leggo il byte corrente
        bnez t1,reset_count # se non trovo zero vuol dire che non c'e spazio
        
        addi t0,t0,-1
        beqz t0,found_address

        addi s5,s5,1 # vado nel byte successivo
        j check_bytes #ricontrollo
        
        reset_count:
            addi s5,s5,1 #analizzo a partire dal bit successivo
            li t0,5
            j find_next_free_addr #finche non trovi 5 byte free
        
        found_address:
            addi s5,s5,-4 # siccome sono andato avanti di 4 byte, vado indietro e ritorno
            mv a1,s5
            addi s5,s5,5 #5 byte sono occupati, quindi faccio un grande balzo in avanti
            ret


