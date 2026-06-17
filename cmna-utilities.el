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

(defun cmna-float-equal-p (x y &optional tolerance)
  "Return non-nil when X and Y differ by no more than TOLERANCE.

TOLERANCE defaults to `cmna-default-tolerance' and must be positive."
  (setq tolerance (or tolerance cmna-default-tolerance))
  (unless (and (numberp x) (numberp y) (numberp tolerance))
    (signal 'wrong-type-argument '(numberp)))
  (when (<= tolerance 0)
    (signal 'cmna-domain-error '("Tolerance must be greater than zero")))
  (<= (abs (- x y)) tolerance))

(defun cmna-sequence (from to by)
  "Return a numeric sequence from FROM toward TO in increments of BY.

The endpoint is included when reached exactly.  Signal `cmna-domain-error'
when BY is zero or points away from TO."
  (unless (and (numberp from) (numberp to) (numberp by))
    (signal 'wrong-type-argument '(numberp)))
  (when (= by 0)
    (signal 'cmna-domain-error '("Increment must be nonzero")))
  (when (or (and (< from to) (< by 0))
            (and (> from to) (> by 0)))
    (signal 'cmna-domain-error '("Increment points away from endpoint")))
  (let ((value from)
        result)
    (if (> by 0)
        (while (<= value to)
          (push value result)
          (setq value (+ value by)))
      (while (>= value to)
        (push value result)
        (setq value (+ value by))))
    (nreverse result)))

(provide 'cmna-utilities)

;;; cmna-utilities.el ends here
