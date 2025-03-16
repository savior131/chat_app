import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CustomCircularAvatar extends StatelessWidget {
  const CustomCircularAvatar(
      {super.key, required this.url, required this.radius});
  final String url;
  final double? radius;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            insetPadding: const EdgeInsets.all(0),
            contentPadding: const EdgeInsets.all(0),
            content: SizedBox(
              height: MediaQuery.of(context).size.width * 10 / 16,
              child: Image.network(
                url,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
      child: CircleAvatar(
        backgroundColor: Colors.white12,
        radius: radius,
        child: ClipOval(
          child: FadeInImage.memoryNetwork(
            width: double.infinity,
            height: double.infinity,
            placeholder: kTransparentImage,
            image: url,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
