/// Base URL of the Backend ASP.NET Core API for the current run target.
///
/// Matches the `http` profile in `Backend/Properties/launchSettings.json`
/// (`http://localhost:5116`). Always `localhost` — including on Android —
/// rather than the AVD emulator's `10.0.2.2` alias, because that alias only
/// resolves on the virtual emulator NAT and breaks on a real phone. Instead,
/// run `adb reverse tcp:5116 tcp:5116` once per USB connection so the
/// device's own `localhost:5116` transparently forwards to the host's; this
/// works for both the emulator and a physical device with one code path.
String get apiBaseUrl {
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
