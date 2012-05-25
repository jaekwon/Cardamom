# See http://docs.python.org/library/bisect.html
"""Bisection algorithms."""

_cmp = (x, y) -> if x < y then -1 else if x == y then 0 else 1

@insort_right = (a, x, {lo, hi, cmp}={}) ->
    """Insert item x in list a, and keep it sorted assuming a is sorted.

    If x is already in a, insert it to the right of the rightmost x.

    Optional args lo (default 0) and hi (default len(a)) bound the
    slice of a to be searched.
    """
    lo  ?= 0
    cmp ?= _cmp

    if lo < 0
        throw new Error('lo must be non-negative')
    if hi is undefined
        hi = a.length
    while lo < hi
        mid = Math.floor (lo+hi)/2
        if cmp(x, a[mid]) is -1 then hi = mid
        else lo = mid+1
    a[lo...lo] = [x]

@bisect_right = (a, x, {lo, hi, cmp}={}) ->
    """Return the index where to insert item x in list a, assuming a is sorted.

    The return value i is such that all e in a[:i] have e <= x, and all e in
    a[i:] have e > x.  So if x already appears in the list, a.insert(x) will
    insert just after the rightmost x already there.

    Optional args lo (default 0) and hi (default len(a)) bound the
    slice of a to be searched.
    """
    lo  ?= 0
    cmp ?= _cmp

    if lo < 0
        throw new Error('lo must be non-negative')
    if hi is undefined
        hi = a.length
    while lo < hi
        mid = Math.floor (lo+hi)/2
        if cmp(x, a[mid]) is -1 then hi = mid
        else lo = mid+1
    return lo

@insort_left = (a, x, {lo, hi, cmp}={}) ->
    """Insert item x in list a, and keep it sorted assuming a is sorted.

    If x is already in a, insert it to the left of the leftmost x.

    Optional args lo (default 0) and hi (default len(a)) bound the
    slice of a to be searched.
    """
    lo  ?= 0
    cmp ?= _cmp

    if lo < 0
        throw new Error('lo must be non-negative')
    if hi is undefined
        hi = a.length
    while lo < hi
        mid = Math.floor (lo+hi)/2
        if cmp(a[mid], x) is -1 then lo = mid+1
        else hi = mid
    a[lo...lo] = [x]


@bisect_left = (a, x, {lo, hi, cmp}={}) ->
    """Return the index where to insert item x in list a, assuming a is sorted.

    The return value i is such that all e in a[:i] have e < x, and all e in
    a[i:] have e >= x.  So if x already appears in the list, a.insert(x) will
    insert just before the leftmost x already there.

    Optional args lo (default 0) and hi (default len(a)) bound the
    slice of a to be searched.
    """
    lo  ?= 0
    cmp ?= _cmp

    if lo < 0
        throw new Error('lo must be non-negative')
    if hi is undefined
        hi = a.length
    while lo < hi
        mid = Math.floor (lo+hi)/2
        if cmp(a[mid], x) is -1 then lo = mid+1
        else hi = mid
    return lo
