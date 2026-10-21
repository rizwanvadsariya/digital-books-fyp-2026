/// Application route definitions for Fehm-e-Quran
enum AppRoutes {
  splash('/'),
  home('/home'),
  reader('/reader/:pageIndex'),
  contents('/contents'),
  answersReview('/answers-review'),
  settings('/settings');

  final String path;
  const AppRoutes(this.path);
}
