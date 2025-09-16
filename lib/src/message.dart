part of '../intl_message.dart';

typedef ErrorHandler = String Function(IntlMessage, Object);

abstract class IntlMessage {
  FutureOr<String> format(Map<String, dynamic> args, {ErrorHandler? onError});

  factory IntlMessage(dynamic stringOrMap) {
    if (stringOrMap is String) {
      var r = IcuParser().message.end().parse(stringOrMap);
      if (r is Success) return r.value;
      throw ArgumentError(
          "Unable to parse IntlMessage (${r.message}) '$stringOrMap'");
    }
    if (stringOrMap is Map) {
      return MultiLanguageMessage(Map.fromIterables(stringOrMap.keys.cast(),
          stringOrMap.values.map((v) => IntlMessage(v))));
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

  static String? get currentCurrency => Zone.current[#IntlMessage.currency];

  static Map<String, Function> get formatters =>
      Zone.current[#IntlMessage.formatters] ?? const {};
}

class LiteralString implements IntlMessage {
  final String string;

  LiteralString(this.string);

  @override
  String format(Map<String, dynamic> args, {ErrorHandler? onError}) =>
      string.replaceAllMapped(
          RegExp("'(.)", dotAll: true), (match) => match.group(1)!);

  @override
  String toString() => string;

  @override
  String toJson() => toString();

  /// Removes non-escaped whitespaces
  LiteralString trim() {
    var s = string;
    s = s.replaceFirst(RegExp(r'^\s*'), '');
    s = s.replaceFirstMapped(RegExp(r"([^'])\s*$"), (m) => m.group(1)!);
    return LiteralString(s);
  }
}

class ComposedMessage implements IntlMessage {
  final List<IntlMessage> messages;

  ComposedMessage(this.messages);

  @override
  FutureOr<String> format(Map<String, dynamic> args, {ErrorHandler? onError}) {
    var parts = messages.map((v) => v.format(args, onError: onError));
    if (parts.every((element) => element is String)) {
      return parts.join();
    }
    return Future.wait(parts.map((v) => Future.value(v))).then((l) => l.join());
  }

  @override
  String toString() => messages.join();

  @override
  String toJson() => toString();
}
