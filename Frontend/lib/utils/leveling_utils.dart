class LevelingUtils {
  static const List<int> _thresholds = [0, 20, 60, 130, 250, 450];

  static int getLevel(int exp) {
    for (int i = _thresholds.length - 1; i >= 0; i--) {
      if (exp >= _thresholds[i]) return i + 1;
    }
    return 1;
  }

  static int getExpForNextLevel(int level) {
    if (level < _thresholds.length) {
      return _thresholds[level];
    }
    return _thresholds.last;
  }

  static String getRankTitle(int level) {
    if (level < 5) return 'Crane Apprentice';
    return 'Paper Artisan';
  }
}
