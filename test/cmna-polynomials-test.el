;;; cmna-polynomials-test.el --- Tests for CMNA polynomials -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: BSD-2-Clause

(require 'ert)
(require 'cmna-polynomials)

(ert-deftest cmna-polynomial-evaluation/canonical-values ()
  (let ((coefficients '(5 -3 2)))
    (dolist (case '((-2 19) (-1 10) (0 5) (1 4) (2 7)))
      (let ((x (car case))
            (expected (cadr case)))
        (should (= (cmna-polynomial-evaluate-naive x coefficients)
                   expected))
        (should (= (cmna-polynomial-evaluate-horner x coefficients)
                   expected))))))

(ert-deftest cmna-polynomial-evaluation/constant-first-order ()
  (should (= (cmna-polynomial-evaluate-naive 2 '(5 -3 2)) 7))
  (should (= (cmna-polynomial-evaluate-horner 2 '(5 -3 2)) 7)))

(ert-deftest cmna-polynomial-evaluation/constant-polynomial ()
  (should (= (cmna-polynomial-evaluate-naive -100 '(5)) 5))
  (should (= (cmna-polynomial-evaluate-horner 100 '(5)) 5)))

(ert-deftest cmna-polynomial-evaluation/methods-agree ()
  (let ((coefficients '(-1 0 3 -2 1)))
    (dolist (x '(-2 -1.5 -1 0 0.5 1 2))
      (should (= (cmna-polynomial-evaluate-naive x coefficients)
                 (cmna-polynomial-evaluate-horner x coefficients))))))

(ert-deftest cmna-polynomial-evaluation/rejects-empty-coefficients ()
  (should-error (cmna-polynomial-evaluate-naive 1 nil)
                :type 'wrong-type-argument)
  (should-error (cmna-polynomial-evaluate-horner 1 nil)
                :type 'wrong-type-argument))

(ert-deftest cmna-polynomial-evaluation/rejects-invalid-input ()
  (should-error (cmna-polynomial-evaluate-naive "1" '(1 2))
                :type 'wrong-type-argument)
  (should-error (cmna-polynomial-evaluate-horner 1 '(1 "2"))
                :type 'wrong-type-argument)
  (should-error (cmna-polynomial-evaluate-naive 1 [1 2])
                :type 'wrong-type-argument))

(provide 'cmna-polynomials-test)

;;; cmna-polynomials-test.el ends here
