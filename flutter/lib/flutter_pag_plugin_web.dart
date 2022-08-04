// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:js_util';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_pag_plugin/pag.dart';

/// A web implementation of the FlutterPagPluginPlatform of the FlutterPagPlugin plugin.
class FlutterPagPluginWeb extends PlatformInterface {
  /// Constructs a FlutterPagPluginPlatform.
  FlutterPagPluginWeb() : super(token: _token);
  static final Object _token = Object();
  static Map<int, PagView> players = {};

  static void registerWith(Registrar registrar) {
    final FlutterPagPluginWeb instance = FlutterPagPluginWeb();
    final MethodChannel channel = MethodChannel(
        'flutter_pag_plugin', const StandardMethodCodec(), registrar);
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "initPag":
          return await instance.newCanvas(call.arguments);
        case "start":
          return instance.playerStart(call.arguments);
        case "stop":
          return instance.playerStop(call.arguments);
        case "pause":
          return instance.playerPause(call.arguments);
        case "setProgress":
          return instance.playerSetProgress(call.arguments);
        case "getLayersUnderPoint":
          return instance.playerGetLayersUnderPoint(call.arguments);
      }
    });
  }

  Future<dynamic> newCanvas(dynamic arguments) async {
    final assetName = arguments["assetName"];
    final url = arguments['url'];
    final repeatCount = arguments['repeatCount'];
    final initProgress = arguments['initProgress'];
    final autoPlay = arguments['autoPlay'];
    final id = DateTime.now().millisecondsSinceEpoch;
    final html.CanvasElement canvasElement = html.CanvasElement()..id = "$id";
    // ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('arguments', (int viewId) {
      return canvasElement;
    });

    final name = assetName ?? url;
    final pag = await promiseToFuture(initPAG());
    final response = await promiseToFuture(fetch(name!));
    final buffer = await response.arrayBuffer();
    final pagFile = await promiseToFuture(pag.PAGFile.load(buffer));
    final pagView =
        await promiseToFuture(pag.PAGView.init(pagFile, canvasElement));
    pagView.setRepeatCount(repeatCount ?? 0);
    pagView.setProgress(initProgress ?? 0.0);
    if (autoPlay) {
      pagView.play();
    }
    players[id] = pagView;
    return {
      "textureId": id,
      "width": pagFile.width(),
      "height": pagFile.height()
    };
  }

  void playerStart(dynamic arguments) {
    final id = arguments['textureId'];
    players[id]?.play();
  }

  void playerStop(dynamic arguments) {
    final id = arguments['textureId'];
    players[id]?.stop();
  }

  void playerPause(dynamic arguments) {
    final id = arguments['textureId'];
    players[id]?.pause();
  }

  void playerSetProgress(dynamic arguments) {
    final id = arguments['textureId'];
    final progress = arguments['progress'];
    players[id]?.setProgress(progress);
  }

  dynamic playerGetLayersUnderPoint(dynamic arguments) {
    final id = arguments['textureId'];
    final x = arguments['x'] ?? 0;
    final y = arguments['y'] ?? 0;
    return players[id]?.getLayersUnderPoint(x, y);
  }
}
