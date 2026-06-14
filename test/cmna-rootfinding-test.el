;;; cmna-rootfinding-test.el --- Tests for CMNA root finding -*- lexical-binding: t; -*-

(require 'ert)
(require 'cmna-errors)
(require 'cmna-rootfinding)
(require 'cmna-utilities)

(ert-deftest cmna-bisection/finds-known-root ()
  (let ((root (cmna-bisection (lambda (x) (- (* x x) 2))
                              1 2 1e-10)))
    (should (cmna-float-equal-p root (sqrt 2) 1e-10))))

(ert-deftest cmna-bisection/reorders-reversed-endpoints ()
  (let ((function (lambda (x) (- (* x x) 2))))
    (should (cmna-float-equal-p
             (cmna-bisection function 2 1 1e-10)
             (cmna-bisection function 1 2 1e-10)
             1e-12))))

(ert-deftest cmna-bisection/returns-endpoint-root ()
  (let ((function (lambda (x) (- x 2))))
    (should (= (cmna-bisection function 2 5) 2))
    (should (= (cmna-bisection function 0 2) 2))))

(ert-deftest cmna-bisection/rejects-unbracketed-root ()
  (should-error
   (cmna-bisection (lambda (x) (+ (* x x) 1)) -1 1)
   :type 'cmna-domain-error))

(ert-deftest cmna-bisection/validates-function ()
  (should-error (cmna-bisection "not-a-function" 0 1)
                :type 'wrong-type-argument))

(ert-deftest cmna-bisection/validates-bounds ()
  (should-error (cmna-bisection #'identity "0" 1)
                :type 'wrong-type-argument)
  (should-error (cmna-bisection #'identity 0 "1")
                :type 'wrong-type-argument))

(ert-deftest cmna-bisection/validates-tolerance ()
  (should-error (cmna-bisection #'identity -1 1 0)
                :type 'cmna-domain-error)
  (should-error (cmna-bisection #'identity -1 1 -1e-6)
                :type 'cmna-domain-error))

(ert-deftest cmna-bisection/validates-max-iterations ()
  (should-error (cmna-bisection #'identity -1 1 nil 0)
                :type 'cmna-domain-error)
  (should-error (cmna-bisection #'identity -1 1 nil 1.5)
                :type 'cmna-domain-error))

(ert-deftest cmna-bisection/rejects-nonfinite-function-values ()
  (should-error (cmna-bisection (lambda (_x) 0.0e+NaN) 0 1)
                :type 'cmna-domain-error)
  (should-error (cmna-bisection (lambda (_x) 1.0e+INF) 0 1)
                :type 'cmna-domain-error))

(ert-deftest cmna-bisection/rejects-nonfinite-midpoint-value ()
  (should-error
   (cmna-bisection
    (lambda (x)
      (cond
       ((= x 0.5) 0.0e+NaN)
       ((< x 0.5) -1)
       (t 1)))
    0 1)
   :type 'cmna-domain-error))

(ert-deftest cmna-bisection/errors-on-iteration-exhaustion ()
  (should-error
   (cmna-bisection (lambda (x) (- (* x x) 2))
                   1 2 1e-15 1)
   :type 'cmna-maximum-iterations-exceeded))

(ert-deftest cmna-bisection/detects-midpoint-collapse ()
  (let* ((a 1.0)
         (b (+ a (* 4 least-positive-normalized-float))))
    (should-error
     (cmna-bisection
      (lambda (x)
        (if (= x a) -1 1))
      a b least-positive-normalized-float)
     :type 'cmna-domain-error)))

(provide 'cmna-rootfinding-test)

;;; cmna-rootfinding-test.el ends here
