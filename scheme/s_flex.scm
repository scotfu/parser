#! /usr/local/bin/guile -s
!#
(load "utils.scm")
(define file_name "test.cfg")
(define contents `())
;rest file_name
(define (get_file_name)
(if (eqv? 2 (length (command-line)))
    (set! file_name (cadr(command-line)))
)
)

(define (test_file file)
(if (file-exists? file_name)
(begin (display file_name)
;do something here
(newline))
(display "ERR:F\n");todo exit here?
)
)


(define (tokenize file)
(let ((p (open-input-file file)))
  (let f ((x (read-char p))) 
    (if (eof-object? x)
        (begin
          (close-input-port p)
          '())
        (begin
        (cond 
         ((char=? x #\" ) ;expression
          
                         );action
         
         ((char=? x #\}) (display "Found }\n"))
         ((char=? x #\{) (display "Found {\n"))
         ((char=? x #\=) (display "Found =\n"))
         ((char=? x #\#) (display "Found #\n"))
         ((char=? x #\space ) (display "Found space\n"))
         ((char=? x #\; ) (display "Found ;\n"))
         ((char=? x #\newline ) (display "Found newline \n"))
         (else (display x))
         )
        (f (read-char p))
        )
        )
    )

  )

)

(get_file_name)
(test_file file_name)
;(display (tokenize file_name))
