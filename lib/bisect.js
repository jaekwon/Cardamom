(function() {
  "Bisection algorithms.";

  var _cmp;

  _cmp = function(x, y) {
    if (x < y) {
      return -1;
    } else if (x === y) {
      return 0;
    } else {
      return 1;
    }
  };

  this.insort_right = function(a, x, _arg) {
    var cmp, hi, lo, mid, _ref, _ref2;
    _ref = _arg != null ? _arg : {}, lo = _ref.lo, hi = _ref.hi, cmp = _ref.cmp;
    "Insert item x in list a, and keep it sorted assuming a is sorted.\n\nIf x is already in a, insert it to the right of the rightmost x.\n\nOptional args lo (default 0) and hi (default len(a)) bound the\nslice of a to be searched.";

    if (lo == null) lo = 0;
    if (cmp == null) cmp = _cmp;
    if (lo < 0) throw new Error('lo must be non-negative');
    if (hi === void 0) hi = a.length;
    while (lo < hi) {
      mid = Math.floor((lo + hi) / 2);
      if (cmp(x, a[mid]) === -1) {
        hi = mid;
      } else {
        lo = mid + 1;
      }
    }
    return ([].splice.apply(a, [lo, lo - lo].concat(_ref2 = [x])), _ref2);
  };

  this.bisect_right = function(a, x, _arg) {
    var cmp, hi, lo, mid, _ref;
    _ref = _arg != null ? _arg : {}, lo = _ref.lo, hi = _ref.hi, cmp = _ref.cmp;
    "Return the index where to insert item x in list a, assuming a is sorted.\n\nThe return value i is such that all e in a[:i] have e <= x, and all e in\na[i:] have e > x.  So if x already appears in the list, a.insert(x) will\ninsert just after the rightmost x already there.\n\nOptional args lo (default 0) and hi (default len(a)) bound the\nslice of a to be searched.";

    if (lo == null) lo = 0;
    if (cmp == null) cmp = _cmp;
    if (lo < 0) throw new Error('lo must be non-negative');
    if (hi === void 0) hi = a.length;
    while (lo < hi) {
      mid = Math.floor((lo + hi) / 2);
      if (cmp(x, a[mid]) === -1) {
        hi = mid;
      } else {
        lo = mid + 1;
      }
    }
    return lo;
  };

  this.insort_left = function(a, x, _arg) {
    var cmp, hi, lo, mid, _ref, _ref2;
    _ref = _arg != null ? _arg : {}, lo = _ref.lo, hi = _ref.hi, cmp = _ref.cmp;
    "Insert item x in list a, and keep it sorted assuming a is sorted.\n\nIf x is already in a, insert it to the left of the leftmost x.\n\nOptional args lo (default 0) and hi (default len(a)) bound the\nslice of a to be searched.";

    if (lo == null) lo = 0;
    if (cmp == null) cmp = _cmp;
    if (lo < 0) throw new Error('lo must be non-negative');
    if (hi === void 0) hi = a.length;
    while (lo < hi) {
      mid = Math.floor((lo + hi) / 2);
      if (cmp(a[mid], x) === -1) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return ([].splice.apply(a, [lo, lo - lo].concat(_ref2 = [x])), _ref2);
  };

  this.bisect_left = function(a, x, _arg) {
    var cmp, hi, lo, mid, _ref;
    _ref = _arg != null ? _arg : {}, lo = _ref.lo, hi = _ref.hi, cmp = _ref.cmp;
    "Return the index where to insert item x in list a, assuming a is sorted.\n\nThe return value i is such that all e in a[:i] have e < x, and all e in\na[i:] have e >= x.  So if x already appears in the list, a.insert(x) will\ninsert just before the leftmost x already there.\n\nOptional args lo (default 0) and hi (default len(a)) bound the\nslice of a to be searched.";

    if (lo == null) lo = 0;
    if (cmp == null) cmp = _cmp;
    if (lo < 0) throw new Error('lo must be non-negative');
    if (hi === void 0) hi = a.length;
    while (lo < hi) {
      mid = Math.floor((lo + hi) / 2);
      if (cmp(a[mid], x) === -1) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  };

}).call(this);