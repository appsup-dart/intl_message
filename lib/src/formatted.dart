part of intl_message;

FutureOr<String> _toString(dynamic v) {
  if (v is Future) return v.then(_toString);
  return v == null || v == false ? '' : '$v';
}

final _evaluator = _MyEvaluator();

class _MyEvaluator extends ExpressionEvaluator {
  @override
  dynamic evalMemberExpression(
      MemberExpression expression, Map<String, dynamic> context) {
    var v = eval(expression.object, context);
    if (v is Map && v.containsKey(expression.property.name)) {
      return v[expression.property.name];
    }
    throw ArgumentError();
  }

  @override
  dynamic evalVariable(Variable variable, Map<String, dynamic> context) {
    if (!context.containsKey(variable.identifier.name)) {
      throw ArgumentError(
          'Variable ${variable.identifier.name} not in context');
    }
    return super.evalVariable(variable, context);
  }
}

class ExpressionSubstitution implements IntlMessage {
  final Expression name;
  final bool fallbackToNullWhenEvaluationFails;

  ExpressionSubstitution(this.name,
      {this.fallbackToNullWhenEvaluationFails = false});

  FutureOr<String> formatter(covariant v, Map<String, dynamic> args) =>
      _toString(v);

  dynamic _evaluate(Map<String, dynamic> args) {
    try {
      return _evaluator.eval(name, args);
    } catch (e) {
      if (fallbackToNullWhenEvaluationFails) return null;
      rethrow;
    }
  }

  FutureOr<String> _format(dynamic v, Map<String, dynamic> args,
      {ErrorHandler? onError}) {
    try {
      return formatter(v, args);
    } catch (e) {
      if (onError == null) rethrow;
      return onError(this, e);
    }
  }

  @override
  FutureOr<String> format(Map<String, dynamic> args, {ErrorHandler? onError}) {
    try {
      var v = _evaluate(args);
      if (v is Future) return v.then((v) => _format(v, args, onError: onError));
      return _format(v, args, onError: onError);
    } catch (e) {
      if (onError == null) rethrow;
      return onError(this, e);
    }
  }

  @override
  String toString() => '{$name}';

  @override
  String toJson() => toString();
}

class NumberMessage extends ExpressionSubstitution {
  final String numberFormat;

  NumberMessage(Expression name, this.numberFormat) : super(name);

  NumberFormat get _numberFormat {
    switch (numberFormat) {
      case 'integer':
        return NumberFormat('0');
      case 'decimal':
        return NumberFormat.decimalPattern();
      case 'percent':
        return NumberFormat.percentPattern();
      case 'currency':
        return NumberFormat.simpleCurrency(name: IntlMessage.currentCurrency);
      default:
        return NumberFormat(numberFormat);
    }
  }

  num _toNum(v) {
    if (v == null) throw ArgumentError.notNull();
    if (v is String) {
      return num.parse(v);
    }
    return v as num;
  }

  @override
  String formatter(v, Map<String, dynamic> args) =>
      _numberFormat.format(_toNum(v));

  @override
  String toString() => '{$name, number, $numberFormat}';
}

class DateTimeMessage extends ExpressionSubstitution {
  static const _dateFormats = {
    'short': 'yMd',
    'medium': 'yMMMd',
    'default': 'yMMMd',
    null: 'yMMMd',
    'long': 'yMMMMd',
    'full': 'yMMMMEEEEd',
  };

  static const _timeFormats = {
    'short': 'jm',
    'medium': 'jms',
    'default': 'jms',
    null: 'jms',
    'long': 'jms z',
    'full': 'jms z',
  };

  final String? dateTimeFormat;
  final Map<String?, String> _formats;

  DateTimeMessage.date(Expression name, this.dateTimeFormat)
      : _formats = _dateFormats,
        super(name);

  DateTimeMessage.time(Expression name, this.dateTimeFormat)
      : _formats = _timeFormats,
        super(name);

  DateTime _toDateTime(v) {
    if (v == null) throw ArgumentError.notNull();
    return (v is String
            ? DateTime.parse(v.replaceAll('UTC', 'Z'))
            : v is num
                ? DateTime.fromMillisecondsSinceEpoch(v.toInt())
                : v as DateTime)
        .toLocal();
  }

  @override
  String formatter(v, Map<String, dynamic> args) =>
      DateFormat(_formats[dateTimeFormat] ?? dateTimeFormat)
          .format(_toDateTime(v));

  @override
  String toString() =>
      '{$name, ${_formats == _dateFormats ? 'date' : 'time'}, $dateTimeFormat}';
}

class CustomFormatMessage extends ExpressionSubstitution {
  final String formatName;
  final List<String> arguments;

  CustomFormatMessage(Expression name, this.formatName, this.arguments)
      : super(name, fallbackToNullWhenEvaluationFails: true);

  @override
  FutureOr<String> formatter(covariant v, Map<String, dynamic> args) {
    var f = IntlMessage.formatters[formatName];
    if (f == null) {
      throw StateError('No formatter with name $formatName defined');
    }
    return _toString(Function.apply(f, [v, ...arguments]));
  }

  @override
  String toString() =>
      '{$name, $formatName${arguments.map((a) => ', $a').join()}}';
}
