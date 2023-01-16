[:heart: sponsor](https://github.com/sponsors/rbellens)

# intl_message

[![Build Status](https://travis-ci.org/appsup-dart/intl_message.svg?branch=master)](https://travis-ci.org/appsup-dart/expressions)

Parses and formats [ICU Message strings](http://userguide.icu-project.org/formatparse/messages).

## Usage

    var msg = new IntlMessage("It is now {now, date, long}");
    
    var str = msg.format({
      "now": new DateTime.now()
    });
    
    print(str);
    
    msg = new IntlMessage({
      "nl": "Toon is geboren op {birthday, date, long}",
      "en": "Toon was born on {birthday, date, long}",
    });
    
    IntlMessage.withLocale("nl", () {
      var str = msg.format({
        "birthday": new DateTime(2008,8,16)
      });
    
      print(str);
   
    });
    
    
## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/appsup-dart/intl_message/issues

## Sponsor

Creating and maintaining this package takes a lot of time. If you like the result, please consider to [:heart: sponsor](https://github.com/sponsors/rbellens). 
With your support, I will be able to further improve and support this project.
Also, check out my other dart packages at [pub.dev](https://pub.dev/packages?q=publisher%3Aappsup.be).

