(module util (displayln string-repeat)
    (import scheme
            r7rs
            (chicken module))
    (reexport (util json) (util web))

    (define-syntax displayln
        (syntax-rules ()
            ((displayln obj)
             (begin 
                (display obj)
                (display "\n")))))

    (define (string-repeat str len)
        (if (= len 0)
            ""
            (string-append str (string-repeat (- len 1)))))

)
