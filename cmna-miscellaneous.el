;;; cmna-miscellaneous.el --- CMNA Miscellaneous -*- lexical-binding: t; -*-
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

(require 'cmna-errors)

(defun wilkinson-polynomial (x &optional degree)
  (unless degree (setq degree 20))
  (unless (natnump degree)
    (signal 'cmna-domain-error
            (format "Wilkinson's polynomial must have a positive degree")))
  (setq x (float x))
  (named-let wilkinson-recur ((running-product 1.0) (degree degree))
    (if (zerop degree)
        running-product
      (wilkinson-recur (* running-product (- x degree)) (1- degree)))))

(provide 'cmna-miscellaneous)

;;; cmna-miscellaneous.el ends here
