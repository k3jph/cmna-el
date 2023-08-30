;;; cmna-optimization.el --- CMNA Optimization -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 James P. Howard, II
;;
;; Author: James P. Howard, II <jh@jameshoward.us>
;; Maintainer: James P. Howard, II <jh@jameshoward.us>
;; Created: August 14, 2023
;; Modified: August 14, 2023
;; Keywords: tools
;; Homepage: https://github.com/k3jph/cmna-el
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  This is Computationl Methods for Numerical Analysis in
;;  Emacs Lisp.
;;
;;; Code:

(defun bisection-method (func a b &optional tolerance max-iterations)
  "Find a root of the continuous function FUNC within the interval [A, B] using
  the bisection method.

The function estimates the root of a given function FUNC, bounded by the
interval [A, B], to within a specified TOLERANCE.  The algorithm will terminate
either when the estimated error falls below TOLERANCE or when MAX-ITERATIONS is
reached.

Arguments:
  FUNC           : The function whose root is to be estimated. It should accept
                   a single numerical argument.
  A, B           : The end-points of the interval within which to search for a
                   root. FUNC(A) and FUNC(B) must have opposite signs.
  TOLERANCE      : Optional. A positive number representing the accuracy to
                   which the root should be estimated. Defaults to 1.0e-6.
  MAX-ITERATIONS : Optional. A positive integer representing the maximum number
                   of iterations the method can perform. Defaults to 1e2.

Returns:
  A floating-point number representing the estimated root within the given
  TOLERANCE.

Errors:
  Signals a \=cmna-domain-error\= if FUNC(A) and FUNC(B) have the same sign, as
  this violates the assumption of the bisection method.

Example usage:
  ; Find a root of x^2 - 4 between -3 and 3
  (bisection-method (lambda (x) (- (* x x) 4)) -3 3)"
  (unless tolerance (setq tolerance 1.0e-6))
  (unless max-iterations (setq max-iterations 1e2))
  (let ((fa (funcall func a))
        (fb (funcall func b))
        (iteration 0))
    (unless (> 0 (* fa fb))
      (signal 'cmna-domain-error "Incorrect initial interval [a, b]. Ensure f(a) < 0 and f(b) > 0."))
    (while (and (< max-iterations)
                (> (abs (- b a)) tolerance))
      (setq iteration (1+ iteration))
      (let* ((c (/ (+ a b) 2.0))
             (fc (funcall func c)))
        (if (< 0 (* fa fc))
            (setq a c fa fc)
          (setq b c fb fc))))
    (/ (+ a b) 2.0)))

(provide 'cmna-optimization)

;;; cmna-optimization.el ends here
