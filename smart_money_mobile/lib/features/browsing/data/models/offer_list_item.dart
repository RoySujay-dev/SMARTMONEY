/// Mirrors the backend `OfferListItemResponse` contract.
class OfferListItem {
  const OfferListItem({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.storeSlug,
    required this.title,
    required this.slug,
    required this.offerType,
    this.shortDescription,
    this.imageUrl,
    required this.cashbackType,
    this.cashbackValue,
    this.cashbackText,
    this.couponCode,
    this.startAt,
    this.endAt,
    required this.isFeatured,
    required this.priority,
  });

  final String id;
  final String storeId;
  final String storeName;
  final String storeSlug;
  final String title;
  final String slug;
  final String offerType;
  final String? shortDescription;
  final String? imageUrl;
  final String cashbackType;
  final double? cashbackValue;
  final String? cashbackText;
  final String? couponCode;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool isFeatured;
  final int priority;

  factory OfferListItem.fromJson(Map<String, dynamic> json) {
    final startAtRaw = json['startAt'] as String?;
    final endAtRaw = json['endAt'] as String?;

    return OfferListItem(
      id: json['id'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      storeName: json['storeName'] as String? ?? '',
      storeSlug: json['storeSlug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      offerType: json['offerType'] as String? ?? '',
      shortDescription: json['shortDescription'] as String?,
      imageUrl: json['imageUrl'] as String?,
      cashbackType: json['cashbackType'] as String? ?? '',
      cashbackValue: (json['cashbackValue'] as num?)?.toDouble(),
      cashbackText: json['cashbackText'] as String?,
      couponCode: json['couponCode'] as String?,
      startAt: startAtRaw == null ? null : DateTime.tryParse(startAtRaw),
      endAt: endAtRaw == null ? null : DateTime.tryParse(endAtRaw),
      isFeatured: json['isFeatured'] as bool? ?? false,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
    );
  }
}
