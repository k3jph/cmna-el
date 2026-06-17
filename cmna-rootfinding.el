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
;; Scalar root-finding algorithms for CMNA.
;;
;;; Code:

(require 'cmna-defaults)
(require 'cmna-errors)
(require 'cmna-utilities)

(defun cmna--same-sign-p (x y)
  "Return non-nil when nonzero numbers X and Y have the same sign."
  (or (and (> x 0) (> y 0))
      (and (< x 0) (< y 0))))

(defun cmna-bisection (function a b &optional tolerance max-iterations)
  "Return a root of FUNCTION bracketed by A and B.

TOLERANCE defaults to `cmna-default-tolerance' and measures the final interval
width.  MAX-ITERATIONS defaults to `cmna-default-maximum-iterations'.
Reversed endpoints are reordered silently, and endpoint roots are returned
immediately.

Signal `cmna-domain-error' when the endpoints do not bracket a root,
`cmna-non-finite-value' when FUNCTION returns an invalid numerical value,
`cmna-stagnation' when floating-point arithmetic prevents further interval
reduction, and `cmna-maximum-iterations-exceeded' when the iteration budget is
exhausted."
  (unless (functionp function)
    (signal 'wrong-type-argument (list 'functionp function)))
  (cmna--validate-finite-number a "a")
  (cmna--validate-finite-number b "b")
  (setq tolerance
        (cmna--validate-tolerance
         (or tolerance cmna-default-tolerance)))
  (setq max-iterations
        (cmna--validate-maximum-iterations
         (or max-iterations cmna-default-maximum-iterations)))
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
              (list "The initial interval does not bracket a root"
                    :a a :b b :f-a fa :f-b fb)))
     (t
      (while (> (abs (- b a)) tolerance)
        (when (>= iteration max-iterations)
          (signal 'cmna-maximum-iterations-exceeded
                  (list (format "Bisection did not converge after %d iterations"
                                max-iterations)
                        :method 'cmna-bisection
                        :iterations iteration
                        :a a :b b)))
        (setq iteration (1+ iteration))
        (let* ((midpoint (+ a (/ (- b a) 2.0)))
               (fmid (cmna--checked-function-value function midpoint
                                                   "f(midpoint)")))
          (when (or (= midpoint a) (= midpoint b))
            (signal 'cmna-stagnation
                    (list "Bisection interval can no longer be reduced"
                          :method 'cmna-bisection
                          :iteration iteration
                          :a a :b b :midpoint midpoint)))
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
`cmna-default-tolerance' and measures the absolute change between successive
estimates.  MAX-ITERATIONS defaults to `cmna-default-maximum-iterations'.
An exact initial or iterated root is returned immediately.

Signal `cmna-zero-derivative' when DERIVATIVE prevents an update,
`cmna-non-finite-value' for invalid evaluations or estimates,
`cmna-stagnation' when floating-point arithmetic prevents movement before
convergence, and `cmna-maximum-iterations-exceeded' when the iteration budget
is exhausted."
  (unless (functionp function)
    (signal 'wrong-type-argument (list 'functionp function)))
  (unless (functionp derivative)
    (signal 'wrong-type-argument (list 'functionp derivative)))
  (cmna--validate-finite-number guess "guess")
  (setq tolerance
        (cmna--validate-tolerance
         (or tolerance cmna-default-tolerance)))
  (setq max-iterations
        (cmna--validate-maximum-iterations
         (or max-iterations cmna-default-maximum-iterations)))
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
            (signal 'cmna-zero-derivative
                    (list "Derivative is zero at the current estimate"
                          :method 'cmna-newton
                          :iteration iteration
                          :estimate x
                          :function-value fx)))
          (let ((next-x
                 (cmna--ensure-finite-number
                  (- x (/ fx fpx))
                  "Next estimate"
                  (list :method 'cmna-newton
                        :iteration iteration
                        :estimate x))))
            (cond
             ((= next-x x)
              (signal 'cmna-stagnation
                      (list "Newton iteration can no longer advance"
                            :method 'cmna-newton
                            :iteration iteration
                            :estimate x
                            :function-value fx)))
             ((<= (abs (- next-x x)) tolerance)
              (setq result next-x
                    converged t))
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
                              max-iterations)
                      :method 'cmna-newton
                      :iterations iteration
                      :estimate x
                      :function-value fx))))))

(defun cmna-secant (function x0 x1 &optional tolerance max-iterations)
  "Return a root of FUNCTION using secant iteration from X0 and X1.

X0 and X1 must be distinct finite initial estimates.  TOLERANCE defaults to
`cmna-default-tolerance' and measures the absolute change between successive
estimates.  MAX-ITERATIONS defaults to `cmna-default-maximum-iterations'.
An exact initial or iterated root is returned immediately.

Signal `cmna-domain-error' when the initial estimates are identical,
`cmna-zero-denominator' when the secant update is undefined,
`cmna-non-finite-value' for invalid evaluations, denominators, or estimates,
`cmna-stagnation' when floating-point arithmetic prevents movement before
convergence, and `cmna-maximum-iterations-exceeded' when the iteration budget
is exhausted."
  (unless (functionp function)
    (signal 'wrong-type-argument (list 'functionp function)))
  (cmna--validate-finite-number x0 "x0")
  (cmna--validate-finite-number x1 "x1")
  (when (= x0 x1)
    (signal 'cmna-domain-error
            (list "Initial estimates must be distinct" :x0 x0 :x1 x1)))
  (setq tolerance
        (cmna--validate-tolerance
         (or tolerance cmna-default-tolerance)))
  (setq max-iterations
        (cmna--validate-maximum-iterations
         (or max-iterations cmna-default-maximum-iterations)))
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
        (let ((denominator
               (cmna--ensure-finite-number
                (- f1 f0)
                "Secant denominator"
                (list :method 'cmna-secant
                      :iteration iteration
                      :x0 x0 :x1 x1
                      :f0 f0 :f1 f1))))
          (when (zerop denominator)
            (signal 'cmna-zero-denominator
                    (list "Secant denominator is zero"
                          :method 'cmna-secant
                          :iteration iteration
                          :x0 x0 :x1 x1
                          :f0 f0 :f1 f1)))
          (let ((next-x
                 (cmna--ensure-finite-number
                  (- x1 (* f1 (/ (- x1 x0) denominator)))
                  "Next estimate"
                  (list :method 'cmna-secant
                        :iteration iteration
                        :x0 x0 :x1 x1))))
            (cond
             ((= next-x x1)
              (signal 'cmna-stagnation
                      (list "Secant iteration can no longer advance"
                            :method 'cmna-secant
                            :iteration iteration
                            :estimate x1
                            :function-value f1)))
             ((<= (abs (- next-x x1)) tolerance)
              (setq result next-x
                    converged t))
             (t
              (setq x0 x1
                    f0 f1
                    x1 next-x
                    f1 (cmna--checked-function-value function next-x
                                                     "f(x1)"))
              (when (zerop f1)
                (setq result x1
                      converged t))))))
        (setq iteration (1+ iteration)))
      (if converged
          result
        (signal 'cmna-maximum-iterations-exceeded
                (list (format "Secant method did not converge after %d iterations"
                              max-iterations)
                      :method 'cmna-secant
                      :iterations iteration
                      :x0 x0 :x1 x1
                      :f0 f0 :f1 f1)))))))

(provide 'cmna-rootfinding)

;;; cmna-rootfinding.el ends here
