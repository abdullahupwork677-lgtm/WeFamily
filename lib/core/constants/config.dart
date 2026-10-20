class AppConfig {
  static const bool useMockData = true;
  static const String appName = 'WeFamily';
  static const String defaultInviteBase = 'https://wefamily.app/join/';

  /// Mapbox public token (pk.*). Empty string falls back to OSM tiles.
  /// Get it from https://account.mapbox.com/access-tokens/
  static const String mapboxToken =
      'pk.eyJ1IjoibXJ3YWpoaXF1cmVzaGkiLCJhIjoiY212ZnByajZnMDNnbzJ4cjZyYmE2bzRmaiJ9.Wflc8FyK77vmzmX3jUkM1g';

  /// Mapbox raster styles used by the optional layer switcher.
  static const List<String> mapboxStyles = [
    'dark-v11',
    'streets-v12',
    'satellite-streets-v12',
  ];

  /// Default soft light map (CARTO Positron). Swap here for MapTiler/Mapbox.
  static const String tileLightUrl =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

  /// Standard street style (CARTO Voyager).
  static const String tileStandardUrl =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

  /// Satellite imagery (Esri World Imagery).
  static const String tileSatelliteUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
}
