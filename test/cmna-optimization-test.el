;;; cmna-optimization-test.el --- Tests for cmna-el -*- lexical-binding: t; -*-

(ert-deftest bisection-method/x2minus4 ()
  "Root of x^2 - 4 at interval [0, 5] with default tolerance"
  (should (float-equal? (bisection-method (lambda (x) (- (* x x) 4)) 0 5 1e-6) 2.0 1e-5)))

(ert-deftest bisection-method/x2minus1 ()
  "Root of x^2 - 1 at interval [0, 2] with default tolerance"
  (should (float-equal? (bisection-method (lambda (x) (- (* x x) 1)) 0 2 1e-6) 1.0 1e-5)))

(ert-deftest bisection-method/sinx ()
  "Root of sin(x) at interval [2, 4] should be around 3.14159"
  (should (float-equal? (bisection-method #'sin 2 4 1e-6) 3.141592653589793 1e-5)))

(ert-deftest bisection-method/domain-error ()
  "Invalid domain [5, 0], expecting error"
  (should-error (bisection-method (lambda (x) x) 5 0 1e-6) :type 'cmna-domain-error)
  (should-error (bisection-method (lambda (x) (+ (* x x))) -1 1)))

(ert-deftest bisection-method/not-a-function ()
  "Function is not a function, expecting error"
  (should-error (bisection-method "not-a-function" 0 1 1e-6)))

;;; cmna-optimization-test.el ends here
