library intl_message.parser;

import 'package:intl_message/intl_message.dart';
import 'package:petitparser/petitparser.dart';

class IcuParser {
  Parser get openCurly => char("{");

  Parser get closeCurly => char("}");

  Parser get quotedCurly => (string("'{'") | string("'}'")).map((x) => x[1]);

  Parser get icuEscapedText => quotedCurly | twoSingleQuotes;

  Parser get curly => (openCurly | closeCurly);

  Parser get notAllowedInIcuText => curly | styleStart;

  Parser get icuText => notAllowedInIcuText.neg();

  Parser get styleStart =>
      string("<style") &
      (whitespace() & char(">").neg().star()).optional() &
      char(">");

  Parser get styleEnd => string("</style>");

  Parser get styleContent => styleEnd.neg().star();

  Parser get style => (styleStart & styleContent & styleEnd).flatten();

  Parser get notAllowedInNormalText => openCurly;

  Parser get normalText => notAllowedInNormalText.neg();

  Parser get messageText => (icuEscapedText | icuText | style)
      .plus()
      .flatten()
      .map((v) => new LiteralString(v));

  Parser get nonIcuMessageText =>
      normalText.plus().flatten().map((v) => new LiteralString(v));

  Parser get twoSingleQuotes => string("''").map((x) => "'");

  Parser get number => digit().plus().flatten().trim().map(int.parse);

  Parser get simpleId =>
      ((letter() | char("_")) & (word() | char("_")).star()).flatten();

  Parser get id => simpleId
      .map((v) => new Variable(v))
      .seq(char(".").seq(simpleId).pick(1).star())
      .map((v) => (v[1] as List).fold(v[0], (a, b) => a.subIndex(b)))
      .trim();

  Parser get comma => char(",").trim();

  /// Given a list of possible keywords, return a rule that accepts any of them.
  /// e.g., given ["male", "female", "other"], accept any of them.
  Parser asKeywords(list) =>
      list.map(string).reduce((a, b) => a | b).flatten().trim();

  Parser get pluralKeyword =>
      asKeywords(["zero", "one", "two", "few", "many", "other"]) |
      (char("=") & digit().plus()).flatten().trim();

  Parser get genderKeyword => asKeywords(["female", "male", "other"]);

  SettableParser interiorText = undefined();

  Parser get preface => (openCurly & id & comma).pick(1);

  Parser get numberLiteral => string("number");

  Parser get intlNumber => (preface &
          numberLiteral &
          (comma & icuText.plus().flatten().trim()).pick(1).optional() &
          closeCurly)
      .map((values) => new NumberMessage(values[0], values[2]));

  Parser get dateLiteral => string("date");

  Parser get dateFormat => icuText.plus().flatten().trim();

  Parser get intlDate => (preface &
          dateLiteral &
          (comma & dateFormat).pick(1).optional() &
          closeCurly)
      .map((values) => new DateTimeMessage.date(values[0], values[2]));

  Parser get timeLiteral => string("time");

  Parser get timeFormat => icuText.plus().flatten().trim();

  Parser get intlTime => (preface &
          timeLiteral &
          (comma & timeFormat).pick(1).optional() &
          closeCurly)
      .map((values) => new DateTimeMessage.time(values[0], values[2]));

  Parser get pluralLiteral => string("plural") | string("selectordinal");

  Parser get pluralClause =>
      (pluralKeyword & openCurly & interiorText & closeCurly)
          .trim()
          .permute([0, 2]);

  Parser get pluralClauses => pluralClause.plus().map((l) =>
      new Map<String, IntlMessage>.fromIterable(l,
          key: (v) => v.first, value: (v) => v.last));

  Parser get offset =>
      (string("offset:") & digit().plus().flatten().map(int.parse)).pick(1);

  Parser get plural =>
      preface &
      pluralLiteral &
      comma &
      offset.optional() &
      pluralClauses &
      closeCurly;

  Parser get intlPlural => plural.map((values) => values[1] == "plural"
      ? new PluralMessage(values.first, values[4], offset: values[3] ?? 0)
      : new SelectOrdinalMessage(values.first, values[4],
          offset: values[3] ?? 0));

  Parser get selectLiteral => string("select");

  Parser get selectClause =>
      (simpleId.trim() & openCurly & interiorText & closeCurly)
          .trim()
          .permute([0, 2]);

  Parser get selectClauses => selectClause.plus().map((l) =>
      new Map<String, IntlMessage>.fromIterable(l,
          key: (v) => v.first, value: (v) => v.last));

  Parser get generalSelect =>
      preface & selectLiteral & comma & selectClauses & closeCurly;

  Parser get intlSelect =>
      generalSelect.map((values) => new SelectMessage(values.first, values[3]));

  Parser get custom => (preface &
          id &
          (comma & icuText.plus().flatten().trim()).pick(1).star() &
          closeCurly)
      .map((values) => new CustomFormatMessage(values.first, values[1],
          values[2].map<String>((v) => v as String).toList()));

  Parser get parameter => (openCurly & id & closeCurly)
      .pick(1)
      .map((param) => new VariableSubstitution(param));

  Parser get variable =>
      intlNumber |
      intlDate |
      intlTime |
      intlSelect |
      intlPlural |
      custom |
      parameter;

  Parser get simpleText =>
      (messageText | variable).plus().map((l) => new ComposedMessage(
          l.map<IntlMessage>((v) => v as IntlMessage).toList()));

  Parser get empty => epsilon().map((_) => new LiteralString(''));

  Parser get message => (simpleText | empty);

  IcuParser() {
    // There is a cycle here, so we need the explicit set to avoid
    // infinite recursion.
    interiorText.set(message);
  }

  IntlMessage parse(String string) => message.parse(string).value;
}
