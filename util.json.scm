(module (util json) (json-read json-obj? json-null? json-pretty-print json-pretty-print-impl)
    (import (only (srfi 180) json-fold)
            (srfi 13) ; string functions like string-join
            scheme
            r7rs
            (chicken port)
            (chicken module))
    (define-syntax displayed
        (syntax-rules ()
            ((displayed obj)
             (with-output-to-string 
                (lambda () (display obj))))))

    (define (json-null? obj)
        (eqv? obj 'null))

    (define (json-obj? obj)
        (and (list? obj)
             (not (null? obj))
             (pair? (car obj))))

    (define (json-read)

      (define %root '(root))

      (define (array-start seed)
        '())

      (define (array-end items)
        (list->vector (reverse items)))

      (define (object-start seed)
        '())

      (define (plist->alist plist)
        (let loop ((plist plist)
                   (out '()))
          (if (null? plist)
              out
              (loop (cddr plist) (cons (cons (cadr plist) (car plist)) out)))))

      (define object-end plist->alist)

      (define (proc obj seed)
        (if (eq? seed %root)
            obj
            (cons obj seed)))

      (let ((out (json-fold proc
                            array-start
                            array-end
                            object-start
                            object-end
                            %root)))
        (if (eq? out %root)
            (eof-object)
            out)))

    (define (json-pretty-print-impl obj indent)
        (define next-indent (string-append "  " indent))
        (define (format-entries entries func sep)
            (string-join (map func entries) sep))
        (define (format-string str)
            (string-append "\"" str "\""))
        (cond
            ((json-null? obj)
             "null")
            ((null? obj)
             "[]")
            ((json-obj? obj)
             (string-append
                "{\n"
                (format-entries obj 
                    (lambda (x) 
                        (string-append next-indent 
                                       (format-string (car x))
                                       ": "
                                       (json-pretty-print-impl (cdr x) next-indent)))
                    ",\n")
                "\n" indent "}"))
            ((vector? obj)
             (string-append
                "[\n"
                (format-entries (vector->list obj)
                    (lambda (x) (string-append next-indent 
                                               (json-pretty-print-impl x next-indent)))
                    ",\n" )
                "\n" indent "]"))
            ((pair? obj)
             )
            ((string? obj)
             (string-append "\"" obj "\""))
            (else (displayed obj))))

    (define-syntax json-pretty-print
        (syntax-rules ()
            ((_ obj) (json-pretty-print-impl obj ""))
            ((_ obj indent) (json-pretty-print-impl obj indent))))

)

