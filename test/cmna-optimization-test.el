;;; cmna-optimization-test.el --- Tests for cmna-el -*- lexical-binding: t; -*-

;; Tests for the bisection method
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

;; Tests for Newton's method
(ert-deftest newton-method/root2 ()
  "Test square root of 2"
  (defun test-func (x) (- (* x x) 2))
  (defun test-func-derivative (x) (* 2 x))
  (should (float-equal? (newton-method 'test-func 'test-func-derivative 1) (sqrt 2) 1e-9)))

(ert-deftest newton-method/root4positive ()
  "Test square root of 4 (positive root)"
  (defun test-func (x) (- (* x x) 4))
  (defun test-func-derivative (x) (* 2 x))
  (should (float-equal? (newton-method 'test-func 'test-func-derivative 3) 2)))

(ert-deftest newton-method/root4negative ()
  "Test square root of 4 (negative root)"
  (defun test-func (x) (- (* x x) 4))
  (defun test-func-derivative (x) (* 2 x))
  (should (float-equal? (newton-method 'test-func 'test-func-derivative -3) -2)))

(ert-deftest newton-method/cuberoot5 ()
  "Test cube root of 5"
  (defun test-func (x) (- (expt x 3) 5))
  (defun test-func-derivative (x) (* 3 (expt x 2)))
  (should (float-equal? (newton-method 'test-func 'test-func-derivative 2 1e-6) (expt 5 (/ 1.0 3.0)) 1e-6)))

(ert-deftest newton-method/sinx ()
  "Test sin(x) = 0 (root at x = 0)"
  (defun test-func (x) (sin x))
  (defun test-func-derivative (x) (cos x))
  (should (float-equal? (newton-method 'test-func 'test-func-derivative 0.5) 0 1e-9)))

(ert-deftest newton-method/nonconvergence ()
  "Test for non-convergence (max-iterations reached)"
  (defun test-func (x) (- (* x x) 2))
  (defun test-func-derivative (x) (* 2 x))
  (should-error (newton-method 'test-func 'test-func-derivative 0) :type 'cmna-maximum-iterations-exceeded))

;;; cmna-optimization-test.el ends here
