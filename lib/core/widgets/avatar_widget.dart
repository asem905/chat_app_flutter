import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showOnlineIndicator;
  final bool isOnline;

  const AvatarWidget({
    Key? key,
    this.imageUrl,
    required this.name,
    this.size = 50,
    this.showOnlineIndicator = false,
    this.isOnline = false,
  }) : super(key: key);

  String _getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '?';
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }
    return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
  }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.orange,
      Colors.deepOrange,
    ];
    final index = name.hashCode % colors.length;
    return colors[index.abs()];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getColorFromName(name),
            image: imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl == null
              ? Center(
                  child: Text(
                    _getInitials(name),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
