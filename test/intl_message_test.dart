import 'package:intl_message/intl_message.dart';
import 'package:test/test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initializeDateFormatting('nl', null);

  group('Examples from https://formatjs.io/guides/message-syntax/', () {
    test('Basic Principles', () {
      expect(IntlMessage('Hello everyone').format({}), 'Hello everyone');
    });

    test('Simple Argument', () {
      expect(IntlMessage('Hello {who}').format({'who': 'you'}), 'Hello you');
    });

    test('Number format', () {
      expect(
          IntlMessage('I have {numCats, number} cats.').format({'numCats': 5}),
          'I have 5 cats.');
      expect(
          IntlMessage('Almost {pctBlack, number, percent} of them are black.')
              .format({'pctBlack': 0.4}),
          'Almost 40% of them are black.');
      expect(
          IntlMessage('{value, number, integer}').format({'value': 5.5}), '6');
    });

    test('Date format', () {
      var time = DateTime(2017, 11, 3);
      var args = {'start': time};
      Intl.withLocale('nl-BE', () {
        expect(IntlMessage('Solden beginnen {start, date, short}').format(args),
            'Solden beginnen 3-11-2017');
        expect(
            IntlMessage('Solden beginnen {start, date, medium}').format(args),
            'Solden beginnen 3 nov. 2017');
        expect(IntlMessage('Solden beginnen {start, date, long}').format(args),
            'Solden beginnen 3 november 2017');
        expect(IntlMessage('Solden beginnen {start, date, full}').format(args),
            'Solden beginnen vrijdag 3 november 2017');
      });
      Intl.withLocale('en', () {
        expect(IntlMessage('Sale begins {start, date, short}').format(args),
            'Sale begins 11/3/2017');
        expect(IntlMessage('Sale begins {start, date, medium}').format(args),
            'Sale begins Nov 3, 2017');
        expect(IntlMessage('Sale begins {start, date, long}').format(args),
            'Sale begins November 3, 2017');
        expect(IntlMessage('Sale begins {start, date, full}').format(args),
            'Sale begins Friday, November 3, 2017');
      });
    });

    test('Time format', () {
      var time = DateTime(2017, 11, 3, 14, 30);
      var args = {'expires': time};
      expect(
          IntlMessage('Coupon expires at {expires, time, short}').format(args),
          'Coupon expires at 2:30 PM');
      expect(
          IntlMessage('Coupon expires at {expires, time, medium}').format(args),
          'Coupon expires at 2:30:00 PM');
    });

    test('Custom format', () {
      var time = DateTime(2017, 11, 3, 14, 30);
      var args = {'start': time};

      Intl.withLocale('en_US', () {
        expect(
            IntlMessage('Your total is {total, number, currency}')
                .format({'total': 99}),
            r'Your total is $99.00');
        expect(
            IntlMessage('Your total is {total, number, ¤#,##0.00}')
                .format({'total': 99}),
            r'Your total is USD99.00');

        expect(IntlMessage('Solden beginnen {start, date, EEEE}').format(args),
            'Solden beginnen Friday');
        expect(
            IntlMessage("Coupon expires at {start, time, h 'o''clock' a}")
                .format(args),
            "Coupon expires at 2 o'clock PM");
      });

      Intl.withLocale('nl', () {
        expect(
            IntlMessage('Your total is {total, number, currency}')
                .format({'total': 99}),
            r'Your total is € 99,00');
        expect(
            IntlMessage('Your total is {total, number, ¤#,##0.00}')
                .format({'total': 99}),
            r'Your total is EUR99,00');
      });
    });

    test('Gender', () {
      var m = IntlMessage(
          '{gender, select, male {He} female {She} other {They}} will respond shortly.');

      expect(m.format({'gender': 'male'}), 'He will respond shortly.');
      expect(m.format({'gender': 'female'}), 'She will respond shortly.');
      expect(m.format({'gender': 'x'}), 'They will respond shortly.');
    });

    test('Nested select', () {
      var m = IntlMessage('{taxableArea, select, '
          'yes {An additional {taxRate, number, percent} tax will be collected.}'
          'other {No taxes apply.}}');

      expect(m.format({'taxableArea': 'yes', 'taxRate': 0.3}),
          'An additional 30% tax will be collected.');
      expect(
          m.format({'taxableArea': 'no', 'taxRate': 0.3}), 'No taxes apply.');
    });

    test('Plural', () {
      var m = IntlMessage(
          'Cart: {itemCount} {itemCount, plural, one {item} other {items}}');

      expect(m.format({'itemCount': 1}), 'Cart: 1 item');
      expect(m.format({'itemCount': 2}), 'Cart: 2 items');
      expect(m.format({'itemCount': 0}), 'Cart: 0 items');

      m = IntlMessage(
          'You have {itemCount, plural, =0 {no items} one {1 item} other {{itemCount} items}}.');

      expect(m.format({'itemCount': 1}), 'You have 1 item.');
      expect(m.format({'itemCount': 2}), 'You have 2 items.');
      expect(m.format({'itemCount': 0}), 'You have no items.');

      m = IntlMessage(
          'You have {itemCount, plural, =0 {no items} one {# item} other {# items}}.');

      expect(m.format({'itemCount': 1}), 'You have 1 item.');
      expect(m.format({'itemCount': 2}), 'You have 2 items.');
      expect(m.format({'itemCount': 0}), 'You have no items.');
    });

    test('Selectordinal', () {
      Intl.withLocale('af', () {
        expect(
            IntlMessage(
                    'Neem die {number, selectordinal, one {ERROR} other {#e}} afdraai na regs.')
                .format({'number': 1}),
            'Neem die 1e afdraai na regs.');
      });
      var m = IntlMessage(
          "It''s my cat''s {year, selectordinal, one {#st} two {#nd} few {#rd} other {#th}} birthday!");
      expect(m.format({'year': 1}), "It's my cat's 1st birthday!");
      expect(m.format({'year': 2}), "It's my cat's 2nd birthday!");
      expect(m.format({'year': 3}), "It's my cat's 3rd birthday!");
      expect(m.format({'year': 4}), "It's my cat's 4th birthday!");
    });
  });

  group('examples from https://messageformat.github.io/guide/', () {
    test('SelectFormat', () {
      var m = IntlMessage(
          '{GENDER, select, male{He} female{She} other{They}} liked this.');

      expect(m.format({'GENDER': 'male'}), 'He liked this.');
      expect(m.format({'GENDER': 'female'}), 'She liked this.');
      expect(m.format({}), 'They liked this.');
    });

    test('PluralFormat', () {
      var m = IntlMessage(
          'There {NUM_RESULTS, plural, =0{are no results} one{is one result} other{are # results}}.');

      expect(m.format({'NUM_RESULTS': 0}), 'There are no results.');
      expect(m.format({'NUM_RESULTS': 1}), 'There is one result.');
      expect(m.format({'NUM_RESULTS': 100}), 'There are 100 results.');
    });

    test('offset extension', () {
      var m = IntlMessage('You {NUM_ADDS, plural, offset:1'
          '=0{did not add this}'
          '=1{added this}'
          'one{and one other person added this}'
          'other{and # others added this}'
          '}.');

      expect(m.format({'NUM_ADDS': 0}), 'You did not add this.');
      expect(m.format({'NUM_ADDS': 1}), 'You added this.');
      expect(m.format({'NUM_ADDS': 2}), 'You and one other person added this.');
      expect(m.format({'NUM_ADDS': 3}), 'You and 2 others added this.');
    });

    test('date', () {
      var date = DateTime(2016, 2, 21);

      expect(IntlMessage('Today is {T, date}').format({'T': date}),
          'Today is Feb 21, 2016');

      Intl.withLocale('fi', () {
        expect(IntlMessage('Tänään on {T, date}').format({'T': date}),
            'Tänään on 21. helmik. 2016');
      });
      expect(
          IntlMessage('Unix time started on {T, date, full}')
              .format({'T': DateTime(1970)}),
          'Unix time started on Thursday, January 1, 1970');
      expect(
          IntlMessage('{sys} became operational on {d0, date, short}')
              .format({'sys': 'HAL 9000', 'd0': '1999-01-12'}),
          'HAL 9000 became operational on 1/12/1999');
    });

    test('number', () {
      expect(
          IntlMessage('{N} is almost {N, number, integer}').format({'N': 3.14}),
          '3.14 is almost 3');
      expect(IntlMessage('{P, number, percent} complete').format({'P': 0.99}),
          '99% complete');

      IntlMessage.withCurrency('EUR', () {
        expect(
            IntlMessage('The total is {V, number, currency}.')
                .format({'V': 5.5}),
            'The total is €5.50.');
      });
    });

    test('time', () {
      var now = DateTime(2000, 1, 1, 23, 26, 35);

      expect(IntlMessage('The time is now {T, time}').format({'T': now}),
          'The time is now 11:26:35 PM');

      Intl.withLocale('fi', () {
        expect(IntlMessage('Kello on nyt {T, time}').format({'T': now}),
            'Kello on nyt 23.26.35');
      });

      expect(
          IntlMessage('The Eagle landed at {T, time} on {T, date, full}')
              .format({'T': '1969-07-20 21:17:40'}),
          'The Eagle landed at 9:17:40 PM on Sunday, July 20, 1969');
    });

    test('custom formatters', () {
      IntlMessage.withFormatters({
        'upcase': (String v) => v.toUpperCase(),
        'locale': (_) => Intl.getCurrentLocale(),
        'prop': (v, p) => v[p]
      }, () {
        expect(IntlMessage('This is {VAR, upcase}.').format({'VAR': 'big'}),
            'This is BIG.');

        Intl.withLocale('nl_BE', () {
          expect(IntlMessage('The current locale is {_, locale}.').format({}),
              'The current locale is nl_BE.');
        });
        expect(
            IntlMessage('Answer: {obj, prop, a}').format({
              'obj': {'q': 3, 'a': 42}
            }),
            'Answer: 42');
      });
    });
  });

  group('using a string pattern', () {
    test('should properly replace direct arguments in the string', () {
      var mf = IntlMessage('My name is {FIRST} {LAST}.');
      var output = mf.format({'FIRST': 'Anthony', 'LAST': 'Pipkin'});

      expect(output, 'My name is Anthony Pipkin.');
    });

    test('should not ignore zero values', () {
      var mf = IntlMessage('I am {age} years old.');
      var output = mf.format({'age': 0});

      expect(output, 'I am 0 years old.');
    });

    test('should ignore false, null, and undefined', () {
      var mf = IntlMessage('{a}{b}');
      var output = mf.format({
        'a': false,
        'b': null,
      });

      expect(output, '');
    });
  });

  group('and plurals under the Arabic locale', () {
    var msg = IntlMessage(''
        'I have {numPeople, plural,'
        'zero {zero points}'
        'one {a point}'
        'two {two points}'
        'few {a few points}'
        'many {lots of points}'
        'other {some other amount of points}}'
        '.');

    test('should match zero', () {
      Intl.withLocale('ar', () {
        var m = msg.format({'numPeople': 0});

        expect(m, 'I have zero points.');
      });
    });

    test('should match one', () {
      Intl.withLocale('ar', () {
        var m = msg.format({'numPeople': 1});

        expect(m, 'I have a point.');
      });
    });

    test('should match two', () {
      Intl.withLocale('ar', () {
        var m = msg.format({'numPeople': 2});

        expect(m, 'I have two points.');
      });
    });

    test('should match few', () {
      Intl.withLocale('ar', () {
        var m = msg.format({'numPeople': 5});

        expect(m, 'I have a few points.');
      });
    });

    test('should match many', () {
      Intl.withLocale('ar', () {
        var m = msg.format({'numPeople': 20});

        expect(m, 'I have lots of points.');
      });
    });

    test('should match other', () {
      Intl.withLocale('ar', () {
        var m = msg.format({'numPeople': 100});

        expect(m, 'I have some other amount of points.');
      });
    });
  });

  group('and changing the locale', () {
    var simple = {
      'en': '{NAME} went to {CITY}.',
      'fr': '{NAME} est {GENDER, select, '
          'female {allée}'
          'other {allé}}'
          ' à {CITY}.'
    };

    var complex = {
      'en': '{TRAVELLERS} went to {CITY}.',
      'fr': '{TRAVELLERS} {TRAVELLER_COUNT, plural, '
          '=1 {est {GENDER, select, '
          'female {allée}'
          'other {allé}}}'
          'other {sont {GENDER, select, '
          'female {allées}'
          'other {allés}}}}'
          ' à {CITY}.'
    };

    var maleObj = {'NAME': 'Tony', 'CITY': 'Paris', 'GENDER': 'male'};

    var femaleObj = {'NAME': 'Jenny', 'CITY': 'Paris', 'GENDER': 'female'};

    var maleTravelers = {
      'TRAVELLERS': 'Lucas, Tony and Drew',
      'TRAVELLER_COUNT': 3,
      'GENDER': 'male',
      'CITY': 'Paris'
    };

    var femaleTravelers = {
      'TRAVELLERS': 'Monica',
      'TRAVELLER_COUNT': 1,
      'GENDER': 'female',
      'CITY': 'Paris'
    };

    test('should format message en-US simple with different objects', () {
      var msgFmt = IntlMessage(simple['en']);
      expect(msgFmt.format(maleObj), 'Tony went to Paris.');
      expect(msgFmt.format(femaleObj), 'Jenny went to Paris.');
    });

    test('should format message fr-FR simple with different objects', () {
      Intl.withLocale('fr-FR', () {
        var msgFmt = IntlMessage(simple['fr']);
        expect(msgFmt.format(maleObj), 'Tony est allé à Paris.');
        expect(msgFmt.format(femaleObj), 'Jenny est allée à Paris.');
      });
    });

    test('should format message en-US complex with different objects', () {
      var msgFmt = IntlMessage(complex['en']);
      expect(
          msgFmt.format(maleTravelers), 'Lucas, Tony and Drew went to Paris.');
      expect(msgFmt.format(femaleTravelers), 'Monica went to Paris.');
    });

    test('should format message fr-FR complex with different objects', () {
      Intl.withLocale('fr-FR', () {
        var msgFmt = IntlMessage(complex['fr']);
        expect(msgFmt.format(maleTravelers),
            'Lucas, Tony and Drew sont allés à Paris.');
        expect(msgFmt.format(femaleTravelers), 'Monica est allée à Paris.');
      });
    });
  });

  group('and change the locale with different counts', () {
    var messages = {
      'en': '{COMPANY_COUNT, plural, '
          '=1 {One company}'
          'other {# companies}}'
          ' published books.',
      'ru': '{COMPANY_COUNT, plural, '
          '=1 {Одна компания опубликовала}'
          'one {# компания опубликовала}'
          'few {# компании опубликовали}'
          'many {# компаний опубликовали}'
          'other {# компаний опубликовали}}'
          ' новые книги.'
    };

    test('should format a message with en-US locale', () {
      var msgFmt = IntlMessage(messages['en']);

      expect(
          msgFmt.format({'COMPANY_COUNT': 0}), '0 companies published books.');
      expect(
          msgFmt.format({'COMPANY_COUNT': 1}), 'One company published books.');
      expect(
          msgFmt.format({'COMPANY_COUNT': 2}), '2 companies published books.');
      expect(
          msgFmt.format({'COMPANY_COUNT': 5}), '5 companies published books.');
      expect(msgFmt.format({'COMPANY_COUNT': 10}),
          '10 companies published books.');
    });

    test('should format a message with ru-RU locale', () {
      Intl.withLocale('ru-RU', () {
        var msgFmt = IntlMessage(messages['ru']);

        expect(msgFmt.format({'COMPANY_COUNT': 0}),
            '0 компаний опубликовали новые книги.');
        expect(msgFmt.format({'COMPANY_COUNT': 1}),
            'Одна компания опубликовала новые книги.');
        expect(msgFmt.format({'COMPANY_COUNT': 2}),
            '2 компании опубликовали новые книги.');
        expect(msgFmt.format({'COMPANY_COUNT': 5}),
            '5 компаний опубликовали новые книги.');
        expect(msgFmt.format({'COMPANY_COUNT': 10}),
            '10 компаний опубликовали новые книги.');
        expect(msgFmt.format({'COMPANY_COUNT': 21}),
            '21 компания опубликовала новые книги.');
      });
    });
  });

  group('arguments with', () {
    group('no spaces', () {
      var msg = IntlMessage('{STATE}');
      var state = 'Missouri';

      test('should fail when the argument in the pattern is not provided', () {
        expect(() => msg.format({}), throwsA(isA<ArgumentError>()));
      });

      test('should fail when the argument in the pattern has a typo', () {
        expect(
            () => msg.format({'ST ATE': state}), throwsA(isA<ArgumentError>()));
      });

      test('should succeed when the argument is correct', () {
        expect(msg.format({'STATE': state}), state);
      });
    });

    group('a numeral', () {
      var msg = IntlMessage('{ST1ATE}');
      var state = 'Missouri';

      test('should fail when the argument in the pattern is not provided', () {
        expect(() => msg.format({'FOO': state}), throwsA(isA<ArgumentError>()));
      });

      test('should fail when the argument in the pattern has a typo', () {
        expect(
            () => msg.format({'ST ATE': state}), throwsA(isA<ArgumentError>()));
      });

      test('should succeed when the argument is correct', () {
        expect(msg.format({'ST1ATE': state}), state);
      });
    });
  });

  group('selectordinal arguments', () {
    var msg =
        'This is my {year, selectordinal, one{#st} two{#nd} few{#rd} other{#th}} birthday.';

    test('should use ordinal pluralization rules', () {
      var mf = IntlMessage(msg);

      expect(mf.format({'year': 1}), 'This is my 1st birthday.');
      expect(mf.format({'year': 2}), 'This is my 2nd birthday.');
      expect(mf.format({'year': 3}), 'This is my 3rd birthday.');
      expect(mf.format({'year': 4}), 'This is my 4th birthday.');
      expect(mf.format({'year': 11}), 'This is my 11th birthday.');
      expect(mf.format({'year': 21}), 'This is my 21st birthday.');
      expect(mf.format({'year': 22}), 'This is my 22nd birthday.');
      expect(mf.format({'year': 33}), 'This is my 33rd birthday.');
      expect(mf.format({'year': 44}), 'This is my 44th birthday.');
      expect(mf.format({'year': 1024}), 'This is my 1,024th birthday.');
    });
  });

  group('exceptions', () {
    test('should use the correct PT plural rules', () {
      var msg = IntlMessage('{num, plural, one{one} other{other}}');

      Intl.withLocale('pt', () {
        expect(msg.format({'num': 0}), 'one');
      });
      Intl.withLocale('pt-PT', () {
        expect(msg.format({'num': 0}), 'other');
      });
    });
  });

  group('subindex', () {
    test('', () {
      var msg = IntlMessage('{person.firstname}');

      expect(
          msg.format({
            'person': {'firstname': 'Rik'}
          }),
          'Rik');
    });
  });

  group('resolve locales', () {
    test('fallback to main locale when sub locale not present', () {
      var msg = IntlMessage({'en': 'Hello world'});
      Intl.withLocale('en_US', () {
        expect(msg.format({}), 'Hello world');
      });
      Intl.withLocale('en-UK', () {
        expect(msg.format({}), 'Hello world');
      });
    });
    test('fallback to default when locale not present', () {
      var msg = IntlMessage({'default': 'Hello world', 'nl': 'Hallo'});
      Intl.withLocale('en-US', () {
        expect(msg.format({}), 'Hello world');
      });
    });
  });

  group('Async formatting', () {
    test('Future arguments', () async {
      expect(
          await IntlMessage('Hello {who}').format({'who': Future.value('you')}),
          'Hello you');
      expect(
          await IntlMessage('{value, number, integer}')
              .format({'value': Future.value(5.5)}),
          '6');

      var time = DateTime(2017, 11, 3, 14, 30);
      var args = {'start': Future.value(time)};
      await Intl.withLocale('en', () async {
        expect(
            await IntlMessage('Sale begins {start, date, short}').format(args),
            'Sale begins 11/3/2017');
        expect(
            await IntlMessage('Sale begins {start, date, medium}').format(args),
            'Sale begins Nov 3, 2017');
        expect(
            await IntlMessage('Sale begins {start, date, long}').format(args),
            'Sale begins November 3, 2017');
        expect(
            await IntlMessage('Sale begins {start, date, full}').format(args),
            'Sale begins Friday, November 3, 2017');
      });

      args = {'expires': Future.value(time)};
      expect(
          await IntlMessage('Coupon expires at {expires, time, medium}')
              .format(args),
          'Coupon expires at 2:30:00 PM');

      await Intl.withLocale('nl', () async {
        expect(
            await IntlMessage('Your total is {total, number, currency}')
                .format({'total': Future.value(99)}),
            r'Your total is € 99,00');
        expect(
            await IntlMessage('Your total is {total, number, ¤#,##0.00}')
                .format({'total': Future.value(99)}),
            r'Your total is EUR99,00');
      });

      var m = IntlMessage(
          '{gender, select, male {He} female {She} other {They}} will respond shortly.');
      expect(await m.format({'gender': Future.value('x')}),
          'They will respond shortly.');

      m = IntlMessage('{taxableArea, select, '
          'yes {An additional {taxRate, number, percent} tax will be collected.}'
          'other {No taxes apply.}}');
      expect(
          await m.format({
            'taxableArea': Future.value('no'),
            'taxRate': Future.value(0.3)
          }),
          'No taxes apply.');

      m = IntlMessage(
          'You have {itemCount, plural, =0 {no items} one {# item} other {# items}}.');
      expect(
          await m.format({'itemCount': Future.value(0)}), 'You have no items.');

      m = IntlMessage(
          "It''s my cat''s {year, selectordinal, one {#st} two {#nd} few {#rd} other {#th}} birthday!");
      expect(await m.format({'year': Future.value(4)}),
          "It's my cat's 4th birthday!");
    });

    test('async custom formatters', () {
      IntlMessage.withFormatters({
        'upcase': (String v) async => v.toUpperCase(),
        'locale': (_) async => Intl.getCurrentLocale(),
        'prop': (v, p) async => v[p]
      }, () async {
        expect(
            await IntlMessage('This is {VAR, upcase}.').format({'VAR': 'big'}),
            'This is BIG.');

        await Intl.withLocale('nl_BE', () async {
          expect(
              await IntlMessage('The current locale is {_, locale}.')
                  .format({}),
              'The current locale is nl_BE.');
        });
        expect(
            await IntlMessage('Answer: {obj, prop, a}').format({
              'obj': {'q': 3, 'a': 42}
            }),
            'Answer: 42');
      });
    });
  });

  group('Expressions', () {
    test('basic expressions', () {
      expect(IntlMessage('{1+2}').format({}), '3');

      IntlMessage.withFormatters({'join': (l) => (l as List).join()}, () {
        expect(IntlMessage('{[1,2,3], join}').format({}), '123');
      });

      var m = IntlMessage(
          '{"male", select, male {He} female {She} other {They}} will respond shortly.');
      expect(m.format({}), 'He will respond shortly.');

      m = IntlMessage(
          'You have {1+4*2, plural, =0 {no items} one {1 item} other {many items}}.');

      expect(m.format({}), 'You have many items.');
    });
    test('member expressions', () {
      expect(
          IntlMessage('{a.b}').format({
            'a': {'b': 1}
          }),
          '1');
    });
    test('method call expressions', () {
      var context = {'sayHello': ([to = 'world']) => 'hello $to'};
      expect(IntlMessage('{sayHello("everyone")}').format(context),
          'hello everyone');
      expect(IntlMessage('{sayHello()}').format(context), 'hello world');
    });
  });

  group('literal strings', () {
    test('trim LiteralString', () {
      expect(
          LiteralString(' hello world \n ').trim().format({}), 'hello world');
      expect(
          LiteralString(' hello world\' ').trim().format({}), 'hello world ');
      expect(LiteralString('\' hello world').trim().format({}), ' hello world');
      expect(
          LiteralString('hello world\'\n').trim().format({}), 'hello world\n');
      expect(LiteralString('  ').trim().format({}), '');
    });
    test('parse general strings as select keys', () {
      expect(
          IntlMessage('{N, select, hello world {greeting} other {no greeting}}')
              .format({'N': 'hello world'}),
          'greeting');
      expect(
          IntlMessage('{N, select, --some-id-- {greeting} other {no greeting}}')
              .format({'N': '--some-id--'}),
          'greeting');
    });
  });
  group('Type errors', () {
    test('NumberMessage should throw when not a number or parseable', () {
      expect(() => IntlMessage('{N, number, integer}').format({'N': 'qdf'}),
          throwsA(isA<FormatException>()));
      expect(() => IntlMessage('{N, number, integer}').format({'N': null}),
          throwsA(isA<ArgumentError>()));
      expect(() => IntlMessage('{N, number, integer}').format({'N': true}),
          throwsA(isA<TypeError>()));
    });
    test('DateTimeMessage should throw when not a DateTime or parseable', () {
      expect(() => IntlMessage('{N, number, integer}').format({'N': 'qdf'}),
          throwsA(isA<FormatException>()));
      expect(() => IntlMessage('{N, number, integer}').format({'N': null}),
          throwsA(isA<ArgumentError>()));
      expect(() => IntlMessage('{N, number, integer}').format({'N': true}),
          throwsA(isA<TypeError>()));
    });
  });
}
