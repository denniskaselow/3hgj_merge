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
    canvas.context2D..setFillColorHsl((180 - c.hue) % 360, 100 - c.saturation, 100 - c.lightness)
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
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var circle = cim.get(entity);
    var color = com.get(entity);

    ctx..beginPath()
       ..setFillColorHsl(color.hue, color.saturation, color.lightness, color.opacity)
       ..arc(t.pos.x, t.pos.y, circle.radius, 0, 2 * PI)
       ..fill()
       ..closePath();
  }
}