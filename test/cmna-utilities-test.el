;;; cmna-utilities-test.el --- Tests for CMNA utilities -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: BSD-2-Clause

(require 'ert)
(require 'cmna-errors)
(require 'cmna-utilities)

(ert-deftest cmna--finite-number-p/recognizes-finite-scalars ()
  (should (cmna--finite-number-p 0))
  (should (cmna--finite-number-p -3.5))
  (should-not (cmna--finite-number-p 0.0e+NaN))
  (should-not (cmna--finite-number-p 1.0e+INF))
  (should-not (cmna--finite-number-p "1")))

(ert-deftest cmna--validate-tolerance/contract ()
  (should (= (cmna--validate-tolerance 1e-6) 1e-6))
  (should-error (cmna--validate-tolerance 0) :type 'cmna-domain-error)
  (should-error (cmna--validate-tolerance -1) :type 'cmna-domain-error)
  (should-error (cmna--validate-tolerance 1.0e+INF)
                :type 'cmna-domain-error))

(ert-deftest cmna--validate-maximum-iterations/contract ()
  (should (= (cmna--validate-maximum-iterations 10) 10))
  (should-error (cmna--validate-maximum-iterations 0)
                :type 'cmna-domain-error)
  (should-error (cmna--validate-maximum-iterations 1.5)
                :type 'cmna-domain-error))

(ert-deftest cmna--ensure-finite-number/signals-numerical-condition ()
  (should-error (cmna--ensure-finite-number 0.0e+NaN "value")
                :type 'cmna-non-finite-value)
  (should-error (cmna--ensure-finite-number 1.0e+INF "value")
                :type 'cmna-numerical-error))

(ert-deftest cmna-float-equal-p/equal ()
  (should (cmna-float-equal-p 1.0 1.0))
  (should (cmna-float-equal-p 1.000000001 1.000000002))
  (should (cmna-float-equal-p 0.0 0.0)))

(ert-deftest cmna-float-equal-p/not-equal ()
  (should-not (cmna-float-equal-p 1.0 1.00000001))
  (should-not (cmna-float-equal-p 0.0 0.00000001))
  (should-not (cmna-float-equal-p -1.000000001 1.000000001)))

(ert-deftest cmna-float-equal-p/different-tolerances ()
  (should (cmna-float-equal-p 1.0 1.00000001 1.0e-7))
  (should-not (cmna-float-equal-p 1.0 1.00000001 1.0e-9)))

(ert-deftest cmna-float-equal-p/domain-error ()
  (should-error (cmna-float-equal-p 1.0 1.0 0)
                :type 'cmna-domain-error)
  (should-error (cmna-float-equal-p 1.0 1.0 -1.0)
                :type 'cmna-domain-error))

(ert-deftest cmna-sequence/ascending-integer-increments ()
  (should (equal (cmna-sequence 1 5 1) '(1 2 3 4 5)))
  (should (equal (cmna-sequence 0 10 2) '(0 2 4 6 8 10)))
  (should (equal (cmna-sequence -5 0 1) '(-5 -4 -3 -2 -1 0))))

(ert-deftest cmna-sequence/descending-integer-increments ()
  (should (equal (cmna-sequence 5 1 -1) '(5 4 3 2 1)))
  (should (equal (cmna-sequence 10 0 -2) '(10 8 6 4 2 0)))
  (should (equal (cmna-sequence 0 -5 -1) '(0 -1 -2 -3 -4 -5))))

(ert-deftest cmna-sequence/floating-point-increments ()
  (let ((result (cmna-sequence 0.0 1.0 0.1))
        (expected '(0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0)))
    (should (= (length result) (length expected)))
    (cl-mapc (lambda (actual wanted)
               (should (cmna-float-equal-p actual wanted 1e-6)))
             result expected)))

(ert-deftest cmna-sequence/domain-error ()
  (should-error (cmna-sequence 1 5 -1) :type 'cmna-domain-error)
  (should-error (cmna-sequence 5 1 1) :type 'cmna-domain-error)
  (should-error (cmna-sequence 1 1 0) :type 'cmna-domain-error))

(ert-deftest cmna-sequence/uneven-division ()
  (should (equal (cmna-sequence 0 5 3) '(0 3))))

(provide 'cmna-utilities-test)

;;; cmna-utilities-test.el ends here
