# Polynomial Evaluation Contract

This document records the shared conceptual contract for polynomial evaluation
in `cmna-el` and `cmna-pkg`.

## Coefficient order

Both implementations use coefficients in ascending power order:

```text
(a0, a1, a2, ..., an)
```

represents

```text
a0 + a1*x + a2*x^2 + ... + an*x^n
```

For example, `(5, -3, 2)` represents `5 - 3*x + 2*x^2`.

This convention is retained because it is the established public R interface.

## Included methods

The Emacs Lisp package exposes:

- `cmna-polynomial-evaluate-naive`; and
- `cmna-polynomial-evaluate-horner`.

The R package additionally exposes cached-power and recursive-Horner variants.

## Successful result

Emacs Lisp accepts a scalar numeric `x` and a non-empty proper list of numeric
coefficients. Each evaluator returns a scalar numeric value.

A one-element coefficient list represents a constant polynomial.

## Input behavior

Non-numeric evaluation points, empty coefficient lists, non-list coefficient
collections, and non-numeric coefficients signal `wrong-type-argument`.
Non-finite numeric values follow ordinary Emacs Lisp arithmetic.

## Canonical cross-implementation cases

Both repositories intentionally test:

1. the polynomial `5 - 3*x + 2*x^2` at `x = -2, -1, 0, 1, 2`;
2. constant polynomials;
3. empty coefficient rejection;
4. non-numeric input rejection; and
5. equality between direct and Horner evaluation.

## Algorithmic distinction

Naive evaluation mirrors the written polynomial directly and computes each
power independently. Horner evaluation rewrites the same polynomial as nested
multiplication and addition, requiring one multiplication and one addition per
coefficient after initialization.

The two repositories need not expose identical helper variants, but they must
preserve the same coefficient interpretation and canonical results.
