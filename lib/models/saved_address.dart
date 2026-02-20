class SavedAddress {
  final String label;
  final String addressLine;
  final double lat;
  final double lng;

  const SavedAddress({
    required this.label,
    required this.addressLine,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
    "label": label,
    "addressLine": addressLine,
    "lat": lat,
    "lng": lng,
  };

  static SavedAddress? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    return SavedAddress(
      label: (raw["label"] ?? "").toString(),
      addressLine: (raw["addressLine"] ?? "").toString(),
      lat: (raw["lat"] as num?)?.toDouble() ?? 0,
      lng: (raw["lng"] as num?)?.toDouble() ?? 0,
    );
  }
}