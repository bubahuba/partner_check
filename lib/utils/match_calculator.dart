import '../models.dart';
import 'color_utils.dart';

/// Utility class for calculating contact matches
class MatchCalculator {
  /// Calculate match score between two contacts with granularity based on diff
  /// Returns a score where higher values indicate better matches
  /// Prioritizes number of match types (vibrations) over granular score
  /// Uses the diff value (0-36) to create granular scoring within the match range
  static num calculateMatchCount(StoredContact contact1, StoredContact contact2) {
    if (contact1.color == contact2.color) {
      return 0; // Same color means no match
    }

    final color1 = ColorUtils.colorFromValue(contact1.color);
    final color2 = ColorUtils.colorFromValue(contact2.color);
    final overlay1 = ColorUtils.overlayColorFromValue(contact1.color);
    final overlay2 = ColorUtils.overlayColorFromValue(contact2.color);

    // Count number of match types (vibrations)
    int vibrationCount = 0;
    num granularScore = 0;

    // Check base match - score based on how close the match is (diff 0 = perfect, diff 36 = threshold)
    final baseMatch = ColorUtils.areColorsMatching(color1, color2);
    if (baseMatch.$1) {
      vibrationCount++;
      // Score: 1.0 for perfect match (diff=0), decreasing to ~0.0 at diff=30
      // Using inverse relationship: smaller diff = higher score
      granularScore += 2.0 - (baseMatch.$2 / 30.0);
    }

    // Check overlay match
    final overlayMatch = ColorUtils.areColorsMatching(overlay1, overlay2);
    if (overlayMatch.$1) {
      vibrationCount++;
      granularScore += 1.5 - (overlayMatch.$2 / 30.0);
    }

    // Check cross matches
    final crossMatch1 = ColorUtils.areColorsMatching(overlay1, color2);
    if (crossMatch1.$1) {
      vibrationCount++;
      granularScore += 1.3 - (crossMatch1.$2 / 30.0);
    }

    final crossMatch2 = ColorUtils.areColorsMatching(color1, overlay2);
    if (crossMatch2.$1) {
      vibrationCount++;
      granularScore += 1.3 - (crossMatch2.$2 / 30.0);
    }

    // Prioritize vibration count over granular score
    // Multiply vibration count by 2 to ensure it's always the primary factor
    // Add granular score (max ~6.1) as secondary factor
    return (vibrationCount * 2) + granularScore;
  }

  /// Check if two contacts match (for vibrations and flashing)
  /// Returns a tuple of (bool match, MatchDetails details)
  static (bool, MatchDetails) checkForMatch(
    StoredContact contact1,
    StoredContact contact2,
  ) {
    if (contact1.color == contact2.color) {
      return (false, MatchDetails());
    }

    final color1 = ColorUtils.colorFromValue(contact1.color);
    final color2 = ColorUtils.colorFromValue(contact2.color);
    final overlay1 = ColorUtils.overlayColorFromValue(contact1.color);
    final overlay2 = ColorUtils.overlayColorFromValue(contact2.color);

    // Check if base colors match or overlay colors match
    final baseMatch = ColorUtils.areColorsMatching(color1, color2).$1;
    final overlayMatch = ColorUtils.areColorsMatching(overlay1, overlay2).$1;

    // Cross-match: overlay of one contact with base of the other
    final crossMatch1 = ColorUtils.areColorsMatching(overlay1, color2).$1;
    final crossMatch2 = ColorUtils.areColorsMatching(color1, overlay2).$1;

    final newMatch = baseMatch || overlayMatch || crossMatch1 || crossMatch2;

    // Determine which areas to highlight for each card
    // Card 1: base matches if baseMatch or crossMatch2, overlay matches if overlayMatch or crossMatch1
    final baseMatch1 = baseMatch || crossMatch2;
    final overlayMatch1 = overlayMatch || crossMatch1;
    // Card 2: base matches if baseMatch or crossMatch1, overlay matches if overlayMatch or crossMatch2
    final baseMatch2 = baseMatch || crossMatch1;
    final overlayMatch2 = overlayMatch || crossMatch2;

    return (
      newMatch,
      MatchDetails(
        baseMatch: baseMatch,
        overlayMatch: overlayMatch,
        crossMatch1: crossMatch1,
        crossMatch2: crossMatch2,
        baseMatch1: baseMatch1,
        overlayMatch1: overlayMatch1,
        baseMatch2: baseMatch2,
        overlayMatch2: overlayMatch2,
      ),
    );
  }
}

/// Details about match between two contacts
class MatchDetails {
  final bool baseMatch;
  final bool overlayMatch;
  final bool crossMatch1;
  final bool crossMatch2;
  final bool baseMatch1;
  final bool overlayMatch1;
  final bool baseMatch2;
  final bool overlayMatch2;

  MatchDetails({
    this.baseMatch = false,
    this.overlayMatch = false,
    this.crossMatch1 = false,
    this.crossMatch2 = false,
    this.baseMatch1 = false,
    this.overlayMatch1 = false,
    this.baseMatch2 = false,
    this.overlayMatch2 = false,
  });

  /// Get list of match types in order
  List<String> get matchTypes {
    final List<String> types = [];
    if (baseMatch) types.add('base');
    if (overlayMatch) types.add('overlay');
    if (crossMatch1) types.add('cross1');
    if (crossMatch2) types.add('cross2');
    return types;
  }
}

