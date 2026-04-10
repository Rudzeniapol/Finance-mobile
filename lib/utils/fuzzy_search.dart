/// Pure-Dart fuzzy search using Levenshtein distance.
///
/// Usage:
///   // Simple match check
///   FuzzySearch.matches('kfcc', 'KFC')           // true  (one extra char)
///   FuzzySearch.matches('paypl', 'Paypal')        // true  (contains)
///
///   // Rank a list
///   FuzzySearch.search('repair', transactions, (t) => [t.title, t.category.name])
class FuzzySearch {
  // ── Levenshtein distance ────────────────────────────────────────────────────

  static int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final d = List.generate(
      s.length + 1,
      (i) => List.generate(t.length + 1, (j) => i == 0 ? j : (j == 0 ? i : 0)),
    );

    for (var i = 1; i <= s.length; i++) {
      for (var j = 1; j <= t.length; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1,
          d[i][j - 1] + 1,
          d[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return d[s.length][t.length];
  }

  // ── Normalised similarity [0.0 – 1.0] ─────────────────────────────────────

  static double similarity(String a, String b) {
    a = a.toLowerCase();
    b = b.toLowerCase();
    if (a.isEmpty && b.isEmpty) return 1.0;
    final maxLen = a.length > b.length ? a.length : b.length;
    return 1.0 - _levenshtein(a, b) / maxLen;
  }

  // ── Best score of query against any sliding window of target ───────────────

  static double _bestScore(String query, String target) {
    final q = query.toLowerCase().trim();
    final t = target.toLowerCase();
    if (q.isEmpty) return 1.0;
    // Fast path: exact substring
    if (t.contains(q)) return 1.0;
    double best = similarity(q, t);
    if (q.length <= t.length) {
      for (var i = 0; i <= t.length - q.length; i++) {
        final window = t.substring(i, i + q.length);
        final s = similarity(q, window);
        if (s > best) best = s;
      }
    }
    return best;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns true when [query] fuzzy-matches [target] at or above [threshold].
  static bool matches(String query, String target,
      {double threshold = 0.45}) {
    if (query.isEmpty) return true;
    return _bestScore(query, target) >= threshold;
  }

  /// Filter [items] by [query] across the field strings returned by
  /// [getFields], then sort by descending relevance.
  ///
  /// Items with no field scoring above 0.30 are excluded.
  static List<T> search<T>(
    String query,
    List<T> items,
    List<String> Function(T item) getFields,
  ) {
    if (query.isEmpty) return List.from(items);

    final scored = <({T item, double score})>[];
    for (final item in items) {
      final fields = getFields(item);
      double best = 0;
      for (final field in fields) {
        final s = _bestScore(query, field);
        if (s > best) best = s;
      }
      if (best > 0.30) scored.add((item: item, score: best));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.item).toList();
  }
}
