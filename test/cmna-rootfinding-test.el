;;; cmna-rootfinding-test.el --- Tests for CMNA root finding -*- lexical-binding: t; -*-

(require 'ert)
(require 'cmna-errors)
(require 'cmna-rootfinding)
(require 'cmna-test-helpers)
(require 'cmna-utilities)

(ert-deftest cmna-bisection/finds-known-root ()
  (let ((root (cmna-bisection (lambda (x) (- (* x x) 2))
                              1 2 1e-10)))
    (cmna-should-float= root (sqrt 2) 1e-10)))

(ert-deftest cmna-bisection/reorders-reversed-endpoints ()
  (let ((function (lambda (x) (- (* x x) 2))))
    (cmna-should-float=
     (cmna-bisection function 2 1 1e-10)
     (cmna-bisection function 1 2 1e-10)
     1e-12)))

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
         (b (+ a 1e-15)))
    (should-error
     (cmna-bisection
      (lambda (x)
        (if (= x a) -1 1))
      a b 1e-18)
     :type 'cmna-domain-error)))

(ert-deftest cmna-newton/finds-known-root ()
  (let ((root (cmna-newton (lambda (x) (- (* x x) 2))
                           (lambda (x) (* 2 x))
                           1
                           1e-10)))
    (cmna-should-float= root (sqrt 2) 1e-10)))

(ert-deftest cmna-newton/returns-initial-root ()
  (should (= (cmna-newton (lambda (x) (- x 2))
                          (lambda (_x) 1)
                          2)
             2)))

(ert-deftest cmna-newton/validates-functions ()
  (should-error (cmna-newton "not-a-function" #'identity 1)
                :type 'wrong-type-argument)
  (should-error (cmna-newton #'identity "not-a-function" 1)
                :type 'wrong-type-argument))

(ert-deftest cmna-newton/validates-guess ()
  (should-error (cmna-newton #'identity #'identity "1")
                :type 'wrong-type-argument)
  (should-error (cmna-newton #'identity #'identity 1.0e+INF)
                :type 'wrong-type-argument))

(ert-deftest cmna-newton/validates-tolerance ()
  (should-error (cmna-newton #'identity #'identity 1 0)
                :type 'cmna-domain-error)
  (should-error (cmna-newton #'identity #'identity 1 -1e-6)
                :type 'cmna-domain-error))

(ert-deftest cmna-newton/validates-max-iterations ()
  (should-error (cmna-newton #'identity #'identity 1 nil 0)
                :type 'cmna-domain-error)
  (should-error (cmna-newton #'identity #'identity 1 nil 1.5)
                :type 'cmna-domain-error))

(ert-deftest cmna-newton/rejects-nonfinite-values ()
  (should-error (cmna-newton (lambda (_x) 0.0e+NaN)
                             (lambda (_x) 1)
                             1)
                :type 'cmna-domain-error)
  (should-error (cmna-newton (lambda (x) (- x 1))
                             (lambda (_x) 1.0e+INF)
                             0)
                :type 'cmna-domain-error))

(ert-deftest cmna-newton/rejects-zero-derivative ()
  (should-error (cmna-newton (lambda (x) (+ (* x x) 1))
                             (lambda (_x) 0)
                             1)
                :type 'cmna-domain-error))

(ert-deftest cmna-newton/rejects-nonfinite-next-estimate ()
  (should-error (cmna-newton (lambda (_x) 1.0e+308)
                             (lambda (_x) 1.0e-308)
                             0)
                :type 'cmna-domain-error))

(ert-deftest cmna-newton/errors-on-iteration-exhaustion ()
  (should-error (cmna-newton (lambda (x) (- (* x x) 2))
                             (lambda (x) (* 2 x))
                             1
                             1e-15
                             1)
                :type 'cmna-maximum-iterations-exceeded))

(ert-deftest cmna-secant/finds-known-root ()
  (let ((root (cmna-secant (lambda (x) (- (* x x) 2))
                           1 2 1e-10)))
    (cmna-should-float= root (sqrt 2) 1e-10)))

(ert-deftest cmna-secant/returns-initial-root ()
  (let ((function (lambda (x) (- x 2))))
    (should (= (cmna-secant function 2 3) 2.0))
    (should (= (cmna-secant function 1 2) 2.0))))

(ert-deftest cmna-secant/validates-function ()
  (should-error (cmna-secant "not-a-function" 0 1)
                :type 'wrong-type-argument))

(ert-deftest cmna-secant/validates-initial-estimates ()
  (should-error (cmna-secant #'identity "0" 1)
                :type 'wrong-type-argument)
  (should-error (cmna-secant #'identity 0 "1")
                :type 'wrong-type-argument)
  (should-error (cmna-secant #'identity 1.0e+INF 1)
                :type 'wrong-type-argument)
  (should-error (cmna-secant #'identity 0 1.0e+INF)
                :type 'wrong-type-argument)
  (should-error (cmna-secant #'identity 1 1)
                :type 'cmna-domain-error))

(ert-deftest cmna-secant/validates-tolerance ()
  (should-error (cmna-secant #'identity 0 1 0)
                :type 'cmna-domain-error)
  (should-error (cmna-secant #'identity 0 1 -1e-6)
                :type 'cmna-domain-error)
  (should-error (cmna-secant #'identity 0 1 1.0e+INF)
                :type 'cmna-domain-error))

(ert-deftest cmna-secant/validates-max-iterations ()
  (should-error (cmna-secant #'identity 0 1 nil 0)
                :type 'cmna-domain-error)
  (should-error (cmna-secant #'identity 0 1 nil 1.5)
                :type 'cmna-domain-error))

(ert-deftest cmna-secant/rejects-nonfinite-initial-function-values ()
  (should-error (cmna-secant (lambda (_x) 0.0e+NaN) 0 1)
                :type 'cmna-domain-error)
  (should-error
   (cmna-secant (lambda (x) (if (zerop x) -1 1.0e+INF)) 0 1)
   :type 'cmna-domain-error))

(ert-deftest cmna-secant/rejects-nonfinite-iterated-function-value ()
  (should-error
   (cmna-secant
    (lambda (x)
      (cond
       ((= x 0.0) -2.0)
       ((= x 1.0) -1.0)
       (t 0.0e+NaN)))
    0 1)
   :type 'cmna-domain-error))

(ert-deftest cmna-secant/rejects-zero-denominator ()
  (should-error
   (cmna-secant (lambda (x) (+ (* x x) 1)) -1 1)
   :type 'cmna-domain-error))

(ert-deftest cmna-secant/rejects-nonfinite-denominator ()
  (should-error
   (cmna-secant
    (lambda (x) (if (< x 0) -1.0e+308 1.0e+308))
    -1 1)
   :type 'cmna-domain-error))

(ert-deftest cmna-secant/rejects-nonfinite-next-estimate ()
  (should-error
   (cmna-secant (lambda (x) (/ x 1.0e+308))
                -1.0e+308 1.0e+308)
   :type 'cmna-domain-error))

(ert-deftest cmna-secant/detects-floating-point-stagnation ()
  (should-error
   (cmna-secant
    (lambda (x) (if (zerop x) 1.0e+308 1.0))
    0 1)
   :type 'cmna-domain-error))

(ert-deftest cmna-secant/errors-on-iteration-exhaustion ()
  (should-error
   (cmna-secant (lambda (x) (- (* x x) 2))
                1 2 1e-15 1)
   :type 'cmna-maximum-iterations-exceeded))

(provide 'cmna-rootfinding-test)

;;; cmna-rootfinding-test.el ends here
