import 'offer_list_item.dart';
import 'store_list_item.dart';

/// Mirrors the backend `SearchResultResponse` contract.
class SearchResult {
  const SearchResult({
    required this.stores,
    required this.offers,
  });

  final List<StoreListItem> stores;
  final List<OfferListItem> offers;

  bool get isEmpty => stores.isEmpty && offers.isEmpty;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final storesJson = json['stores'] as List<dynamic>? ?? const [];
    final offersJson = json['offers'] as List<dynamic>? ?? const [];

    return SearchResult(
      stores: storesJson
          .whereType<Map<String, dynamic>>()
          .map(StoreListItem.fromJson)
          .toList(),
      offers: offersJson
          .whereType<Map<String, dynamic>>()
          .map(OfferListItem.fromJson)
          .toList(),
    );
  }
}
