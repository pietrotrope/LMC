;;;; Tropeano Pietro 829757
;;;; lmc.lisp


;;;Lettura del file

; get-file legge una file ponendo ogni riga come elemento di una lista

(defun get-file (path)
  (with-open-file (in path
                      :direction :input
                      :if-does-not-exist :error)
    (read-list-from in)))

; read-list-from è una funzione di supporto per get-file e serve a leggere la
; singola riga

(defun read-list-from (input-stream)
  (let ((e 
         (read-line 
          input-stream
          nil
          'eof)))
    (unless (eq e 'eof)
      (cons e (read-list-from 
               input-stream)))))


;;; Rimozione dei commenti

; decomment decommenta una stringa (rimuovendo tutto ciò che è presente dopo i
; caratteri "//")

(defun decomment (line)
  (format nil "~{~A ~}"
          (read-from-string 
           (concatenate'string "("
                       (subseq
                        line
                        0 
                        (search "//" line))
                       ")"))))


;;; Gestione delle etichette

; label-tester restituisce 1 se to-test è una stringa corrispondente ad un
; identificatore di istruzione, 0 altrimenti

(defun label-tester (to-test)
  (cond ((string= to-test "ADD") 1)
        ((string= to-test "SUB") 1)
        ((string= to-test "STA") 1)
        ((string= to-test "LDA") 1)
        ((string= to-test "BRA") 1)
        ((string= to-test "BRZ") 1)
        ((string= to-test "BRP") 1)
        ((string= to-test "INP") 1)
        ((string= to-test "OUT") 1)
        ((string= to-test "HLT") 1)
        ((string= to-test "DAT") 1)
        (t 0)))


; get-label recupera (qualora sia presente) una label e le assegna il numero
; di cella corrispondente in memoria

(defun get-label (line n)
  (let ((label 
         (subseq
          line
          0
          (position #\Space line))))
    (cond ((and (eq 0 (label-tester label ))
                (< (position #\Space line)
                   (- (length line) 1)))
           (list label n)))))


; label-present verifica che una determinata etichetta trovata tra le
; istruzioni appartenga effetivamente all'insieme delle etichette che
; si possono risolvere (ovvero le etichette che hanno a loro associato
; il numero di cella corrispondente)

(defun label-present (label labels-list)
  (cond ((null (car labels-list)) NIL)
        (t (if (string= 
                (car (car labels-list))
                label)
               (car (cdr (car labels-list)))
             (label-present
              label
              (cdr labels-list))))))


; replace-labels applica replace-label sull'intera lista di istruzioni
; ins-list

(defun replace-labels (ins-list lab-list replaced)
  (let ((updated
         (nconc
          replaced
          (list
           (replace-label
            (car ins-list)
            lab-list)))))
    (cond ((not (eq NIL (cdr ins-list)))
           (replace-labels 
            (cdr ins-list)
            lab-list
            updated))
          (t updated))))


; replace-label sostituisce una label con il relativo codice associato

(defun replace-label (line labels-list)
  (cond ((< (position #\Space line)
            (- (length line) 1))
         (let ((number  
                (label-present 
                 (subseq 
                  line
                  (+ 1 (position #\Space line))
                  (- (length line) 1))
                 labels-list)))
           (cond ((eq NIL number)
                  (string-right-trim " (*)" line))
                 (t (if (string= "DAT" (subseq
                                        line 
                                        0
                                        (position #\Space line)))
                        NIL
                      (concatenate 
                       'string 
                       (subseq
                        line 
                        0
                        (+ 1 (position #\Space line)))
                       (write-to-string  number)))))))
        (t (string-right-trim " (*)" line) )))

        
; contains-duplicates verifica che una label non compaia più volte in righe 
; diverse restituisce 1 se non vi sono duplicati, 0 altrimenti

(defun contains-duplicates (list)
 (let ((names (mapcar #'(lambda (x) (car x)) list)))
   (cond ((eq 
           (remove-duplicates names :test #'equal)
           names) 1)
         (t 0))))


; remove-labbel data una riga ne rimuove l'identificativo di una label se 
; questo è presente

(defun remove-label (line list)
  (let ((label (subseq
                line
                0
                (position #\Space line))))
    (if (eq 
         NIL
         (label-present label list))
        line
      (subseq 
       line 
       (+ 1 (position #\Space line))))))


; remove-labels applica remove-label su un'intera lista di istruzioni ins-list

(defun remove-labels (ins-list lab-list removed)
  (let ((updated (nconc 
                  removed
                  (list (remove-label 
                         (car ins-list) 
                         lab-list)))))
    (cond ((eq (cdr ins-list) NIL)
           updated)
          (t (remove-labels 
              (cdr ins-list)
              lab-list
              updated)))))


; get-labels ricava le labels da una lista di istruzioni 
; in codice assembly semplificato

(defun get-labels (lista n labels-list)
  (let ((updated-list (remove 
                       NIL 
                       (nconc
                        labels-list 
                        (list (get-label (car lista) n))))))
    (cond ((null (cdr lista))
           (if (eq 
                (contains-duplicates updated-list)
                1) 
               updated-list
             -1))
          (t (get-labels 
              (cdr lista)
              (+ 1 n)
              updated-list  )))))


;;; Decodifica da identificativo isttruzione a codice associato

; decode-line riceve in input una stringa e traduce ogni identificativo di
; istruzione nel codice ad esso associato

(defun decode-line (line)
  (cond ((= (length line) 3)
         (cond ((string= line "INP") "901")
               ((string= line "OUT") "902")
               ((string= line "HLT") "0")
               ((string= line "DAT") "0")))
        (t (let ((ins (subseq
                       line
                       0
                       (position #\Space line))))
             (cond ((string= ins "ADD") 
                    (concatenate 'string "1"
                                 (subseq 
                                  line 
                                  (+ 1 (position #\Space line)) 
                                  (length line))))
                   ((string= ins "SUB") 
                    (concatenate 'string "2"
                                 (subseq
                                  line
                                  (+ 1 (position #\Space line))
                                  (length line))))
                   ((string= ins "STA") 
                    (concatenate 'string "3"
                                 (subseq
                                  line 
                                  (+ 1 (position #\Space line)) 
                                  (length line))))
                   ((string= ins "LDA") 
                    (concatenate 'string "5"
                                 (subseq
                                  line
                                  (+ 1 (position #\Space line))
                                  (length line))))
                   ((string= ins "BRA") 
                    (concatenate 'string "6"
                                 (subseq
                                  line
                                  (+ 1 (position #\Space line))
                                  (length line))))
                   ((string= ins "BRZ") 
                    (concatenate 'string "7"
                                 (subseq 
                                  line 
                                  (+ 1 (position #\Space line))
                                  (length line))))
                   ((string= ins "BRP") 
                    (concatenate 'string "8"
                                 (subseq
                                  line 
                                  (+ 1 (position #\Space line))
                                  (length line))))
                   ((string= ins "DAT") 
                    (subseq
                     line 
                     (+ 1 (position #\Space line))
                     (length line))))))))


;;; Gestione numero delle celle in memoria

; expand-list aggiunge celle inizializzate a 0 in memoria 
; (fino ad arrivare a 100 celle)
; se vi sono 100 celle non fa niente
; se vi sono più di 100 celle restituisce un errore

(defun expand-list (list)
  (cond ((> 100 (length list))
         (concatenate 'list
                      list
                      (make-list (- 100 (length list)) :initial-element "0")))
        ((= 100 (length list)) list)
        ((< 100 (length list) -1))))


;;; gestione di memoria e input

; check-list esegue un controllo per verificare che la lista list sia conforme
; alle specifiche
; (ogni elemento valutato come numero è compreso tra 0 e 999 estremi inclusi)

(defun check-list (list)
  (let ((head (car list)))
    (cond
     ((null head) 1)
     ((and (< head 1000) (> head -1))
      (check-list (cdr list)))
     (t 0))))


; lmc-load dato un file sorgente di assembly semplificato ne ricava il
; contenuto iniziale della memoria del sistema

(defun lmc-load (path)
  (let ((pre-label-work (remove ""
                                (mapcar 'decomment (get-file path))
                                :test #'equal)))
    (let ((label-list (get-labels
                       pre-label-work 
                       0
                       ()
                       )))
      (cond ((numberp label-list)
             -1)
            (t (
                expand-list (mapcar 
                             'decode-line 
                             (replace-labels 
                              (remove-labels 
                               pre-label-work
                               label-list
                               ())
                              label-list ()))))))))


; lmc-run letto un file assembler e inizializzato con lmc-load produce come
; output la coda di output dello stato finale del LMC

(defun lmc-run (file inp)
  (let ((mem (lmc-load file)))
    (cond ((or (= 0 (check-list inp))
               (numberp mem)
               (not (eq NIL (position NIL mem)))
               (not (eq NIL (position "err" mem)))
               (numberp (handler-case (mapcar 'parse-integer mem)
                          (error (c)
                            -1)))
               (= 0 (check-list (mapcar 'parse-integer mem))) )
           NIL)
          (t 
           (execution-loop (make-state
                            :acc 0
                            :pc 0
                            :mem mem 
                            :in inp 
                            :out NIL
                            :flag 0))))))


;;; gestione degli stati 

; make-halted-state produce uno halted state inizializzato con:
; accumulatore = acc
; Program Counter = pc
; memoria = mem
; coda di input = in
; coda di output = out
; flag = flag

(defun make-halted-state (&key acc pc mem in out flag)
(list "HALTED-STATE" 
      ':acc acc 
      ':pc pc
      ':mem mem
      ':in in
      ':out out
      ':flag flag))


; make-state produce uno stato inizializzato con:
; accumulatore = acc
; Program Counter = pc
; memoria = mem
; coda di input = in
; coda di output = out
; flag = flag

(defun make-state (&key acc pc mem in out flag)
(list "STATE" 
      ':acc acc 
      ':pc pc
      ':mem mem
      ':in in
      ':out out
      ':flag flag))


;;; funzioni di supporto per semplificare gestione e lettura degli stati

; get-type-of-state restituisce STATE o HALTED-STATE sulla base del tipo di
; stato passato in input

(defun get-type-of-state (state) (nth 0 state))


; get-acc restituisce l'accumulatore di uno stato

(defun get-acc (state) (nth 2 state))


; get-pc restituisce il program counter di uno stato

(defun get-pc (state) (nth 4 state))


; get-mem restituisce la memoria di uno stato

(defun get-mem (state) (nth 6 state))


; get-in restituisce la coda di input di uno stato

(defun get-in (state) (nth 8 state))


; get-out restituisce la coda di output di uno stato

(defun get-out (state) (nth 10 state))


; get-flag restituisce il flag di uno stato

(defun get-flag (state) (nth 12 state))


; execution-loop riceve in ingresso lo stato iniziale e restituisce la coda di
; output dello stato finale dopo aver eseguito le istruzioni
; e aver raggiunto un halted-state

(defun execution-loop (state)
  (cond ((string= "STATE" (get-type-of-state state))
         (execution-loop (one-instruction state)))
        (t (get-out state))))
  
      
; one instruction riceve in ingresso uno stato e restituisce l'unico stato che
; segue dopo aver eseguito l'istruzione puntata dal program counter

(defun one-instruction (state)
  (let ((id (nth (get-pc state) 
                 (get-mem state))))
    (let ((ins (subseq id 0 1)))
      (cond ((string= "0" ins) ;;Halt
             (make-halted-state :acc (get-acc state)
                                :pc (+ 1 (get-pc state))
                                :mem (get-mem state)
                                :in (get-in state)
                                :out (get-out state)
                                :flag (get-flag state)))
            ((string= "1" ins) ;;Addizione
             (let ((ris (add (get-acc state) 
                             (parse-integer (nth (parse-integer 
                                                  (subseq id 1 (length id)))
                                                 (get-mem state))))))
               (make-state :acc (cdr ris)
                           :pc (+ 1 (get-pc state))
                           :mem (get-mem state)
                           :in (get-in state)
                           :out (get-out state)
                           :flag (car ris))))
            ((string= "2" ins) ;;Sottrazione
             (let ((ris (add (get-acc state) 
                             (* -1 (parse-integer (nth
                                                   (parse-integer 
                                                    (subseq id 1 (length id)))
                                                   (get-mem state)))))))
               (make-state :acc (cdr ris)
                           :pc (+ 1 (get-pc state))
                           :mem (get-mem state)
                           :in (get-in state)
                           :out (get-out state)
                           :flag (car ris))))
            ((string= "3" ins) ;;store-value
             (setf (nth 
                    (parse-integer (subseq id 1 (length id)))
                    (get-mem state)) 
                   (write-to-string (get-acc state)))
             (make-state :acc  (get-acc state)
                         :pc (+ 1 (get-pc state))
                         :mem (get-mem state)
                         :in (get-in state)
                         :out (get-out state)
                         :flag (get-flag state)))
            ((string= "5" ins) ;;Load
             (make-state :acc (parse-integer (nth (parse-integer 
                                                   (subseq id 1 (length id)))
                                                  (get-mem state)))
                         :pc (+ 1 (get-pc state))
                         :mem (get-mem state)
                         :in (get-in state)
                         :out (get-out state)
                         :flag (get-flag state)))
            ((string= "6" ins) ;Branch
             (make-state :acc (get-acc state)
                         :pc (parse-integer (subseq id 1 (length id)))
                         :mem (get-mem state)
                         :in (get-in state)
                         :out (get-out state)
                         :flag (get-flag state)))
            ((string= "7" ins) ;;Branch if zerop
             (cond ((and (= 0 (get-acc state)) (= 0 (get-flag state)))
                    (make-state :acc (get-acc state)
                                :pc (parse-integer (subseq id 1 (length id)))
                                :mem (get-mem state)
                                :in (get-in state)
                                :out (get-out state)
                                :flag (get-flag state)))
                   (t (make-state :acc (get-acc state)
                                  :pc (+ 1 (get-pc state))
                                  :mem (get-mem state)
                                  :in (get-in state)
                                  :out (get-out state)
                                  :flag (get-flag state)))))
            ((string= "8" ins) ;;Branch if positive
             (cond ((= 0 (get-flag state))
                    (make-state :acc (get-acc state)
                                :pc (parse-integer (subseq id 1 (length id)))
                                :mem (get-mem state)
                                :in (get-in state)
                                :out (get-out state)
                                :flag (get-flag state)))
                   (t (make-state :acc (get-acc state)
                                  :pc (+ 1 (get-pc state))
                                  :mem (get-mem state)
                                  :in (get-in state)
                                  :out (get-out state)
                                  :flag (get-flag state)))))
            ((string= "9" ins) ;;Input e Output
             (cond ((string= "01" (subseq id 1 (length id))) ;;Input
                    (cond ((eq (car (get-in state)) NIL) 
                           (make-halted-state :acc 0
                                              :pc (+ 1 (get-pc state))
                                              :in NIL
                                              :out NIL
                                              :flag (get-flag state)))
                          (t (make-state :acc (car (get-in state))
                                         :pc (+ 1 (get-pc state))
                                         :mem (get-mem state)
                                         :in (cdr (get-in state))
                                         :out (get-out state)
                                         :flag (get-flag state)))))
                   ((string= "02" (subseq id 1 (length id))) ;;Output
                    (make-state :acc (get-acc state)
                                :pc (+ 1 (get-pc state))
                                :mem (get-mem state)
                                :in  (get-in state)
                                :out (concatenate 'list
                                                  (get-out state)
                                                  (list  (get-acc state)))
                                :flag (get-flag state)))))))))


; add effettua una somma in modulo 1000 restituendo una cons dove:
; car = 0 se il risultato della somma è compreso tra 0 e 1000, 1 altrimenti
; cdr = risultato della somma in modulo 1000

(defun add (acc val) 
  (let ((ris (+ acc val)))
    (cond ((and (> 1000 ris)
                (< -1 ris)) (cons 0 ris))
          (t (cons 1 (mod ris 1000))))))


;;;; End of file -- lmc.lisp