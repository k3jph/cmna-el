;;; cmna-polynomials.el --- CMNA polynomial methods -*- lexical-binding: t; -*-
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
;; Polynomial evaluation, real quadratic roots, and real nth roots for CMNA.
;;
;;; Code:

(require 'cmna-errors)
(require 'cmna-utilities)

(defun cmna--validate-polynomial-input (x coefficients)
  "Validate scalar X and ascending-power COEFFICIENTS."
  (unless (numberp x)
    (signal 'wrong-type-argument (list 'numberp x "x")))
  (unless (and (listp coefficients) coefficients)
    (signal 'wrong-type-argument
            (list 'consp coefficients "coefficients")))
  (dolist (coefficient coefficients)
    (unless (numberp coefficient)
      (signal 'wrong-type-argument
              (list 'numberp coefficient "coefficients")))))

(defun cmna-polynomial-evaluate-naive (x coefficients)
  "Evaluate a polynomial at X by direct powers.

COEFFICIENTS is a non-empty proper list in ascending power order.  Thus
`(5 -3 2)' represents 5 - 3x + 2x^2."
  (cmna--validate-polynomial-input x coefficients)
  (let ((degree 0)
        (result 0))
    (dolist (coefficient coefficients result)
      (setq result (+ result (* coefficient (expt x degree)))
            degree (1+ degree)))))

(defun cmna-polynomial-evaluate-horner (x coefficients)
  "Evaluate a polynomial at X using Horner's rule.

COEFFICIENTS is a non-empty proper list in ascending power order.  Thus
`(5 -3 2)' represents 5 - 3x + 2x^2."
  (cmna--validate-polynomial-input x coefficients)
  (let ((result 0))
    (dolist (coefficient (reverse coefficients) result)
      (setq result (+ coefficient (* x result))))))

(defun cmna--quadratic-discriminant (a b c)
  "Validate A, B, and C and return the real quadratic discriminant."
  (cmna--validate-finite-number a "a")
  (cmna--validate-finite-number b "b")
  (cmna--validate-finite-number c "c")
  (when (zerop a)
    (signal 'cmna-domain-error
            (list "a must be nonzero for a quadratic equation"
                  :a a :b b :c c)))
  (let ((discriminant (- (* b b) (* 4 a c))))
    (when (< discriminant 0)
      (signal 'cmna-domain-error
              (list "Quadratic equation has no real roots"
                    :a a :b b :c c
                    :discriminant discriminant)))
    discriminant))

(defun cmna-quadratic-roots (a b c)
  "Return the real roots of A*x^2 + B*x + C using the textbook formula.

Return a two-element list in ascending numeric order.  A repeated root appears
twice.  Signal `cmna-domain-error' when A is zero or the discriminant is
negative."
  (let* ((discriminant (cmna--quadratic-discriminant a b c))
         (root-discriminant (sqrt discriminant))
         (denominator (* 2.0 a))
         (root1 (/ (- (- b) root-discriminant) denominator))
         (root2 (/ (+ (- b) root-discriminant) denominator)))
    (if (<= root1 root2)
        (list root1 root2)
      (list root2 root1))))

(defun cmna-quadratic-roots-stable (a b c)
  "Return real roots of A*x^2 + B*x + C using a stable formulation.

Return a two-element list in ascending numeric order.  A repeated root appears
twice.  The first root is formed to avoid catastrophic cancellation and the
second uses the product-of-roots identity when possible.  Signal
`cmna-domain-error' when A is zero or the discriminant is negative."
  (let* ((discriminant (cmna--quadratic-discriminant a b c))
         (root-discriminant (sqrt discriminant)))
    (if (zerop root-discriminant)
        (let ((root (/ (- b) (* 2.0 a))))
          (list root root))
      (let* ((sign-b (if (< b 0) -1.0 1.0))
             (q (* -0.5 (+ b (* sign-b root-discriminant))))
             (root1 (/ q a))
             (root2 (if (zerop q)
                        (/ (- b) a)
                      (/ c q))))
        (if (<= root1 root2)
            (list root1 root2)
          (list root2 root1))))))

(defun cmna-nth-root (radicand degree &optional tolerance max-iterations)
  "Return the real DEGREE-th root of RADICAND by Newton iteration.

DEGREE must be a positive integer.  Negative RADICAND values are accepted only
when DEGREE is odd.  TOLERANCE and MAX-ITERATIONS default to the package-wide
CMNA settings.  Signal CMNA numerical or convergence conditions for non-finite
intermediate values, stagnation, and exhausted iteration limits."
  (setq tolerance (or tolerance cmna-default-tolerance)
        max-iterations (or max-iterations cmna-default-maximum-iterations))
  (cmna--validate-finite-number radicand "radicand")
  (unless (and (integerp degree) (> degree 0))
    (signal 'cmna-domain-error
            (list "Degree must be a positive integer" :degree degree)))
  (cmna--validate-tolerance tolerance)
  (cmna--validate-maximum-iterations max-iterations)
  (when (and (< radicand 0) (zerop (% degree 2)))
    (signal 'cmna-domain-error
            (list "Negative radicands require an odd degree"
                  :radicand radicand :degree degree)))
  (cond
   ((zerop radicand) 0)
   ((= degree 1) radicand)
   (t
    (let* ((sign-result (if (< radicand 0) -1.0 1.0))
           (target (abs (float radicand)))
           (estimate (if (>= target 1.0) (/ target degree) 1.0))
           (scale (max 1.0 target))
           (iteration 0)
           next-estimate
           residual)
      (catch 'converged
        (while (< iteration max-iterations)
          (setq iteration (1+ iteration))
          (let ((denominator
                 (cmna--ensure-finite-number
                  (expt estimate (1- degree))
                  "nth-root denominator"
                  (list :iteration iteration :estimate estimate))))
            (when (zerop denominator)
              (signal 'cmna-zero-denominator
                      (list "Nth-root iteration encountered a zero denominator"
                            :iteration iteration :estimate estimate)))
            (setq next-estimate
                  (cmna--ensure-finite-number
                   (/ (+ (* (1- degree) estimate)
                         (/ target denominator))
                      degree)
                   "nth-root estimate"
                   (list :iteration iteration))))
          (setq residual
                (cmna--ensure-finite-number
                 (abs (- (expt next-estimate degree) target))
                 "nth-root residual"
                 (list :iteration iteration :estimate next-estimate)))
          (when (<= residual (* tolerance scale))
            (throw 'converged (* sign-result next-estimate)))
          (when (= next-estimate estimate)
            (signal 'cmna-stagnation
                    (list "Nth-root iteration stagnated before convergence"
                          :iteration iteration
                          :estimate estimate
                          :residual residual)))
          (setq estimate next-estimate))
        (signal 'cmna-maximum-iterations-exceeded
                (list "Nth-root iteration exceeded maximum iterations"
                      :iterations max-iterations
                      :estimate (* sign-result estimate))))))))

(provide 'cmna-polynomials)

;;; cmna-polynomials.el ends here
