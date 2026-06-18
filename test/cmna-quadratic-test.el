;;; cmna-quadratic-test.el --- Tests for CMNA quadratic roots -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: BSD-2-Clause

(require 'ert)
(require 'cmna-polynomials)

(ert-deftest cmna-quadratic-roots/distinct-real-roots ()
  (should (equal (cmna-quadratic-roots 1 0 -1) '(-1.0 1.0)))
  (should (equal (cmna-quadratic-roots-stable 1 0 -1) '(-1.0 1.0))))

(ert-deftest cmna-quadratic-roots/repeated-root ()
  (should (equal (cmna-quadratic-roots 4 -4 1) '(0.5 0.5)))
  (should (equal (cmna-quadratic-roots-stable 4 -4 1) '(0.5 0.5))))

(ert-deftest cmna-quadratic-roots/zero-constant-term ()
  (should (equal (cmna-quadratic-roots 1 -3 0) '(0.0 3.0)))
  (should (equal (cmna-quadratic-roots-stable 1 -3 0) '(0.0 3.0))))

(ert-deftest cmna-quadratic-roots/stable-form-preserves-small-root ()
  (let* ((stable (cmna-quadratic-roots-stable 1 -1e8 1))
         (textbook (cmna-quadratic-roots 1 -1e8 1))
         (expected 1e-8))
    (should (< (abs (- (car stable) expected)) 1e-15))
    (should (< (abs (- (cadr stable) 1e8)) 1e-7))
    (should (< (abs (- (car stable) expected))
               (abs (- (car textbook) expected))))))

(ert-deftest cmna-quadratic-roots/rejects-nonquadratic-equation ()
  (should-error (cmna-quadratic-roots 0 2 1)
                :type 'cmna-domain-error)
  (should-error (cmna-quadratic-roots-stable 0 2 1)
                :type 'cmna-domain-error))

(ert-deftest cmna-quadratic-roots/rejects-negative-discriminant ()
  (should-error (cmna-quadratic-roots 1 0 1)
                :type 'cmna-domain-error)
  (should-error (cmna-quadratic-roots-stable 1 0 1)
                :type 'cmna-domain-error))

(ert-deftest cmna-quadratic-roots/rejects-invalid-coefficients ()
  (should-error (cmna-quadratic-roots "1" 0 -1)
                :type 'wrong-type-argument)
  (should-error (cmna-quadratic-roots-stable 1 "0" -1)
                :type 'wrong-type-argument))

(provide 'cmna-quadratic-test)

;;; cmna-quadratic-test.el ends here
