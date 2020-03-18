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
      print(variable.identifier.name);
      throw ArgumentError();
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
      {ErrorHandler onError}) {
    try {
      return formatter(v, args);
    } catch (e) {
      if (onError == null) rethrow;
      return onError(this, e);
    }
  }

  @override
  FutureOr<String> format(Map<String, dynamic> args, {ErrorHandler onError}) {
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
    switch (numberFormat ?? 'decimal') {
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

  num _toNum(v) => v is num ? v : v is String ? num.parse(v) : v;

  @override
  String formatter(v, Map<String, dynamic> args) =>
      _numberFormat.format(_toNum(v));

  @override
  String toString() => '{$name, number, $numberFormat}';
}

class DateTimeMessage extends ExpressionSubstitution {
  static const formats = {
    'date': {
      'short': 'yMd',
      'medium': 'yMMMd',
      'default': 'yMMMd',
      null: 'yMMMd',
      'long': 'yMMMMd',
      'full': 'yMMMMEEEEd',
    },
    'time': {
      'short': 'jm',
      'medium': 'jms',
      'default': 'jms',
      null: 'jms',
      'long': 'jms z',
      'full': 'jms z',
    }
  };

  final String dateTimeFormat;
  final String type;

  DateTimeMessage.date(Expression name, this.dateTimeFormat)
      : type = 'date',
        super(name);

  DateTimeMessage.time(Expression name, this.dateTimeFormat)
      : type = 'time',
        super(name);

  DateTime _toDateTime(v) => (v is String
          ? DateTime.parse(v.replaceAll('UTC', 'Z'))
          : v is num ? DateTime.fromMillisecondsSinceEpoch(v.toInt()) : v)
      ?.toLocal();

  @override
  String formatter(v, Map<String, dynamic> args) =>
      DateFormat(formats[type][dateTimeFormat] ?? dateTimeFormat)
          .format(_toDateTime(v));

  @override
  String toString() => '{$name, type, $dateTimeFormat}';
}

class CustomFormatMessage extends ExpressionSubstitution {
  final String formatName;
  final List<String> arguments;

  CustomFormatMessage(Expression name, this.formatName, this.arguments)
      : super(name, fallbackToNullWhenEvaluationFails: true);

  @override
  FutureOr<String> formatter(covariant v, Map<String, dynamic> args) =>
      _toString(Function.apply(
          IntlMessage.formatters[formatName], [v, ...arguments]));

  @override
  String toString() =>
      '{$name, $formatName${arguments.map((a) => ', $a').join()}}';
}
