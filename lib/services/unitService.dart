import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sensor_status/models/assetsUnit.dart';
import 'package:sensor_status/models/company.dart';
import 'package:sensor_status/utils/consts.dart' as consts;

class UnitService {
  Future<List<Company>> fetchUnits() async {
    final dio = Dio();
    try {
      String url = "${consts.apiUri}/companies";
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Company.fromJson(json)).toList();
      }

      throw Exception('Failed to load units');
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<AssetsUnit>> fetchUnitLocation(String companyId) async {
    final dio = Dio();
    try {
      String url = "${consts.apiUri}/companies/$companyId/locations";

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;

        return data
            .map((json) => AssetsUnit.fromJson(json, isLocation: true))
            .toList();
      }
      throw Exception('Failed to load unit location');
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<AssetsUnit>> fetchAssetsUnit(String companyId) async {
    final dio = Dio();
    try {
      String url = "${consts.apiUri}/companies/$companyId/assets";

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        final result = await compute(parseJsonFetchAssetsUnit, data);

        return result;
      }
      throw Exception('Failed to load assets unit');
    } catch (e) {
      throw Exception(e);
    }
  }

  List<AssetsUnit> parseJsonFetchAssetsUnit(List<dynamic> responseData) {
    return responseData
        .map((json) => AssetsUnit.fromJson(json, isAsset: true))
        .toList();
  }
}
