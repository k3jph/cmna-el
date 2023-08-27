;;; cmna-utilities-test.el --- Tests for cmna-el -*- lexical-binding: t; -*-

(ert-deftest float-equal?/equal ()
  "Test cases for equal floats"
  (should (float-equal? 1.0 1.0))
  (should (float-equal? 1.000000001 1.000000002))
  (should (float-equal? 0.0 0.0)))

(ert-deftest float-equal?/not-equal ()
  "Test cases for not equal floats"
  (should-not (float-equal? 1.0 1.00000001))
  (should-not (float-equal? 0.0 0.00000001))
  (should-not (float-equal? -1.000000001 1.000000001)))

(ert-deftest float-equal?/different-tolerances ()
  "Test cases for different tolerances"
  (should (float-equal? 1.0 1.00000001 1.0e-7))
  (should-not (float-equal? 1.0 1.00000001 1.0e-9)))

(ert-deftest float-equal?/negative-numbers ()
  "Test cases with negative numbers"
  (should (float-equal? -1.0 -1.0))
  (should (float-equal? -1.000000001 -1.000000002))
  (should-not (float-equal? -1.0 1.0)))

(ert-deftest float-equal?/zeros ()
  "Test cases with zero"
  (should (float-equal? 0.0 0.0))
  (should-not (float-equal? 0.0 0.00000001))
  (should (float-equal? 0.0 0.0000000001)))

(ert-deftest float-equal?/domain-error ()
  "Test cases for domain error"
  (should-error (float-equal? 1.0 1.0 0) :type 'cmna-domain-error)
  (should-error (float-equal? 1.0 1.0 -1.0) :type 'cmna-domain-error))

(ert-deftest sequence/ascending-integer-increments ()
  "Ascending sequences with integer increments"
  (should (equal (sequence 1 5 1) '(1 2 3 4 5)))
  (should (equal (sequence 0 10 2) '(0 2 4 6 8 10)))
  (should (equal (sequence -5 0 1) '(-5 -4 -3 -2 -1 0))))

(ert-deftest sequence/descending-integer-increments ()
  "Descending sequences with integer increments"
  (should (equal (sequence 5 1 -1) '(5 4 3 2 1)))
  (should (equal (sequence 10 0 -2) '(10 8 6 4 2 0)))
  (should (equal (sequence 0 -5 -1) '(0 -1 -2 -3 -4 -5))))

(ert-deftest sequence/ascending-floating-point-increments ()
  "Ascending sequences with floating-point increments"
  (let
      ((result (sequence 0.0 1.0 0.1))
       (expected '(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)))
    (should (= (length result) (length expected)))
    (dolist (pair (cl-mapcar #'cons result expected))
      (should (float-equal? (car pair) (cdr pair) 1e-6)))))

(ert-deftest sequence/descending-floating-point-increments ()
  "Descending sequences with floating-point increments"
  (should (equal (sequence 2.0 1.0 -0.5) '(2.0 1.5 1.0))))

(ert-deftest sequence/domain-error ()
  "Sequences where no numbers are generated due to increment"
  (should-error (sequence 1 5 -1) :type 'cmna-domain-error)
  (should-error (sequence 5 1 1) :type 'cmna-domain-error))

(ert-deftest sequence/larger-increments ()
  "Sequences with larger increments"
  (should (equal (sequence 0 100 20) '(0 20 40 60 80 100))))

(ert-deftest sequence/loop-once ()
  "Sequences that loop once"
  (should (equal (sequence 0 0 1) '(0)))
  (should (equal (sequence 0.0 0.0 0.1) '(0.0))))

(ert-deftest sequence/loop-zero ()
  "Sequences that loop zero times"
  (should-error (sequence 1 1 0) :type 'cmna-domain-error)
  (should-error (sequence 0 0 0) :type 'cmna-domain-error))

(ert-deftest sequence/negative-start-end ()
  "Sequences with negative start and end values"
  (should (equal (sequence -3 -1 1) '(-3 -2 -1)))
  (should (equal (sequence -1 -3 -1) '(-1 -2 -3))))

(ert-deftest sequence/uneven-division ()
  "Sequences where the increment doesn't divide evenly into the range"
  (should (equal (sequence 0 5 3) '(0 3))))

;;; cmna-utilities-test.el ends here
