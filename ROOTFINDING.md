# Root-Finding Family Contract

This document records the shared mathematical contract for the scalar
root-finding methods implemented in `cmna-el` and `cmna-pkg`.  The two packages
are companion implementations, not source translations.  They agree on the
problem being solved, convergence meaning, important preconditions, and failure
categories while using interfaces and condition mechanisms natural to each
language.

## Included methods

- bisection;
- Newton's method; and
- the secant method.

In Emacs Lisp these are exposed as `cmna-bisection`, `cmna-newton`, and
`cmna-secant`.

## Successful result

Each method returns a scalar approximation to a real root of a caller-supplied
function.  No diagnostic wrapper is returned.  Richer return objects may be
introduced only through a future package-wide decision.

An exact root at an initial endpoint or estimate is returned immediately.  An
exact root encountered during iteration is also returned immediately.

## Convergence

- Bisection converges when the width of the bracketing interval is no greater
  than the requested tolerance.  The returned value is the midpoint of the
  final interval.
- Newton and secant iteration converge when the absolute change between
  successive estimates is no greater than the requested tolerance.
- Every method has a finite maximum iteration count.
- A zero-sized update with a nonzero function value is floating-point
  stagnation, not convergence.

## Preconditions

Public functions require:

- callable function arguments;
- finite scalar endpoints or initial estimates;
- a positive finite tolerance;
- a positive integer iteration limit;
- distinct secant estimates; and
- a valid sign-changing bracket for bisection unless an endpoint is already a
  root.

User-supplied functions and derivatives must continue to return finite numeric
values throughout iteration.

## Failure categories

The family distinguishes three broad concepts.

### Invalid use

Malformed arguments and violated preconditions are rejected before meaningful
iteration where possible.  In Emacs Lisp, type mismatches normally use
`wrong-type-argument`; numerical preconditions such as an invalid bracket use
`cmna-domain-error`.

### Numerical breakdown

A mathematically significant state prevents the next update:

- `cmna-non-finite-value` for a non-finite evaluation, denominator, or estimate;
- `cmna-zero-derivative` for a Newton update with zero derivative; and
- `cmna-zero-denominator` for an undefined secant update.

These inherit from `cmna-numerical-error`.

### Failed convergence

A valid iteration fails to satisfy its convergence rule:

- `cmna-stagnation` when floating-point arithmetic prevents progress; and
- `cmna-maximum-iterations-exceeded` when the iteration budget is exhausted.

These inherit from `cmna-convergence-error`.

Condition data include a human-readable message and, where practical, structured
context such as the method, estimate, interval, iteration, and function value.

## Canonical cross-implementation cases

Both repositories intentionally test the following concepts:

1. all three methods approximate the positive root of `x^2 - 2` under an
   explicitly supplied common tolerance;
2. bisection accepts reversed endpoints and returns endpoint roots;
3. Newton returns an exact initial root and rejects a zero derivative;
4. secant returns either exact initial root and rejects a zero denominator;
5. all methods reject non-finite evaluations;
6. Newton and secant reject floating-point stagnation before accepting a
   zero-sized step as convergence; and
7. all methods visibly fail when their iteration budget is exhausted.

## Deliberate language-specific differences

- Emacs Lisp uses optional positional controls named `tolerance` and
  `max-iterations`; R retains its established `tol` and `m` arguments.
- `cmna-el` uses package condition symbols and condition inheritance;
  `cmna-pkg` uses base-R condition objects with CMNA-specific classes.
- The default controls differ intentionally for compatibility: `cmna-el` uses
  package-wide defaults of `1e-9` and `1000`, while the R functions retain the
  historical book-facing defaults `1e-3` and `100`.  Cross-implementation tests
  supply the same explicit tolerance rather than relying on defaults.

A substantial semantic change in either implementation should trigger review of
this document and the corresponding tests in both repositories.
