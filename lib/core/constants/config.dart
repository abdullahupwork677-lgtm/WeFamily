class AppConfig {
  /// Real Firebase mode by default. Demo builds/tests can opt in with
  /// `--dart-define=USE_MOCK_DATA=true`.
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: false,
  );
  static const String appName = 'WeFamily';
  static const String defaultInviteBase = 'https://wefamily.app/join/';

  /// Mapbox public token (safe to embed). Get it from
  /// https://account.mapbox.com/access-tokens/
  static const String mapboxToken =
      'pk.eyJ1IjoibXJ3YWpoaXF1cmVzaGkiLCJhIjoiY212ZnByajZnMDNnbzJ4cjZyYmE2bzRmaiJ9.Wflc8FyK77vmzmX3jUkM1g';

  static String _mapboxStyle(String style) =>
      'https://api.mapbox.com/styles/v1/mapbox/$style/tiles/256/{z}/{x}/{y}'
      '?access_token=$mapboxToken';

  /// Default soft light map (Mapbox Light), matches the reference design.
  static final String tileLightUrl = _mapboxStyle('light-v11');

  /// Standard street style (Mapbox Streets).
  static final String tileStandardUrl = _mapboxStyle('streets-v12');

  /// Satellite imagery with labels (Mapbox Satellite Streets).
  static final String tileSatelliteUrl = _mapboxStyle('satellite-streets-v12');

  /// Cloudinary unsigned uploads (Firebase Storage is not available on the
  /// current plan). These values are public by design.
  static const String cloudinaryCloud = 'a14novzi';
  static const String cloudinaryPreset = 'ml_default';
  static const String cloudinaryImageUrl =
      'https://api.cloudinary.com/v1_1/$cloudinaryCloud/image/upload';
  static const String cloudinaryVideoUrl =
      'https://api.cloudinary.com/v1_1/$cloudinaryCloud/video/upload';
}
