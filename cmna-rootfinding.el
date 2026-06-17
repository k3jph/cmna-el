;;; cmna-rootfinding.el --- CMNA root finding -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 James P. Howard, II
;; SPDX-License-Identifier: BSD-2-Clause
;;
;; Author: James P. Howard, II <jh@jameshoward.us>
;; Maintainer: James P. Howard, II <jh@jameshoward.us>
;; Keywords: tools
;; Homepage: https://github.com/k3jph/cmna-el
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Root-finding algorithms for CMNA.
;;
;;; Code:

(require 'cmna-defaults)
(require 'cmna-errors)
(require 'cmna-utilities)

(defun cmna--finite-number-p (value)
  "Return non-nil when VALUE is a finite number."
  (and (numberp value)
       (= value value)
       (or (integerp value)
           (< (abs value) 1.0e+INF))))

(defun cmna--same-sign-p (x y)
  "Return non-nil when nonzero numbers X and Y have the same sign."
  (or (and (> x 0) (> y 0))
      (and (< x 0) (< y 0))))

(defun cmna--checked-function-value (function argument label)
  "Call FUNCTION with ARGUMENT and validate the result.

LABEL is used in error messages."
  (let ((value (funcall function argument)))
    (unless (cmna--finite-number-p value)
      (signal 'cmna-domain-error
              (list (format "%s must be a finite number" label))))
    value))

(defun cmna-bisection (function a b &optional tolerance max-iterations)
  "Return a root of FUNCTION bracketed by A and B.

TOLERANCE defaults to `cmna-default-tolerance'.  MAX-ITERATIONS defaults to
`cmna-default-maximum-iterations'.  Reversed endpoints are reordered
silently.  Endpoint roots are returned immediately."
  (unless (functionp function)
    (signal 'wrong-type-argument (list 'functionp function)))
  (unless (cmna--finite-number-p a)
    (signal 'wrong-type-argument (list 'numberp a)))
  (unless (cmna--finite-number-p b)
    (signal 'wrong-type-argument (list 'numberp b)))
  (setq tolerance (or tolerance cmna-default-tolerance))
  (setq max-iterations (or max-iterations cmna-default-maximum-iterations))
  (unless (and (cmna--finite-number-p tolerance) (> tolerance 0))
    (signal 'cmna-domain-error '("Tolerance must be greater than zero")))
  (unless (and (integerp max-iterations) (> max-iterations 0))
    (signal 'cmna-domain-error
            '("Maximum iterations must be a positive integer")))
  (when (> a b)
    (let ((temporary a))
      (setq a b)
      (setq b temporary)))
  (let ((fa (cmna--checked-function-value function a "f(a)"))
        (fb (cmna--checked-function-value function b "f(b)"))
        (iteration 0))
    (cond
     ((zerop fa) a)
     ((zerop fb) b)
     ((cmna--same-sign-p fa fb)
      (signal 'cmna-domain-error
              '("The initial interval does not bracket a root")))
     (t
      (while (> (abs (- b a)) tolerance)
        (when (>= iteration max-iterations)
          (signal 'cmna-maximum-iterations-exceeded
                  (list (format "Bisection did not converge after %d iterations"
                                max-iterations))))
        (setq iteration (1+ iteration))
        (let* ((midpoint (+ a (/ (- b a) 2.0)))
               (fmid (cmna--checked-function-value function midpoint
                                                   "f(midpoint)")))
          (when (or (= midpoint a) (= midpoint b))
            (signal 'cmna-domain-error
                    '("Bisection interval can no longer be reduced")))
          (if (zerop fmid)
              (setq a midpoint
                    b midpoint)
            (if (cmna--same-sign-p fa fmid)
                (setq a midpoint
                      fa fmid)
              (setq b midpoint
                    fb fmid)))))
      (+ a (/ (- b a) 2.0))))))

(defun cmna-newton (function derivative guess &optional tolerance max-iterations)
  "Return a root of FUNCTION using Newton iteration from GUESS.

DERIVATIVE is the derivative of FUNCTION.  TOLERANCE defaults to
`cmna-default-tolerance'.  MAX-ITERATIONS defaults to
`cmna-default-maximum-iterations'."
  (unless (functionp function)
    (signal 'wrong-type-argument (list 'functionp function)))
  (unless (functionp derivative)
    (signal 'wrong-type-argument (list 'functionp derivative)))
  (unless (cmna--finite-number-p guess)
    (signal 'wrong-type-argument (list 'numberp guess)))
  (setq tolerance (or tolerance cmna-default-tolerance))
  (setq max-iterations (or max-iterations cmna-default-maximum-iterations))
  (unless (and (cmna--finite-number-p tolerance) (> tolerance 0))
    (signal 'cmna-domain-error '("Tolerance must be greater than zero")))
  (unless (and (integerp max-iterations) (> max-iterations 0))
    (signal 'cmna-domain-error
            '("Maximum iterations must be a positive integer")))
  (let ((x (float guess))
        (fx nil)
        (iteration 0)
        (result nil)
        (converged nil))
    (setq fx (cmna--checked-function-value function x "f(x)"))
    (if (zerop fx)
        x
      (while (and (< iteration max-iterations) (not converged))
        (let ((fpx (cmna--checked-function-value derivative x "f'(x)")))
          (when (zerop fpx)
            (signal 'cmna-domain-error
                    '("Derivative is zero at the current estimate")))
          (let ((next-x (- x (/ fx fpx))))
            (unless (cmna--finite-number-p next-x)
              (signal 'cmna-domain-error
                      '("Next estimate must be a finite number")))
            (cond
             ((<= (abs (- next-x x)) tolerance)
              (setq result next-x
                    converged t))
             ((= next-x x)
              (signal 'cmna-domain-error
                      '("Newton iteration can no longer advance")))
             (t
              (setq x next-x)
              (setq fx (cmna--checked-function-value function x "f(x)"))
              (when (zerop fx)
                (setq result x
                      converged t))))))
        (setq iteration (1+ iteration)))
      (if converged
          result
        (signal 'cmna-maximum-iterations-exceeded
                (list (format "Newton's method did not converge after %d iterations"
                              max-iterations)))))))

(defun cmna-secant (function x0 x1 &optional tolerance max-iterations)
  "Return a root of FUNCTION using secant iteration from X0 and X1.

X0 and X1 must be distinct finite initial estimates.  TOLERANCE defaults to
`cmna-default-tolerance' and measures the absolute change between successive
estimates.  MAX-ITERATIONS defaults to
`cmna-default-maximum-iterations'.

Return immediately when either initial estimate is an exact root.  Signal
`cmna-domain-error' when a function value, denominator, or update is invalid,
or when floating-point arithmetic prevents the iteration from advancing.
Signal `cmna-maximum-iterations-exceeded' when convergence is not achieved
within MAX-ITERATIONS."
  (unless (functionp function)
    (signal 'wrong-type-argument (list 'functionp function)))
  (unless (cmna--finite-number-p x0)
    (signal 'wrong-type-argument (list 'numberp x0)))
  (unless (cmna--finite-number-p x1)
    (signal 'wrong-type-argument (list 'numberp x1)))
  (when (= x0 x1)
    (signal 'cmna-domain-error
            '("Initial estimates must be distinct")))
  (setq tolerance (or tolerance cmna-default-tolerance))
  (setq max-iterations (or max-iterations cmna-default-maximum-iterations))
  (unless (and (cmna--finite-number-p tolerance) (> tolerance 0))
    (signal 'cmna-domain-error '("Tolerance must be greater than zero")))
  (unless (and (integerp max-iterations) (> max-iterations 0))
    (signal 'cmna-domain-error
            '("Maximum iterations must be a positive integer")))
  (let* ((x0 (float x0))
         (x1 (float x1))
         (f0 (cmna--checked-function-value function x0 "f(x0)"))
         (f1 (cmna--checked-function-value function x1 "f(x1)"))
         (iteration 0)
         (result nil)
         (converged nil))
    (cond
     ((zerop f0) x0)
     ((zerop f1) x1)
     (t
      (while (and (< iteration max-iterations) (not converged))
        (let ((denominator (- f1 f0)))
          (unless (cmna--finite-number-p denominator)
            (signal 'cmna-domain-error
                    '("Secant denominator must be a finite number")))
          (when (zerop denominator)
            (signal 'cmna-domain-error
                    '("Secant denominator is zero")))
          (let ((next-x (- x1
                           (* f1
                              (/ (- x1 x0) denominator)))))
            (unless (cmna--finite-number-p next-x)
              (signal 'cmna-domain-error
                      '("Next estimate must be a finite number")))
            (when (= next-x x1)
              (signal 'cmna-domain-error
                      '("Secant iteration can no longer advance")))
            (if (<= (abs (- next-x x1)) tolerance)
                (setq result next-x
                      converged t)
              (setq x0 x1
                    f0 f1
                    x1 next-x
                    f1 (cmna--checked-function-value function next-x
                                                     "f(x1)"))
              (when (zerop f1)
                (setq result x1
                      converged t)))))
        (setq iteration (1+ iteration)))
      (if converged
          result
        (signal 'cmna-maximum-iterations-exceeded
                (list (format "Secant method did not converge after %d iterations"
                              max-iterations))))))))

(provide 'cmna-rootfinding)

;;; cmna-rootfinding.el ends here
