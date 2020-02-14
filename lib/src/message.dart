part of intl_message;

abstract class IntlMessage {
  String format(Map<String, dynamic> args);

  factory IntlMessage(stringOrMap) {
    if (stringOrMap is String) {
      var r = IcuParser().message.end().parse(stringOrMap);
      if (r.isSuccess) return r.value;
      throw ArgumentError(
          "Unable to parse IntlMessage (${r.message}) '$stringOrMap'");
    }
    if (stringOrMap is Map) {
      return MultiLanguageMessage(Map.fromIterables(
          stringOrMap.keys, stringOrMap.values.map((v) => IntlMessage(v))));
    }

    throw ArgumentError('Expected String or Map');
  }

  static T withLocale<T>(String locale, T Function() function) {
    return Intl.withLocale(locale, function);
  }

  static T withCurrency<T>(String currency, T Function() function) {
    return runZoned(function, zoneValues: {#IntlMessage.currency: currency});
  }

  static T withFormatters<T>(
      Map<String, Function> formatters, T Function() function) {
    return runZoned(function, zoneValues: {
      #IntlMessage.formatters:
          Map<String, Function>.from(IntlMessage.formatters)..addAll(formatters)
    });
  }

  dynamic toJson();

  static String get currentLocale => Intl.getCurrentLocale();

  static String get currentCurrency => Zone.current[#IntlMessage.currency];

  static Map<String, Function> get formatters =>
      Zone.current[#IntlMessage.formatters] ?? const {};
}

class LiteralString implements IntlMessage {
  final String string;

  LiteralString(this.string);

  @override
  String format(Map<String, dynamic> args) => string;

  @override
  String toString() => string;

  @override
  String toJson() => toString();
}

class ComposedMessage implements IntlMessage {
  final List<IntlMessage> messages;

  ComposedMessage(this.messages);

  @override
  String format(Map<String, dynamic> args) =>
      messages.map((v) => v.format(args)).join();

  @override
  String toString() => messages.join();

  @override
  String toJson() => toString();
}
