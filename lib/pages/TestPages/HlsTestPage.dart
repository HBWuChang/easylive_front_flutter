import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// 测试 HLS 支持的页面
class HlsTestPage extends StatefulWidget {
  const HlsTestPage({Key? key}) : super(key: key);

  @override
  State<HlsTestPage> createState() => _HlsTestPageState();
}

class _HlsTestPageState extends State<HlsTestPage> {
  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    
    // 测试加载一个 HLS 流
    _loadHlsStream();
  }

  void _loadHlsStream() {
    // 使用一个公开的 HLS 测试流
    const hlsUrl = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
    player.open(Media(hlsUrl));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HLS 测试'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Video(
                  controller: controller,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (player.state.playing) {
                        player.pause();
                      } else {
                        player.play();
                      }
                    },
                    child: StreamBuilder<bool>(
                      stream: player.stream.playing,
                      builder: (context, snapshot) {
                        final playing = snapshot.data ?? false;
                        return Text(playing ? '暂停' : '播放');
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '正在测试 HLS 流播放',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'URL: https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
