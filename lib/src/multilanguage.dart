part of intl_message;

class MultiLanguageMessage implements IntlMessage {
  final Map<String, IntlMessage> languageMap;

  MultiLanguageMessage(this.languageMap);

  @override
  String format(Map<String, dynamic> args, {ErrorHandler onError}) {
    var locale = IntlMessage.currentLocale;
    var verifiedLocale = Intl.verifiedLocale(locale, languageMap.containsKey,
        onFailure: (locale) => 'default');
    var message = languageMap[verifiedLocale];
    if (message == null) {
      return onError(
          this,
          Exception(
              'No message available for locale $locale')); // TODO make custom exception
    }
    return languageMap[verifiedLocale].format(args, onError: onError);
  }

  @override
  Map<String, dynamic> toJson() => languageMap;
}
