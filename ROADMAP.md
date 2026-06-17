# CMNA Emacs Lisp Roadmap

This document explains why `cmna-el` exists, how it relates to CMNA 2.0 and the second edition of *Computational Methods for Numerical Analysis with R*, and the order in which the Emacs Lisp implementation should grow. The companion [architecture document](ARCHITECTURE.md) defines the package boundaries and engineering rules used to carry out this roadmap.

## Purpose

`cmna-el` is a native Emacs Lisp implementation of the numerical methods developed for CMNA. It is not a mechanical translation of the R package and it is not intended to turn Emacs into a competitor to specialized scientific-computing systems.

Its purposes are to:

- provide readable numerical algorithms in a small, expressive Lisp;
- demonstrate that the mathematical ideas in CMNA are independent of one implementation language;
- make useful numerical methods available inside Emacs for experimentation, teaching, and lightweight computation;
- serve as a second implementation against which contracts and edge cases can be checked; and
- develop an idiomatic, tested Emacs Lisp package rather than a collection of disconnected snippets.

The target is a coherent CMNA 2.0 companion library whose scope follows the numerical-analysis curriculum while respecting the strengths and limitations of Emacs Lisp.

## Why we are here

The original CMNA package showed numerical methods directly in R. Rebuilding selected and eventually broad portions of that material in Emacs Lisp creates a useful form of independent verification: the implementation details change, but the mathematics, convergence assumptions, and failure conditions should remain recognizable.

That independence is valuable only if `cmna-el` is engineered deliberately. Dynamic typing, generic arithmetic, Emacs condition handling, package loading, byte compilation, and the absence of R's native vector and matrix conventions create different design pressures. A literal line-by-line port would inherit the wrong abstractions from R while failing to establish clear Lisp interfaces.

The project therefore proceeds family by family. Each family receives:

- a language-native public API;
- explicit argument and numerical validation;
- defined convergence and failure behavior;
- ERT tests covering success and breakdown cases;
- package-level documentation; and
- a semantic comparison with the R implementation where both exist.

## Branch and release policy

This repository uses Git Flow.

- `main` is release-only and represents published, stable versions.
- `develop` is the integration branch and the source of truth for current CMNA 2.0 work.
- Features and maintenance begin from `develop` on `feature/**`, `chore/**`, or another appropriate Git Flow branch.
- Release stabilization occurs on `release/**`.
- Urgent released-version corrections use `hotfix/**` and are reconciled into `develop`.

New development should not be committed directly to `main`.

## Modernization and implementation standard

A numerical method is complete only when it satisfies all of the following.

1. **The mathematical contract is documented.** The docstring states what problem is solved, what assumptions apply, and what the return value means.
2. **The public API is idiomatic Emacs Lisp.** Functions use the `cmna-` prefix, lexical binding, clear required and optional arguments, and stable condition behavior.
3. **Inputs are validated.** Invalid functions, malformed numbers, non-finite values, invalid intervals, impossible dimensions, and nonsensical iteration controls fail before or during the computation as appropriate.
4. **Termination is explicit.** Iterative methods have a finite iteration budget and a documented convergence test.
5. **Numerical breakdown is represented by conditions.** Zero derivatives, zero denominators, non-finite evaluations, stagnation, and exhausted iteration limits are not silent results.
6. **Tests cover nominal and adverse behavior.** ERT tests include known answers, boundaries, invalid inputs, and each documented condition.
7. **The package compiles and loads cleanly.** Eask checks, byte compilation, and the supported Emacs matrix remain green.
8. **Parity is reviewed where relevant.** The implementation agrees mathematically with `cmna-pkg` without copying R-specific interface choices.

## Current position

As of June 2026, `cmna-el` has moved beyond a monolithic experiment and established the initial package architecture.

- Eask manages development dependencies, compilation, and tests.
- CI covers the supported modern Emacs versions, currently Emacs 28 through 30.
- `cmna.el` acts as the package entry point, while numerical code is separated into domain modules.
- Shared defaults, utilities, and condition definitions have been separated from algorithm implementations.
- The root-finding module contains modern implementations of:
  - bisection;
  - Newton's method; and
  - the secant method.
- ERT tests cover convergence and important failure modes.
- Shared test macros now provide consistent approximate floating-point assertions.

The root-finding work is the first vertical slice of the intended architecture. Other modules contain legacy or partial material and require the same methodical review.

## Roadmap

The phases below describe dependency and implementation order rather than fixed dates. A phase is complete when its contracts, tests, documentation, and quality gates are satisfied.

### Phase 0 — Package foundation

**Goal:** make later numerical work predictable and inexpensive to review.

Work includes:

- maintain this roadmap and the architecture document;
- preserve lexical binding in every source and test file;
- keep Eask, byte compilation, ERT, and the Emacs-version CI matrix current;
- define package-wide vocabulary for tolerances, iteration limits, condition symbols, and optional arguments;
- maintain the separation among defaults, utilities, errors, numerical modules, and the package entry point;
- standardize test helpers for approximate values and repeated condition assertions;
- ensure every source file has appropriate package headers, `provide` forms, and dependency declarations; and
- document compatibility and deprecation rules before expanding the public API substantially.

**Exit criteria:** a contributor can add a numerical method by following established module, validation, condition, testing, and documentation patterns.

### Phase 1 — Root finding

**Goal:** complete and stabilize the reference family for iterative scalar algorithms.

Included methods:

- `cmna-bisection`;
- `cmna-newton`; and
- `cmna-secant`.

Remaining family-level work includes:

- review argument names and optional defaults for consistency;
- confirm a common distinction among invalid input, numerical breakdown, and failed convergence;
- ensure every public condition has stable parentage and useful data or messages;
- complete docstring and README examples;
- compare canonical cases with the R implementation; and
- decide whether any optional diagnostic interface is needed before other iterative families copy the current scalar-return pattern.

**Exit criteria:** all three methods expose coherent contracts, have complete condition tests, and serve as the model for later iterative routines.

### Phase 2 — Fundamentals and numerical utilities

**Goal:** establish the small numerical building blocks and examples used throughout the library.

Likely scope includes:

- polynomial evaluation, including naive and Horner forms;
- naive and compensated summation;
- roots and quadratic formulas;
- sequence and sample functions;
- finite-number and approximate-comparison utilities; and
- examples illustrating conditioning, rounding error, and algorithmic complexity.

This phase should keep public instructional algorithms separate from package-private utilities. A Kahan summation implementation, for example, is a public algorithm; a predicate that validates a finite scalar is infrastructure.

**Exit criteria:** fundamental examples are readable, tested, and reusable without turning the utility module into a hidden numerical framework.

### Phase 3 — Data representation and linear algebra

**Goal:** choose and implement coherent conventions for vectors, matrices, and linear systems before adding a large family of algorithms.

This phase begins with an architectural decision on representation. Emacs Lisp offers lists, vectors, and nested combinations, but none should be used inconsistently across public functions.

Likely algorithm sequence:

1. vector validation and norms;
2. row operations;
3. matrix shape and indexing helpers;
4. row-echelon and reduced row-echelon forms;
5. direct solution, determinants, and inverse methods;
6. LU and Cholesky decompositions;
7. Jacobi and Gauss-Seidel iteration;
8. conjugate gradient; and
9. tridiagonal solvers.

Questions to settle include mutability, copying, rectangular matrices, exact versus floating arithmetic, pivoting, singularity tests, symmetry, positive definiteness, and return structures.

**Exit criteria:** all public linear-algebra functions accept and return a documented representation and are tested through residual and reconstruction invariants.

### Phase 4 — Interpolation, differentiation, and integration

**Goal:** implement the function- and sample-based approximation families.

Potential scope includes:

- linear and polynomial interpolation;
- piecewise interpolation and splines;
- Bezier curves;
- finite-difference derivatives;
- midpoint, trapezoid, and Simpson rules;
- Gaussian quadrature;
- adaptive and Romberg integration; and
- Monte Carlo integration where a clear Emacs Lisp use case and reproducible API can be provided.

This phase requires conventions for sequences of sample points, callable functions, interval orientation, recursive limits, and stochastic state.

**Exit criteria:** each approximation routine documents the data it consumes, the approximation it computes, and the numerical or structural conditions under which it fails.

### Phase 5 — Optimization

**Goal:** build a consistent optimization layer using the root-finding family's termination and condition lessons.

Potential scope includes:

- golden-section minimization and maximization;
- gradient ascent and descent;
- line-search variants;
- hill climbing;
- simulated annealing; and
- selected discrete instructional examples.

Deterministic and stochastic methods should not be forced into one misleading interface. Randomized methods require explicit reproducibility support and tests that do not depend on chance.

**Exit criteria:** every optimizer has a defined objective contract, termination rule, failure model, and reproducible test strategy.

### Phase 6 — Differential equations

**Goal:** add initial-value and instructional grid-based solvers after vector and matrix representations are stable.

Likely sequence:

- Euler's method;
- midpoint methods;
- fourth-order Runge-Kutta;
- multistep methods;
- systems of ODEs;
- boundary-value examples; and
- carefully selected one-dimensional PDE demonstrations.

The architecture must define state vectors, time grids, returned trajectories, step-size constraints, and whether solvers accept lists, vectors, or a package-specific structure.

**Exit criteria:** solvers share a coherent state model and are tested against analytic solutions or expected convergence order.

### Phase 7 — User documentation and package release

**Goal:** make the library understandable and releasable as a coherent Emacs package.

Work includes:

- complete package commentary and README usage material;
- provide discoverable examples for each public family;
- generate or maintain an API reference if the project adopts one;
- audit autoloads, package headers, dependencies, and minimum Emacs version;
- run clean byte compilation with warnings treated seriously;
- run the full ERT suite across the supported CI matrix;
- prepare `NEWS.md` and migration notes;
- stabilize on a `release/**` branch; and
- merge and tag an approved release on `main`.

**Exit criteria:** a user can install, load, discover, and correctly use the supported methods without reading the test suite or repository history.

## Coordination with `cmna-pkg`

The R and Emacs Lisp repositories should share mathematical semantics, not source-level identity.

They should agree on:

- the definition of the numerical problem;
- major preconditions;
- convergence and iteration-exhaustion behavior;
- method-specific breakdown states;
- canonical examples; and
- whether edge cases are valid, normalized, or rejected.

They may differ in:

- argument order and optional-argument conventions;
- lists, vectors, matrices, and return containers;
- R conditions versus Emacs Lisp condition symbols;
- documentation systems;
- helper organization; and
- language-specific performance techniques.

A substantial semantic change in one implementation should prompt review of the corresponding method in the other repository. Shared canonical cases may be duplicated intentionally in both test suites so that each repository remains independently runnable.

## Prioritization rules

Choose the next task using the following order of preference:

1. complete a partially modernized family;
2. settle a representation or contract required by several future families;
3. correct a silent numerical failure or ambiguous condition;
4. support material actively being prepared for the second edition;
5. improve package loading, tests, compilation, or CI; and
6. expand breadth only after the current family is internally coherent.

A smaller, complete family is more valuable than a wide set of untested ports.

## Non-goals

`cmna-el` is not intended to:

- compete with optimized scientific-computing environments;
- duplicate every R convenience regardless of its fit with Emacs Lisp;
- introduce a large object system solely to imitate data structures from another language;
- hide textbook algorithms behind macros that obscure their numerical steps;
- promise arbitrary-size or high-performance matrix computation; or
- maintain exact interface parity when that would make either implementation unnatural.

## Maintaining this roadmap

This is a living document on `develop`. Update it when the supported scope, phase order, representation decisions, compatibility policy, or release criteria change. GitHub issues and pull requests should hold individual work items; this document records project-level direction.
