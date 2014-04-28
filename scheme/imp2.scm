#! /usr/local/bin/guile -s
!#

(use-modules (oop goops))
(use-modules (oop goops describe))
(use-modules (ice-9 regex))
;token type constants
(define N_CONF  101 )
(define N_GLOBAL  102)
(define GLOBAL_KEYWORD 1021)                                                                       
(define N_HOSTS 103)
(define N_HOST 1031)
(define HOST_KEYWORD  1032)
(define HOST_NAME  1033)
(define LEFT  104)
(define KV_PAIRS  105)
(define KV_PAIR 1051)
(define KEY  1052)
(define EQUAL  1053)
(define VALUE  1054)
(define QUOTED_STRING 10541)
(define STRING  10542)
(define INT  10543)
(define FLOAT  10544)
(define RIGHT  106)
(define SEMI  107)
(define COMMENT  108)
(define NEW_LINE  109)
(define ERROR  110)


(define file_name "test.cfg")
(define contents "")
(define tokens `())
(define global_keys (make-list 0))
(define global_node_list (make-list 0))
(define global_lineno 1)
(define-class <node> ()
  (type #:init-value 0 #:getter get-type #:setter set-type! #:init-keyword #:type)
  (value #:init-value 0 #:getter get-value #:setter set-value! #:init-keyword #:value)
  (lineno #:init-value 0 #:getter get-lineno #:setter set-lineno! #:init-keyword #:lineno)
  (c1 #:init-value 0 #:getter get-c1 #:setter set-c1! #:init-keyword #:c1)
  (c2 #:init-value 0 #:getter get-c2 #:setter set-c2! #:init-keyword #:c2)
  (c3 #:init-value 0 #:getter get-c3 #:setter set-c3! #:init-keyword #:c3)
  (c4 #:init-value 0 #:getter get-c4 #:setter set-c4! #:init-keyword #:c4)
  (c5 #:init-value 0 #:getter get-c5 #:setter set-c5! #:init-keyword #:c5)
  (c6 #:init-value 0 #:getter get-c6 #:setter set-c6! #:init-keyword #:c6)


)

;get file name
(define (get_file_name)
(if (eqv? 2 (length (command-line)))
    (set! file_name (cadr(command-line)))
)
)
;
;test file if exists
(define (test_file file)
(if (file-exists? file_name)
(begin 
(values))
;do something here
(begin
(display "ERR:F\n");todo exit here?
(exit)
)
)
)

(define format_quoted_string
(lambda (str)
(let ((out (make-list 0))
      (n (string-length str))
      (i 0)
      )

  (set! str (string->list str))
  (while (< i  n )
         (if (equal? #\\ (list-ref str i))
             (begin
               (set! i (+ i 1))
                        (cond ((equal? #\n (list-ref str i))
                            (set! out (append out (make-list 1 #\newline)))
                            )
                              ((equal? #\r (list-ref str i))
                            (set! out (append out (make-list 1 #\return)))
                            )
                              (else 
                            (set! out (append out  (make-list 1 (list-ref str i))))
                               )
                              
                              )
             )
             (set! out (append out (make-list 1 (list-ref str i))))
             )
         (set! i (+ i 1))
         
         )

  (set! out (list->string out))
(set! out (string-append "\"\"" out "\"\""))
out
)

))

;read the file then return a string
(define get_contents 
(lambda (file_name)
(letrec  ((port (open-input-file file_name))
       )
(while (> 1 0);#t
(let ((new_char (read-char port))

      )
(if (eof-object? new_char) 
    (break)
    (begin
;      (display (string new_char))
      (set! contents (string-append contents (string new_char)))
      )
    )
  
)
);while
(begin
;(display contents)
;(display (string? contents))
(close-input-port port)
)

);letrec
contents
);lambda

);define

(define quoted_string 
(lambda (str)
(let ((n 1)
      (var "")
      (output `())
      ) 
(while (> 1 0)
(cond
 ((char=? #\newline (list-ref str (- n 1)))
  (begin
    (display "ERR:L:")
    (display global_lineno)
    (newline)
    (exit)
    ))

 ((char>? (list-ref str (- n 1)) #\delete)
  (begin
    (display "ERR:L:")
    (display global_lineno)
    (newline)
    (exit)
    ))
 
 ((not(char=? #\" (list-ref str n)))
    (begin
    (set! n (+ n 1))

    ))
 (else
  (begin
    (if (char=? #\\ (list-ref str (- n 1)))
         (set! n (+ n 1))
         (begin 
           (set! n (+ n 1))
           (set! var (list->string (list-head str n)))
           (set! str (list-tail str n))
           (break)
                )
         );if
     
     ));begin
    );if
)
(set! output (list str var))
output
);while

)
);

(define-syntax for
  (syntax-rules (in as)
    ((for element in list body ...)
     (map (lambda (element)
            body ...)
          list))
    ((for list as element body ...)
     (for element in list body ...))))

(define char_in
(lambda (char char_list)
(let ((output #f)
      )
  (for i in char_list

       (if (equal? char i)
           (set! output #t)
           )
       );for
output
);lambda

);let

);function

(define n_string
(lambda (str)
(let ((var "")
      (terminal `(#\space #\{ #\} #\; #\= #\newline #\#))
      )
(if (char<=? (list-ref str 0) #\delete)
    (begin
    (set! var (string (list-ref str 0)))
    (set! str (list-tail str 1))
    (while (> (length str) 0)
             (if  (not(char_in (list-ref str 0) terminal))
           (begin
             (set! var (string-append var (string (list-ref str 0))))
             (set! str (list-tail str 1))
             )
           (begin;else
             (break)
             )
)
);if

)
);lambda
(list str var)
);n_string

)
)
;(define commment ;remove comment and leave the newline
;(lambda (str)

;);lambda
;);function


(define (tokenize str)
(let (
       (str_list (string->list str))
       (tokens (make-list 0))
;       (lineno 1)
)
(if (char_in #\null str_list)
(begin
    (display "ERR:L:");bug here no lineno
    (display global_lineno)
    (newline)
    (exit))
)

(while (> (length str_list) 0)
       (letrec (
             (var "")

             (tmp `())
             (mchar (car str_list))

             )

       (cond
       ((char=? mchar #\") (begin ;(display #\")
                                  (set! tmp (quoted_string str_list))
                                  (set! str_list (car tmp))
                                  (set! var (car (cdr tmp)))
                                  (set! tokens (append tokens (make-list 1 
                                                                         (make <node> #:value var
                                                                               #:lineno global_lineno
                                                                               #:type QUOTED_STRING))))
                                  ;(display var)
                                  )
;        (display "ERR:L\n")
        )
       ((char=? mchar #\#) (begin 
                             ;(display "# ")
                             ;remove valid comment
                               (while (not(char=? #\newline (list-ref str_list 0)))
                                      (set! str_list (list-tail str_list 1 ))

                                      );while
                                  ;(set! str_list (cdr str_list))
                                  ;(set! tokens (append tokens (list mchar)))
                                  ))
       ((char=? mchar #\{) (begin 
                             ;(display "{")
                                  (set! str_list (cdr str_list))

                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value #\{
                                                                             #:lineno global_lineno
                                                                             #:type LEFT))))
                                  ))
       ((char=? mchar #\}) (begin 
                             ;(display "}" )
                                  (set! str_list (cdr str_list))
                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value #\}
                                                                             #:lineno global_lineno
                                                                             #:type RIGHT))))
;                                  (set! tokens (append tokens (list mchar)))
                                  ))
       ((char=? mchar #\;) (begin 
                             ;(display ";")
                                  (set! str_list (cdr str_list))

                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value #\;
                                                                             #:lineno global_lineno
                                                                             #:type SEMI))))
;                                  (set! tokens (append tokens (list mchar)))
                                  ))
       ((char=? mchar #\space) (begin 
                                 ;(display " ")
                                  (set! str_list (cdr str_list))
                                  ;(set! tokens (append tokens (list mchar)))
                                  ))
       ((char=? mchar #\newline) (begin 
                                   ;(display "\n ")
                                  (set! str_list (cdr str_list))

                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value "newline"
                                                                             #:type NEW_LINE
                                                                             #:lineno global_lineno))))
                                  (set! global_lineno (+ 1 global_lineno))

                                        ))
       ((char=? mchar #\=) (begin 
                                   ;(display "=")
                                  (set! str_list (cdr str_list))
                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value #\=
                                                                             #:type EQUAL
                                                                             #:lineno global_lineno))))

                                        ))

       ((char<=? mchar #\delete) (begin 
                                  (set! tmp (n_string str_list))
                                  (set! var (car (cdr tmp)))
                                  (set! str_list (car tmp))
                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value var
                                                                             #:type STRING
                                                                             #:lineno global_lineno))))
                                  ;(display var)
;                                  (display (list? var))
                                        ))
       (else
        (begin
          (display "ERR:P:")
          (display (get-lineno (car tokens)))
          (newline)
          (exit)
          )
        )
        )
);let
);while
tokens
);let*
);function

;parser parts start here

(define clean_newline 
(lambda (tokens)
(while (and (not(null? tokens))  (eqv? (get-type (car tokens)) NEW_LINE))
       (set! tokens (cdr tokens))
)

tokens
)
)

(define key_value_pair
(lambda (tokens currnode flag)
(set! tokens (clean_newline tokens))
(cond (
       (and (not (null? tokens))
            (eqv? STRING (get-type (car tokens)))
            (regexp-match? (string-match "^[a-zA-Z_][a-zA-Z_0-9]*$" (get-value (car tokens)))))

       (begin 
         (slot-set! currnode `c1 (make <node> #:type KEY #:value  (get-value (car tokens))))
         (set! tokens (cdr tokens))
         (letrec (
                  (node_type 0)
                  (prefix "")
                  )
           (if flag
               (set! global_keys (append global_keys (make-list 1 (get-value (get-c1 currnode)))))
               );add to global keys
    (if (and (not (null? tokens))
             (eqv? EQUAL (get-type (car tokens))))
        (begin
          (slot-set! currnode `c2 (car tokens))
          (set! tokens (cdr tokens))
        (cond 
         ((and (not (null? tokens))
               (eqv? STRING (get-type (car tokens))))
          (begin
            (cond
             
             (
              (regexp-match? (string-match "^[+-]?[0-9]+$" (get-value (car tokens))))
              (begin 
                (set! node_type INT)
                (set! prefix "I::")
                )
              );int
             ((and (not (null? tokens))
                   (eqv? STRING (get-type (car tokens)))
                   (regexp-match? (string-match "^[+-]?[0-9]+\\.[0-9]*$" (get-value (car tokens))))
                   )
              (begin 
                
                (set! node_type FLOAT)
                (set! prefix "F::")
                ));float
             
             ((and (not (null? tokens))
                   (eqv? STRING (get-type (car tokens)))
                   (regexp-match? (string-match "^[/a-zA-Z][/\\._a-zA-Z0-9\\-]*$" (get-value (car tokens))))
                   )
              (begin 
                
                (set! node_type STRING)
                (set! prefix "S::")
                )
              );string

             (else
              (begin
                (display "ERR:P:")
                (display (get-lineno (car tokens)))
                (newline)
                (exit)
                )
              )
             )
            (set-c3! currnode (make <node> #:type node_type #:value (get-value (car tokens))))
            (set! tokens (cdr tokens))
            ))
         
         ((and (not (null? tokens)) (eqv? QUOTED_STRING (get-type (car tokens))))

          (set-c3! currnode (make <node> #:type QUOTED_STRING #:value (format_quoted_string (get-value (car tokens)))))
          (set! tokens (cdr tokens))
          (set! prefix "Q::")
          )
         (else
          (begin
            (display "ERR:P:")
            (display (get-lineno (car tokens)))
            (newline)
            (exit)
            )
          )
         )
        (if (and (char_in (get-value (get-c1 currnode)) global_keys)
                 (not flag))
            (begin
            (set! prefix (string-append (string-take prefix 2) "O" (string-take-right prefix 1)))
            ))
        (set-value! (get-c1 currnode) (string-append "    " prefix (get-value (get-c1 currnode))))
)
    (begin
        (display "ERR:P:")
        (display (get-lineno (car tokens)))
        (newline)
        (exit)
        )


);END OF IF
    (if (not (null? tokens))
        (cond
         ((eqv? NEW_LINE (get-type (car tokens)))
          (set! tokens (cdr tokens))
          )
         ((eqv? RIGHT (get-type (car tokens)))
          (values)
          )
         (else    (begin
                    (display "ERR:P:")
                    (display (get-lineno (car tokens)))
                    (newline)
                    (exit)
                    ))

         ))
    )))
      ((eqv? RIGHT (get-type (car tokens)))(values))
      (else
    (begin
        (display "ERR:P:")
        (display (get-lineno (car tokens)))
        (newline)
        (exit)
        )
)

      )
tokens
)
)




(define key_value_pairs 
(lambda (tokens currnode flag)
(set! tokens (clean_newline tokens))

(if (null? tokens)
    (values)
    )
(if (eqv? RIGHT (get-type (car tokens) ));diff
    (begin
     (values))
    (begin
      (set-c1! currnode (make <node> #:type KV_PAIR))
      (set! tokens (key_value_pair tokens (get-c1 currnode) flag))
      ;reset tokens
      (set-c2! currnode (make <node> #:type KV_PAIRS))
      (set! tokens (key_value_pairs tokens (get-c2 currnode) flag))

      )
)
tokens
)
)

(define host_conf
(lambda (tokens currnode)

(set! tokens (clean_newline tokens))
(if (and (not(null? tokens)) (equal? "host" 
                                             (get-value (car tokens))))
    (begin
      (set! tokens (cdr tokens))
      (slot-set! currnode `c1 (make <node> #:value "HOST" #:type HOST_KEYWORD))

      )
    (begin
        (display "ERR:P:")
        (display (get-lineno (car tokens)))
        (newline)
        (exit)
        )

    ;todo exception handler

)

(set! tokens (clean_newline tokens))
(if (and (not(null? tokens)) 
         (regexp-match? (string-match "^[a-zA-Z_0-9\\._\\-]*$" (get-value (car tokens)))))
    (begin
      (slot-set! currnode `c2 (make <node> #:value (get-value (car tokens)) #:type HOST_NAME))
      (set! tokens (cdr tokens))

      )
    (begin
        (display "ERR:P:")
        (display (get-lineno (car tokens)))
        (newline)
        (exit)
        )

    ;todo exception handler

)

(set! tokens (clean_newline tokens))
(if (and (not(null? tokens)) (eqv? LEFT  (get-type (car tokens)))  )
    (begin
      (slot-set! currnode `c3 (car tokens))
      (set! tokens (cdr tokens))
      )
    (begin
        (display "ERR:P:")
        (display (get-lineno (car tokens)))
        (newline)
        (exit)
        )

    ;todo exception handler
)

(set! tokens (clean_newline tokens))
(slot-set! currnode `c4 (make <node> #:type KV_PAIRS));todo c3
(set! tokens (key_value_pairs tokens (get-c4 currnode) #f));return tokens needed 

(set! tokens (clean_newline tokens))
(if (and (not(null? tokens)) (equal? RIGHT  (get-type (car tokens)))  )
    (begin
      (slot-set! currnode `c5 (car tokens));todo c3
      (set! tokens (cdr tokens))
      )
    (begin
        (display "ERR:P:")
        (display (get-lineno (car tokens)))
        (newline)
        (exit)
        )

    ;todo exception handler
)

(set! tokens (clean_newline tokens))
(if (and (not(null? tokens)) (eqv? SEMI (get-type (car tokens))))
    (begin
      (slot-set! currnode `c6 (car tokens))
      (set! tokens (cdr tokens))

      )
    ;optional, no exception here
)
tokens
)
)


(define host_confs
(lambda (tokens currnode)
(set! tokens (clean_newline tokens))
(if (null? tokens)
    (values)
    (begin
(set-c1! currnode (make <node> #:type N_HOST))
(set! tokens (host_conf tokens (get-c1 currnode)))

(set-c2! currnode (make <node> #:type N_HOSTS))

(set! tokens (host_confs tokens (get-c2 currnode)))
)

)
tokens
)
)




(define conf
(lambda (tokens currnode)
(begin
(slot-set! currnode `c1 (make <node> #:type N_GLOBAL ))
(set! tokens (global_conf tokens (get-c1 currnode)))

(slot-set! currnode `c2 (make <node> #:type N_HOSTS ))
(host_confs tokens (get-c2 currnode))

)
)
)

(define global_conf
(lambda (tokens currnode)

(set! tokens (clean_newline tokens))
(if (and (not(null? tokens)) (equal? "global" (get-value (car tokens)))) 
    (begin
      (set! tokens (cdr tokens))
      (slot-set! currnode `c1 (make <node> #:value "GLOBAL" #:type GLOBAL_KEYWORD))

      )
    (begin
        (display "ERR:P:")
        (display (get-lineno (car tokens)))
        (newline)
        (exit)
        )
    ;todo exception handler

)

(set! tokens (clean_newline tokens))
(if (and (not(null? tokens)) (eqv? LEFT  (get-type (car tokens)))  )
    (begin
      (slot-set! currnode `c2 (car tokens))
      (set! tokens (cdr tokens))
      )
    (begin
        (display "ERR:P:")
        (display (get-lineno (car tokens)))
        (newline)
        (exit)
        )

    ;todo exception handler
)

(set! tokens (clean_newline tokens))
(slot-set! currnode `c3 (make <node> #:type KV_PAIRS));todo c3
(set! tokens (key_value_pairs tokens (get-c3 currnode) #t));return tokens needed 

(set! tokens (clean_newline tokens))
(if (and (not(null? tokens)) (equal? RIGHT  (get-type (car tokens)))  )
    (begin
      (slot-set! currnode `c4 (car tokens));todo c3
      (set! tokens (cdr tokens))
      )
    (begin
        (display "ERR:P:")
        (display (get-lineno (car tokens)))
        (newline)
        (exit)
        )

    ;todo exception handler
)

(set! tokens (clean_newline tokens))
(if (and (not(null? tokens)) (eqv? SEMI (get-type (car tokens))))
    (begin
      (slot-set! currnode `c5 (car tokens))
      (set! tokens (cdr tokens))

      )

    ;optional, no exception here
)
tokens
)

)


(define delete
  (lambda (item list)
    (cond
     ((equal? item (car list)) (cdr list))
     (else (cons (car list) (delete item (cdr list)))))))

(define get_nodes
(lambda (node)
(let ((last_one 10000)
      (last_node 0)
      )
  
  (if (char_in  (get-type node) 
                (list GLOBAL_KEYWORD HOST_KEYWORD HOST_NAME KEY STRING INT FLOAT EQUAL QUOTED_STRING RIGHT SEMI LEFT))
      (set! global_node_list (append global_node_list (make-list 1 node)))
      )

  (if (equal? ERROR (get-type node))
      (begin
      (set! last_one (length global_node_list))
      (set! last_one (- last_one 1))
      (set! last_node (list-ref global_node_list last_one))
      (while (and 
             (not (null? global_node_list))
             (not (equal? RIGHT (get-type ))))
             (set! global_node_list (reverse (cdr (reverse global_node_list))))
             )
      )
  )
  (if  (not (eqv? 0 (get-c1 node)))
       (get_nodes (get-c1 node)))

  (if (not (eqv? 0 (get-c2 node)))
            (get_nodes (get-c2 node) ))
                 
  (if (not (eqv? 0 (get-c3 node)))
             (get_nodes (get-c3 node)))

  (if (not (eqv? 0 (get-c4 node)))
             (get_nodes (get-c4 node)))
                 
  (if (not (eqv? 0 (get-c5 node)))
             (get_nodes (get-c5 node)))

  (if (not (eqv? 0 (get-c6 node)))
             (get_nodes (get-c6 node)))

)
)
)


(define parser 
(lambda (tokens)
  (let  (
        (root  (make <node> #:type N_CONF))
        (output "")
          )

    (conf tokens root)
    (get_nodes root)
    
    (for node in global_node_list
         (if (equal? GLOBAL_KEYWORD (get-type node))
             (set! output (string-append output "GLOBAL:\n"))
             )
         (if (equal? HOST_KEYWORD (get-type node))
             (set! output (string-append output "HOST "))
             )
         (if (equal? HOST_NAME (get-type node))
             (set! output (string-append output (get-value node) ":\n"))
             )
         (if (equal? KEY (get-type node))
             (set! output (string-append output (get-value node)))
             )
         (if (equal? STRING (get-type node))
             (set! output (string-append output (get-value node) "\n"))
             )
         (if (equal? INT (get-type node))
             (set! output (string-append output (get-value node) "\n"))
             )
         (if (equal? FLOAT (get-type node))
             (set! output (string-append output  (get-value node) "\n"))
             )
         (if (equal? EQUAL (get-type node))
             (set! output (string-append output ":"))
             )
         (if (equal? QUOTED_STRING (get-type node))
             (set! output (string-append output  (get-value node) "\n"))
             )

                  )

    (display output)

)
)
)


(get_file_name)
(test_file file_name)
;(display (get_contents file_name))
(parser (tokenize (get_contents file_name)))

