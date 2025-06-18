import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_barrage_craft/flutter_barrage_craft.dart';
import '../../controllers/VideoDamnuController.dart';

/// 视频弹幕层，覆盖在视频播放器之上
class VideoPlayDanmu extends StatefulWidget {
  final String videoId;
  final String fileId;
  final double height;
  final double width;

  const VideoPlayDanmu({
    Key? key,
    required this.videoId,
    required this.fileId,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  State<VideoPlayDanmu> createState() => _VideoPlayDanmuState();
}

class _VideoPlayDanmuState extends State<VideoPlayDanmu> {
  late BarrageController barrageController;
  late VideoDamnuController _danmuController;

  @override
  void initState() {
    super.initState();
    _danmuController = Get.find<VideoDamnuController>(
        tag: '${widget.videoId}VideoDamnuController');
    // _barrageController = _danmuController.barrageController;
    _danmuController.reset(); // 重置弹幕状态
    barrageController = _danmuController.barrageController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        debugPrint(
            'VideoPlayDanmu: initState called, initializing BarrageController');
        barrageController.init(Size(Get.width, Get.height));
        barrageController.setSingleBarrageRemoveScreenCallBack((value) {
          _danmuController.SingleBarrageRemoveScreenCallBack(value);
        });
        if (_danmuController.player!.state.playing) {
          _danmuController.sendToBarrage();
        }
      });
    });
  }

  @override
  void dispose() {
    debugPrint('VideoPlayDanmu: dispose called, cleaning up resources');
    barrageController.clearScreen();
    barrageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _danmuController.context = context;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: BarrageView(controller: barrageController),
    );
    // });
  }
}

/// 视频弹幕层，覆盖在视频播放器之上
class FullscreenVideoPlayDanmu extends StatefulWidget {
  final String videoId;
  final String fileId;
  final double height;
  final double width;

  const FullscreenVideoPlayDanmu({
    Key? key,
    required this.videoId,
    required this.fileId,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  State<FullscreenVideoPlayDanmu> createState() =>
      _FullscreenVideoPlayDanmuState();
}

class _FullscreenVideoPlayDanmuState extends State<FullscreenVideoPlayDanmu> {
  BarrageController fullscreenBarrageController = BarrageController();
  late VideoDamnuController _danmuController;

  @override
  void initState() {
    super.initState();
    _danmuController = Get.find<VideoDamnuController>(
        tag: '${widget.videoId}VideoDamnuController');
    // _barrageController = _danmuController.barrageController;
    _danmuController.reset(); // 重置弹幕状态
    _danmuController.fullscreenBarrageController = fullscreenBarrageController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        debugPrint(
            'VideoPlayDanmu: initState called, initializing BarrageController');
        fullscreenBarrageController.init(Size(Get.width, Get.height));
        fullscreenBarrageController.setSingleBarrageRemoveScreenCallBack((value) {
          _danmuController.fullscreenSingleBarrageRemoveScreenCallBack(value);
        });
        if (_danmuController.player!.state.playing) {
          _danmuController.sendToBarrage();
        }
      });
    });
  }

  @override
  void dispose() {
    debugPrint('FullscreenVideoPlayDanmu: dispose called, cleaning up resources');
    fullscreenBarrageController.clearScreen();
    fullscreenBarrageController.dispose();
    _danmuController.fullscreenBarrageController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _danmuController.context = context;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: BarrageView(controller: fullscreenBarrageController),
    );
    // });
  }
}
