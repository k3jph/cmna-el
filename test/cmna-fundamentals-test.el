;;; cmna-fundamentals-test.el --- Tests for cmna-el -*- lexical-binding: t; -*-

(require 'cmna-utilities)

(ert-deftest sum/basic ()
  "Test basic summation."
  (should (= (sum '(1 2 3 4)) 10)))

(ert-deftest sum/empty-list ()
  "Test summing an empty list."
  (should (= (sum '()) 0)))

(ert-deftest sum/single-element ()
  "Test summing a list with a single element."
  (should (= (sum '(7)) 7)))

(ert-deftest sum/negative-numbers ()
  "Test summing negative numbers."
  (should (= (sum '(-1 -2 -3)) -6)))

(ert-deftest sum/mixed-signs ()
  "Test summing numbers with mixed signs."
  (should (= (sum '(3 -2 1 -1)) 1)))

(ert-deftest sum/floating-point ()
  "Test summing floating-point numbers."
  (should (float-equal? (sum '(1.1 2.1 3.1)) 6.3)))

(ert-deftest sum/incorrect-argument ()
  "Test summing non-number elements."
  (should-error (sum '(1 2 "3"))))

(ert-deftest sum/no-argument ()
  "Test summing without any arguments."
  (should-error (sum)))

(ert-deftest sum/multiple-arguments ()
  "Test summing with multiple arguments."
  (should-error (sum '(1 2) '(3 4))))

(ert-deftest arithmetic-mean/basic ()
  "Test basic arithmetic mean calculation."
  (should (float-equal? (arithmetic-mean '(1 2 3 4)) 2.5)))

(ert-deftest arithmetic-mean/single-element ()
  "Test arithmetic mean of a single-element list."
  (should (float-equal? (arithmetic-mean '(5)) 5)))

(ert-deftest arithmetic-mean/negative-numbers ()
  "Test arithmetic mean with negative numbers."
  (should (float-equal? (arithmetic-mean '(-1 -2 -3)) -2)))

(ert-deftest arithmetic-mean/mixed-signs ()
  "Test arithmetic mean with numbers of mixed signs."
  (should (float-equal? (arithmetic-mean '(4 -2 1 -1)) 0.5)))

(ert-deftest arithmetic-mean/floating-point ()
  "Test arithmetic mean with floating-point numbers."
  (should (float-equal? (arithmetic-mean '(1.1 2.1 3.1)) 2.1)))

(ert-deftest arithmetic-mean/empty-list ()
  "Test arithmetic mean of an empty list should raise error."
  (should-error (arithmetic-mean '())))

(ert-deftest arithmetic-mean/incorrect-argument ()
  "Test arithmetic mean with non-number elements."
  (should-error (arithmetic-mean '(1 2 "3"))))


;;; cmna-fundamentals-test.el ends here
