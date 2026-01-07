(module (util web) (make-request perform-request current-response)
    (import
        http-client
        (chicken io)
        uri-common
        (scheme base)
        (chicken module))
    (reexport (rename intarweb (make-request intarweb:make-request) (headers intarweb:headers)))

    (define (make-request uri #!rest rest #!key headers)
        (apply intarweb:make-request uri: (uri-reference uri) headers: (intarweb:headers headers) rest))

    (define current-response (make-parameter '()))
    (define-syntax perform-request
        (syntax-rules ()
            ((_ request writer reader)
             (let ((writer1 
                   (if (eqv? writer #f)
                       (lambda (x) '())
                       (writer))))
                (call-with-input-request* request writer1
                        (lambda (port resp)
                            (parameterize ((current-input-port port)
                                           (current-response resp)) 
                                (reader))))))))
)
