library shared;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';

part 'src/shared/components.dart';

//part 'src/shared/systems/name.dart';
part 'src/shared/systems/logic.dart';

const TAG_PLAYER = 'player';
const WIDTH = 600;
const HEIGHT = 600;

final gameState = new GameState();

class GameState implements Tweenable {
  static const ZOOM_FACTOR = 0;
  int _absorbed = 0;
  int bestAbsorbed = 0;
  double bestRadius = 10.0;
  double threshold = 1.2;
  int _zoomLevel = 0;
  double _zoomFactor = 1.0;
  double _tZoomFactor = 1.0;

  void set zoomLevel(int value) {
    _zoomLevel = value;
    _tZoomFactor = pow(threshold, value).toDouble();
    Tween.to(this, ZOOM_FACTOR, 1000.0)
          ..targetValues = [_tZoomFactor]
          ..easing = Back.OUT
          ..start(tweenManager);
  }

  int get zoomLevel => _zoomLevel;
  double get zoomFactor => _zoomFactor;
  double get tZoomFactor => _tZoomFactor;
  int get absorbed => _absorbed;
  void set absorbed(int value) {
    _absorbed = value;
    if (_absorbed > bestAbsorbed) {
      bestAbsorbed = _absorbed;
    }
  }

  @override
  int getTweenableValues(int tweenType, List<num> returnValues) {
    if (tweenType == ZOOM_FACTOR) {
      returnValues[0] = _zoomFactor;
      return 1;
    }
    return 0;
  }

  @override
  void setTweenableValues(int tweenType, List<num> newValues) {
    if (tweenType == ZOOM_FACTOR) {
      _zoomFactor = newValues[0];
    }
  }
}
