;;; cmna-nth-root-test.el --- Tests for CMNA nth roots -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: BSD-2-Clause

(require 'ert)
(require 'cmna-polynomials)

(ert-deftest cmna-nth-root/canonical-positive-roots ()
  (should (< (abs (- (cmna-nth-root 100 2 1e-12) 10.0)) 1e-10))
  (should (< (abs (- (cmna-nth-root 1000 3 1e-12) 10.0)) 1e-10))
  (should (< (abs (- (cmna-nth-root 65536 4 1e-12) 16.0)) 1e-10)))

(ert-deftest cmna-nth-root/zero-and-first-root ()
  (should (= (cmna-nth-root 0 7) 0))
  (should (= (cmna-nth-root -12 1) -12)))

(ert-deftest cmna-nth-root/negative-odd-root ()
  (should (< (abs (- (cmna-nth-root -125 3 1e-12) -5.0)) 1e-10)))

(ert-deftest cmna-nth-root/rejects-negative-even-root ()
  (should-error (cmna-nth-root -16 2) :type 'cmna-domain-error))

(ert-deftest cmna-nth-root/validates-degree-and-controls ()
  (should-error (cmna-nth-root 16 0) :type 'cmna-domain-error)
  (should-error (cmna-nth-root 16 2.5) :type 'cmna-domain-error)
  (should-error (cmna-nth-root 16 "2") :type 'cmna-domain-error)
  (should-error (cmna-nth-root 16 2 0) :type 'cmna-domain-error)
  (should-error (cmna-nth-root 16 2 1e-9 0) :type 'cmna-domain-error))

(ert-deftest cmna-nth-root/validates-radicand ()
  (should-error (cmna-nth-root "16" 2) :type 'wrong-type-argument))

(ert-deftest cmna-nth-root/exposes-iteration-limit ()
  (should-error (cmna-nth-root 2 2 1e-15 1)
                :type 'cmna-maximum-iterations-exceeded))

(provide 'cmna-nth-root-test)

;;; cmna-nth-root-test.el ends here
