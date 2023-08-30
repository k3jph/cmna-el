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
  "Check for the equality of two floating-point numbers X and Y within a given
TOLERANCE.

This function determines whether two floating-point numbers, X and Y, are equal
to within a specified TOLERANCE. The default tolerance is 1.0e-9 if not
provided.

Arguments:
  X, Y         : Floating-point numbers to compare.
  TOLERANCE    : Optional. A positive floating-point number indicating the
                 maximum allowed difference between X and Y for them to be
                 considered equal. Defaults to 1.0e-9.

Returns:
  A boolean value indicating whether X and Y are equal within the given
  TOLERANCE.


Errors:
  Signals a \=cmna-domain-error\= if the provided TOLERANCE is not greater than
  zero.

Example usage:
  (float-equal? 1.0 1.000000001) ;=> t
  (float-equal? 1.0 1.1)         ;=> nil
  (float-equal? 1.0 1.1 0.2)     ;=> t"
  (unless tolerance (setq tolerance 1.0e-9))
  (when (>= 0 tolerance)
    (signal 'cmna-domain-error "Error tolerance must be greater than 0"))
  (<= (abs (- x y)) tolerance))

;; We will need this in some of our functions
(defun sequence (from to by)
  "Generate a sequence of numbers from FROM to TO with an increment of BY.

This function returns a list of numbers starting from FROM, incrementing by BY,
and ending at a value that is less than or equal to TO. The increment BY can be
positive or negative, but not zero.

Arguments:
  FROM  : The starting number of the sequence.
  TO    : The end boundary for the sequence. The sequence will not contain
          numbers greater than TO for positive BY or numbers smaller than TO for
          negative BY.
  BY    : The increment by which consecutive numbers in the sequence will
          differ. Must be non-zero.

Returns:
  A list containing the generated sequence of numbers.

Errors:
  Signals a \=cmna-domain-error\= in the following cases:
  - Increment BY is negative, but FROM is less than TO.
  - Increment BY is positive, but FROM is greater than TO.
  - Increment BY is zero.

Example usage:
  (sequence 0 5 1)   ;=> (0 1 2 3 4 5)
  (sequence 5 0 -1)  ;=> (5 4 3 2 1 0)
  (sequence 0 5 0.5) ;=> (0 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0)"
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
