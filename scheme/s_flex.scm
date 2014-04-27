#! /usr/local/bin/guile -s
!#

(load "utils.scm")

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
(define  EQUAL  1053)
(define VALUE  1054)
(define QUOTED_STRING  10541)
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

(use-modules (oop goops))
(define-class <node> ()
  (type #:init-value 0 #:getter get-type #:setter set-type! #:init-keyword #:type)
  (value #:init-value 0 #:getter get-value #:setter set-value! #:init-keyword #:value)
  (lineno #:init-value 0 #:getter get-lineno #:setter set-lineno! #:init-keyword #:lineno)
  c1 c2 c3 c4 c5 c6)

;get file name
(define (get_file_name)
(if (eqv? 2 (length (command-line)))
    (set! file_name (cadr(command-line)))
)
)

;test file if exists
(define (test_file file)
(if (file-exists? file_name)
(begin (display file_name)
;do something here
(newline))
(display "ERR:F\n");todo exit here?
)
)

;(defstruct node 

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
(if (not(char=? #\" (list-ref str n)))
    (begin
    (set! n (+ n 1))
;    (newline)
;    (display "I am showing n\n")
;    (display n)
;    (newline)

    )

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
     
     );begin
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

       (if (char=? char i)
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
             (lineno 1)
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
                                  (set! var (cdr tmp))
                                  (set! tokens (append tokens (make-list 1 
                                                                         (make <node> #:value var
                                                                               #:lineno lineno
                                                                               #:type QUOTED_STRING))))
                                  (display var)
                                  ))
       ((char=? mchar #\#) (begin 
                             (display "# ")
                             ;remove valid comment
                               (while (not(char=? #\newline (list-ref str_list 0)))
                                      (set! str_list (list-tail str_list 1 ))

                                      );while
                                  ;(set! str_list (cdr str_list))
                                  ;(set! tokens (append tokens (list mchar)))
                                  ))
       ((char=? mchar #\{) (begin 
                             (display "{")
                                  (set! str_list (cdr str_list))

                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value #\{
                                                                             #:lineno lineno
                                                                             #:type LEFT))))
                                  ))
       ((char=? mchar #\}) (begin 
                             (display "}" )
                                  (set! str_list (cdr str_list))
                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value #\}
                                                                             #:lineno lineno
                                                                             #:type RIGHT))))
;                                  (set! tokens (append tokens (list mchar)))
                                  ))
       ((char=? mchar #\;) (begin 
                             (display ";")
                                  (set! str_list (cdr str_list))

                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value #\;
                                                                             #:lineno lineno
                                                                             #:type SEMI))))
;                                  (set! tokens (append tokens (list mchar)))
                                  ))
       ((char=? mchar #\space) (begin 
                                 (display " ")
                                  (set! str_list (cdr str_list))
                                  ;(set! tokens (append tokens (list mchar)))
                                  ))
       ((char=? mchar #\newline) (begin 
                                   (display "\n ")
                                  (set! str_list (cdr str_list))

                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value "newline"
                                                                             #:type NEW_LINE
                                                                             #:lineno lineno))))
                                  (set! lineno (+ 1 lineno))

                                        ))
       ((char=? mchar #\=) (begin 
                                   (display "=")
                                  (set! str_list (cdr str_list))
                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value #\=
                                                                             #:type EQUAL
                                                                             #:lineno lineno))))

                                        ))

       ((char<=? mchar #\delete) (begin 
                                  (set! tmp (n_string str_list))
                                  (set! var (cdr tmp))
                                  (set! str_list (car tmp))
                                  (set! tokens (append tokens (make-list 1 (make <node> 
                                                                             #:value var
                                                                             #:type STRING
                                                                             #:lineno lineno))))
                                  (display var)
 
                                        ))
        )
);let
);while
(for t in  tokens
     (display (get-value t))
     (display ":")
     (display (get-lineno t))
     (newline)
)
);let*
);function

(get_file_name)
(test_file file_name)
;(display (get_contents file_name))
(tokenize (get_contents file_name))

