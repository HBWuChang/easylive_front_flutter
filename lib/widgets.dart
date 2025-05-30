import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:extended_image/extended_image.dart';
Widget Avatar({String? avatarValue, double? radius = 16, Key? key}) {
  // 如果avatarValue为空或null，显示默认头像
  // 否则显示网络头像
  if (avatarValue == null || avatarValue.isEmpty) {
    return CircleAvatar(
      key: key,
      radius: radius!,
      backgroundImage: AssetImage(Constants.defaultAvatar),
    );
  } else {
    return CircleAvatar(
      key: key,
      radius: radius!,
      backgroundImage: ExtendedNetworkImageProvider(
        ApiService.baseUrl + ApiAddr.fileGetResourcet + avatarValue,
      ),
    );
  }
}

Widget accountDialogNumWidget(String info, {int? count}) {
  int showCount = count ?? 0;
  String showText;
  if (showCount >= 1000000) {
    showText = (showCount / 1000000)
            .toStringAsFixed(showCount % 1000000 == 0 ? 0 : 1) +
        'M';
  } else if (showCount >= 1000) {
    showText =
        (showCount / 1000).toStringAsFixed(showCount % 1000 == 0 ? 0 : 1) + 'K';
  } else {
    showText = showCount.toString();
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: '$showCount',
          child: Text(
            showText,
            style: TextStyle(fontSize: 20, color: Colors.black87),
          ),
        ),
        Text(
          info,
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    ),
  );
}
