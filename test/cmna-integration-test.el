;;; cmna-integration-test.el --- Tests for CMNA integration -*- lexical-binding: t; -*-

(require 'ert)
(require 'cmna-integration)
(require 'cmna-utilities)

(ert-deftest midpoint-rule/constant-function ()
  "Test integration of constant function."
  (should (cmna-float-equal-p (midpoint-rule (lambda (_x) 2) 0 1 10) 2)))

(ert-deftest midpoint-rule/linear-function ()
  "Test integration of linear function."
  (should (cmna-float-equal-p (midpoint-rule (lambda (x) x) 0 1 10)
                              0.5 1e-3)))

(ert-deftest midpoint-rule/quadratic-function ()
  "Test integration of quadratic function."
  (should (cmna-float-equal-p (midpoint-rule (lambda (x) (* x x))
                                             0 1 1000)
                              (/ 1.0 3.0) 1e-7)))

(ert-deftest midpoint-rule/cubic-function ()
  "Test integration of cubic function."
  (should (cmna-float-equal-p (midpoint-rule (lambda (x) (* x x x))
                                             0 1 100)
                              (/ 1.0 4.0) 1e-3)))

(ert-deftest trapezoid-rule/constant-func ()
  (should (cmna-float-equal-p (trapezoid-rule (lambda (_x) 1) 0 1 100) 1)))

(ert-deftest trapezoid-rule/linear-func ()
  (should (cmna-float-equal-p (trapezoid-rule (lambda (x) x) 0 1 100) 0.5)))

(ert-deftest trapezoid-rule/quadratic-func ()
  (should (cmna-float-equal-p (trapezoid-rule (lambda (x) (* x x)) 0 1 100)
                              (/ 1.0 3.0) 1e-4)))

(ert-deftest trapezoid-rule/cubic-func ()
  (should (cmna-float-equal-p (trapezoid-rule (lambda (x) (* x x x)) 0 1 100)
                              (/ 1.0 4.0) 1e-4)))

(ert-deftest trapezoid-rule/zero-interval ()
  (should (cmna-float-equal-p (trapezoid-rule (lambda (x) x) 0 0 100) 0)))

(ert-deftest trapezoid-rule/invalid-subintervals ()
  (should-error (trapezoid-rule (lambda (x) x) 0 1 -1)
                :type 'cmna-domain-error))

(ert-deftest trapezoid-rule/sinusoidal-func ()
  (should (cmna-float-equal-p
           (trapezoid-rule #'sin 0 (* 2 float-pi) 100)
           0)))

(ert-deftest simpsons-rule/constant-func ()
  (should (cmna-float-equal-p (simpsons-rule (lambda (_x) 1) 0 1 100) 1)))

(ert-deftest simpsons-rule/linear-func ()
  (should (cmna-float-equal-p (simpsons-rule (lambda (x) x) 0 1 100) 0.5)))

(ert-deftest simpsons-rule/quadratic-func ()
  (should (cmna-float-equal-p (simpsons-rule (lambda (x) (* x x)) 0 1 100)
                              (/ 1.0 3.0))))

(ert-deftest simpsons-rule/cubic-func ()
  (should (cmna-float-equal-p (simpsons-rule (lambda (x) (* x x x)) 0 1 100)
                              (/ 1.0 4.0))))

(ert-deftest simpsons-rule/zero-interval ()
  (should (cmna-float-equal-p (simpsons-rule (lambda (x) x) 0 0 100) 0)))

(ert-deftest simpsons-rule/invalid-subintervals ()
  (should-error (simpsons-rule (lambda (x) x) 0 1 -1)
                :type 'cmna-domain-error))

(ert-deftest simpsons-rule/sinusoidal-func ()
  (should (cmna-float-equal-p
           (simpsons-rule #'sin 0 (* 2 float-pi) 100)
           0)))

(provide 'cmna-integration-test)

;;; cmna-integration-test.el ends here
