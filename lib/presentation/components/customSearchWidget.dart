import 'package:flutter/material.dart';

class CustomSearchWidget extends StatefulWidget {
  CustomSearchWidget({
    super.key,
    required this.onCriticalPressed,
    required this.onEnergySensorPressed,
    required this.onSearchPressed,
    required this.isCriticoSelected,
    required this.isSensorSelected,
    required this.searchTextController
  });
  Function() onCriticalPressed;
  Function() onEnergySensorPressed;
  Function() onSearchPressed;
  bool isSensorSelected = false;
  bool isCriticoSelected = false;
  TextEditingController searchTextController;

  @override
  _CustomSearchWidgetState createState() => _CustomSearchWidgetState();
}

class _CustomSearchWidgetState extends State<CustomSearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.searchTextController,
            onSubmitted: (_) => widget.onSearchPressed(),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search, 
            decoration: InputDecoration(              
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: IconButton(icon:Icon(Icons.search), color: Colors.grey, onPressed: widget.onSearchPressed),
              hintText: 'Buscar Ativo ou Local',
              hintStyle: TextStyle(color: Colors.grey),
              suffixIcon: IconButton(icon:Icon(Icons.close), color: Colors.grey, onPressed:(){ setState(() {
                widget.searchTextController.clear();
                widget.onSearchPressed();
              }); } ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed:(){
                  setState(() {
                    widget.onEnergySensorPressed();
                    widget.onSearchPressed();
                  });
                } ,
                icon: Icon(
                  Icons.bolt,
                  color: widget.isSensorSelected ? Colors.white : Colors.grey,
                ),
                label: Text(
                  'Sensor de Energia',
                  style: TextStyle(
                    color: widget.isSensorSelected ? Colors.white : Colors.grey,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      widget.isSensorSelected
                          ? Colors.blue
                          : Colors.transparent,
                  side: BorderSide(
                    color: widget.isSensorSelected ? Colors.blue : Colors.grey,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              OutlinedButton.icon(
                onPressed:(){
                  setState(() {
                    widget.onCriticalPressed();
                    widget.onSearchPressed();
                  });
                },
                icon: Icon(
                  Icons.error_outline,
                  color: widget.isCriticoSelected ? Colors.white : Colors.grey,
                ),
                label: Text(
                  'Crítico',
                  style: TextStyle(
                    color:
                        widget.isCriticoSelected ? Colors.white : Colors.grey,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      widget.isCriticoSelected
                          ? Colors.blue
                          : Colors.transparent,
                  side: BorderSide(
                    color: widget.isCriticoSelected ? Colors.blue : Colors.grey,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Divider(color: Colors.grey, thickness: 0.5),
          ),
        ],
      ),
    );
  }
}
