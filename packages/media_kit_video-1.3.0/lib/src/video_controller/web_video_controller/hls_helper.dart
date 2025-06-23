/// HLS.js helper for media_kit_video
/// This file provides HLS support for web platform using HLS.js library
/// 
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/rendering.dart';
import 'package:web/web.dart' as web;

/// Check if HLS.js is available and supported
@JS('Hls.isSupported')
external bool isHlsSupported();

/// HLS.js main class
@JS()
@staticInterop
class Hls {
  external factory Hls(HlsConfig config);
}

extension HlsExtension on Hls {
  external void destroy();
  external void stopLoad();
  external void loadSource(String videoSrc);
  external void attachMedia(web.HTMLVideoElement video);
  external void on(String event, JSFunction callback);
  external HlsConfig config;
}

/// HLS.js configuration
@JS()
@anonymous
@staticInterop
class HlsConfig {
  external factory HlsConfig({JSFunction? xhrSetup});
}

extension HlsConfigExtension on HlsConfig {
  external JSFunction? get xhrSetup;
}

/// Error data structure from HLS.js
class HlsErrorData {
  final String type;
  final String details;
  final bool fatal;

  HlsErrorData({
    required this.type,
    required this.details,
    required this.fatal,
  });

  factory HlsErrorData.fromJs(JSObject data) {
    return HlsErrorData(
      type: data.getProperty('type'.toJS).dartify()?.toString() ?? 'unknown',
      details: data.getProperty('details'.toJS).dartify()?.toString() ?? 'unknown',
      fatal: data.getProperty('fatal'.toJS).dartify() as bool? ?? false,
    );
  }
}

/// HLS helper class for managing HLS.js integration
class HlsHelper {
  Hls? _hls;
  
  /// Check if the URL is an HLS stream
  static bool isHlsUrl(String url) {
    return url.contains('.m3u8') || url.contains('#EXTM3U');
  }
  
  /// Check if browser supports HLS natively
  static bool canPlayHlsNatively(web.HTMLVideoElement element) {
    try {
      final canPlayType = element.canPlayType('application/vnd.apple.mpegurl');
      return canPlayType.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if should use HLS.js library
  static bool shouldUseHlsLibrary(String url, web.HTMLVideoElement element) {
    debugPrint('HlsHelper: Checking if should use HLS for URL: $url');
    debugPrint('isHlsSupported: ${isHlsSupported()}');
    debugPrint('isHlsUrl: ${isHlsUrl(url)}');
    debugPrint('canPlayHlsNatively: ${canPlayHlsNatively(element)}');
    return isHlsSupported() && 
          //  isHlsUrl(url) && 
           !canPlayHlsNatively(element);
  }
  
  /// Initialize HLS.js for the video element
  bool initialize(
    web.HTMLVideoElement videoElement, 
    String url, {
    Map<String, String>? headers,
    Function(HlsErrorData)? onError,
  }) {
    print('HlsHelper: Checking if should use HLS for URL: $url');
    
    // Check if we should use HLS.js
    if (!shouldUseHlsLibrary(url, videoElement)) {
      print('HlsHelper: Not using HLS.js - either not supported, not HLS URL, or browser supports natively');
      return false;
    }
    
    print('HlsHelper: Initializing HLS.js for URL: $url');
    
    try {
      // Create HLS.js instance with configuration
      _hls = Hls(HlsConfig(
        xhrSetup: headers != null && headers.isNotEmpty
            ? ((web.XMLHttpRequest xhr, String _) {
                // Set custom headers
                if (headers.containsKey('useCookies')) {
                  xhr.withCredentials = true;
                }
                headers.forEach((key, value) {
                  if (key != 'useCookies') {
                    xhr.setRequestHeader(key, value);
                  }
                });
              }).toJS
            : null,
      ));
      
      // Attach media element
      _hls!.attachMedia(videoElement);
      
      // Handle HLS events
      _hls!.on('hlsMediaAttached', ((String _, JSObject __) {
        _hls!.loadSource(url);
      }).toJS);
      
      // Handle HLS errors
      if (onError != null) {
        _hls!.on('hlsError', ((String _, JSObject data) {
          try {
            final errorData = HlsErrorData.fromJs(data);
            if (errorData.fatal) {
              onError(errorData);
            }
          } catch (e) {
            // Error parsing HLS error
          }
        }).toJS);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Dispose HLS.js instance
  void dispose() {
    _hls?.destroy();
    _hls = null;
  }
  
  /// Check if HLS.js is currently being used
  bool get isUsingHls => _hls != null;
}
