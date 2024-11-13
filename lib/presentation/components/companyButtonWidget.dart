import 'package:flutter/material.dart';
import 'package:sensor_status/models/company.dart';
import 'package:sensor_status/presentation/screens/hierarchyScreen.dart';
import 'package:sensor_status/utils/consts.dart';

class CompanyButtonWidget extends StatelessWidget {
  final Company? company;

  const CompanyButtonWidget({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width * .95;
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HierarchyScreen(companyId: company!.id),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        fixedSize: Size(buttonWidth, 76),
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 10, 0, 10),
        child: Row(
          children: [
            ImageIcon(AssetImage('assets/icon.png'), color: Colors.white),
            SizedBox(width: 15),
            Text(
              company!.name,
              style: textStyle.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
