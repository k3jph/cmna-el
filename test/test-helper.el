;;; test-helper.el --- Helpers for CMNA tests -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: BSD-2-Clause

(add-to-list 'load-path
             (file-name-directory (or load-file-name buffer-file-name)))

(require 'cmna)
(require 'ert)
(require 'cmna-test-helpers)

;;; test-helper.el ends here
