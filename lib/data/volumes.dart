/// A volume of the book available in the app.
class BookVolume {
  const BookVolume({
    required this.id,
    required this.number,
    required this.assetPath,
    required this.coverSubtitle,
    required this.units,
    required this.storageNamespace,
  });

  /// Stable identifier, persisted as the selected volume.
  final String id;
  final int number;
  final String assetPath;

  /// The volume name as printed on the book's cover (book content, Urdu).
  final String coverSubtitle;

  /// Units covered, e.g. "1–3", for the volume shelf.
  final String units;

  /// Prefix for this volume's answers, progress and bookmarks. Answer IDs are
  /// only unique within a volume, so each volume needs its own namespace.
  /// Volume 1 keeps the original un-prefixed keys so existing data survives.
  final String storageNamespace;
}

const bookVolumes = [
  BookVolume(
    id: 'vol1',
    number: 1,
    assetPath: 'assets/data/muallim_ul_quran_vol1_full.json',
    coverSubtitle: 'جلد اوّل',
    units: '1–3',
    storageNamespace: '',
  ),
  BookVolume(
    id: 'vol2',
    number: 2,
    assetPath: 'assets/data/muallim_ul_quran_vol2_full.json',
    coverSubtitle: 'جلد دوم',
    units: '4–5',
    storageNamespace: 'vol2.',
  ),
];

BookVolume volumeById(String? id) =>
    bookVolumes.firstWhere((v) => v.id == id, orElse: () => bookVolumes.first);
