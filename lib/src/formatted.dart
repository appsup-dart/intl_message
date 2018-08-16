part of intl_message;

String _toString(dynamic v) => v == null || v == false ? "" : "$v";

abstract class Variable {
  Variable._();

  factory Variable(String name) => new _BaseVariable(name);

  dynamic get(Map<String, dynamic> args, {bool failOnNotFound: true});

  Variable subIndex(String v) => new _SubIndex(this, v);
}

class _BaseVariable extends Variable {
  final String name;

  _BaseVariable(this.name) : super._();

  @override
  get(Map<String, dynamic> args, {bool failOnNotFound: true}) {
    if (failOnNotFound && !args.containsKey(name))
      throw new ArgumentError("The context variable '$name'");

    return args[name];
  }

  @override
  String toString() => name;
}

class _SubIndex extends Variable {
  final Variable variable;
  final String index;

  _SubIndex(this.variable, this.index) : super._();

  @override
  get(Map<String, dynamic> args, {bool failOnNotFound: true}) {
    var v = variable.get(args);
    if (failOnNotFound && !v.containsKey(index))
      throw new ArgumentError("The context variable '$index'");

    return v[index];
  }

  @override
  String toString() => "$variable.$index";
}

class VariableSubstitution implements IntlMessage {
  final Variable name;

  VariableSubstitution(this.name);

  String formatter(covariant v) => _toString(v);

  @override
  String format(Map<String, dynamic> args) {
    return formatter(name.get(args));
  }

  @override
  String toString() => "{$name}";
}

class NumberMessage extends VariableSubstitution {
  final String numberFormat;

  NumberMessage(Variable name, this.numberFormat) : super(name);

  NumberFormat get _numberFormat {
    switch (numberFormat ?? "decimal") {
      case "integer":
        return new NumberFormat("0");
      case "decimal":
        return new NumberFormat.decimalPattern();
      case "percent":
        return new NumberFormat.percentPattern();
      case "currency":
        return new NumberFormat.simpleCurrency(
            name: IntlMessage.currentCurrency);
      default:
        return new NumberFormat(numberFormat);
    }
  }

  num _toNum(v) => v is num ? v : v is String ? num.parse(v) : v;

  @override
  String formatter(v) => _numberFormat.format(_toNum(v));

  @override
  String toString() => "{$name, number, $numberFormat}";
}

class DateTimeMessage extends VariableSubstitution {
  static const formats = const {
    "date": const {
      "short": "yMd",
      "medium": "yMMMd",
      "default": "yMMMd",
      null: "yMMMd",
      "long": "yMMMMd",
      "full": "yMMMMEEEEd",
    },
    "time": const {
      "short": "jm",
      "medium": "jms",
      "default": "jms",
      null: "jms",
      "long": "jms z",
      "full": "jms z",
    }
  };

  final String dateTimeFormat;
  final String type;

  DateTimeMessage.date(Variable name, this.dateTimeFormat)
      : type = "date",
        super(name);

  DateTimeMessage.time(Variable name, this.dateTimeFormat)
      : type = "time",
        super(name);

  DateTime _toDateTime(v) => (v is String
          ? DateTime.parse(v.replaceAll("UTC", "Z"))
          : v is num ? new DateTime.fromMillisecondsSinceEpoch(v.toInt()) : v)
      ?.toLocal();

  @override
  String formatter(v) =>
      new DateFormat(formats[type][dateTimeFormat] ?? dateTimeFormat)
          .format(_toDateTime(v));

  @override
  String toString() => "{$name, type, $dateTimeFormat}";
}

class CustomFormatMessage extends VariableSubstitution {
  final Variable formatName;
  final List<String> arguments;

  CustomFormatMessage(Variable name, this.formatName, this.arguments)
      : super(name);

  @override
  String formatter(covariant v) => _toString(Function.apply(
      formatName.get(IntlMessage.formatters), [v]..addAll(arguments)));

  @override
  String format(Map<String, dynamic> args) {
    return formatter(name.get(args, failOnNotFound: false));
  }

  @override
  String toString() =>
      "{$name, $formatName${arguments.map((a) => ", $a").join()}}";
}
