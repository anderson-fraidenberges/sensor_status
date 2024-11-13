import 'package:flutter/material.dart';
import 'package:sensor_status/models/assetsUnit.dart';
import 'package:sensor_status/presentation/components/customSearchWidget.dart';
import 'package:sensor_status/presentation/screens/cacheAssets.dart';
import 'package:sensor_status/presentation/screens/filterAssets.dart';
import 'package:sensor_status/presentation/screens/hierarchyBuilder.dart';
import 'package:sensor_status/utils/consts.dart';

class AssetsUnitTreeWidget extends StatefulWidget {
  List<AssetsUnit> assets;

  AssetsUnitTreeWidget({super.key, required this.assets});

  @override
  _AssetsUnitTreeState createState() => _AssetsUnitTreeState();
}

class _AssetsUnitTreeState extends State<AssetsUnitTreeWidget> {  

  final Map<AssetsUnit, bool> _expandedNodes = {};
  bool _isSensorSelected = false;
  bool _isCriticoSelected = false;
  final TextEditingController _searchTextController = TextEditingController();
  HierarchyBuilder hierarchyBuilder = HierarchyBuilder();

  void _initializeExpansionState(List<AssetsUnit> assets) {
    for (var asset in assets) {
      _expandedNodes[asset] = false;
      if (asset.children.isNotEmpty) {
        _initializeExpansionState(asset.children);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    CacheAssets.addAssets(widget.assets);
    _initializeExpansionState(widget.assets);
  }

  List<Widget> buildTreeNodeList(List<AssetsUnit> assets, int depth) {
    List<Widget> nodeList = [];

    for (var asset in assets) {
      bool isExpanded = _expandedNodes[asset] ?? false;
      nodeList.add(treeNodeBuilder(context, asset, depth, isExpanded));

      if (isExpanded && asset.children.isNotEmpty) {
        nodeList.addAll(buildTreeNodeList(asset.children, depth + 1));
      }
    }

    return nodeList;
  }

  Widget treeNodeBuilder(
    BuildContext context,
    AssetsUnit asset,
    int depth,
    bool isExpanded,
  ) {
    final hasChildren = asset.children.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 40,
        child: Row(
          children: <Widget>[
            SizedBox(width: 20.0 * depth),
            if (hasChildren)
              IconButton(
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _expandedNodes[asset] = !isExpanded;
                  });
                },
              )
            else
              SizedBox(
                width:
                    (asset.children.isEmpty && asset.parentId == null)
                        ? 15
                        : 28.0,
              ),
            Image.asset("assets/${asset.leadingIcon}.png"),
            const SizedBox(width: 10),
            Text(asset.name),
            const SizedBox(width: 5),
            asset.sensorType != null
                ? Image.asset("assets/${asset.sensorType}.png")
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  SnackBar snackBar(String message) {
    return SnackBar(
      backgroundColor: titleColor,
      content: Text(message),
      duration: Duration(seconds: 3),
    );
  }  

  void searchOnPressed() {
    setState(() {
      widget.assets =  CacheAssets.getClonedList();       
    });
    if (_isCriticoSelected ||
        _isSensorSelected ||
        _searchTextController.text.isNotEmpty) {

      FilterAssets filterAssets = FilterAssets(
        assets: widget.assets,
        filterAlertStatus: _isCriticoSelected,
        filterSensorTypeEnergy: _isSensorSelected,
        searchName: _searchTextController.text,
      );
      
      List<AssetsUnit> assets = filterAssets.filter();

      List<AssetsUnit> filteredAssets = hierarchyBuilder.createTreeHierarchyFilteredData(assets);
      if (filteredAssets.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(snackBar("Não foram encontrados dados"));
      }
      setState(() {
        widget.assets = filteredAssets;
      });
    }
  }
   @override
  void dispose() {   
    super.dispose();
    CacheAssets.clearAssets();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> treeNodes = buildTreeNodeList(widget.assets, 0);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: CustomSearchWidget(
            searchTextController: _searchTextController,
            onSearchPressed: searchOnPressed,
            onCriticalPressed: () {
              setState(() {
                _isCriticoSelected = !_isCriticoSelected;
              });
            },
            onEnergySensorPressed: () {
              setState(() {
                _isSensorSelected = !_isSensorSelected;
              });
            },
            isCriticoSelected: _isCriticoSelected,
            isSensorSelected: _isSensorSelected,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((
            BuildContext context,
            int index,
          ) {
            return treeNodes[index];
          }, childCount: treeNodes.length),
        ),
      ],
    );
  }
}
