;;; cmna-optimization.el --- CMNA Optimization -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 James P. Howard, II
;;
;; Author: James P. Howard, II <jh@jameshoward.us>
;; Maintainer: James P. Howard, II <jh@jameshoward.us>
;; Created: August 14, 2023
;; Modified: August 14, 2023
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

(defun bisection-method (func a b &optional tolerance max-iterations)
  "Find a root of a continuous function F within the interval [A, B] using the
   bisection method.

   F is the function whose root is to be determined.  A and B are endpoints of
   the interval. F(A) and F(B) must have opposite signs; otherwise, the function
   will signal an error.  TOLERANCE is the stopping criterion. The method stops
   when the width of the interval [A, B] becomes less than TOLERANCE.
   MAX-ITERATIONS is the maximum number of iterations allowed to achieve
   convergence.

   Returns the approximate root as a floating-point number.

   Signals an error if:
    - F(A) and F(B) have the same sign, as a root is not guaranteed to exist
      within [A, B].
    - MAX-ITERATIONS is exceeded without finding a root within TOLERANCE.

   Example usage:

      (bisection-method (lambda (x) (- (* x x) 4)) 0 3)"
  (unless tolerance (setq tolerance 1.0e-6))
  (unless max-iterations (setq max-iterations 1e2))
  (let ((fa (funcall func a))
        (fb (funcall func b))
        (iteration 0))
    (unless (> 0 (* fa fb))
      (signal 'cmna-domain-error "Incorrect initial interval [a, b]. Ensure f(a) < 0 and f(b) > 0."))
    (while (and (< max-iterations)
                (> (abs (- b a)) tolerance))
      (setq iteration (1+ iteration))
      (let* ((c (/ (+ a b) 2.0))
             (fc (funcall func c)))
        (if (< 0 (* fa fc))
            (setq a c fa fc)
          (setq b c fb fc))))
    (/ (+ a b) 2.0)))

(provide 'cmna-optimization)

;;; cmna-optimization.el ends here
