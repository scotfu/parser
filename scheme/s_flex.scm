#! /usr/local/bin/guile -s
!#
(define file_name "test.cfg")

;rest file_name
(define (get_file_name)
(if (eqv? 2 (length (command-line)))
    (set! file_name (cadr(command-line)))
)
)
(get_file_name)
(if (file-exists? file_name)
(begin (display file_name)
;do something here
(newline))
(display "ERR:F\n")
)
