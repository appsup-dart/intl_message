/// Based on the code of the intl package for plural rules
library ordinal_rules;

import 'package:intl/src/plural_rules.dart';

/// This must be called before evaluating a new rule, because we're using
/// library-global state to both keep the rules terse and minimize space.
void startRuleEvaluation(int howMany) {
  _n = howMany;
}

/// The number whose [PluralCase] we are trying to find.
///
// This is library-global state, along with the other variables. This allows us
// to avoid calculating parameters that the functions don't need and also
// not introduce a subclass per locale or have instance tear-offs which
// we can't cache. This is fine as long as these methods aren't async, which
// they should never be.
int _n;

/// The integer part of [_n] - since we only support integers, it's the same as
/// [_n].
int get _i => _n;
int opt_precision; // Not currently used.

// http://www.unicode.org/repos/cldr/trunk/common/supplemental/ordinals.xml

// other
PluralCase _default_rule() => PluralCase.OTHER;

// one,other

PluralCase _sv_rule() {
  var units = _n % 10;
  var tens = _n % 100;
  if ((units == 1 || units == 2) && tens != 11 && tens != 12) {
    return PluralCase.ONE;
  }
  return PluralCase.OTHER;
}

PluralCase _fil_rule() {
  if (_n == 1) return PluralCase.ONE;
  return PluralCase.OTHER;
}

PluralCase _hu_rule() {
  if (_n == 1 || _n == 5) return PluralCase.ONE;
  return PluralCase.OTHER;
}

PluralCase _ne_rule() {
  switch (_n) {
    case 1:
    case 2:
    case 3:
    case 4:
      return PluralCase.ONE;
  }
  return PluralCase.OTHER;
}

// few,other

PluralCase _be_rule() {
  var units = _n % 10;
  var tens = _n % 100;
  if ((units == 2 || units == 3) && tens != 12 && tens != 13) {
    return PluralCase.FEW;
  }
  return PluralCase.OTHER;
}

PluralCase _uk_rule() {
  var units = _n % 10;
  var tens = _n % 100;
  if (units == 3 && tens != 13) return PluralCase.FEW;
  return PluralCase.OTHER;
}

PluralCase _tk_rule() {
  var units = _n % 10;
  if (units == 6 || units == 9 || _n == 10) return PluralCase.FEW;
  return PluralCase.OTHER;
}

// many,other

PluralCase _kk_rule() {
  switch (_n % 10) {
    case 6:
    case 9:
    case 10:
      if (_n != 0) return PluralCase.MANY;
  }
  return PluralCase.OTHER;
}

PluralCase _it_rule() {
  switch (_n) {
    case 8:
    case 11:
    case 80:
    case 800:
      return PluralCase.MANY;
  }
  return PluralCase.OTHER;
}

// one,many,other

PluralCase _ka_rule() {
  if (_i == 1) return PluralCase.ONE;
  if (_i == 0) return PluralCase.MANY;
  var v = _i % 100;
  if (v >= 2 && v <= 20) return PluralCase.MANY;
  if (v == 40 || v == 60 || v == 80) return PluralCase.MANY;
  return PluralCase.OTHER;
}

PluralCase _sq_rule() {
  if (_n == 1) return PluralCase.ONE;
  if (_n % 10 == 4 && _n % 100 != 14) return PluralCase.MANY;
  return PluralCase.OTHER;
}

// one,two,few,other

PluralCase _en_rule() {
  if (_n > 10 && _n < 20) return PluralCase.OTHER;
  switch (_n % 10) {
    case 1:
      return PluralCase.ONE;
    case 2:
      return PluralCase.TWO;
    case 3:
      return PluralCase.FEW;
  }
  return PluralCase.OTHER;
}

PluralCase _mr_rule() {
  switch (_n) {
    case 1:
      return PluralCase.ONE;
    case 2:
    case 3:
      return PluralCase.TWO;
    case 4:
      return PluralCase.FEW;
  }
  return PluralCase.OTHER;
}

PluralCase _ca_rule() {
  switch (_n) {
    case 1:
    case 3:
      return PluralCase.ONE;
    case 2:
      return PluralCase.TWO;
    case 4:
      return PluralCase.FEW;
  }
  return PluralCase.OTHER;
}

// one,two,many,other

PluralCase _mk_rule() {
  if (_i > 10 && _i < 20) return PluralCase.OTHER;
  switch (_i % 10) {
    case 1:
      return PluralCase.ONE;
    case 2:
      return PluralCase.TWO;
    case 7:
    case 8:
      return PluralCase.MANY;
  }
  return PluralCase.OTHER;
}

// one,few,many,other

PluralCase _az_rule() {
  switch (_i % 10) {
    case 1:
    case 2:
    case 5:
    case 7:
    case 8:
      return PluralCase.ONE;
    case 3:
    case 4:
      return PluralCase.FEW;
    case 6:
      return PluralCase.MANY;
    case 0:
      switch (_i % 100) {
        case 20:
        case 50:
        case 70:
        case 80:
          return PluralCase.ONE;
        case 40:
        case 60:
        case 90:
          return PluralCase.MANY;
        case 0:
          if (_i == 0) return PluralCase.MANY;
          return PluralCase.FEW;
      }
  }
  return PluralCase.OTHER;
}

// one,two,few,many,other

PluralCase _gu_rule() {
  switch (_n) {
    case 1:
      return PluralCase.ONE;
    case 2:
    case 3:
      return PluralCase.TWO;
    case 4:
      return PluralCase.FEW;
    case 6:
      return PluralCase.MANY;
  }
  return PluralCase.OTHER;
}

PluralCase _as_rule() {
  if (_n == 0 || _n > 10) return PluralCase.OTHER;
  switch (_n) {
    case 2:
    case 3:
      return PluralCase.TWO;
    case 4:
      return PluralCase.FEW;
    case 6:
      return PluralCase.MANY;
  }
  return PluralCase.ONE;
}

PluralCase _or_rule() {
  if (_n == 0 || _n >= 10) return PluralCase.OTHER;
  switch (_n) {
    case 2:
    case 3:
      return PluralCase.TWO;
    case 4:
      return PluralCase.FEW;
    case 6:
      return PluralCase.MANY;
  }
  return PluralCase.ONE;
}

// zero,one,two,few,many,other

PluralCase _cy_rule() {
  switch (_n) {
    case 0:
    case 7:
    case 8:
    case 9:
      return PluralCase.ZERO;
    case 1:
      return PluralCase.ONE;
    case 2:
      return PluralCase.TWO;
    case 3:
    case 4:
      return PluralCase.FEW;
    case 5:
    case 6:
      return PluralCase.MANY;
  }
  return PluralCase.OTHER;
}

final Map pluralRules = {
  'default': _default_rule,
  'sv': _sv_rule,
  'fil': _fil_rule,
  'fr': _fil_rule,
  'ga': _fil_rule,
  'hy': _fil_rule,
  'lo': _fil_rule,
  'mo': _fil_rule,
  'ms': _fil_rule,
  'ro': _fil_rule,
  'tl': _fil_rule,
  'vi': _fil_rule,
  'hu': _hu_rule,
  'ne': _ne_rule,
  'be': _be_rule,
  'uk': _uk_rule,
  'tk': _tk_rule,
  'kk': _kk_rule,
  'it': _it_rule,
  'ka': _ka_rule,
  'sq': _sq_rule,
  'en': _en_rule,
  'mr': _mr_rule,
  'ca': _ca_rule,
  'mk': _mk_rule,
  'az': _az_rule,
  'gu': _gu_rule,
  'hi': _gu_rule,
  'as': _as_rule,
  'bn': _as_rule,
  'or': _or_rule,
  'cy': _cy_rule,
};

/// Do we have plural rules specific to [locale]
bool localeHasPluralRules(String locale) => pluralRules.containsKey(locale);
