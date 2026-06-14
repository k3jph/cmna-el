;;; cmna-fundamentals-test.el --- Tests for CMNA fundamentals -*- lexical-binding: t; -*-

(require 'ert)
(require 'cmna-errors)
(require 'cmna-fundamentals)
(require 'cmna-utilities)

(ert-deftest cmna-sum/basic ()
  (should (= (cmna-sum '(1 2 3 4)) 10)))

(ert-deftest cmna-sum/empty-list ()
  (should (= (cmna-sum nil) 0)))

(ert-deftest cmna-sum/single-element ()
  (should (= (cmna-sum '(7)) 7)))

(ert-deftest cmna-sum/negative-numbers ()
  (should (= (cmna-sum '(-1 -2 -3)) -6)))

(ert-deftest cmna-sum/floating-point ()
  (should (cmna-float-equal-p (cmna-sum '(1.1 2.1 3.1)) 6.3)))

(ert-deftest cmna-sum/incorrect-argument ()
  (should-error (cmna-sum '(1 2 "3")) :type 'wrong-type-argument))

(ert-deftest cmna-arithmetic-mean/basic ()
  (should (cmna-float-equal-p (cmna-arithmetic-mean '(1 2 3 4)) 2.5)))

(ert-deftest cmna-arithmetic-mean/single-element ()
  (should (cmna-float-equal-p (cmna-arithmetic-mean '(5)) 5.0)))

(ert-deftest cmna-arithmetic-mean/negative-numbers ()
  (should (cmna-float-equal-p (cmna-arithmetic-mean '(-1 -2 -3)) -2.0)))

(ert-deftest cmna-arithmetic-mean/mixed-signs ()
  (should (cmna-float-equal-p (cmna-arithmetic-mean '(4 -2 1 -1)) 0.5)))

(ert-deftest cmna-arithmetic-mean/floating-point ()
  (should (cmna-float-equal-p (cmna-arithmetic-mean '(1.1 2.1 3.1)) 2.1)))

(ert-deftest cmna-arithmetic-mean/empty-list ()
  (should-error (cmna-arithmetic-mean nil) :type 'cmna-domain-error))

(ert-deftest cmna-arithmetic-mean/incorrect-argument ()
  (should-error (cmna-arithmetic-mean '(1 2 "3"))
                :type 'wrong-type-argument))

(provide 'cmna-fundamentals-test)

;;; cmna-fundamentals-test.el ends here
