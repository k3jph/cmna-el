# Summation Family Contract

This document records the shared mathematical contract for the summation methods
implemented in `cmna-el` and `cmna-pkg`. The two packages are companion
implementations, not source translations. They agree on the numerical ideas and
canonical cases while retaining language-native names, data structures, and
condition mechanisms.

## Included methods

In Emacs Lisp, the summation family includes:

- `cmna-sum` — the historical left-to-right CMNA summation function;
- `cmna-naive-sum` — explicit left-to-right summation; and
- `cmna-kahan-sum` — Kahan compensated summation.

`cmna-sum` is retained as the established public name and is equivalent to
`cmna-naive-sum`.

## Successful result

Each method returns a scalar sum.

The empty list returns zero. A single-element list returns that single value.

## Input contract

The Emacs Lisp implementation accepts proper lists whose elements are numbers.
Non-list inputs and lists containing non-numeric elements signal
`wrong-type-argument`.

Numeric values follow ordinary Emacs Lisp arithmetic. No diagnostic wrapper is
returned.

## Algorithmic distinction

`cmna-naive-sum` is intentionally direct: it adds values from left to right and
is therefore sensitive to the order and scale of partial sums.

`cmna-kahan-sum` maintains a compensation term. The compensation tracks
low-order information lost during the previous addition and reinserts it into
subsequent steps.

## Canonical cross-implementation cases

Both repositories intentionally test the following concepts:

1. ordinary numeric collections produce the expected scalar sum;
2. empty input returns zero;
3. single-element input returns that element;
4. non-numeric input is rejected; and
5. a small-correction example demonstrates that compensated summation can retain
   low-order information lost by naive left-to-right summation.

The canonical compensated-summation example is:

```text
1, followed by one thousand copies of 1e-16, followed by -1
```

The exact mathematical sum is `1e-13`. Left-to-right summation loses the small
increments after the leading `1`; Kahan summation recovers them to useful
accuracy.

## Deliberate language-specific differences

- Emacs Lisp uses the `cmna-` namespace and exposes `cmna-sum`,
  `cmna-naive-sum`, and `cmna-kahan-sum`.
- R preserves the historical public names `naivesum()`, `kahansum()`, and
  `pwisesum()`.
- Emacs Lisp accepts proper lists of numbers; R accepts numeric vectors and
  `NULL`.
- R includes `pwisesum()` as a recursive pairwise summation example. The Emacs
  Lisp companion implementation does not yet expose a pairwise summation method.
- Neither implementation returns diagnostic wrappers.

A substantial semantic change in either implementation should trigger review of
this document and the corresponding tests in both repositories.
