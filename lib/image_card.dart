

import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String image,city;
  const ImageCard({super.key, required this.image, required this.city});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentGeometry.bottomCenter,
      padding: EdgeInsets.only(bottom: 30),
      width: 200,
      height: 300,
      decoration: BoxDecoration(
          borderRadius: BorderRadiusGeometry.circular(30),
          image: DecorationImage(image: AssetImage(image,


          ),
              fit: BoxFit.cover

          )

      ),
      child: Text(city,
        style: TextStyle(color: Colors.white,
            fontSize: 30

        ),
      ),

    );
  }
}

