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