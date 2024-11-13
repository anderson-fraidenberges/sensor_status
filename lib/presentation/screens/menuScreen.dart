import 'package:flutter/material.dart';
import 'package:sensor_status/models/company.dart';
import 'package:sensor_status/presentation/components/companyButtonWidget.dart';
import 'package:sensor_status/services/unitService.dart';
import 'package:sensor_status/utils/consts.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<MenuScreen> {
  late Future<List<Company>> companyList;
  final UnitService unitService = UnitService();

  @override
  void initState() {
    super.initState();
    setState(() {
      companyList = unitService.fetchUnits();
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
        title: Image.asset('assets/company.png', height: 30),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Company>>(
        future: companyList,        
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
               ScaffoldMessenger.of(context).showSnackBar(snackBar('Não há dados a serem exibidos'));
             });
            return Container();
          } else {
            
            final companies = snapshot.data!;
            return ListView(
              children:
                  companies.map((company) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CompanyButtonWidget(company: company),
                    );
                  }).toList(),
            );
          }
        },
      ),
    );
  }
}
