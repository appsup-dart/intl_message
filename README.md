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
      "nl": "Toon is geboren op {now, date, long}",
      "en": "Toon was born on {now, date, long}",
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
