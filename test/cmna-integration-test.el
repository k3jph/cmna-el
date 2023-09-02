;;; cmna-integration-test.el --- Tests for CMNA Integration -*- lexical-binding: t; -*-

(ert-deftest midpoint-rule/constant-function ()
  "Test integration of constant function."
  (should (float-equal? (midpoint-rule (lambda (x) 2) 0 1 10) 2)))

(ert-deftest midpoint-rule/linear-function ()
  "Test integration of linear function."
  (should (float-equal? (midpoint-rule (lambda (x) x) 0 1 10) 0.5 1e-3)))

(ert-deftest midpoint-rule/quadratic-function ()
  "Test integration of quadratic function."
  (should (float-equal? (midpoint-rule (lambda (x) (* x x)) 0 1 1000) (/ 1.0 3.0) 1e-7)))

(ert-deftest midpoint-rule/cubic-function ()
  "Test integration of cubic function."
  (should (float-equal? (midpoint-rule (lambda (x) (* x x x)) 0 1 100) (/ 1.0 4.0) 1e-3)))

(ert-deftest trapezoid-rule/constant-func ()
  "Test trapezoid-rule with a constant function f(x) = 1"
  (should (float-equal? (trapezoid-rule (lambda (x) 1) 0 1 100) 1)))

(ert-deftest trapezoid-rule/linear-func ()
  "Test trapezoid-rule with a linear function f(x) = x"
  (should (float-equal? (trapezoid-rule (lambda (x) x) 0 1 100) 0.5)))

(ert-deftest trapezoid-rule/quadratic-func ()
  "Test trapezoid-rule with a quadratic function f(x) = x^2"
  (should (float-equal? (trapezoid-rule (lambda (x) (* x x)) 0 1 100) (/ 1 3.0) 1e-4)))

(ert-deftest trapezoid-rule/cubic-func ()
  "Test trapezoid-rule with a cubic function f(x) = x^3"
  (should (float-equal? (trapezoid-rule (lambda (x) (* x x x)) 0 1 100) (/ 1 4.0) 1e-4)))

(ert-deftest trapezoid-rule/zero-interval ()
  "Test trapezoid-rule with zero interval"
  (should (float-equal? (trapezoid-rule (lambda (x) x) 0 0 100) 0)))

(ert-deftest trapezoid-rule/invalid-subintervals ()
  "Test trapezoid-rule with negative number of subintervals"
  (should-error (trapezoid-rule (lambda (x) x) 0 1 -1) :type 'cmna-domain-error))

(ert-deftest trapezoid-rule/sinusoidal-func ()
  "Test trapezoid-rule with sinusoidal function f(x) = sin(x)"
  (should (float-equal? (trapezoid-rule #'sin 0 (* 2 float-pi) 100) 0)))

;;; cmna-integration-test.el ends here
