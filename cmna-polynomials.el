;;; cmna-polynomials.el --- CMNA polynomial evaluation -*- lexical-binding: t; -*-
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
;; Polynomial evaluation algorithms for CMNA.
;;
;;; Code:

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

(provide 'cmna-polynomials)

;;; cmna-polynomials.el ends here
