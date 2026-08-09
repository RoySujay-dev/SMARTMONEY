/// Mirrors the backend `StoreDetailsResponse` contract.
class StoreDetails {
  const StoreDetails({
    required this.id,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    required this.websiteUrl,
    this.defaultCashbackText,
    required this.isFeatured,
  });

  final String id;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String websiteUrl;
  final String? defaultCashbackText;
  final bool isFeatured;

  factory StoreDetails.fromJson(Map<String, dynamic> json) {
    return StoreDetails(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      shortDescription: json['shortDescription'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String? ?? '',
      defaultCashbackText: json['defaultCashbackText'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }
}
