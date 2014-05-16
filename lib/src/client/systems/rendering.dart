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
  ComponentMapper<Transform> tm;
  ComponentMapper<Circle> cim;
  ComponentMapper<Color> com;
  CanvasRenderingContext2D ctx;
  CircleRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Transform, Circle, Color]));

  @override
  void begin() {
    ctx..save()
       ..translate(250, 250);
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

    var radius = circle.radius / 1000;
    var unit = 'm';
    if (radius < 0.000000001) {
      unit = 'pm';
      radius *= 1000000000000;
    } else if (radius < 0.000001) {
      unit = 'nm';
      radius *= 1000000000;
    } else if (radius < 0.001) {
      unit = 'µm';
      radius *= 1000000;
    } else if (radius < 0.01) {
      unit = 'mm';
      radius *= 1000;
    } else if (radius < 1.0) {
      unit = 'cm';
      radius *= 100;
    } else if (radius < 1000.0) {
      unit = 'm';
    } else if (radius < 6335.437) {
      unit = 'km';
      radius /= 1000;
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

    var textRadius = 'Radius: ${radius.toStringAsFixed(2)} $unit';
    var textEaten = 'Circles absorbed: ${gameState.eatenEntities}';
    var textRadiusWidth = ctx.measureText(textRadius).width;

    ctx..font = 'bold ${ctx.font}'
       ..setFillColorHsl(color.hue, color.saturation, color.lightness)
       ..fillText(textEaten, 10, 480)
       ..fillText(textRadius, 490 - textRadiusWidth, 480);
  }
}