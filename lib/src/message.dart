
part of intl_message;

abstract class IntlMessage {

  String format(Map<String,dynamic> args);

  factory IntlMessage(stringOrMap) {
    if (stringOrMap is String) {
      var r = new IcuParser().message.end().parse(stringOrMap);
      if (r.isSuccess) return r.value;
      throw new ArgumentError("Unable to parse IntlMessage (${r.message}) '$stringOrMap'");
    }
    if (stringOrMap is Map)
      return new MultiLanguageMessage(new Map.fromIterables(
          stringOrMap.keys,
          stringOrMap.values.map((v)=>new IntlMessage(v))
    ));

    throw new ArgumentError("Expected String or Map");
  }

  static T withLocale<T>(String locale, T Function()function) {
    return Intl.withLocale(locale, function);
  }

  static T withCurrency<T>(String currency, T Function()function) {
    return runZoned(function, zoneValues: {#IntlMessage.currency: currency});
  }

  static T withFormatters<T>(Map<String,Function> formatters, T Function()function) {
    return runZoned(function, zoneValues: {
      #IntlMessage.formatters: new Map.from(IntlMessage.formatters)..addAll(formatters)
    });
  }

  static String get currentLocale => Intl.getCurrentLocale();

  static String get currentCurrency => Zone.current[#IntlMessage.currency];

  static Map<String,Function> get formatters => Zone.current[#IntlMessage.formatters]??const{};

}

class LiteralString implements IntlMessage {
  final String string;

  LiteralString(this.string);

  @override
  String format(Map<String, dynamic> args) => string;

  @override
  String toString() => string;
}

class ComposedMessage implements IntlMessage {

  final List<IntlMessage> messages;

  ComposedMessage(this.messages);

  @override
  String format(Map<String, dynamic> args) => messages.map((v)=>v.format(args)).join();

  @override
  String toString() => messages.join();
}
