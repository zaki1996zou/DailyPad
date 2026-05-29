class TextHelpers {
  TextHelpers._();

  static String normalize(String value) => value.trim().toLowerCase();

  static bool matchesQuery(String haystack, String query) {
    if (query.isEmpty) return true;
    return normalize(haystack).contains(normalize(query));
  }
}
