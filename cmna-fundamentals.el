;;; cmna-fundamentals.el --- CMNA fundamentals -*- lexical-binding: t; -*-
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
;; Fundamental numerical operations used by CMNA algorithms.
;;
;;; Code:

(require 'cmna-errors)

(defun cmna-sum (numbers)
  "Return the sum of NUMBERS.

NUMBERS must be a list of numeric values.  The empty list returns 0."
  (let ((running-sum 0))
    (dolist (number numbers running-sum)
      (unless (numberp number)
        (signal 'wrong-type-argument (list 'numberp number)))
      (setq running-sum (+ running-sum number)))))

(defun cmna-arithmetic-mean (numbers)
  "Return the arithmetic mean of NUMBERS.

Signal `cmna-domain-error' when NUMBERS is empty."
  (when (null numbers)
    (signal 'cmna-domain-error '("Cannot calculate the mean of an empty list")))
  (/ (float (cmna-sum numbers)) (length numbers)))

(provide 'cmna-fundamentals)

;;; cmna-fundamentals.el ends here
