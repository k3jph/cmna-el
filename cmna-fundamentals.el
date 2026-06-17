;;; cmna-fundamentals.el --- CMNA fundamentals -*- lexical-binding: t; -*-
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
;; Fundamental numerical operations used by CMNA algorithms.
;;
;;; Code:

(require 'cmna-errors)

(defun cmna--validate-number-list (numbers label)
  "Return NUMBERS when it is a proper list of numbers.

LABEL identifies the argument in errors."
  (unless (listp numbers)
    (signal 'wrong-type-argument (list 'listp numbers label)))
  (dolist (number numbers)
    (unless (numberp number)
      (signal 'wrong-type-argument (list 'numberp number label))))
  numbers)

(defun cmna-naive-sum (numbers)
  "Return the left-to-right sum of NUMBERS.

NUMBERS must be a proper list of numeric values.  The empty list returns 0.
This function intentionally performs direct accumulation and is sensitive to
floating-point ordering and scale."
  (cmna--validate-number-list numbers "numbers")
  (let ((running-sum 0))
    (dolist (number numbers running-sum)
      (setq running-sum (+ running-sum number)))))

(defun cmna-sum (numbers)
  "Return the left-to-right sum of NUMBERS.

This is the historical CMNA summation function and is equivalent to
`cmna-naive-sum'.  NUMBERS must be a proper list of numeric values.  The empty
list returns 0."
  (cmna-naive-sum numbers))

(defun cmna-kahan-sum (numbers)
  "Return the Kahan compensated sum of NUMBERS.

NUMBERS must be a proper list of numeric values.  The empty list returns 0.
Kahan summation maintains a compensation term for low-order information lost
to floating-point rounding during the previous addition."
  (cmna--validate-number-list numbers "numbers")
  (let ((running-sum 0.0)
        (compensation 0.0))
    (dolist (number numbers running-sum)
      (let* ((adjusted (- number compensation))
             (temporary (+ running-sum adjusted)))
        (setq compensation (- (- temporary running-sum) adjusted)
              running-sum temporary)))))

(defun cmna-arithmetic-mean (numbers)
  "Return the arithmetic mean of NUMBERS.

Signal `cmna-domain-error' when NUMBERS is empty."
  (when (null numbers)
    (signal 'cmna-domain-error '("Cannot calculate the mean of an empty list")))
  (/ (float (cmna-sum numbers)) (length numbers)))

(provide 'cmna-fundamentals)

;;; cmna-fundamentals.el ends here
