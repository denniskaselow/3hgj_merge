part of shared;


class Transform extends Component {
  double x, y;
  Transform(num x, num y) : x = x.toDouble(), y = y.toDouble();
}

class Circle extends Component {
  double radius;
  Circle(num radius) : this.radius = radius.toDouble();
  double get area => PI * radius * radius;
}

class Color extends Component {
  int hue;
  double saturation, lightness, opacity;
  Color({num hue: 0, num saturation: 50, num lightness: 50, num opacity: 1})
      : hue = hue.toInt(),
        saturation = saturation.toDouble(),
        lightness = lightness.toDouble(),
        opacity = opacity.toDouble();

}

class Player extends Component {}
class Acceleration extends Component {
  double x = 0.0;
  double y = 0.0;
  double max = 0.00016;
  Acceleration();
}
class Velocity extends Component {
  double x = 0.0;
  double y = 0.0;
  Velocity({num x: 0, num y: 0}) : x = x.toDouble(), y = y.toDouble();
}
class Lifetime extends Component {
  double lifetime = 10000.0;
}
class Particle extends Component {}