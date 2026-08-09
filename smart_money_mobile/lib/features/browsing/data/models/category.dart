/// Mirrors the backend `CategoryListItemResponse` contract.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconUrl,
    required this.displayOrder,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;
  final int displayOrder;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
