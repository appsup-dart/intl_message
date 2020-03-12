import 'package:intl/date_symbol_data_local.dart';
import 'package:intl_message/intl_message.dart';

void main() {
  initializeDateFormatting();

  var msg = IntlMessage('It is now {now, date, long}');

  var str = msg.format({'now': DateTime.now()});

  print(str);

  msg = IntlMessage({
    'nl': 'Toon is geboren op {birthday, date, long}',
    'en': 'Toon was born on {birthday, date, long}',
  });

  IntlMessage.withLocale('nl', () {
    var str = msg.format({'birthday': DateTime(2008, 8, 16)});

    print(str);
  });
}
