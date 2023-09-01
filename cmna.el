;;; cmna.el --- Computational Methods for Numerical Analysis in Emacs Lisp -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 James P. Howard, II
;;
;; Author: James P. Howard, II <jh@jameshoward.us>
;; Maintainer: James P. Howard, II <jh@jameshoward.us>
;; Keywords: tools
;; Homepage: https://github.com/k3jph/cmna-el
;; Package-Requires: ((emacs "24.3"))
;; Package-Version: 0.1.0
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
(require 'cmna-fundamentals)
(require 'cmna-utilities)

(require 'cmna-integration)
(require 'cmna-rootfinding)

(provide 'cmna)

;;; cmna.el ends here
