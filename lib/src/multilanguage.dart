
part of intl_message;

class MultiLanguageMessage implements IntlMessage {

  final Map<String,IntlMessage> languageMap;

  MultiLanguageMessage(this.languageMap);

  @override
  String format(Map<String, dynamic> args) {
    var locale = IntlMessage.currentLocale;
    var verifiedLocale = Intl.verifiedLocale(
        locale, languageMap.containsKey,
        onFailure: (locale) => 'default');
    return languageMap[verifiedLocale].format(args);
  }
}
