import 'package:flutter/material.dart';

import 'constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(60),
          gradient: kLightGradient),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60),
        ),
        height: 60,
        onPressed: () {},
        child:
        Text(
          "Log In",
          style: TextStyle(fontSize: 28.0, color: Colors.white),
        ),
      ),
    );
  }
}
