(module (util web) (perform-request current-response)
    (import
        http-client
        (chicken io)
        (rename intarweb (make-request intarweb:make-request))
        uri-common
        (scheme base))

    (define current-response (make-parameter '()))
    (define-syntax perform-request
        (syntax-rules ()
            ((_ request writer reader)
             (let ((writer1 
                   (if (eqv? writer #f)
                       (lambda (x) '())
                       (writer))))
                (call-with-response request writer1
                        (lambda (resp) 
                            (parameterize ((current-input-port (response-port resp))
                                           (current-response resp)) 
                                (reader))))))))
)
