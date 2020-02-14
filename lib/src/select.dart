part of intl_message;

abstract class SubMessage extends ExpressionSubstitution {
  final Map<String, IntlMessage> messages;

  SubMessage(Expression name, this.messages)
      : super(name, fallbackToNullWhenEvaluationFails: true);

  String _index(dynamic v);

  String get _type;

  @override
  FutureOr<String> formatter(v, Map<String, dynamic> args) {
    var index = _index(v);
    var m = messages[index] ?? messages['other'];
    return m.format(args);
  }

  @override
  String toString() =>
      '{$name, $_type, ${messages.keys.map((k) => '$k {${messages[k]}}').join(' ')}';

  @override
  String toJson() => toString();
}

class SelectMessage extends SubMessage {
  SelectMessage(Expression name, Map<String, IntlMessage> messages)
      : super(name, messages);

  @override
  String _index(v) => v;

  @override
  String get _type => 'select';
}

class SelectOrdinalMessage extends PluralMessage {
  SelectOrdinalMessage(Expression name, Map<String, IntlMessage> messages,
      {int offset = 0})
      : super(name, messages, offset: offset);

  @override
  plural_rules.PluralCase _pluralCase(int howMany) {
    var locale = Intl.getCurrentLocale();
    ordinal_rules.startRuleEvaluation(howMany);
    var verifiedLocale = Intl.verifiedLocale(
        locale, ordinal_rules.localeHasPluralRules,
        onFailure: (locale) => 'default');
    return ordinal_rules.pluralRules[verifiedLocale]();
  }

  @override
  String get _type => 'selectordinal';
}

class PluralMessage extends SubMessage {
  final int offset;

  PluralMessage(Expression name, Map<String, IntlMessage> messages,
      {this.offset = 0})
      : super(name, messages);

  @override
  FutureOr<String> format(Map<String, dynamic> args, {ErrorHandler onError}) {
    var s = super.format(args);
    return _replace(s, args);
  }

  @override
  FutureOr<String> formatter(covariant v, Map<String, dynamic> args) {
    var s = super.formatter(v, args);
    return _replace(s, v);
  }

  FutureOr<String> _replace(FutureOr<String> s, v) {
    if (s is String) {
      return s.replaceAllMapped(RegExp(r'(^|[^\\])#'),
          (m) => m.group(1) + NumberFormat().format(v - offset));
    }
    return (s as Future<String>).then((s) => _replace(s, v));
  }

  plural_rules.PluralCase _pluralCase(int howMany) {
    var locale = Intl.getCurrentLocale();
    plural_rules.startRuleEvaluation(howMany);
    var verifiedLocale = Intl.verifiedLocale(
        locale, plural_rules.localeHasPluralRules,
        onFailure: (locale) => 'default');
    return plural_rules.pluralRules[verifiedLocale]();
  }

  @override
  String _index(v) {
    if (!(v is int)) {
      throw ArgumentError(
          'Expected argument $name to be of type int, was ${v.runtimeType} ($v)');
    }
    if (messages.containsKey('=$v')) {
      return '=$v';
    }
    return const {
      plural_rules.PluralCase.ZERO: 'zero',
      plural_rules.PluralCase.ONE: 'one',
      plural_rules.PluralCase.TWO: 'two',
      plural_rules.PluralCase.FEW: 'few',
      plural_rules.PluralCase.MANY: 'many',
      plural_rules.PluralCase.OTHER: 'other',
    }[_pluralCase(v - offset)];
  }

  @override
  String get _type => 'plural';
}
