part of shared;


class Transform extends Component {
  Vector2 pos;
  Transform(num x, num y) : pos = new Vector2(x.toDouble(), y.toDouble());
}

class Circle extends Component {
  double radius;
  Circle(num radius) : this.radius = radius.toDouble();
}

class Color extends Component {
  int hue;
  double saturation;
  double lightness;
  double opacity;
  Color({num hue: 0, num saturation: 50, num lightness: 50, num opacity: 1})
      : hue = hue.toInt(),
        saturation = saturation.toDouble(),
        lightness = lightness.toDouble(),
        opacity = opacity.toDouble();

}

class InputController extends Component {}
class Acceleration extends Component {
  Vector2 value = new Vector2.zero();
  double max = 10.0;
  Acceleration();
}
class Velocity extends Component {
  Vector2 value;
  Velocity({num x: 0, num y: 0}) : value = new Vector2(x.toDouble(), y.toDouble());
}