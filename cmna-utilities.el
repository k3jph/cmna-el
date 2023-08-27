;;; cmna-utilities.el --- CMNA Utilities -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 James P. Howard, II
;;
;; Author: James P. Howard, II <jh@jameshoward.us>
;; Maintainer: James P. Howard, II <jh@jameshoward.us>
;; Created: August 14, 2023
;; Modified: August 14, 2023
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

;; Floating point equality, because sometimes close enough is close enough
(defun float-equal? (x y &optional tolerance)
  "Floating point equality check"
  (unless tolerance (setq tolerance 1.0e-9))
  (when (>= 0 tolerance)
    (signal 'cmna-domain-error "Error tolerance must be greater than 0"))
  (<= (abs (- x y)) tolerance))

;; We will need this in some of our functions
(defun sequence (from to by)
  "Generate a sequence of numbers"
  (when (and (< from to) (< by 0))
    (signal 'cmna-domain-error "Increment is negative but 'from' is less than 'to'."))
  (when (and (> from to) (> by 0))
    (signal 'cmna-domain-error "Increment is positive but 'from' is greater than 'to'."))
  (when (equal by 0)
    (signal 'cmna-domain-error "Increment must be greater than zero"))
  (let ((seq (list from)))
    (dotimes
        (i (/ (- to from) by))
      (push (+ from (* by (+ 1 i))) seq))
    (nreverse seq)))

(provide 'cmna-utilities)

;;; cmna-utilities.el ends here
