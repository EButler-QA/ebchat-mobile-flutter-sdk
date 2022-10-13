import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    Key? key,
    required this.user,
    required this.radius,
    this.onTap,
  }) : super(key: key);

  const Avatar.verySmall({
    Key? key,
    required this.user,
    this.onTap,
  })  : radius = 10,
        super(key: key);

  const Avatar.small({
    Key? key,
    required this.user,
    this.onTap,
  })  : radius = 18,
        super(key: key);

  const Avatar.medium({
    Key? key,
    required this.user,
    this.onTap,
  })  : radius = 26,
        super(key: key);

  const Avatar.large({
    Key? key,
    required this.user,
    this.onTap,
  })  : radius = 34,
        super(key: key);

  const Avatar.veryLarge({
    Key? key,
    required this.user,
    this.onTap,
  })  : radius = 40,
        super(key: key);

  const Avatar.value({
    Key? key,
    required this.user,
    this.onTap,
    required this.radius,
  }) : super(key: key);

  final double radius;
  final User user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _avatar(context),
    );
  }

  Widget _avatar(BuildContext context) {
    if ((user.image != null && user.image!.isNotEmpty) ||
        (user.extraData["avatar"] != null &&
            user.extraData["avatar"].toString().isNotEmpty)) {
      String url = (user.image != null && user.image!.isNotEmpty)
          ? user.image!
          : user.extraData["avatar"].toString();

      return user.role != "guest"
          ? CircleAvatar(
              radius: radius,
              backgroundImage: CachedNetworkImageProvider(url),
              backgroundColor: Theme.of(context).cardColor,
            )
          : ClipOval(
              child: SizedBox.fromSize(
                size: Size.fromRadius(radius), // Image radius
                child: SvgPicture.network(
                  url,
                  fit: BoxFit.cover,
                ),
              ),
            );
    } else {
      if (user.id == Config.alfredId) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Theme.of(context).cardColor,
          backgroundImage: Image.asset(
            package: "ebchat",
            "assets/alfred.png",
          ).image,
        );
      } else {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Theme.of(context).cardColor,
          backgroundImage: Image.asset(
            package: "ebchat",
            "assets/unknownAvatar.png",
          ).image,
        );
      }
    }
  }
}
