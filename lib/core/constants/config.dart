class AppConfig {
  static const bool useMockData = true;
  static const String appName = 'WeFamily';
  static const String defaultInviteBase = 'https://wefamily.app/join/';

  /// Mapbox public token (pk.*). Empty string falls back to OSM tiles.
  /// Get it from https://account.mapbox.com/access-tokens/
  static const String mapboxToken =
      'pk.eyJ1IjoibXJ3YWpoaXF1cmVzaGkiLCJhIjoiY212ZnByajZnMDNnbzJ4cjZyYmE2bzRmaiJ9.Wflc8FyK77vmzmX3jUkM1g';

  /// Mapbox raster styles used by the map layer switcher.
  static const List<String> mapboxStyles = [
    'dark-v11',
    'streets-v12',
    'satellite-streets-v12',
  ];
}
