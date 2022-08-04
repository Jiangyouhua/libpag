import 'package:flutter/material.dart';
import 'package:flutter_pag_plugin/flutter_pag_plugin.dart';
import 'package:flutter_pag_plugin/pag_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final GlobalKey<PAGViewState> assetPagKey = GlobalKey<PAGViewState>();
  final GlobalKey<PAGViewState> networkPagKey = GlobalKey<PAGViewState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('PAGView example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///TODO: PAGView加载本地资源
            Padding(
              padding: EdgeInsets.only(top: 20, left: 12, bottom: 20),
              child: Text(
                "PAGView加载本地资源：",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54),
              ),
            ),
            PAGView.asset(
              "assets/ball.pag",
              repeatCount: PAGView.REPEAT_COUNT_LOOP,
              initProgress: 0.25,
              autoPlay: true,
              key: assetPagKey,
            ),
            Padding(
              padding: EdgeInsets.only(left: 12, top: 10),
              child: Row(
                children: [
                  IconButton(
                    iconSize: 30,
                    icon: const Icon(
                      Icons.pause_circle,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      // 暂停
                      assetPagKey.currentState?.pause();
                    },
                  ),
                  IconButton(
                    iconSize: 30,
                    icon: const Icon(
                      Icons.play_circle,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      //播放
                      assetPagKey.currentState?.start();
                    },
                  ),
                  Text(
                    "<= 请点击控制动画",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
