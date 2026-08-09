/// Mirrors the backend `StoreListItemResponse` contract.
class StoreListItem {
  const StoreListItem({
    required this.id,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.logoUrl,
    this.defaultCashbackText,
    required this.isFeatured,
    required this.displayOrder,
  });

  final String id;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? logoUrl;
  final String? defaultCashbackText;
  final bool isFeatured;
  final int displayOrder;

  factory StoreListItem.fromJson(Map<String, dynamic> json) {
    return StoreListItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      shortDescription: json['shortDescription'] as String?,
      logoUrl: json['logoUrl'] as String?,
      defaultCashbackText: json['defaultCashbackText'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
