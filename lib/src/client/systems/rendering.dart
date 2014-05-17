part of client;

class CanvasCleaningSystem extends VoidEntitySystem {
  TagManager tm;
  ComponentMapper<Color> cm;
  CanvasElement canvas;
  String fillStyle;

  CanvasCleaningSystem(this.canvas);

  void processSystem() {
    var entity = tm.getEntity(TAG_PLAYER);
    var c = cm.get(entity);
    canvas.context2D..setFillColorHsl((180 + c.hue) % 360, 100 - c.saturation, 100 - c.lightness, c.opacity)
                    ..fillRect(0, 0, canvas.width, canvas.height);
  }
}

class CircleRenderingSystem extends EntityProcessingSystem {
  static const halfWidth = WIDTH / 2;
  static const halfHeight = HEIGHT / 2;
  ComponentMapper<Transform> tm;
  ComponentMapper<Circle> cim;
  ComponentMapper<Color> com;
  CanvasRenderingContext2D ctx;
  CircleRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Transform, Circle, Color]));

  @override
  void begin() {
    ctx..save()
       ..translate(halfWidth, halfHeight);
  }

  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var circle = cim.get(entity);
    var color = com.get(entity);

    ctx..beginPath()
       ..setFillColorHsl(color.hue, color.saturation, color.lightness, color.opacity)
       ..arc(t.pos.x / gameState.zoomFactor, t.pos.y / gameState.zoomFactor, circle.radius / gameState.zoomFactor, 0, 2 * PI)
       ..fill()
       ..closePath();
  }

  @override
  void end() {
    ctx.restore();
  }
}

class StatsRenderingSystem extends VoidEntitySystem {
  static const currentStatsY = HEIGHT - 40;
  static const bestStatsY = HEIGHT - 20;
  static const borderRight = WIDTH - 10;
  CanvasRenderingContext2D ctx;
  TagManager tm;
  ComponentMapper<Circle> cm;
  ComponentMapper<Color> com;
  StatsRenderingSystem(this.ctx);

  @override
  void processSystem() {
    var player = tm.getEntity(TAG_PLAYER);
    var circle = cm.get(player);
    var color = com.get(player);

    var radius = getRadius(circle.radius);
    var bestRadius = getRadius(gameState.bestRadius);
    var textRadius = 'Radius: $radius';
    var textBestRadius = 'Personal best: $bestRadius';
    var textAbsorbed = 'Circles absorbed: ${gameState.absorbed}';
    var textBestAbsorbed = 'Personal best: ${gameState.bestAbsorbed}';
    var textRadiusWidth = ctx.measureText(textRadius).width;
    var textBestRadiusWidth = ctx.measureText(textBestRadius).width;

    ctx..font = 'bold ${ctx.font}'
       ..setFillColorHsl(color.hue, color.saturation, color.lightness)
       ..fillText(textAbsorbed, 10, currentStatsY)
       ..fillText(textBestAbsorbed, 10, bestStatsY)
       ..fillText(textRadius, borderRight - textRadiusWidth, currentStatsY)
       ..fillText(textBestRadius, borderRight - textBestRadiusWidth, bestStatsY);
  }

  String getRadius(double radius) {
    radius = radius / 1000.0;
    var unit = 'm';
    if (radius < 0.000000001) {
      unit = 'pm';
      radius *= 1000000000000.0;
    } else if (radius < 0.000001) {
      unit = 'nm';
      radius *= 1000000000.0;
    } else if (radius < 0.001) {
      unit = 'µm';
      radius *= 1000000.0;
    } else if (radius < 0.01) {
      unit = 'mm';
      radius *= 1000.0;
    } else if (radius < 1.0) {
      unit = 'cm';
      radius *= 100.0;
    } else if (radius < 1000.0) {
      unit = 'm';
    } else if (radius < 6335.437) {
      unit = 'km';
      radius /= 1000.0;
    } else if (radius < 695500000.0) {
      unit = 'Earth radius';
      radius /= 6335.437;
    } else if (radius < 149597870700.0) {
      unit = 'Sun radius';
      radius /= 695500000.0;
    } else if (radius < 25902068400000.0) {
      unit = 'AU';
      radius /= 149597870700.0;
    } else if (radius < 9460528400000000.0) {
      unit = 'lightdays';
      radius /= 25902068400000.0;
    } else if (radius < 30856776000000000.0) {
      unit = 'lightyears';
      radius /= 9460528400000000.0;
    } else {
      unit = 'parsec';
      radius /= 30856776000000000.0;
    }
    return '${radius.toStringAsFixed(2)} $unit';
  }
}