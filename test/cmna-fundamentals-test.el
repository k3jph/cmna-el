;;; cmna-fundamentals-test.el --- Tests for CMNA fundamentals -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: BSD-2-Clause

(require 'ert)
(require 'cmna-errors)
(require 'cmna-fundamentals)
(require 'cmna-utilities)

(ert-deftest cmna-naive-sum/basic ()
  (should (= (cmna-naive-sum '(1 2 3 4)) 10)))

(ert-deftest cmna-naive-sum/empty-list ()
  (should (= (cmna-naive-sum nil) 0)))

(ert-deftest cmna-naive-sum/single-element ()
  (should (= (cmna-naive-sum '(7)) 7)))

(ert-deftest cmna-naive-sum/negative-numbers ()
  (should (= (cmna-naive-sum '(-1 -2 -3)) -6)))

(ert-deftest cmna-naive-sum/floating-point ()
  (should (cmna-float-equal-p (cmna-naive-sum '(1.1 2.1 3.1)) 6.3)))

(ert-deftest cmna-naive-sum/incorrect-argument ()
  (should-error (cmna-naive-sum '(1 2 "3")) :type 'wrong-type-argument)
  (should-error (cmna-naive-sum [1 2 3]) :type 'wrong-type-argument))

(ert-deftest cmna-naive-sum/is-intentionally-left-to-right ()
  (let ((numbers (append (list 1.0)
                         (make-list 1000 1e-16)
                         (list -1.0))))
    (should (= (cmna-naive-sum numbers) 0.0))
    (should (> (cmna-kahan-sum numbers) (cmna-naive-sum numbers)))))

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

(ert-deftest cmna-kahan-sum/basic ()
  (should (= (cmna-kahan-sum '(1 2 3 4)) 10.0)))

(ert-deftest cmna-kahan-sum/empty-list ()
  (should (= (cmna-kahan-sum nil) 0.0)))

(ert-deftest cmna-kahan-sum/single-element ()
  (should (= (cmna-kahan-sum '(7)) 7.0)))

(ert-deftest cmna-kahan-sum/incorrect-argument ()
  (should-error (cmna-kahan-sum '(1 2 "3")) :type 'wrong-type-argument)
  (should-error (cmna-kahan-sum [1 2 3]) :type 'wrong-type-argument))

(ert-deftest cmna-kahan-sum/recovers-low-order-additions ()
  (let ((numbers (append (list 1.0)
                         (make-list 1000 1e-16)
                         (list -1.0))))
    (cmna-should-float= (cmna-kahan-sum numbers) 1e-13 1e-15)
    (should (< (abs (- (cmna-kahan-sum numbers) 1e-13))
               (abs (- (cmna-naive-sum numbers) 1e-13))))))

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

(ert-deftest cmna-fibonacci/zero-based-indexing ()
  (should (= (cmna-fibonacci 0) 0))
  (should (= (cmna-fibonacci 1) 1))
  (should (= (cmna-fibonacci 2) 1))
  (should (= (cmna-fibonacci 10) 55)))

(ert-deftest cmna-fibonacci/uses-exact-bignums ()
  (should (= (cmna-fibonacci 100) 354224848179261915075)))

(ert-deftest cmna-fibonacci/rejects-invalid-indices ()
  (should-error (cmna-fibonacci -1) :type 'cmna-domain-error)
  (should-error (cmna-fibonacci 1.5) :type 'cmna-domain-error)
  (should-error (cmna-fibonacci "10") :type 'cmna-domain-error))

(provide 'cmna-fundamentals-test)

;;; cmna-fundamentals-test.el ends here
