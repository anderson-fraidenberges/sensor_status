import 'package:sensor_status/models/assetsUnit.dart';


class CacheAssets {
  static final List<AssetsUnit> _originalAssets = [];

  static void addAssets(List<AssetsUnit> assets) {
    _originalAssets.clear();
    _originalAssets.addAll(assets);
  }

  static AssetsUnit _cloneUnit(AssetsUnit originalUnit) {
     AssetsUnit result =  AssetsUnit.clone(originalUnit);

       if (originalUnit.children.isNotEmpty) {
        List<AssetsUnit> clonedChildren = [];
            for (var originalAsset in originalUnit.children) {
              clonedChildren.add(AssetsUnit.clone(originalAsset));
         }
         result.children = clonedChildren;
      }      
      return result;     
  }  

  static List<AssetsUnit> getClonedList() {
     List<AssetsUnit> result = [];

     for (var original in _originalAssets) {        
        if (original.children.isNotEmpty) {
          result.add(_cloneUnit(original)); 
        }
        else {
          result.add(AssetsUnit.clone(original));
        }
     }

     return result;
  }
  
  static void clearAssets() {
    _originalAssets.clear();
  }
}
