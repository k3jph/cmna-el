;;; cmna-integration-test.el --- Tests for CMNA Integration -*- lexical-binding: t; -*-

(ert-deftest midpoint-rule/constant-function ()
  "Test integration of constant function."
  (should (float-equal? (midpoint-rule (lambda (x) 2) 0 1 100) 2)))

(ert-deftest midpoint-rule/linear-function ()
  "Test integration of linear function."
  (should (float-equal? (midpoint-rule (lambda (x) x) 0 1 1000) 0.5 1e-3)))

(ert-deftest midpoint-rule/quadratic-function ()
  "Test integration of quadratic function."
  (should (float-equal? (midpoint-rule (lambda (x) (* x x)) 0 1 100) (/ 1.0 3.0) 1e-2)))

(ert-deftest midpoint-rule/cubic-function ()
  "Test integration of cubic function."
  (should (float-equal? (midpoint-rule (lambda (x) (* x x x)) 0 1 100) (/ 1.0 4.0) 1e-1)))

;;; cmna-integration-test.el ends here
