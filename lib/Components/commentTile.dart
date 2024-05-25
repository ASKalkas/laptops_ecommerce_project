import 'package:flutter/material.dart';

import '../models/comment.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment});

  final Comment comment;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return SizedBox(
      width: 0.9 * screenWidth,
      height: (70 / 640) * screenHeight,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 0.9 * screenWidth,
              height: (70 / 640) * screenHeight,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            left: (5 / 360) * screenWidth,
            top: (5 / 360) * screenWidth,
            child: const Icon(
              Icons.person,
            ),
          ),
          Positioned(
            left: (30 / 360) * screenWidth,
            top: (5 / 640) * screenHeight,
            child: Text(
              '${comment.buyerName}:',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),
          ),
          Positioned(
              right: (5 / 360) * screenWidth,
              top: (5 / 360) * screenWidth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return buildStar(context, index, comment.rating);
                }),
              )),
          Positioned(
            left: (10 / 360) * screenWidth,
            top: (30 / 640) * screenHeight,
            child: SizedBox(
              width: 0.9*screenWidth,
              height: (50/640)*screenHeight,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Full Comment'),
                        content: SizedBox(
                          width: (300 / 360) *
                              screenWidth, // Set the width of the dialog
                          height: (100 / 640) *
                              screenHeight, // Set the height of the dialog
                          child: SingleChildScrollView(
                            child: Text(comment.content),
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  comment.content,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.2, // Adjusted height for better text fitting
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStar(BuildContext context, int index, rating) {
    IconData icon;
    if (index >= rating) {
      icon = Icons.star_border;
    } else if (index > rating - 1 && index < rating) {
      icon = Icons.star_half;
    } else {
      icon = Icons.star;
    }
    return Icon(
      icon,
      color: Colors.amber,
    );
  }
}
