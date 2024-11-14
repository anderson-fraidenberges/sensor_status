import 'package:sensor_status/models/assetsUnit.dart';

class FilterAssets {
  List<AssetsUnit> assets = <AssetsUnit>[];
  String? searchName;
  bool filterSensorTypeEnergy;
  bool filterAlertStatus;

  FilterAssets({
    required this.assets,
    this.searchName,
    this.filterSensorTypeEnergy = false,
    this.filterAlertStatus = false,
  });

  final List<AssetsUnit> _filteredAssetsAux = [];
  final List<AssetsUnit> _filteredAssets = [];
  List<String> _assetsIds = [];

  bool _matchFilter(AssetsUnit asset) {
    bool result = false;

    if (asset.isAsset) {
      if (!filterSensorTypeEnergy && !filterAlertStatus) {
        result = true;
      } else if (filterSensorTypeEnergy && !filterAlertStatus) {
        result = asset.sensorType == "energy";
      } else if (!filterSensorTypeEnergy && filterAlertStatus) {
        result = asset.status == "alert";
      } else if (filterSensorTypeEnergy && filterAlertStatus) {
        result = asset.status == "alert" && asset.sensorType == "energy";
      }
    }

    if (searchName != null &&
        searchName!.isNotEmpty &&
        searchName!.trim().length > 2) {
      bool isSearchName = asset.name.toLowerCase().contains(
        searchName!.toLowerCase().trim(),
      );

      if (asset.isAsset) {
        return result && isSearchName;
      }
      return isSearchName;
    }

    return result;
  }

  void _addAssetsIds(String id) {
    if (!_assetsIds.contains(id)) {
      _assetsIds.add(id);
    }
  }

  void _searchParent(
    AssetsUnit asset,
    String? parentId,
    String? locationId,
    String? childId,
  ) {
    List<AssetsUnit> children = asset.children;

    if (asset.id == parentId || (parentId == null && asset.id == locationId)) {
      if (_filteredAssetsAux.isEmpty ||
          _filteredAssetsAux.where((e) => e.id == asset.id).isEmpty) {
        _addAssetsIds(asset.id);
        _filteredAssetsAux.insert(0, asset);
      }
      parentId = asset.parentId;
      locationId = asset.locationId;
      children = assets;
    }

    for (var asset in children) {
      _searchParent(asset, parentId, locationId, asset.id);
    }
  }

  void _searchAsset(AssetsUnit asset) {
    if (_matchFilter(asset)) {
      _addAssetsIds(asset.id);
      _filteredAssetsAux.insert(0, asset);

      for (var parent in assets) {
        if (parent.id == asset.id) {
          break;
        }
        _searchParent(parent, asset.parentId, asset.locationId, null);
      }
    }

    for (var child in asset.children) {
      _searchAsset(child);
    }
  }

  bool _searchById(List<AssetsUnit> assets, String id) {
    for (var item in assets) {
      if (item.id == id) {
        return true;
      }

      if (item.children.isNotEmpty) {        
        if (_searchById(item.children, id)) {
          return true;
        }
      }
    }
    return false;
  }

  void _validateChild() {
    if (_assetsIds.isNotEmpty) {
      for (var id in _assetsIds) {
        AssetsUnit assetUnit = _filteredAssetsAux.firstWhere((w) => w.id == id);
        if (!(_assetsIds.first == assetUnit.id)) {
          assetUnit.children = [];
        }

        if (!_searchById(_filteredAssets, id)) {
          _filteredAssets.add(assetUnit);
        }
      }
      _assetsIds = [];
    }
  }

  void _finalizeFilteredAssets() {
    _filteredAssets.sort((a, b) => a.name.compareTo(b.name));
  }

  List<AssetsUnit> filter() {
    for (var asset in assets) {
      _searchAsset(asset);
      _validateChild();
    }
    _finalizeFilteredAssets();
    return _filteredAssets;
  }
}
