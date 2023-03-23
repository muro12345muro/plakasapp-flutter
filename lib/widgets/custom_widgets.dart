import 'package:flutter/material.dart';

void showSnackbar({required BuildContext context, required Color color, required String message, bool showProgressCircle = false, bool? isInfinite}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 20,),
          showProgressCircle ?
          SizedBox(height: 20, width: 20, child: circularProgressIndicator()) :
          const SizedBox()
        ],
      ),
      backgroundColor: color,
      duration: isInfinite ?? false ? const Duration(days: 1) : showProgressCircle ? const Duration(days: 1) : const Duration(seconds: 2),
      action: !showProgressCircle ? SnackBarAction(
        label: "OK",
        onPressed: () {},
        textColor: Colors.white,
      ) : null,
    ),
  );
}


class NonEmptyCircleAvatar extends StatelessWidget {
  const NonEmptyCircleAvatar({
    Key? key,
    this.profilePictureURL,
    required this.radius,
  }) : super(key: key);

  final String? profilePictureURL;
  final double radius;
//28/18
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage:  profilePictureURL == null ? null : NetworkImage(profilePictureURL!),
      radius: radius,
      backgroundColor: Colors.grey,
      child: profilePictureURL == null ? Icon(Icons.person, size: radius * (28/18), color: Colors.white,) : null,
    );
  }
}

Center circularProgressIndicator() => Center(child: CircularProgressIndicator(color: Colors.orange, backgroundColor: Colors.red));