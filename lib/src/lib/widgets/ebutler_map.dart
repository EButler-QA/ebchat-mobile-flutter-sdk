import 'package:ebchat/src/lib/Theme/my_theme.dart';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EbutlerMap extends StatefulWidget {
  EbutlerMap(this.initalPostion, {Key? key}) : super(key: key);
  LatLng initalPostion;
  @override
  State<EbutlerMap> createState() => _EbutlerMapState();
}

class _EbutlerMapState extends State<EbutlerMap> {
  bool isMapRead = false;
  late List<Marker> markers;

  @override
  void initState() {
    markers = [
      Marker(
        width: 40.0,
        height: 40.0,
        point: widget.initalPostion,
        builder: (ctx) => const Icon(
          Icons.location_on,
          color: AppColors.primary,
          size: 40,
        ),
      )
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
            center: widget.initalPostion,
            zoom: 13.0,
            interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            onTap: (_, pos) {
              markers.clear();
              markers.add(
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: pos,
                  builder: (ctx) => const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              );
              if (mounted) {
                setState(() {
                  markers;
                });
              }
            }),
        children: [
          TileLayer(
            urlTemplate:
                "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=main&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key=$Config.azureMapsApiKey!",
            additionalOptions: {'subscriptionKey': Config.azureMapsApiKey!},
          ),
          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(markers.first.point),
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }
}
