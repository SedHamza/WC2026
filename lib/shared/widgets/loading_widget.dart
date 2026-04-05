import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color color;
  const LoadingWidget({
    super.key,
    this.color = const Color(0xFF002868),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: color),
    );
  }
}