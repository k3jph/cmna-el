;;; cmna-errors.el --- CMNA errors -*- lexical-binding: t; -*-
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
;; Conditions shared by CMNA numerical algorithms.
;;
;;; Code:

(define-error 'cmna-error "CMNA error")

(define-error 'cmna-domain-error "CMNA domain error" 'cmna-error)
(define-error 'cmna-range-error "CMNA range error" 'cmna-error)

(define-error 'cmna-numerical-error "CMNA numerical breakdown" 'cmna-error)
(define-error 'cmna-non-finite-value "CMNA non-finite value"
  'cmna-numerical-error)
(define-error 'cmna-zero-derivative "CMNA zero derivative"
  'cmna-numerical-error)
(define-error 'cmna-zero-denominator "CMNA zero denominator"
  'cmna-numerical-error)

(define-error 'cmna-convergence-error "CMNA convergence failure" 'cmna-error)
(define-error 'cmna-stagnation "CMNA floating-point stagnation"
  'cmna-convergence-error)
(define-error 'cmna-maximum-iterations-exceeded
  "CMNA maximum iterations exceeded" 'cmna-convergence-error)

(define-error 'cmna-underflow-error "CMNA underflow error"
  'cmna-numerical-error)
(define-error 'cmna-overflow-error "CMNA overflow error"
  'cmna-numerical-error)

(provide 'cmna-errors)

;;; cmna-errors.el ends here
