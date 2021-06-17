import 'package:dart_validate/dart_validate.dart';
import 'package:test/test.dart';

class _NotAJsonObject {
  final String message = "I am not the right one";
}

class _IAmAJsonObject extends _NotAJsonObject {
  dynamic toJson() {
    return [message];
  }
}

/// A matcher for [IllegalStateError].
const isIllegalStateError = const TypeMatcher<IllegalStateError>();

/// A matcher for functions that throw IllegalStateError.
// ignore: deprecated_member_use
const Matcher throwsIllegalStateError = const Throws(isIllegalStateError);

main() {
  // final _logger = new Logger('DartValidate.testDartValidate');
  // configLogging();

  group('Validator-Test', () {
    test('isTrue', () {
      expect(() => (DartValidate.isTrue(true)), returnsNormally);
      expect(() => (DartValidate.isTrue(false)), throwsArgumentError);
    });

    test('> notNull', () {
      expect(() => (DartValidate.notNull("Test")), returnsNormally);
      expect(() => (DartValidate.notNull(null)), throwsArgumentError);
    });

    test('> notEmpty', () {
      expect(() => (DartValidate.notEmpty("Test")), returnsNormally);
      expect(() => (DartValidate.notEmpty([10, 20])), returnsNormally);

      final Map<String, Object> map = new Map<String, Object>();
      expect(() => (DartValidate.notEmpty(map)), throwsArgumentError);

      map["Hallo"] = "Test";
      expect(() => (DartValidate.notEmpty(map)), returnsNormally);

      // int has not Method "isEmpty"
      expect(() => (DartValidate.notEmpty(0)), throwsNoSuchMethodError);

      expect(() => (DartValidate.notEmpty("")), throwsArgumentError);
    });

    test('> notBlank', () {
      expect(() => (DartValidate.notBlank("Test")), returnsNormally);
      expect(() => (DartValidate.notBlank(null)), throwsArgumentError);
      expect(() => (DartValidate.notBlank("")), throwsArgumentError);

      // Dart should point out at least a warning!!!!
      //expect(() => (DartValidate.notBlank(10)),throwsA(new isInstanceOf<ArgumentError>()));
    });

    test('> noNullElements', () {
      expect(() => (DartValidate.noNullElements([1, 2, 3, 4])), returnsNormally);

      final List<String?> list = []..addAll(["one", "two", "three"]);

      expect(() => (DartValidate.noNullElements(list)), returnsNormally);

      list.add(null);
      expect(4, list.length);
      expect(() => (DartValidate.noNullElements(list)), throwsArgumentError);

      expect(() => (DartValidate.noNullElements([])), returnsNormally);
    });

    test('> validIndex', () {
      expect(() => (DartValidate.validIndex([1, 2], 1)), returnsNormally);
      expect(() => (DartValidate.validIndex([1, 2], 3)), throwsRangeError);

      final List<String> list = []..addAll(["one", "two", "three"]);

      expect(() => (DartValidate.validIndex(list, 1)), returnsNormally);
    });

    test('> validState', () {
      expect(() => (DartValidate.validState(true)), returnsNormally);
      expect(() => (DartValidate.validState(false)), throwsIllegalStateError);
    });

    test('> matchesPattern', () {
      expect(
          () => (DartValidate.matchesPattern("Test", new RegExp("^\\we\\w{2}\$"))),
          returnsNormally);
      expect(
          () => (DartValidate.matchesPattern("Te_st", new RegExp("^\\we\\w{2}\$"))),
          throwsA(new isInstanceOf<ArgumentError>()));

      expect(() => (DartValidate.isEmail("urbi@orbi.it")), returnsNormally);
      expect(() => (DartValidate.isEmail("urbi@orbit")), throwsArgumentError);

      expect(() => (DartValidate.isAlphaNumeric("123abcdö")), returnsNormally);
      expect(() => (DartValidate.isAlphaNumeric("123a#bcd")), throwsArgumentError);

      expect(() => (DartValidate.isHex("1234567890abcdef")), returnsNormally);
      expect(() => (DartValidate.isHex("0x1234567890abcdef")), returnsNormally);
      expect(() => (DartValidate.isHex("1234567890abcdefg")), throwsArgumentError);
    });

    test('> password', () {
      expect(() => (DartValidate.isPassword("1abcdefGH#")), returnsNormally);
      expect(() => (DartValidate.isPassword("1abcdefGH?")), returnsNormally);

      expect(() => (DartValidate.isPassword("urbi@orbi.it")), throwsArgumentError);
      expect(() => (DartValidate.isPassword("1234567890abcdefGH#")),
          throwsArgumentError);
      expect(() => (DartValidate.isPassword("12345678aA# ")), throwsArgumentError);
      expect(() => (DartValidate.isPassword("12345678aA'")), throwsArgumentError);
      expect(() => (DartValidate.isPassword("")), throwsArgumentError);
      expect(() => (DartValidate.isPassword("1abcdefGH;")), throwsArgumentError);
    });

    test('> inclusive', () {
      expect(() => (DartValidate.inclusiveBetween(0, 2, 2)), returnsNormally);
      expect(() => (DartValidate.inclusiveBetween(0, 2, 3)), throwsArgumentError);

      expect(() => (DartValidate.exclusiveBetween(0, 2, 2)), throwsArgumentError);
      expect(() => (DartValidate.exclusiveBetween(0, 2, 1)), returnsNormally);
    });

    test('> json', () {
      expect(() => (DartValidate.isJson("Test")), returnsNormally);
      expect(() => (DartValidate.isJson(1)), returnsNormally);
      expect(() => (DartValidate.isJson(["3", "4"])), returnsNormally);

      expect(
          () => (DartValidate.isJson(new _NotAJsonObject())), throwsArgumentError);
      expect(() => (DartValidate.isJson(new _IAmAJsonObject())), returnsNormally);
    });

    test('> key in Map', () {
      final Map<String, dynamic> map1ToTest = new Map<String, dynamic>();
      map1ToTest.putIfAbsent("name", () => "Mike");
      map1ToTest.putIfAbsent("number", () => 42);

      expect(() => (DartValidate.isKeyInMap("name", map1ToTest)), returnsNormally);
      expect(
          () => (DartValidate.isKeyInMap("number", map1ToTest)), returnsNormally);

      //expect(() => (DartValidate.isKeyInMap("email",map1ToTest)),returnsNormally);
      expect(() => (DartValidate.isKeyInMap("email", map1ToTest)),
          throwsArgumentError);

      try {
        DartValidate.isKeyInMap("email", map1ToTest);
        expect(false, isTrue);
      } on ArgumentError catch (e) {
        // Strip out all whitespaces
        expect(e.message.replaceAll(new RegExp("\\s+"), " "),
            "The key 'email' is not available for this structure: { \"name\": \"Mike\", \"number\": 42 }");
      }
    });

    test('> isInstanceOf', () {
      expect(() => (DartValidate.isInstance(new instanceCheck<List<String>>(), [])),
          throwsArgumentError);

      expect(
          () => (DartValidate.isInstance(
              new instanceCheck<List<String>>(strict: false), [])),
          returnsNormally);

      expect(() => (DartValidate.isInstance(new instanceCheck<String>(), "Test")),
          returnsNormally);
      expect(() => (DartValidate.isInstance(new instanceCheck<String>(), 1)),
          throwsArgumentError);
      expect(
          () => (DartValidate.isInstance(
              new instanceCheck<String>(strict: false), 1)),
          throwsArgumentError);

      expect(() => (DartValidate.isInstance(new instanceCheck<int>(), 29)),
          returnsNormally);
      expect(() => (DartValidate.isInstance(new instanceCheck<String>(), 1)),
          throwsArgumentError);

      expect(
          () => (DartValidate.isInstance(
              new instanceCheck<num>(strict: false), 29.0)),
          returnsNormally);
      expect(() => (DartValidate.isInstance(new instanceCheck<num>(), 29.0)),
          throwsArgumentError);
      expect(
          () =>
              (DartValidate.isInstance(new instanceCheck<num>(strict: false), 29)),
          returnsNormally);

      expect(() => (DartValidate.isInstance(null!, 29.0)), throwsArgumentError);
    });
  });
}
