part of shared;


class AcccelerationSystem extends EntityProcessingSystem {
  ComponentMapper<Acceleration> am;
  ComponentMapper<Velocity> vm;
  AcccelerationSystem() : super(Aspect.getAspectForAllOf([Acceleration, Velocity]));

  @override
  void processEntity(Entity entity) {
    var a = am.get(entity);
    var v = vm.get(entity);

    v.value.x += a.value.x / world.delta;
    v.value.y += a.value.y / world.delta;

    a.value.setZero();
  }
}

class MovementSystem extends EntityProcessingSystem {
  ComponentMapper<Velocity> vm;
  ComponentMapper<Transform> tm;
  MovementSystem() : super(Aspect.getAspectForAllOf([Transform, Velocity]));

  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var v = vm.get(entity);

    t.pos.x += v.value.x / world.delta;
    t.pos.y += v.value.y / world.delta;
  }
}

class WallBouncingSystem extends EntityProcessingSystem {
  ComponentMapper<Velocity> vm;
  ComponentMapper<Transform> tm;
  WallBouncingSystem() : super(Aspect.getAspectForAllOf([Player, Velocity, Transform]));

  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var v = vm.get(entity);

    var x = t.pos.x;
    var y = t.pos.y;
    if (x <= 0.0 || x >= 500.0) {
      t.pos.x = x > 0.0 ? 500.0 : 0.0;
      v.value.x = -0.8 * v.value.x;
    }
    if (y <= 0.0 || y >= 500.0) {
      t.pos.y = y > 0.0 ? 500.0 : 0.0;
      v.value.y = -0.8 * v.value.y;
    }
  }
}

class CircleSpawner extends IntervalEntityProcessingSystem {
  ComponentMapper<Circle> cm;
  CircleSpawner() : super(1000, Aspect.getAspectForAllOf([Player, Circle]));

  @override
  void processEntity(Entity entity) {
    var radius = cm.get(entity).radius;
    var x = 0.5 - random.nextDouble();
    var y = 0.5 - random.nextDouble();
    if (x < 0.0) {
      x = -50 + x * 100;
    } else {
      x = 550 + x * 100;
    }
    if (y < 0.0) {
      y = -50 + y * 100;
    } else {
      y = 550 + y * 100;
    }
    var vx = -x.sign * (2.0 + random.nextDouble() * 18);
    var vy = -y.sign * (2.0 + random.nextDouble() * 18);

    world.createAndAddEntity([new Transform(x, y),
                              new Velocity(x: vx, y: vy),
                              new Lifetime(),
                              new Circle(0.5 * radius + random.nextDouble() * radius),
                              new Color(hue: random.nextInt(360),
                                  saturation: random.nextDouble() * 100,
                                  lightness: random.nextDouble() * 100,
                                  opacity: 0.2 + random.nextDouble() * 0.8)]);
  }
}

class CircleRemover extends EntityProcessingSystem {
  ComponentMapper<Lifetime> lm;
  ComponentMapper<Transform> tm;
  CircleRemover() : super(Aspect.getAspectForAllOf([Lifetime, Transform]));

  @override
  void processEntity(Entity entity) {
    var lt = lm.get(entity);
    lt.lifetime -= world.delta;
    if (lt.lifetime <= 0.0) {
      var pos = tm.get(entity).pos;
      if (pos.x <= -100.0 || pos.x > 600.0 || pos.y <= -100.0 || pos.y > 600.0) {
        entity.deleteFromWorld();
      }
    }
  }
}