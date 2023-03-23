import 'package:flutter/material.dart'
    '';

import '../helper/manuplator_functions.dart';
import '../models/models.dart';
import '../pages/view_single_photo.dart';
class DMChatPageMessageTile extends StatefulWidget {
  final String messageContext;
  final String date;
  final bool sentByMe;
  final DirectMessageKinds type;

  const DMChatPageMessageTile({
    Key? key,
    required this.messageContext,
    required this.date,
    required this.sentByMe,
    required this.type,
  }) : super(key: key);

  @override
  State<DMChatPageMessageTile> createState() => _DMChatPageMessageTileState();
}

class _DMChatPageMessageTileState extends State<DMChatPageMessageTile> {
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final heigth = size.height - padding.top - padding.bottom;
    final width = size.width - padding.left - padding.right;

    final availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    bool? hideDateText = false;

    if (widget.date == ".") {
      hideDateText = true;
    }

    return Container(
      child: Row(
        mainAxisAlignment: widget.sentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            //width: width-40,
            constraints: BoxConstraints(minWidth: 0, maxWidth: width-40),
            margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: widget.sentByMe ? const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ) : const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                color: widget.sentByMe ? Colors.grey : Colors.orange
            ),
            child: Column(
              crossAxisAlignment: widget.sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                
                Container(
                  child: widget.type == DirectMessageKinds.text ? Text(
                    widget.messageContext,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.start,
                    style: TextStyle(

                    ),
                  ) :
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return ViewSinglePhoto(imageProvider: NetworkImage(widget.messageContext,),);
                      }));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.messageContext,
                        height: 200,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3,),
                hideDateText ? Container() : Padding(
                  padding: widget.sentByMe ? const EdgeInsets.only(right: 0.0) : const EdgeInsets.only(left: 0.0),
                  child: Text(
                    StringDateExtensions.displayTimeAgoFromDMYHM(widget.date),
                    style: TextStyle(
                        color: widget.sentByMe ? Colors.white60 :  Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
