# CMNA Emacs Lisp Architecture

This document defines the architecture for `cmna-el` as it evolves on `develop`. It establishes module boundaries, dependency direction, public API rules, numerical behavior, condition handling, testing, documentation, and release controls. The companion [roadmap](ROADMAP.md) explains the purpose and sequencing of the work.

## 1. Architectural goals

`cmna-el` is guided by six goals.

1. **Readable numerical implementations.** The structure of an algorithm should remain visible to a reader learning the method.
2. **Idiomatic Emacs Lisp.** The package should use normal Emacs Lisp loading, namespacing, conditions, docstrings, lexical binding, and testing conventions.
3. **Explicit numerical contracts.** Public functions should define valid input, convergence, return values, and failure behavior.
4. **Small, stable layers.** Defaults, utilities, conditions, algorithm families, and tests should remain distinct.
5. **Incremental extensibility.** New numerical families should fit the architecture without requiring a rewrite of existing modules.
6. **Semantic companionship with R.** Shared methods should agree mathematically with `cmna-pkg` while retaining language-native interfaces.

The architecture intentionally rejects both extremes: a single monolithic file of textbook snippets and an elaborate framework that hides simple algorithms behind infrastructure.

## 2. Runtime and audience

The package runs inside Emacs and targets users who want to inspect, experiment with, or lightly apply numerical methods without leaving Emacs Lisp. It also supports maintainers using the second implementation to challenge assumptions made in the R code.

The supported baseline is modern Emacs with lexical binding, currently exercised across Emacs 28 through 30. Compatibility policy should be reviewed at release boundaries rather than changed casually inside individual features.

`cmna-el` assumes ordinary Emacs Lisp numeric types and functions. It does not promise arbitrary precision, BLAS-backed arrays, or production-scale scientific performance unless a future architectural decision explicitly introduces such a layer.

## 3. Repository structure

The current and target structure separates package entry, cross-cutting support, numerical domains, and tests.

```text
cmna-el/
├── cmna.el                       # public package entry point
├── cmna-defaults.el              # shared default values
├── cmna-errors.el                # condition hierarchy
├── cmna-utilities.el             # small package-wide helpers
├── cmna-fundamentals.el          # elementary numerical methods
├── cmna-rootfinding.el           # scalar root-finding methods
├── cmna-integration.el           # numerical integration
├── cmna-miscellaneous.el         # legacy/transition material to classify
├── ...                           # future domain modules
├── Eask                          # development and package tooling
├── ROADMAP.md
├── ARCHITECTURE.md
├── README.md
└── test/
    ├── test-helper.el
    ├── cmna-test-helpers.el
    └── *-test.el
```

The exact set of numerical modules will grow, but the separation of responsibilities should remain stable.

`cmna-miscellaneous.el` is treated as a transitional module, not a permanent destination for unrelated algorithms. As methods are modernized, they should move into a coherent numerical domain when one exists.

## 4. Module layers

### 4.1 Package entry point: `cmna.el`

`cmna.el` is the supported entry point for users.

It should:

- contain package metadata and high-level commentary;
- require the public domain modules that constitute the installed package;
- avoid implementing substantial numerical algorithms itself;
- avoid defining duplicate aliases for every public function unless compatibility requires them; and
- provide the `cmna` feature.

Requiring `cmna` should make the documented public API available. Requiring an individual domain feature may remain supported for users who want a narrower load, provided dependency declarations are complete.

### 4.2 Defaults: `cmna-defaults.el`

This module owns package-wide default values such as the default numerical tolerance or default iteration limit.

Rules:

- defaults must have clear names with the `cmna-` prefix;
- a default should be shared only when it has the same semantic meaning across methods;
- changing a default is an API change and requires tests and release notes;
- defaults should not become mutable hidden state during an algorithm; and
- method-specific constants belong in their domain modules unless they are genuinely package-wide.

A single numerical tolerance is convenient only if its meaning is documented. Algorithms may need method-specific criteria even when they share the same default magnitude.

### 4.3 Conditions: `cmna-errors.el`

This module defines the condition hierarchy used by public numerical functions.

The hierarchy should distinguish at least three concepts:

1. **invalid use** — malformed arguments or violated preconditions detectable before meaningful computation;
2. **numerical breakdown** — a mathematically significant state that prevents the method from continuing, such as a zero derivative or denominator; and
3. **failed convergence** — a valid iteration that exhausts its budget or stagnates before satisfying the convergence contract.

Domain-specific conditions may inherit from broader CMNA conditions. The hierarchy should be shallow enough to understand and specific enough for callers and tests to handle meaningful categories.

Conditions should include useful messages and, when practical, structured data describing the relevant argument, estimate, iteration, or residual. Callers should not need to parse prose to distinguish condition types.

### 4.4 Utilities: `cmna-utilities.el`

This module contains small, stable helpers used across multiple numerical domains.

Appropriate responsibilities include:

- finite-number predicates;
- validation of positive tolerances and iteration counts;
- approximate floating-point comparison;
- common argument-normalization helpers; and
- narrowly scoped helpers for constructing or signaling package conditions.

It should not become a second implementation layer containing hidden algorithms. A helper belongs here only when it expresses a package-wide concept and has users in more than one domain or is clearly foundational.

Internal helper names still require the `cmna-` prefix because Emacs Lisp has a global symbol namespace. Internal status should be communicated through naming, documentation, and lack of autoload exposure rather than an unprefixed symbol.

### 4.5 Numerical domain modules

Each domain module owns a coherent family of algorithms and its domain-private helpers.

Examples include:

- fundamentals;
- root finding;
- linear algebra;
- interpolation;
- differentiation;
- integration;
- optimization;
- ordinary differential equations; and
- partial differential equations.

A domain module may depend on defaults, errors, and utilities. It should not depend on an unrelated numerical domain unless the dependency is mathematically intrinsic and documented.

## 5. Dependency direction

The normal dependency graph is:

```text
cmna.el
  └── numerical domain modules
        ├── cmna-defaults.el
        ├── cmna-errors.el
        └── cmna-utilities.el
              ├── cmna-defaults.el   # only when a utility requires a shared default
              └── cmna-errors.el     # only for common validation signaling
```

Tests depend on the package and test helpers, never the reverse.

Rules:

- `cmna-defaults.el` should have no numerical-domain dependencies;
- `cmna-errors.el` should have no numerical-domain dependencies;
- `cmna-utilities.el` must not call public algorithms;
- numerical modules must not form circular `require` relationships;
- `cmna.el` coordinates loading but contains no low-level behavior needed by its dependencies; and
- test-only helpers remain under `test/` and are not required by production files.

## 6. Source-file conventions

Every source file should:

- enable lexical binding in its file-local header;
- use the `cmna-` prefix for externally interned symbols;
- contain a standard commentary section describing its responsibility;
- explicitly `require` the features it uses;
- define public functions before private implementation detail when that aids readability;
- end with a matching `provide` form; and
- byte-compile without avoidable warnings.

Public functions should have complete docstrings. Internal helpers should also have docstrings when their contract or numerical role is not obvious.

Macros should be used when macro semantics are actually needed. They should not be introduced merely to shorten algorithm code or conceal repeated numerical steps.

## 7. Public API design

### 7.1 Namespacing

All public functions, variables, constants, condition symbols, and customization symbols use the `cmna-` prefix.

Function names should describe the mathematical method rather than the implementation file. Existing names such as `cmna-bisection`, `cmna-newton`, and `cmna-secant` establish the preferred style.

### 7.2 Required and optional arguments

Required arguments should represent the minimum mathematical problem. Optional arguments should control behavior with sensible package defaults.

For iterative methods, the package should converge on a consistent pattern for:

- tolerance;
- maximum iterations;
- initial estimates or brackets; and
- optional diagnostics, if diagnostics are later adopted.

Emacs Lisp's `&optional` and `&key` conventions should be chosen deliberately. Positional optional arguments are concise for small stable APIs; keyword arguments may be preferable once a method has several independent controls. A package-wide transition to keywords would be an architectural and compatibility decision, not a local style change.

### 7.3 Validation

Dynamic typing makes boundary validation essential.

Public functions should validate, as relevant:

- callable arguments satisfy `functionp`;
- scalar numeric values satisfy the expected numeric and finite predicates;
- tolerances are positive and finite;
- iteration limits are positive integers;
- interval endpoints and initial estimates are valid;
- list or vector structures have compatible lengths and shapes;
- user functions continue to return valid numeric values throughout iteration; and
- domain-specific assumptions such as bracketing, symmetry, or monotonic ordering hold.

Validation should produce CMNA conditions rather than incidental low-level errors wherever the package can provide better context.

### 7.4 Return values

Return the simplest language-native value that fully represents the successful result.

- Scalar algorithms return numbers.
- Several intrinsic outputs may be returned as a documented plist, alist, vector, or structure.
- Sequence-producing methods should choose lists or vectors consistently within a domain.
- Matrix and trajectory representations require package-level decisions before broad implementation.

The package should not return one shape on ordinary success and a different undocumented shape on edge-case success.

### 7.5 Compatibility

Public API changes should be handled deliberately.

- Correcting a bug does not require preserving the bug.
- Renames should normally provide aliases and obsolete declarations for an appropriate period.
- Signature and return-shape changes require release notes.
- Condition hierarchy changes require care because callers may use `condition-case`.
- Shared defaults are public behavior even when users do not pass them explicitly.

## 8. Numerical behavior

### 8.1 Determinism and side effects

Numerical functions should be deterministic for fixed inputs unless randomness is part of the documented method. They should not modify buffers, global variables, user options, or input sequences unexpectedly.

When an implementation uses mutable vectors or lists internally, it should copy caller-owned data unless destructive behavior is explicitly documented in the function name and contract. The default CMNA API should be non-destructive.

Randomized methods must expose a reproducible strategy compatible with Emacs Lisp's random facilities and must not make tests probabilistic.

### 8.2 Finite numbers

Emacs Lisp numerical behavior varies across integer and floating-point operations. Public methods should define when integers are accepted, when coercion to floating point occurs, and which intermediate values must be finite.

Non-finite function evaluations or updates should signal a specific numerical condition near the point of origin rather than producing an obscure later failure.

### 8.3 Convergence contracts

Every iterative method requires:

- a documented convergence measure;
- a finite maximum iteration count;
- immediate success when the initial state already meets the problem;
- detection of method-specific breakdown;
- detection of floating-point stagnation; and
- a failed-convergence condition on exhaustion.

A method must not return the most recent estimate as successful merely because the loop ended.

### 8.4 Floating-point comparison

Approximate comparison is contextual. `cmna-float-equal-p` and the shared ERT macros provide a consistent primitive, but tests and algorithms should choose tolerances appropriate to the method and scale.

Where scale matters, a future utility may combine absolute and relative tolerances. Such a change should be made package-wide and accompanied by parity review with the R implementation.

### 8.5 Stagnation and representability

Iterative methods should detect when arithmetic can no longer change the state meaningfully, for example:

- a bisection midpoint equals an endpoint;
- a Newton or secant update equals the current estimate;
- a denominator is zero or numerically unusable; or
- a residual is non-finite.

Stagnation counts as success only when the documented convergence criterion is already satisfied. Otherwise it signals a numerical condition.

## 9. Data representation strategy

Scalar methods can be implemented without a package-wide container design. Linear algebra, interpolation grids, ODE systems, and PDE examples cannot.

Before broad work in those domains, the project must decide:

- whether public vectors are Emacs vectors, lists, or accepted in both forms;
- the canonical matrix representation;
- whether functions preserve the caller's sequence type;
- whether indexing is hidden behind helpers or exposed through native sequence operations;
- how rectangular-shape validation works;
- whether outputs are immutable by convention; and
- the representation of trajectories and grids.

Until those decisions are recorded, new public APIs should avoid inventing local matrix or trajectory formats that later become compatibility obligations.

A likely direction is to accept a narrow, clearly documented representation for each domain and convert once at the boundary rather than supporting every sequence combination throughout an algorithm. The final choice requires an explicit architectural decision and tests.

## 10. Condition architecture

The package should use `define-error` to create stable condition symbols with meaningful inheritance.

A conceptual hierarchy may include:

```text
error
└── cmna-error
    ├── cmna-invalid-argument
    ├── cmna-numerical-error
    │   ├── cmna-non-finite-value
    │   ├── cmna-zero-denominator
    │   ├── cmna-zero-derivative
    │   └── cmna-stagnation
    └── cmna-convergence-error
        └── cmna-iteration-limit
```

The exact existing names remain authoritative until changed deliberately. The important architecture is the distinction among misuse, numerical breakdown, and failed convergence.

Signaling code should preserve useful context. Tests should assert condition symbols and relevant data rather than only matching complete message text.

## 11. Testing architecture

The test suite uses ERT and is organized by production domain.

### 11.1 Test bootstrap

`test/test-helper.el` loads the package and shared test support. Production modules must never require it.

### 11.2 Shared test helpers

`test/cmna-test-helpers.el` owns test-only abstractions such as:

- `cmna-should-float=`; and
- `cmna-should-not-float=`.

Additional helpers are appropriate when they make numerical intent clearer, such as asserting a condition type with stable data. They should not grow into an alternate implementation of production logic.

### 11.3 Contract tests

Verify argument validation, defaults, normalization, return types, and condition classes.

### 11.4 Canonical numerical tests

Use problems with analytic or trusted reference solutions. Choose tolerances according to the algorithm rather than relying on exact floating-point equality.

### 11.5 Invariant tests

Prefer mathematical properties when available:

- a returned root has a small residual;
- a bracket shrinks while preserving a sign change;
- a decomposition reconstructs its input;
- an interpolant reproduces its nodes;
- quadrature integrates known test functions to the expected accuracy; and
- refinement reduces ODE error at the expected rate.

### 11.6 Failure-mode tests

Every documented condition path should have a test, including invalid input, non-finite evaluations, zero derivatives or denominators, stagnation, and iteration exhaustion.

### 11.7 Regression tests

Every fixed bug should receive a test that demonstrates the former failure.

### 11.8 Cross-language semantic tests

Selected canonical problems may be duplicated in `cmna-pkg` and `cmna-el`. Each suite remains independent; parity is judged by mathematical behavior and justified tolerances, not identical formatting or internal steps.

## 12. Build and quality gates

Eask is the development entry point. The normal quality pipeline should include:

- dependency installation;
- byte compilation;
- ERT execution;
- package metadata validation where available;
- linting or checkdoc-style review when adopted; and
- CI across the supported Emacs versions.

A change is eligible for `develop` only when the relevant automated checks pass and review confirms the mathematical implementation and condition behavior.

Byte-compiler warnings should be treated as design feedback. Suppression is appropriate only when the behavior is intentional and documented.

## 13. Documentation architecture

Documentation exists at several levels.

- **Function docstrings** are the authoritative usage contracts.
- **File commentary** explains the responsibility and design of a module.
- **README.md** introduces installation and common usage.
- **ROADMAP.md** records project direction and sequencing.
- **ARCHITECTURE.md** records package-wide engineering rules.
- **NEWS.md**, when established, records user-visible changes and migration notes.
- Longer tutorial material may be maintained as Org or Markdown documentation if it remains buildable and connected to the public API.

Docstrings should state:

- the numerical problem;
- argument requirements;
- optional defaults;
- the returned value;
- convergence behavior; and
- conditions that may be signaled.

The source code may be educational, but users should not have to read the implementation to discover the contract.

## 14. Relationship to `cmna-pkg`

The two repositories share the following architectural concepts:

- numerical methods are grouped by domain;
- inputs and intermediate values are validated;
- iterative methods have explicit convergence and failure rules;
- canonical cases and invariants establish correctness;
- silent non-convergence is prohibited; and
- modernization proceeds family by family on `develop`.

The Emacs Lisp architecture remains authoritative for:

- symbol names and prefixes;
- feature loading and `require` relationships;
- condition symbols and `condition-case` behavior;
- lists and vectors;
- lexical binding;
- ERT; and
- Eask and byte compilation.

No R abstraction should be copied merely to create visual similarity.

## 15. Architectural decision process

A decision should be recorded in this document or a future `docs/decisions/` record when it affects multiple modules or creates a long-lived public constraint. Examples include:

- the canonical vector and matrix representations;
- positional optional arguments versus keyword arguments;
- absolute versus combined absolute-relative tolerance semantics;
- structured diagnostic return values;
- the public condition hierarchy;
- minimum supported Emacs version;
- autoload and packaging strategy; and
- a shared cross-language test-data format.

Local implementation choices belong in code, tests, and pull-request discussion unless they establish a precedent that later modules are expected to follow.

## 16. Definition of architectural completion

A numerical method fits the architecture when the following questions have clear answers.

1. Which domain module owns it?
2. What is its public mathematical contract?
3. Which defaults and utilities does it use?
4. Which arguments and intermediate values are validated?
5. How does it converge, stagnate, break down, or exhaust its budget?
6. Which condition symbols represent those failures?
7. What language-native value does it return?
8. Which ERT tests establish nominal behavior, invariants, and adverse cases?
9. How is the function discovered and documented?
10. Does the corresponding R method require a semantic parity review?

When these answers are routine, `cmna-el` can expand from its root-finding foundation without losing clarity or becoming an accidental collection of incompatible mini-libraries.
