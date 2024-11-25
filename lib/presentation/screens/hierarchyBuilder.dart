import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
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
    final result = await compute(_buildHierarchy, nodes);
    return result;
  }

  Future<List<AssetsUnit>> _buildLocationHierarchyAsync() async {
    List<AssetsUnit> nodes = await _unitService.fetchUnitLocation(companyId);
    final result = await compute(_buildHierarchy, nodes);
    return result;
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
    final List<AssetsUnit> treeHierarchy = [];

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

  Future<List<AssetsUnit>> createTreeHierarchyDataAsync() async {
    locations = await _buildLocationHierarchyAsync();

    assets = await _buildAssetsHierarchyAsync();

    final result = await Isolate.run(_treeHierarchy);

    return Future.value(result);
  }

  Future<List<AssetsUnit>> createTreeHierarchyFilteredData(List<AssetsUnit> nodes) async {
    final locationsNodes = nodes.where((w) => w.isLocation).toList();
    final assetsNodes = nodes.where((w) => w.isParentAsset || w.isAsset).toList();

    locations = await compute(_buildHierarchy, locationsNodes);
    
    assets = await compute(_buildHierarchy, assetsNodes);

    final result = await Isolate.run(_treeHierarchy);

    return Future.value(result);
  }
}
