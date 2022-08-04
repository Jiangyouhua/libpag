import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PAGView extends StatefulWidget {
  double? width;
  double? height;
  String? assetName;
  String? url;
  double? initProgress;
  bool autoPlay;
  int? repeatCount;
  static const int REPEAT_COUNT_LOOP = -1; //无限循环
  static const int REPEAT_COUNT_DEFAULT = 1; //默认仅播放一次

  PAGView.network(this.url,
      {this.width,
      this.height,
      this.repeatCount,
      this.initProgress,
      this.autoPlay = true,
      Key? key})
      : super(key: key);

  PAGView.asset(this.assetName,
      {this.width,
      this.height,
      this.repeatCount,
      this.initProgress,
      this.autoPlay = true,
      Key? key})
      : super(key: key);

  @override
  PAGViewState createState() => PAGViewState();
}

class PAGViewState extends State<PAGView> {
  final _channel = const MethodChannel('flutter_pag_plugin');
  bool _hasLoadTexture = false;
  int _textureId = -1;
  final Widget _canvasWidget = !kIsWeb
      ? const Text("web")
      : HtmlElementView(
          key: UniqueKey(),
          viewType: "arguments",
        );

  double _rawWidth = 0;
  double _rawHeight = 0;

  @override
  void initState() {
    render();
    super.initState();
  }

  void render() async {
    int repeatCount = widget.repeatCount ?? PAGView.REPEAT_COUNT_DEFAULT;
    if (repeatCount <= 0 && repeatCount != PAGView.REPEAT_COUNT_LOOP) {
      repeatCount = PAGView.REPEAT_COUNT_DEFAULT;
    }

    dynamic result = await _channel.invokeMethod('initPag', {
      'assetName': widget.assetName,
      'url': widget.url,
      'width': widget.width,
      'height': widget.height,
      'repeatCount': repeatCount,
      'initProgress': widget.initProgress ?? 0,
      'autoPlay': widget.autoPlay,
    });

    setState(() {
      _textureId = result['textureId'];
      _rawWidth = result['width'] ?? 0;
      _rawHeight = result['height'] ?? 0;
      _hasLoadTexture = true;
    });
  }

  void start() {
    _channel.invokeMethod('start', {'textureId': _textureId});
  }

  void stop() {
    _channel.invokeMethod('stop', {'textureId': _textureId});
  }

  void pause() {
    _channel.invokeMethod('pause', {'textureId': _textureId});
  }

  void setProgress(double progress) {
    _channel.invokeMethod(
        'setProgress', {'textureId': _textureId, 'progress': progress});
  }

  Future<List<String>> getLayersUnderPoint(double x, double y) async {
    return (await _channel.invokeMethod('getLayersUnderPoint',
            {'textureId': _textureId, 'x': x, 'y': y}) as List)
        .map((e) => e.toString())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? (_rawWidth / 2),
      height: widget.height ?? (_rawHeight / 2),
      child: kIsWeb
          ? _canvasWidget
          : (_hasLoadTexture
              ? Texture(textureId: _textureId)
              : const Text("PAG")),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _channel.invokeMethod('release', {'textureId': _textureId});
  }
}
