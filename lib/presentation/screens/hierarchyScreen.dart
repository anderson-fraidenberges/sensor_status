import 'package:flutter/material.dart';
import 'package:sensor_status/models/assetsUnit.dart';
import 'package:sensor_status/presentation/components/assetsUnitTreeWidget.dart';
import 'package:sensor_status/presentation/screens/hierarchyBuilder.dart';
import 'package:sensor_status/utils/consts.dart';

class HierarchyScreen extends StatefulWidget {
  const HierarchyScreen({super.key, required this.companyId});
  final String companyId;

  @override
  State<HierarchyScreen> createState() => _HierarchyscreenState();
}

class _HierarchyscreenState extends State<HierarchyScreen> {
  late Future<List<AssetsUnit>> _treeHierarchy;
  HierarchyBuilder hierarchyBuilder = HierarchyBuilder();
  

  @override
  void initState() {
    super.initState();
    setState(() {  
      _treeHierarchy = hierarchyBuilder.createTreeHierarchyDataAsync(widget.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
     SnackBar snackBar(String message) {
      return SnackBar(
        backgroundColor: titleColor,
        content: Text(message),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: titleColor,
        title: Text("Assets", style: textStyle),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<AssetsUnit>>(
        future: _treeHierarchy,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               ScaffoldMessenger.of(context).showSnackBar(snackBar("Falha ao carregar os dados"));
             });
             return Container();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               ScaffoldMessenger.of(context).showSnackBar(snackBar("Não há dados a serem exibidos"));
             });
             return Container();
          } else {
            final assets = snapshot.data!;
            return AssetsUnitTreeWidget(assets: assets);
          }
        },
      ),
    );
  }
}
