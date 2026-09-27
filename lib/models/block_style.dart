/// Decoded form of a block's free-form `style` string.
///
/// The source data uses underscore-joined tokens (`red_bold_large_centered`,
/// `boxed_ornamental`, `black_badge`, ...). Rather than enumerating every
/// combination, each token toggles one visual trait so new combinations render
/// sensibly without code changes.
class BlockStyle {
  const BlockStyle({
    this.raw,
    this.red = false,
    this.bold = false,
    this.large = false,
    this.centered = false,
    this.boxed = false,
    this.ornamental = false,
    this.blackBadge = false,
    this.circleBadge = false,
    this.ornamentalBadge = false,
    this.underlined = false,
    this.exclamation = false,
    this.banner = false,
  });

  factory BlockStyle.parse(String? style) {
    if (style == null || style.isEmpty) return const BlockStyle();
    final tokens = style.split('_').toSet();
    bool has(String t) => tokens.contains(t);
    return BlockStyle(
      raw: style,
      red: has('red'),
      bold: has('bold') || has('large'),
      large: has('large'),
      centered: has('centered'),
      boxed: has('boxed') || has('frame') || style == 'boxed',
      ornamental: has('ornamental') && !has('badge'),
      blackBadge: style.contains('black_badge'),
      circleBadge: style.contains('circle_badge'),
      ornamentalBadge: style.contains('ornamental_badge'),
      underlined: has('underlined'),
      exclamation: has('exclamation'),
      banner: has('banner'),
    );
  }

  static const none = BlockStyle();

  final String? raw;
  final bool red;
  final bool bold;
  final bool large;
  final bool centered;
  final bool boxed;
  final bool ornamental;
  final bool blackBadge;
  final bool circleBadge;
  final bool ornamentalBadge;
  final bool underlined;
  final bool exclamation;
  final bool banner;

  bool get isBadge => blackBadge || circleBadge || ornamentalBadge;
}

abstract final class BlockStylePresets {
  static const blackBadge = BlockStyle(raw: 'black_badge', blackBadge: true, bold: true);
}
