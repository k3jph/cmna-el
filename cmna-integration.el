;;; cmna-integration.el --- CMNA Integration -*- lexical-binding: t; -*-
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
    (midpoint-rule-tail-recursive (lambda (x) (* x x)) 0 1 100)"
  (let ((h (/ (- b a) (float n))))
    (named-let midpoint-rule-recur
        ((current-sum 0.0) (iteration 0))
      (if (>= iteration n)
          (* h current-sum)
        (midpoint-rule-recur
         (+ current-sum (funcall func (+ a (* iteration h))))
         (1+ iteration))))))


(provide 'cmna-integration)

;;; cmna-integration.el ends here
