;;; cmna-rootfinding.el --- CMNA root finding -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 James P. Howard, II
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

(defun newton-method (func func-prime guess &optional tolerance max-iterations)
  "Find an approximate root of FUNC using Newton's method from GUESS."
  (unless tolerance (setq tolerance cmna-default-tolerance))
  (unless max-iterations (setq max-iterations cmna-default-maximum-iterations))
  (named-let newton-method-recur ((guess (float guess))
                                  (iteration 0))
    (when (>= iteration max-iterations)
      (signal 'cmna-maximum-iterations-exceeded
              (format "Newton's method did not converge after %d iterations"
                      max-iterations)))
    (let* ((y (funcall func guess))
           (y-derivative (funcall func-prime guess))
           (next-guess (- guess (/ y y-derivative))))
      (if (cmna-float-equal-p guess next-guess tolerance)
          next-guess
        (newton-method-recur next-guess (1+ iteration))))))

(defun secant-method (func guess-1 guess-2 &optional tolerance max-iterations)
  "Use the secant method to find a root of FUNC."
  (unless tolerance (setq tolerance cmna-default-tolerance))
  (unless max-iterations (setq max-iterations cmna-default-maximum-iterations))
  (when (equal guess-1 guess-2)
    (signal 'cmna-domain-error
            (format "Guess 1 and guess 2 cannot be identical")))
  (named-let secant-method-recur ((guess-1 (float guess-1))
                                  (guess-2 (float guess-2))
                                  (val-guess-1 (funcall func guess-1))
                                  (iteration 0))
    (when (>= iteration max-iterations)
      (signal 'cmna-maximum-iterations-exceeded
              (format "Secant method did not converge after %d iterations"
                      max-iterations)))
    (let* ((val-guess-2 (funcall func guess-2))
           (guess-3 (- guess-2
                       (* val-guess-2
                          (/ (- guess-2 guess-1)
                             (- val-guess-2 val-guess-1))))))
      (if (cmna-float-equal-p guess-2 guess-3 tolerance)
          guess-3
        (secant-method-recur guess-2 guess-3 val-guess-2
                             (1+ iteration))))))

(provide 'cmna-rootfinding)

;;; cmna-rootfinding.el ends here
