import 'package:sensor_status/models/assetsUnit.dart';
import 'package:sensor_status/services/unitService.dart';

class HierarchyBuilder {
  final UnitService _unitService = UnitService();

  Future<List<AssetsUnit>> _buildAssetsHierarchyAsync(String companyId) async {
    List<AssetsUnit> nodes = await _unitService.fetchAssetsUnit(companyId);
    return _getHierarchy(nodes);
  }

  Future<List<AssetsUnit>> _buildLocationHierarchyAsync(
    String companyId,
  ) async {
    List<AssetsUnit> nodes = await _unitService.fetchUnitLocation(companyId);
    return _getHierarchy(nodes);
  }

  void _attachChildren(AssetsUnit parent, List<AssetsUnit> childNodes) {
    for (var child in childNodes.where((w) => w.parentId == parent.id)) {
      parent.children.add(child);
      _attachChildren(child, childNodes);
    }
  }

  List<AssetsUnit> _getHierarchy(List<AssetsUnit> parentNodes) {
    List<AssetsUnit> hierarchy = [];
    for (var node in parentNodes) {
      if (node.parentId == null) {
        _attachChildren(node, parentNodes);
        hierarchy.add(node);
      }
    }
    return hierarchy;
  }

  List<AssetsUnit> _treeHierarchy(
    List<AssetsUnit> locations,
    List<AssetsUnit> assets,
  ) {
    List<AssetsUnit> treeHierarchy = [];

    void attachAssetsChildren(AssetsUnit parent) {
      if (parent.children.isEmpty) {
        parent.children =
            assets.where((w) => w.locationId == parent.id).toList();
      }

      for (var child in parent.children) {
        attachAssetsChildren(child);
      }
    }

    for (var location in locations) {
      attachAssetsChildren(location);
      if (location.children.isNotEmpty) {
        treeHierarchy.add(location);
      }
    }

    treeHierarchy.addAll(locations.where((w) => w.children.isEmpty).toList());

    treeHierarchy.addAll(
      assets.where((w) => w.parentId == null && w.locationId == null).toList(),
    );

    return treeHierarchy;
  }

  Future<List<AssetsUnit>> createTreeHierarchyDataAsync(
    String companyId,
  ) async {
    List<AssetsUnit> locationHierarchy = await _buildLocationHierarchyAsync(
      companyId,
    );
    List<AssetsUnit> assetsHierarchy = await _buildAssetsHierarchyAsync(
      companyId,
    );
    return Future.value(_treeHierarchy(locationHierarchy, assetsHierarchy));
  }

  List<AssetsUnit> createTreeHierarchyFilteredData(List<AssetsUnit> nodes) {
    List<AssetsUnit> locationHierarchy = _getHierarchy(
      nodes.where((w) => w.isLocation).toList(),
    );
    List<AssetsUnit> assetsHierarchy = _getHierarchy(
      nodes.where((w) => w.isParentAsset || w.isAsset).toList(),
    );
    return _treeHierarchy(locationHierarchy, assetsHierarchy);
  }
}
