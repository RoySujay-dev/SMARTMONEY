import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_money_mobile/core/network/api_exception.dart';
import 'package:smart_money_mobile/features/browsing/data/services/browsing_api_service.dart';

const String _base = 'http://test.local';

BrowsingApiService _serviceReturning(
  dynamic body, {
  int status = 200,
  void Function(http.Request request)? onRequest,
}) {
  final client = MockClient((request) async {
    onRequest?.call(request);
    return http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );
  });
  return BrowsingApiService(client: client, baseUrl: _base);
}

void main() {
  group('BrowsingApiService', () {
    test('getCategories hits /api/categories and parses list', () async {
      Uri? requested;
      final service = _serviceReturning(
        [
          {'id': 'c1', 'name': 'Fashion', 'slug': 'fashion', 'displayOrder': 0},
        ],
        onRequest: (r) => requested = r.url,
      );

      final categories = await service.getCategories();

      expect(requested.toString(), '$_base/api/categories');
      expect(categories, hasLength(1));
      expect(categories.first.slug, 'fashion');
    });

    test('getStoresByCategory encodes the slug', () async {
      Uri? requested;
      final service = _serviceReturning(
        <dynamic>[],
        onRequest: (r) => requested = r.url,
      );

      await service.getStoresByCategory('home & living');

      // Uri.encodeComponent encodes both the space and the ampersand.
      expect(
        requested.toString(),
        '$_base/api/categories/home%20%26%20living/stores',
      );
    });

    test('getStoreDetails maps a 404 to a not-found ApiException', () async {
      final service = _serviceReturning(
        {'message': 'nope'},
        status: 404,
      );

      expect(
        () => service.getStoreDetails('missing'),
        throwsA(
          isA<ApiException>().having((e) => e.isNotFound, 'isNotFound', true),
        ),
      );
    });

    test('non-2xx list response throws ApiException', () async {
      final service = _serviceReturning(
        {'message': 'boom'},
        status: 500,
      );

      expect(
        () => service.getOffers(),
        throwsA(isA<ApiException>()),
      );
    });

    test('search with blank query does not hit the network', () async {
      var called = false;
      final client = MockClient((request) async {
        called = true;
        return http.Response('{}', 200);
      });
      final service = BrowsingApiService(client: client, baseUrl: _base);

      final result = await service.search('   ');

      expect(called, isFalse);
      expect(result.isEmpty, isTrue);
    });

    test('search sends a trimmed, encoded q parameter', () async {
      Uri? requested;
      final service = _serviceReturning(
        {'stores': <dynamic>[], 'offers': <dynamic>[]},
        onRequest: (r) => requested = r.url,
      );

      await service.search('  myntra deals  ');

      expect(requested!.path, '/api/search');
      expect(requested!.queryParameters['q'], 'myntra deals');
    });

    test('getOfferDetails parses the payload', () async {
      final service = _serviceReturning({
        'id': 'o1',
        'storeId': 's1',
        'storeName': 'Myntra',
        'storeSlug': 'myntra',
        'title': 'Deal',
        'slug': 'deal',
        'offerType': 'Cashback',
        'cashbackType': 'Percentage',
        'destinationUrl': 'https://x/y',
        'isFeatured': false,
      });

      final offer = await service.getOfferDetails('deal');

      expect(offer.slug, 'deal');
      expect(offer.destinationUrl, 'https://x/y');
    });
  });
}
