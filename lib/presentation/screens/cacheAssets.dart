import 'package:sensor_status/models/assetsUnit.dart';

class CacheAssets {
  static final List<AssetsUnit> _originalAssets = [];

  static List<AssetsUnit> get originalAssets => _originalAssets;

  static void addAssets(List<AssetsUnit> assets) {
    _originalAssets.clear();
    _originalAssets.addAll(assets);
  }

  static void clearAssets() {
    _originalAssets.clear();
  }
}
