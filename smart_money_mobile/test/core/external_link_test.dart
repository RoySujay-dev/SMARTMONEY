import 'package:flutter_test/flutter_test.dart';
import 'package:smart_money_mobile/core/utils/external_link.dart';

void main() {
  group('ExternalLink.parse', () {
    test('accepts http and https store URLs', () {
      expect(ExternalLink.parse('https://www.myntra.com')?.host, 'www.myntra.com');
      expect(ExternalLink.parse('http://example.com/deal')?.scheme, 'http');
    });

    test('trims surrounding whitespace', () {
      expect(ExternalLink.parse('  https://www.flipkart.com  ')?.host,
          'www.flipkart.com');
    });

    test('rejects null, empty and whitespace', () {
      expect(ExternalLink.parse(null), isNull);
      expect(ExternalLink.parse(''), isNull);
      expect(ExternalLink.parse('   '), isNull);
    });

    test('rejects non-http schemes so the API cannot trigger other intents', () {
      expect(ExternalLink.parse('javascript:alert(1)'), isNull);
      expect(ExternalLink.parse('file:///etc/passwd'), isNull);
      expect(ExternalLink.parse('tel:+911234567890'), isNull);
    });

    test('rejects a URL with no authority', () {
      expect(ExternalLink.parse('https://'), isNull);
      expect(ExternalLink.parse('not a url'), isNull);
    });
  });
}
