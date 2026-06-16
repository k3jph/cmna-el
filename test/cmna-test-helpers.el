;;; cmna-test-helpers.el --- Test helpers for CMNA -*- lexical-binding: t; -*-

(require 'ert)
(require 'cmna-defaults)
(require 'cmna-utilities)

(defmacro cmna-should-float= (actual expected &optional tolerance)
  "Assert that ACTUAL and EXPECTED are approximately equal.

TOLERANCE defaults to `cmna-default-tolerance'."
  `(should (cmna-float-equal-p ,actual ,expected
                               ,(or tolerance 'cmna-default-tolerance))))

(defmacro cmna-should-not-float= (actual expected &optional tolerance)
  "Assert that ACTUAL and EXPECTED are not approximately equal.

TOLERANCE defaults to `cmna-default-tolerance'."
  `(should-not (cmna-float-equal-p ,actual ,expected
                                   ,(or tolerance 'cmna-default-tolerance))))

(provide 'cmna-test-helpers)

;;; cmna-test-helpers.el ends here
