import 'dart:async';
import 'dart:isolate';

import 'package:sensor_status/models/assetsUnit.dart';
import 'package:sensor_status/services/unitService.dart';

class HierarchyBuilder {
  HierarchyBuilder(this.companyId);
  final String companyId;
  late List<AssetsUnit> locations;
  late List<AssetsUnit> assets;
  final UnitService _unitService = UnitService();

  Future<List<AssetsUnit>> _buildAssetsHierarchyAsync() async {
    List<AssetsUnit> nodes = await _unitService.fetchAssetsUnit(companyId);
    return _buildHierarchy(nodes);
  }

  Future<List<AssetsUnit>> _buildLocationHierarchyAsync() async {
    List<AssetsUnit> nodes = await _unitService.fetchUnitLocation(companyId);
    return _buildHierarchy(nodes);
  }

  List<AssetsUnit> _buildHierarchy(List<AssetsUnit> nodes) {
    
    final Map<String, AssetsUnit> nodeMap = {
      for (var node in nodes) node.id: node,
    };

    
    final List<AssetsUnit> hierarchy = [];
    
    for (var node in nodes) {
      if (node.parentId == null) {
        hierarchy.add(node);
      } else {
        final parent = nodeMap[node.parentId];
        if (parent != null) {
          parent.children.add(node);
        }
      }
    }

    return hierarchy;
  }

  List<AssetsUnit> _treeHierarchy() {
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
    locations = await Isolate.run(_buildLocationHierarchyAsync);

    assets = await Isolate.run(_buildAssetsHierarchyAsync);

    return Future.value(_treeHierarchy());
  }

  List<AssetsUnit> createTreeHierarchyFilteredData(List<AssetsUnit> nodes) {
    locations = _buildHierarchy(nodes.where((w) => w.isLocation).toList());
    assets = _buildHierarchy(
      nodes.where((w) => w.isParentAsset || w.isAsset).toList(),
    );
    return _treeHierarchy();
  }
}
