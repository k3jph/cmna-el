;;; cmna-errors.el --- CMNA Errors -*- lexical-binding: t; -*-
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
;;  This is Computationl Methods for Numerical Analysis in
;;  Emacs Lisp.
;;
;;; Code:

(define-error 'cmna-error "CMNA error")
(define-error 'cmna-domain-error "CMNA domain error" 'cmna-error)
(define-error 'cmna-range-error "CMNA range error" 'cmna-error)
(define-error 'cmna-maximum-iterations-exceeded "CMNA maximum iterations exceeded" 'cmna-error)
(define-error 'cmna-underflow-error "CMNA underflow error" 'cmna-error)
(define-error 'cmna-overflow-error "CMNA overflow error" 'cmna-error)

(provide 'cmna-errors)

;;; cmna-errors.el ends here
