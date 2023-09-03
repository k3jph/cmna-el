;;; cmna-fundamentals.el --- CMNA Fundamentals -*- lexical-binding: t; -*-
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
;;  This is Computationl Methods for Numerical Analysis in
;;  Emacs Lisp.
;;
;;; Code:

(defun sum (x)
  "Compute the sum of a list of numbers.

Arguments:
  X : A list of numerical elements to be summed.

Returns:
  The sum of all numerical elements in the list X.

Example:
  (sum \=(1 2 3))  ; Returns 6

Notes:
  - The function uses tail recursion for efficiency.
  - An empty list returns 0.

Raises:

  - This function does not perform type-checking. Ensure that the list contains
    only numbers."

  (named-let sum-recur ((numbers x)
                        (running-sum 0))
    (if numbers
        (sum-recur (cdr numbers) (+ running-sum (car numbers)))
      (identity running-sum))))

(defun arithmetic-mean (x)
  "Compute the arithmetic mean of a list of numbers.

Arguments:
  X : A list of numerical elements for which the arithmetic mean is to be
      calculated.

Returns:
  The arithmetic mean of all numerical elements in the list X.

Example:
  (arithmetic-mean \=(1 2 3))  ; Returns 2

Notes:

  - The function does not perform type-checking. Ensure that the list contains
    only numbers.
  - An empty list will result in a division-by-zero error.

Raises:
  - Division-by-zero error if the list is empty."
  (let ((count (float (length x))))
    (if (equal count 0.0)
        (signal 'cmna-underflow-error
                (format "Cannot calculate mean of empty list"))
      (/ (sum x) count))))

(provide 'cmna-fundamentals)

;;; cmna-fundamentals.el ends here
