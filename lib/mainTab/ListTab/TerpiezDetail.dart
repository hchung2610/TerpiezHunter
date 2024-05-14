import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class TerpiezDetail extends StatefulWidget  {
  final String terpiezName;
  final Color iconColor;
  final Color textColor;
  final String heroTag;
  final String imagePath;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> stats;
  final String description;
  const TerpiezDetail({Key? key, required this.terpiezName, required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.stats,
    required this.description,

    this.iconColor = Colors.white, this.textColor = Colors.white, required this.heroTag,}) : super(key: key);
  @override
  _TerpiezDetailState createState() => _TerpiezDetailState();
}

class _TerpiezDetailState extends State<TerpiezDetail> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )
      ..repeat(reverse: true);
    _colorAnimation1 = ColorTween(
      begin: Colors.blue.shade600,
      end: Colors.red.shade600,
    ).animate(_controller);

    _colorAnimation2 = ColorTween(
      begin: Colors.yellow.shade600,
      end: Colors.green.shade600,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    mapController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    Set<Marker> markers = {
      Marker(
        markerId: MarkerId("terpiezLocation"),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: widget.terpiezName,
        ),
      ),
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.terpiezName, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: orientation == Orientation.portrait
          ? portraitLayout(context, markers)
          :landscapeLayout(context, markers),
    );
  }

  Widget portraitLayout(BuildContext context, Set<Marker> markers) {
    return Column(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      _colorAnimation1.value ?? Colors.blue,
                      _colorAnimation2.value ?? Colors.red,
                    ],
                  ),
                ),
                child: child,
              );
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 16),
                  Hero(
                    tag: widget.heroTag,
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.35,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(widget.imagePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        widget.terpiezName,
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        width: MediaQuery.of(context).size.width * 0.55,
                        height: MediaQuery.of(context).size.height * 0.20,
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(widget.latitude, widget.longitude),
                            zoom: 16.0,
                          ),
                          markers: markers,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 21, left: 5),
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: ListView.builder(
                                itemCount: widget.stats.length,
                                itemBuilder: (context, index) {
                                  String key = widget.stats.keys.elementAt(index);
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                                    child: Text(
                                      '$key: ${widget.stats[key]}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 27),
                    child: Text(widget.description),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget landscapeLayout(BuildContext context, Set<Marker> markers) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                _colorAnimation1.value ?? Colors.blue,
                _colorAnimation2.value ?? Colors.red,
              ],
            ),
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Hero(
                      tag: widget.heroTag,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(widget.imagePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    widget.terpiezName,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(widget.latitude, widget.longitude),
                        zoom: 16.0,
                      ),
                      markers: markers,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: ListView.builder(
                      itemCount: widget.stats.length,
                      itemBuilder: (context, index) {
                        String key = widget.stats.keys.elementAt(index);
                        return Padding(
                          padding: EdgeInsets.only(left: 60, top: 0),
                          child: Text(
                            '$key: ${widget.stats[key]}',
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.description,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}