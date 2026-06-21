# Numeric Sequences

`cmna-el` provides `cmna-sequence` because Emacs Lisp has no direct built-in numeric sequence helper with the same interface.

`cmna-pkg` does not provide a CMNA sequence wrapper. R users should use base `seq()`.

`cmna-sequence` requires finite numeric `from`, `to`, and `by` values. The increment must be nonzero and point toward the endpoint. Equal endpoints return one value.

The endpoint is included when reached, allowing for floating-point roundoff. When the next step would cross the endpoint, the sequence stops.

Examples:

```text
1 to 5 by 1     -> 1, 2, 3, 4, 5
5 to 1 by -1    -> 5, 4, 3, 2, 1
0 to 5 by 3     -> 0, 3
2 to 2 by -1    -> 2
```

A floating-point value sufficiently close to the endpoint is replaced by the exact endpoint. Thus `0` to `1` by `0.1` ends with exactly `1`.
