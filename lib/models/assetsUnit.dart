class AssetsUnit {
  String? gatewayId;
  String id;
  String? locationId;
  String name;
  String? parentId;
  String? sensorId;
  String? sensorType;
  String? status;
  String? leadingIcon;
  bool isLocation;
  bool isAsset;
  bool isParentAsset;
  List<AssetsUnit> children = <AssetsUnit>[];

  AssetsUnit({
    required this.id,
    this.gatewayId,
    this.locationId,
    required this.name,
    this.parentId,
    this.sensorId,
    this.sensorType,
    this.status,
    this.leadingIcon,
    this.isAsset = false,
    this.isLocation = false,
    this.isParentAsset = false,
  });

  AssetsUnit.clone(AssetsUnit original)
    : id = original.id,
      gatewayId = original.gatewayId,
      locationId = original.locationId,
      name = original.name,
      parentId = original.parentId,
      sensorId = original.sensorId,
      sensorType = original.sensorType,
      status = original.status,
      leadingIcon = original.leadingIcon,
      isAsset = original.isAsset,
      isLocation = original.isLocation,
      isParentAsset = original.isParentAsset,
      children = original.children;

  factory AssetsUnit.fromJson(
    Map<String, dynamic> json, {
    bool isAsset = false,
    bool isLocation = false,
    bool isParentAsset = false,
  }) {
    void setParentAsset(String? sensorType) {
      isParentAsset = (isAsset && sensorType == null);
      isAsset = false;
    }

    String itemType(String? sensorType) {
      if (isLocation) {
        return "location";
      }

      if (sensorType != null) {
        return "component";
      }

      setParentAsset(sensorType);
      return "parentComponent";
    }

    return AssetsUnit(
      id: json['id'],
      gatewayId: json['gatewayId'],
      locationId: json['locationId'],
      name: json['name'],
      parentId: json['parentId'],
      sensorId: json["sensorId"],
      sensorType: json["sensorType"],
      status: json['status'],
      leadingIcon: itemType(json['sensorType']),
      isAsset: isAsset,
      isLocation: isLocation,
      isParentAsset: isParentAsset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gatewayId': gatewayId,
      'id': id,
      'locationId': locationId,
      'name': name,
      'isAsset': isAsset,
      'isLocation': isLocation,
      'isParentAsset': isParentAsset,
      'parentId': parentId,
      'sensorId': sensorId,
      'sensorType': sensorType,
      'status': status,
      'children': children,
    };
  }
}
extension AssetsUnitExtension on AssetsUnit {
  AssetsUnit clone() {
    return AssetsUnit(
      id: id,
      gatewayId: gatewayId,
      locationId: locationId,
      name: name,
      parentId: parentId,
      sensorId: sensorId,
      sensorType: sensorType,
      status: status,
      leadingIcon: leadingIcon,
      isAsset: isAsset,
      isLocation: isLocation,
      isParentAsset: isParentAsset,
    )..children = children.map((child) => child.clone()).toList();
  }
}

extension AssetsUnitListClone on List<AssetsUnit> {
  List<AssetsUnit> nestedClone () {
    return map((m) => m.clone()).toList();
  }
}
