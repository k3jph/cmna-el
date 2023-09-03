;;; cmna-miscellaneous-test.el --- Tests for CMNA Miscellaneous -*- lexical-binding: t; -*-

(require 'cmna-miscellaneous)
(require 'cmna-utilities)

(ert-deftest wilkinson-polynomial/degree-zero ()
  "Test wilkinson-polynomial with zero degree"
  (should (float-equal? (wilkinson-polynomial 1 0) 1)))

(ert-deftest wilkinson-polynomial/degree-one ()
  "Test wilkinson-polynomial with degree 1"
  (should (float-equal? (wilkinson-polynomial 1) 0)))

(ert-deftest wilkinson-polynomial/degree-two ()
  "Test wilkinson-polynomial with degree 2"
  (should (float-equal? (wilkinson-polynomial float-pi 2) 2.444826440319978)))

(ert-deftest wilkinson-polynomial/degree-three ()
  "Test wilkinson-polynomial with degree 3"
  (should (float-equal? (wilkinson-polynomial 8 3) 210)))

(ert-deftest wilkinson-polynomial/degree-default ()
  "Test wilkinson-polynomial with default degree"
  (should (float-equal? (wilkinson-polynomial 1) 0)))

(ert-deftest wilkinson-polynomial/degree-negative ()
  "Test wilkinson-polynomial with negative degree"
  (should-error (wilkinson-polynomial 1 -1) :type 'cmna-domain-error))

(provide 'cmna-miscellaneous-test)

;;; cmna-miscellaneous-test.el ends here
