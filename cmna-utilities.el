;;; cmna-utilities.el --- CMNA utilities -*- lexical-binding: t; -*-
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
;; Shared numerical helpers for CMNA algorithms.
;;
;;; Code:

(require 'cmna-defaults)
(require 'cmna-errors)

(defun cmna--finite-number-p (value)
  "Return non-nil when VALUE is a finite number."
  (and (numberp value)
       (= value value)
       (or (integerp value)
           (< (abs value) 1.0e+INF))))

(defun cmna--validate-finite-number (value label)
  "Return VALUE when it is finite, using LABEL in errors."
  (unless (cmna--finite-number-p value)
    (signal 'wrong-type-argument (list 'numberp value label)))
  value)

(defun cmna--validate-tolerance (tolerance)
  "Return TOLERANCE when it is positive and finite."
  (unless (and (cmna--finite-number-p tolerance) (> tolerance 0))
    (signal 'cmna-domain-error
            '("Tolerance must be a positive finite number")))
  tolerance)

(defun cmna--validate-maximum-iterations (max-iterations)
  "Return MAX-ITERATIONS when it is a positive integer."
  (unless (and (integerp max-iterations) (> max-iterations 0))
    (signal 'cmna-domain-error
            '("Maximum iterations must be a positive integer")))
  max-iterations)

(defun cmna--ensure-finite-number (value label &optional context)
  "Return VALUE when finite, otherwise signal a CMNA condition.

LABEL identifies the numerical value.  CONTEXT, when non-nil, is appended to
the condition data for programmatic inspection."
  (unless (cmna--finite-number-p value)
    (signal 'cmna-non-finite-value
            (append (list (format "%s must be a finite number" label)
                          :label label
                          :value value)
                    context)))
  value)

(defun cmna--checked-function-value (function argument label)
  "Call FUNCTION with ARGUMENT and require a finite result named LABEL."
  (cmna--ensure-finite-number
   (funcall function argument)
   label
   (list :argument argument)))

(defun cmna-float-equal-p (x y &optional tolerance)
  "Return non-nil when X and Y differ by no more than TOLERANCE.

TOLERANCE defaults to `cmna-default-tolerance' and must be positive."
  (setq tolerance (or tolerance cmna-default-tolerance))
  (unless (and (numberp x) (numberp y) (numberp tolerance))
    (signal 'wrong-type-argument '(numberp)))
  (cmna--validate-tolerance tolerance)
  (<= (abs (- x y)) tolerance))

(defun cmna-sequence (from to by)
  "Return a finite numeric sequence from FROM toward TO in steps of BY.

FROM, TO, and BY must be finite numbers.  BY must be nonzero and point toward
TO.  The endpoint is included when reached, allowing for ordinary
floating-point roundoff.  When BY does not divide the interval evenly, the
sequence stops before crossing TO.  Equal endpoints return a one-element list."
  (cmna--validate-finite-number from "from")
  (cmna--validate-finite-number to "to")
  (cmna--validate-finite-number by "by")
  (when (zerop by)
    (signal 'cmna-domain-error '("Increment must be nonzero")))
  (when (or (and (< from to) (< by 0))
            (and (> from to) (> by 0)))
    (signal 'cmna-domain-error '("Increment points away from endpoint")))
  (if (= from to)
      (list from)
    (let* ((roundoff (* 8.0 2.220446049250313e-16
                        (max 1.0 (abs from) (abs to) (abs by))))
           (value from)
           result)
      (if (> by 0)
          (while (<= value (+ to roundoff))
            (when (<= (abs (- value to)) roundoff)
              (setq value to))
            (push value result)
            (setq value (+ value by)))
        (while (>= value (- to roundoff))
          (when (<= (abs (- value to)) roundoff)
            (setq value to))
          (push value result)
          (setq value (+ value by))))
      (nreverse result))))

(provide 'cmna-utilities)

;;; cmna-utilities.el ends here
