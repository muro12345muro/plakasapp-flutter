import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewSinglePhoto extends StatefulWidget {
  final ImageProvider imageProvider;
  const ViewSinglePhoto({Key? key, required this.imageProvider}) : super(key: key);

  @override
  State<ViewSinglePhoto> createState() => _ViewSinglePhotoState();
}

class _ViewSinglePhotoState extends State<ViewSinglePhoto> {
  @override
  Widget build(BuildContext context) {

    final availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: availableHeight,
          child: Stack(
            children: [
              Container(
                  height: availableHeight,
                  child: PhotoView(
                    minScale: PhotoViewComputedScale.contained * 1.0,
                    imageProvider: widget.imageProvider,
                  )
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.white,),
                  iconSize: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
