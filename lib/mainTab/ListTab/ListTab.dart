import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../provider/CaughtTerpiezProvider.dart';
import 'TerpiezDetail.dart';

class ListTab extends StatefulWidget {
  const ListTab({Key? key}) : super(key: key);

  @override
  _ListTabState createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {

  @override
  void initState() {
    super.initState();
    Provider.of<CaughtTerpiezProvider>(context, listen: false).loadCaughtTerpiez();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CaughtTerpiezProvider>(
      builder: (context, provider, child) {
        final caughtTerpiez = provider.caughtTerpiez;
        return ListView.builder(
          itemCount: caughtTerpiez.length,
          itemBuilder: (context, index) {
            final terpiez = caughtTerpiez[index];
            final thumbnailPath = terpiez['thumbnail'];
            final imagePath = terpiez['image'];
            final File thumbnailFile = File(thumbnailPath);

            // Checking if the thumbnail file exists.
            bool fileExists = thumbnailFile.existsSync();
            print('Terpiez: ${terpiez['name']}');
            print('Thumbnail Path: $thumbnailPath');
            print('Image Path: $imagePath');
            print('File Exists: $fileExists');

            return ListTile(
              leading: fileExists
                  ? CircleAvatar(
                backgroundImage: FileImage(thumbnailFile),
                backgroundColor: Colors.transparent,
              )
                  : CircleAvatar(
                child: Icon(Icons.image, color: Colors.white),
                backgroundColor: Colors.grey,
              ),
              title: Text(terpiez['name']),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      TerpiezDetail(
                          terpiezName: terpiez['name'],
                          heroTag: 'terpiez_${terpiez['id']}',
                          imagePath: terpiez['image'],
                          latitude: terpiez['latitude'],
                          longitude: terpiez['longitude'],
                          stats: terpiez['stats'],
                          description: terpiez['description']
                      ),
                ));
              },
            );
          },
        );
      },
    );
  }
}
