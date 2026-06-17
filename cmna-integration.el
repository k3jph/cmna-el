;;; cmna-integration.el --- CMNA Integration -*- lexical-binding: t; -*-
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
;;  This is Computationl Methods for Numerical Analysis in
;;  Emacs Lisp.
;;
;;; Code:

(defun midpoint-rule (func a b n)
  "Calculates the integral of FUNC from A to B using N intervals with the
  midpoint rule.

  Parameters:
    FUNC: The function to integrate.
    A: The lower limit of integration.
    B: The upper limit of integration.
    N: The number of intervals to use for the calculation.

  Returns:
    The approximate integral of FUNC from A to B.

  Example:
    (midpoint-rule (lambda (x) (* x x)) 0 1 100)"
  (unless (< 0 n)
    (signal 'cmna-domain-error
            (format "Midpoint rule requires a positive number of subintervals")))
  (let ((h (/ (- b a) (* 2.0 n))))
    (named-let midpoint-rule-recur
        ((current-sum 0.0) (iteration 0))
      (if (equal iteration n)
          (* h current-sum 2.0)
        (midpoint-rule-recur
         (+ current-sum (funcall func (+ a (* (1+ (* 2.0 iteration)) h))))
         (1+ iteration))))))

(defun trapezoid-rule (func a b n)
  "Calculates the integral of FUNC from A to B using N intervals with the
  trapezoid rule.

  Parameters:
    FUNC: The function to integrate.
    A: The lower limit of integration.
    B: The upper limit of integration.
    N: The number of intervals to use for the calculation.

  Returns:
    The approximate integral of FUNC from A to B.

  Example:
    (trapezoid-rule (lambda (x) (* x x)) 0 1 100)"
  (unless (< 0 n)
    (signal 'cmna-domain-error
            (format "Trapezoid rule requires a positive number of subintervals")))
  (let ((h (/ (- b a) (float n))))
    (named-let trapezoid-rule-recur
        ((current-sum 0.0)
         (iteration 1)
         (val-lower-bound (funcall func a)))
      (if (> iteration n)
          (/ (* h current-sum) 2)
        (let ((val-upper-bound (funcall func (+ a (* iteration h)))))
          (trapezoid-rule-recur
           (+ current-sum (+ val-lower-bound val-upper-bound))
           (1+ iteration)
           val-upper-bound))))))

(defun simpsons-rule(func a b n)
  "Calculates the integral of FUNC from A to B using N intervals with the
  Simpson's rule.

  Parameters:
    FUNC: The function to integrate.
    A: The lower limit of integration.
    B: The upper limit of integration.
    N: The number of intervals to use for the calculation.

  Returns:
    The approximate integral of FUNC from A to B.

  Example:
    (simpsons-rule (lambda (x) (* x x)) 0 1 100)"
  (unless (< 0 n)
    (signal 'cmna-domain-error
            (format "Simpson's rule requires a positive number of subintervals")))
  (let ((h (/ (- b a) (float n))))
    (named-let simpsons-rule-recur
        ((current-sum 0.0)
         (iteration 1)
         (val-lower-bound (funcall func a)))
      (if (> iteration n)
          (/ (* h current-sum) 6)
        (let ((val-inner-point (funcall func (- (+ a (* iteration h)) (/ h 2))))
              (val-upper-bound (funcall func (+ a (* iteration h)))))
          (simpsons-rule-recur
           (+ current-sum (+ val-lower-bound (* val-inner-point 4.0) val-upper-bound))
           (1+ iteration)
           val-upper-bound))))))

(provide 'cmna-integration)

;;; cmna-integration.el ends here
