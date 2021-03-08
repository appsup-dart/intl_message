library intl_message.parser;

import 'package:expressions/expressions.dart';
import 'package:expressions/src/parser.dart';
import 'package:intl_message/intl_message.dart';
import 'package:petitparser/petitparser.dart';

class IcuParser {
  Parser<String> get openCurly => char('{');

  Parser<String> get closeCurly => char('}');

  Parser get quotedCurly => (string("'{'") | string("'}'"));

  Parser get icuEscapedText => quotedCurly | twoSingleQuotes;

  Parser get curly => (openCurly | closeCurly);

  Parser get notAllowedInIcuText => curly | styleStart;

  Parser<String> get icuText => notAllowedInIcuText.neg();

  Parser<List> get styleStart =>
      string('<style') &
      (whitespace() & char('>').neg().star()).optional() &
      char('>');

  Parser<String> get styleEnd => string('</style>');

  Parser<List<String>> get styleContent => styleEnd.neg().star();

  Parser<String> get style => (styleStart & styleContent & styleEnd).flatten();

  Parser<String> get notAllowedInNormalText => openCurly;

  Parser<String> get normalText => notAllowedInNormalText.neg();

  Parser<LiteralString> get messageText => (icuEscapedText | icuText | style)
      .plus()
      .flatten()
      .map((v) => LiteralString(v));

  Parser<LiteralString> get nonIcuMessageText =>
      normalText.plus().flatten().map((v) => LiteralString(v));

  Parser<String> get twoSingleQuotes => string("''").map((x) => "'");

  Parser<int> get number => digit().plus().flatten().trim().map(int.parse);

  Parser<String> get simpleId =>
      ((letter() | char('_')) & (word() | char('_')).star()).flatten();

  Parser<Expression> get expression => ExpressionParser().expression.trim();

  Parser<String> get comma => char(',').trim();

  /// Given a list of possible keywords, return a rule that accepts any of them.
  /// e.g., given ['male', 'female', 'other'], accept any of them.
  Parser<String> asKeywords(List<String> list) =>
      list.map(string).reduce((a, b) => (a | b).flatten()).trim();

  Parser<String> get pluralKeyword =>
      ((asKeywords(['zero', 'one', 'two', 'few', 'many', 'other']) |
              (char('=') & digit().plus()).flatten().trim()))
          .cast();

  Parser<String> get genderKeyword => asKeywords(['female', 'male', 'other']);

  SettableParser<IntlMessage> interiorText = undefined();

  Parser<Expression> get preface => (openCurly & expression & comma).pick(1);

  Parser<String> get numberLiteral => string('number');

  Parser<NumberMessage> get intlNumber => (preface &
          numberLiteral &
          (comma & icuText.plus().flatten().trim()).pick(1).optional() &
          closeCurly)
      .map((values) => NumberMessage(values[0], values[2] ?? 'decimal'));

  Parser<String> get dateLiteral => string('date');

  Parser<String> get dateFormat => icuText.plus().flatten().trim();

  Parser<DateTimeMessage> get intlDate => (preface &
          dateLiteral &
          (comma & dateFormat).pick(1).optional() &
          closeCurly)
      .map((values) => DateTimeMessage.date(values[0], values[2]));

  Parser<String> get timeLiteral => string('time');

  Parser<String> get timeFormat => icuText.plus().flatten().trim();

  Parser<DateTimeMessage> get intlTime => (preface &
          timeLiteral &
          (comma & timeFormat).pick(1).optional() &
          closeCurly)
      .map((values) => DateTimeMessage.time(values[0], values[2]));

  Parser get pluralLiteral => string('plural') | string('selectordinal');

  Parser<List> get pluralClause =>
      (pluralKeyword & openCurly & interiorText & closeCurly)
          .trim()
          .permute([0, 2]);

  Parser<Map<String, IntlMessage>> get pluralClauses =>
      pluralClause.plus().map((l) => {for (var v in l) v.first: v.last});

  Parser<int> get offset =>
      (string('offset:') & digit().plus().flatten().map(int.parse)).pick(1);

  Parser get plural =>
      preface &
      pluralLiteral &
      comma &
      offset.optional() &
      pluralClauses &
      closeCurly;

  Parser<IntlMessage> get intlPlural => plural.map((values) => values[1] ==
          'plural'
      ? PluralMessage(values.first, values[4], offset: values[3] ?? 0)
      : SelectOrdinalMessage(values.first, values[4], offset: values[3] ?? 0));

  Parser<String> get selectLiteral => string('select');

  Parser<List> get selectClause =>
      (messageText.map((v) => v.trim().format(const {})) &
              openCurly &
              interiorText &
              closeCurly)
          .trim()
          .permute([0, 2]);

  Parser<Map<String, IntlMessage>> get selectClauses =>
      selectClause.plus().map((l) => {for (var v in l) v.first: v.last});

  Parser get generalSelect =>
      preface & selectLiteral & comma & selectClauses & closeCurly;

  Parser<SelectMessage> get intlSelect =>
      generalSelect.map((values) => SelectMessage(values.first, values[3]));

  Parser<CustomFormatMessage> get custom => (preface &
          simpleId &
          (comma & icuText.plus().flatten().trim()).pick(1).star() &
          closeCurly)
      .map((values) => CustomFormatMessage(values.first, values[1],
          values[2].map<String>((v) => v as String).toList()));

  Parser<ExpressionSubstitution> get parameter =>
      (openCurly & expression & closeCurly)
          .pick(1)
          .map((param) => ExpressionSubstitution(param));

  Parser get variable =>
      intlNumber |
      intlDate |
      intlTime |
      intlSelect |
      intlPlural |
      custom |
      parameter;

  Parser<ComposedMessage> get simpleText =>
      (messageText | variable).plus().map((l) => ComposedMessage(
          l.map<IntlMessage>((v) => v as IntlMessage).toList()));

  Parser<LiteralString> get empty => epsilon().map((_) => LiteralString(''));

  Parser<IntlMessage> get message => (simpleText | empty).cast();

  IcuParser() {
    // There is a cycle here, so we need the explicit set to avoid
    // infinite recursion.
    interiorText.set(message);
  }

  IntlMessage parse(String string) => message.parse(string).value;
}
