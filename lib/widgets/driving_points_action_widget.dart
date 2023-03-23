import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../services/firebase/database/user/user_database_service.dart';

class DrivingPointsActionWidget extends StatefulWidget {
  const DrivingPointsActionWidget({
    Key? key,
    required this.titleBgColor,
    this.givenRating,
    this.initialRating,
    required this.drivingPointsTapped,
  }) : super(key: key);

  final Color titleBgColor;
  final double? initialRating;
  final int? givenRating;
  final Function(int point) drivingPointsTapped;

  @override
  State<DrivingPointsActionWidget> createState() => _DrivingPointsActionWidgetState();
}

class _DrivingPointsActionWidgetState extends State<DrivingPointsActionWidget> {


  void sendDrivingPointTapped(int point) async {
    widget.drivingPointsTapped(point);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("d23f23f ${widget.givenRating}");
  }
// 20(p) -  80(puanla) -  24x5(iconsize) + 5x8(int.p.)   - 20(p) 280
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final width = size.width - padding.left - padding.right;

    print("23f2f32 $width");
    return Container(
      //height: 50,
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black54,
              blurRadius: 1.0,
              offset: Offset(0.0, 0.0)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            margin: const EdgeInsets.only(right: 0),
            decoration: BoxDecoration(
                color: widget.titleBgColor
            ),
            width: 80,
            height: 40,
            child: Row(
              children: const [
                Icon(Icons.drive_eta_rounded),
                Text("Puanla"),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatingBar.builder(
                  ignoreGestures: widget.givenRating == null ? false : true,
                  initialRating: widget.givenRating != null ? widget.givenRating!.toDouble() : 0.0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.drive_eta_rounded,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    sendDrivingPointTapped(rating.toInt());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
