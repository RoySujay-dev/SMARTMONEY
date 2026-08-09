import 'package:flutter_test/flutter_test.dart';
import 'package:smart_money_mobile/features/browsing/data/models/category.dart';
import 'package:smart_money_mobile/features/browsing/data/models/offer_details.dart';
import 'package:smart_money_mobile/features/browsing/data/models/offer_list_item.dart';
import 'package:smart_money_mobile/features/browsing/data/models/search_result.dart';
import 'package:smart_money_mobile/features/browsing/data/models/store_details.dart';
import 'package:smart_money_mobile/features/browsing/data/models/store_list_item.dart';

void main() {
  group('Category.fromJson', () {
    test('parses full payload', () {
      final category = Category.fromJson({
        'id': 'c1',
        'name': 'Fashion',
        'slug': 'fashion',
        'description': 'Clothing and more',
        'iconUrl': 'https://cdn/x.png',
        'displayOrder': 3,
      });

      expect(category.id, 'c1');
      expect(category.name, 'Fashion');
      expect(category.slug, 'fashion');
      expect(category.description, 'Clothing and more');
      expect(category.iconUrl, 'https://cdn/x.png');
      expect(category.displayOrder, 3);
    });

    test('keeps nullable fields null and defaults order', () {
      final category = Category.fromJson({
        'id': 'c1',
        'name': 'Fashion',
        'slug': 'fashion',
        'description': null,
        'iconUrl': null,
      });

      expect(category.description, isNull);
      expect(category.iconUrl, isNull);
      expect(category.displayOrder, 0);
    });
  });

  group('StoreListItem.fromJson', () {
    test('parses and defaults isFeatured', () {
      final store = StoreListItem.fromJson({
        'id': 's1',
        'name': 'Myntra',
        'slug': 'myntra',
        'shortDescription': null,
        'logoUrl': null,
        'defaultCashbackText': 'Up to 10%',
        'displayOrder': 1,
      });

      expect(store.name, 'Myntra');
      expect(store.slug, 'myntra');
      expect(store.shortDescription, isNull);
      expect(store.logoUrl, isNull);
      expect(store.defaultCashbackText, 'Up to 10%');
      expect(store.isFeatured, isFalse);
    });
  });

  group('StoreDetails.fromJson', () {
    test('parses website and nullable banner', () {
      final store = StoreDetails.fromJson({
        'id': 's1',
        'name': 'Myntra',
        'slug': 'myntra',
        'shortDescription': 'Fashion',
        'description': null,
        'logoUrl': null,
        'bannerUrl': null,
        'websiteUrl': 'https://myntra.com',
        'defaultCashbackText': null,
        'isFeatured': true,
      });

      expect(store.websiteUrl, 'https://myntra.com');
      expect(store.bannerUrl, isNull);
      expect(store.isFeatured, isTrue);
    });
  });

  group('OfferListItem.fromJson', () {
    test('parses dates, nullable decimal and coupon', () {
      final offer = OfferListItem.fromJson({
        'id': 'o1',
        'storeId': 's1',
        'storeName': 'Myntra',
        'storeSlug': 'myntra',
        'title': '10% cashback',
        'slug': 'myntra-10-percent',
        'offerType': 'Cashback',
        'shortDescription': null,
        'imageUrl': null,
        'cashbackType': 'Percentage',
        'cashbackValue': 10,
        'cashbackText': 'Up to 10%',
        'couponCode': null,
        'startAt': '2026-08-01T00:00:00Z',
        'endAt': null,
        'isFeatured': true,
        'priority': 5,
      });

      expect(offer.slug, 'myntra-10-percent');
      expect(offer.cashbackValue, 10.0);
      expect(offer.couponCode, isNull);
      expect(offer.startAt, isNotNull);
      expect(offer.endAt, isNull);
      expect(offer.isFeatured, isTrue);
      expect(offer.priority, 5);
    });

    test('handles missing cashbackValue as null', () {
      final offer = OfferListItem.fromJson({
        'id': 'o1',
        'storeId': 's1',
        'storeName': 'Myntra',
        'storeSlug': 'myntra',
        'title': 'Flat deal',
        'slug': 'flat-deal',
        'offerType': 'Deal',
        'cashbackType': 'Flat',
        'cashbackValue': null,
      });

      expect(offer.cashbackValue, isNull);
      expect(offer.startAt, isNull);
    });
  });

  group('OfferDetails.fromJson', () {
    test('parses destinationUrl and terms', () {
      final offer = OfferDetails.fromJson({
        'id': 'o1',
        'storeId': 's1',
        'storeName': 'Myntra',
        'storeSlug': 'myntra',
        'title': '10% cashback',
        'slug': 'myntra-10-percent',
        'offerType': 'Cashback',
        'description': 'Full description',
        'termsAndConditions': 'Some terms',
        'cashbackType': 'Percentage',
        'cashbackValue': 10,
        'destinationUrl': 'https://myntra.com/deal',
        'isFeatured': false,
      });

      expect(offer.destinationUrl, 'https://myntra.com/deal');
      expect(offer.termsAndConditions, 'Some terms');
      expect(offer.description, 'Full description');
    });
  });

  group('SearchResult.fromJson', () {
    test('parses both groups', () {
      final result = SearchResult.fromJson({
        'stores': [
          {'id': 's1', 'name': 'Myntra', 'slug': 'myntra', 'displayOrder': 0},
        ],
        'offers': [
          {
            'id': 'o1',
            'storeId': 's1',
            'storeName': 'Myntra',
            'storeSlug': 'myntra',
            'title': 'Deal',
            'slug': 'deal',
            'offerType': 'Cashback',
            'cashbackType': 'Percentage',
          },
        ],
      });

      expect(result.stores, hasLength(1));
      expect(result.offers, hasLength(1));
      expect(result.isEmpty, isFalse);
    });

    test('treats missing arrays as empty', () {
      final result = SearchResult.fromJson({});
      expect(result.stores, isEmpty);
      expect(result.offers, isEmpty);
      expect(result.isEmpty, isTrue);
    });
  });
}
