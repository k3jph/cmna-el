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

(require 'cmna-utilities)

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
  (when (>= 0 max-iterations)
    (signal 'cmna-maximum-iterations-exceeded
            (format "Bisection method did not converge after %d iterations" max-iterations)))
  (let* ((fa (funcall func a))
         (fb (funcall func b)))
    (unless (>= 0 (* fa fb))
      (signal 'cmna-domain-error "Invalid initial interval [a, b]. Ensure f(a) < 0 and f(b) > 0."))
    (let* ((c (/ (+ a b) 2.0))
           (fc (funcall func c)))
      (if (float-equal? a b tolerance)
          (/ (+ a b) 2.0)
        (if (< 0 (* fa fc))
            (bisection-method func a c tolerance (1- max-iterations)))
        (bisection-method func c b tolerance (1- max-iterations))))))

(defun newton-method (func func-prime guess &optional tolerance max-iterations)
  "Find an approximate root of the function FUNC using Newton's method,
   starting from an initial GUESS.

This function iteratively refines the estimate for the root of FUNC using its
derivative FUNC-PRIME. The algorithm starts with an initial GUESS and iterates
until either the difference between successive guesses is within TOLERANCE, or
until MAX-ITERATIONS are reached.

Arguments:

  FUNC           : A function whose root is to be found. Must accept a single
                   numerical argument.
  FUNC-PRIME     : The derivative of FUNC. Must also accept a single numerical
                   argument.
  GUESS          : Initial guess for the root.
  TOLERANCE      : Optional. A positive number representing the desired
                   accuracy. Defaults to 1e-6.
  MAX-ITERATIONS : Optional. A positive integer indicating the maximum number of
                   iterations. Defaults to 1e2.

Returns:

  A floating-point number representing the estimated root within the given
  TOLERANCE.

Errors:
  Signals \=cmna-maximum-iterations-exceeded\= if the method did not converge
  within MAX-ITERATIONS.

Example usage:
  ; Finds a root of x^2 - 4, starting from 2
  (newton-method (lambda (x) (- (* x x) 4)) (lambda (x) (* 2 x)) 2)"
  (unless tolerance (setq tolerance 1e-6))
  (unless max-iterations (setq max-iterations 1e2))
  (let ((last-guess (+ guess (* 10 tolerance)))
        (iteration 0))
    (while (and (< iteration max-iterations)
                (not (float-equal? guess last-guess (/ tolerance 10))))
      (let* ((y (funcall func guess))
             (y-derivative (float (funcall func-prime guess))))
        (setq last-guess guess
              guess (- guess (/ y y-derivative))
              iteration (1+ iteration))))
    (when (>= iteration max-iterations)
        (signal 'cmna-maximum-iterations-exceeded
                (format "Newton's method did not converge after %d iterations" max-iterations)))
    (identity last-guess)))

(provide 'cmna-optimization)

;;; cmna-optimization.el ends here
