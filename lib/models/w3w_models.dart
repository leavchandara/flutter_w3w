// What3words API models

class W3WCoordinates {
  final double lat;
  final double lng;

  W3WCoordinates({required this.lat, required this.lng});

  factory W3WCoordinates.fromJson(Map<String, dynamic> json) {
    return W3WCoordinates(
      lat: json['lat']?.toDouble() ?? 0.0,
      lng: json['lng']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  String toString() => 'W3WCoordinates(lat: $lat, lng: $lng)';
}

class W3WAddress {
  final String words;
  final String? country;
  final String? nearestPlace;
  final W3WCoordinates? coordinates;
  final String? language;
  final String? map;

  W3WAddress({
    required this.words,
    this.country,
    this.nearestPlace,
    this.coordinates,
    this.language,
    this.map,
  });

  factory W3WAddress.fromJson(Map<String, dynamic> json) {
    return W3WAddress(
      words: json['words'] ?? '',
      country: json['country'],
      nearestPlace: json['nearestPlace'],
      coordinates: json['coordinates'] != null
          ? W3WCoordinates.fromJson(json['coordinates'])
          : null,
      language: json['language'],
      map: json['map'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'words': words,
      'country': country,
      'nearestPlace': nearestPlace,
      'coordinates': coordinates?.toJson(),
      'language': language,
      'map': map,
    };
  }

  @override
  String toString() => 'W3WAddress(words: $words, coordinates: $coordinates)';
}

class W3WSuggestion {
  final String words;
  final int rank;
  final String? country;
  final String? nearestPlace;
  final int? distanceToFocus;

  W3WSuggestion({
    required this.words,
    required this.rank,
    this.country,
    this.nearestPlace,
    this.distanceToFocus,
  });

  factory W3WSuggestion.fromJson(Map<String, dynamic> json) {
    return W3WSuggestion(
      words: json['words'] ?? '',
      rank: json['rank'] ?? 0,
      country: json['country'],
      nearestPlace: json['nearestPlace'],
      distanceToFocus: json['distanceToFocus'],
    );
  }

  @override
  String toString() => 'W3WSuggestion(words: $words, rank: $rank)';
}

class W3WGridSection {
  final String northeast;
  final String southwest;
  final List<W3WGridLine> lines;

  W3WGridSection({
    required this.northeast,
    required this.southwest,
    required this.lines,
  });

  factory W3WGridSection.fromJson(Map<String, dynamic> json) {
    return W3WGridSection(
      northeast: json['northeast'] ?? '',
      southwest: json['southwest'] ?? '',
      lines: (json['lines'] as List<dynamic>?)
              ?.map((line) => W3WGridLine.fromJson(line))
              .toList() ??
          [],
    );
  }
}

class W3WGridLine {
  final W3WCoordinates start;
  final W3WCoordinates end;

  W3WGridLine({required this.start, required this.end});

  factory W3WGridLine.fromJson(Map<String, dynamic> json) {
    return W3WGridLine(
      start: W3WCoordinates.fromJson(json['start']),
      end: W3WCoordinates.fromJson(json['end']),
    );
  }
}

class W3WError {
  final String code;
  final String message;

  W3WError({required this.code, required this.message});

  factory W3WError.fromJson(Map<String, dynamic> json) {
    return W3WError(
      code: json['error']?['code'] ?? 'unknown',
      message: json['error']?['message'] ?? 'An unknown error occurred',
    );
  }

  @override
  String toString() => 'W3WError(code: $code, message: $message)';
}
