import 'package:flutter/material.dart';
import 'package:para_final/presentation/utils/text_utilities.dart';

// ignore: must_be_immutable
class RoundedInformation extends StatefulWidget {
  RoundedInformation({Key? key, this.text, this.child}) : super(key: key);
  String? text;
  Widget? child;
  @override
  _RoundedInformationState createState() => _RoundedInformationState();
}

class _RoundedInformationState extends State<RoundedInformation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(
          shadows: [
            BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Color.fromARGB(184, 0, 153, 140))
          ],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
              side: BorderSide(width: 4, color: textColor)),
          color: Color.fromARGB(255, 69, 137, 139)),
      child: widget.child == null
          ? Text(
              widget.text != null ? widget.text! : "",
              style: defaultTextStyle.copyWith(fontSize: 16),
            )
          : widget.child!,
    );
  }
}
