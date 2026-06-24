import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

/// Base URL of the Backend ASP.NET Core API for the current run target.
///
/// Matches the `http` profile in `Backend/Properties/launchSettings.json`
/// (`http://localhost:5116`). The Android emulator can't reach the host's
/// `localhost` directly — `10.0.2.2` is its alias for the host machine.
String get apiBaseUrl {
  if (!kIsWeb && Platform.isAndroid) {
    return 'http://10.0.2.2:5116';
  }
  return 'http://localhost:5116';
}

/// Resolves a URL returned by the API to one [Image.network] can load.
///
/// Diagram/thumbnail/hero URLs come back as paths relative to the API's
/// static file root (e.g. `/diagrams/Easy/BallonBase/1.jpg`); this prefixes
/// them with [apiBaseUrl]. Already-absolute URLs are returned unchanged.
String resolveAssetUrl(String url) {
  if (url.isEmpty) return url;
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return '$apiBaseUrl$url';
}
