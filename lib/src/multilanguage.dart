part of intl_message;

class MultiLanguageMessage implements IntlMessage {
  final Map<String, IntlMessage> languageMap;

  MultiLanguageMessage(this.languageMap);

  @override
  FutureOr<String> format(Map<String, dynamic> args, {ErrorHandler? onError}) {
    var locale = IntlMessage.currentLocale;
    var verifiedLocale = Intl.verifiedLocale(locale, languageMap.containsKey,
        onFailure: (locale) => 'default')!;
    var message = languageMap[verifiedLocale];
    if (message == null) {
      var e = Exception(
          'No message available for locale $locale'); // TODO make custom exception
      if (onError == null) throw e;
      return onError(this, e);
    }
    return message.format(args, onError: onError);
  }

  @override
  Map<String, dynamic> toJson() =>
      languageMap.map((key, value) => MapEntry(key, value.toJson()));
}
