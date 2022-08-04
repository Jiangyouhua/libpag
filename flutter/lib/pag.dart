@JS()
library pag.js;

import 'package:js/js.dart';

@JS()
external dynamic loadPagBuffter();

@JS("fetch")
external Result fetch(String file);

@JS()
class Result {
  external dynamic arrayBuffer();
}

@JS('libpag.PAGInit')
external PAG initPAG();

@JS()
class PAG {
  external PagFile get PAGFile;
  external PagView get PAGView;
}

@JS()
@anonymous
class PagFile {
  external PagFile load(dynamic butter);
  external int width();
  external int height();
}

@JS()
@anonymous
class PagView {
  external PagView init(PagFile file, dynamic canvas);
  external void setRepeatCount(int repeatCount);
  external void play();
  external void start();
  external void pause();
  external void stop();
  external void setProgress(double progress);
  external dynamic getLayersUnderPoint(int x, int y);
}
