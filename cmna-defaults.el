;;; cmna-defaults.el --- CMNA defaults -*- lexical-binding: t; -*-
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
;; Default values shared by CMNA numerical methods.
;;
;;; Code:

(defgroup cmna nil
  "Computational Methods for Numerical Analysis in Emacs Lisp."
  :group 'applications)

(defcustom cmna-default-tolerance 1e-9
  "Default numerical tolerance used by CMNA algorithms."
  :type 'number
  :group 'cmna)

(defcustom cmna-default-maximum-iterations 1000
  "Default maximum iteration count used by CMNA algorithms."
  :type 'integer
  :group 'cmna)

(provide 'cmna-defaults)

;;; cmna-defaults.el ends here
