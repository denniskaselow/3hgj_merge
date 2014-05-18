part of shared;

class AcccelerationSystem extends EntityProcessingSystem {
  ComponentMapper<Acceleration> am;
  ComponentMapper<Velocity> vm;
  AcccelerationSystem() : super(Aspect.getAspectForAllOf([Acceleration, Velocity]));

  @override
  void processEntity(Entity entity) {
    var a = am.get(entity);
    var v = vm.get(entity);

    v.x += a.x / world.delta;
    v.y += a.y / world.delta;

    a.x = 0.0;
    a.y = 0.0;
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

    t.x += v.x / world.delta;
    t.y += v.y / world.delta;
  }
}

class WallBouncingSystem extends EntityProcessingSystem {
  static const halfWidth = WIDTH / 2;
  static const halfHeight = HEIGHT / 2;
  ComponentMapper<Velocity> vm;
  ComponentMapper<Transform> tm;
  WallBouncingSystem() : super(Aspect.getAspectForAllOf([Player, Velocity, Transform]));

  @override
  void processEntity(Entity entity) {
    var t = tm.get(entity);
    var v = vm.get(entity);

    var x = t.x;
    var y = t.y;
    if (x.abs() >= halfWidth * gameState.zoomFactor) {
      t.x = (x > 0.0 ? halfWidth : -halfWidth) * gameState.zoomFactor;
      v.x = -0.8 * v.x;
    }
    if (y.abs() >= halfHeight * gameState.zoomFactor) {
      t.y = (y > 0.0 ? halfHeight : -halfHeight) * gameState.zoomFactor;
      v.y = -0.8 * v.y;
    }
  }
}

class CircleSpawner extends IntervalEntityProcessingSystem {
  static const circleSpawnX = WIDTH + 100;
  static const circleSpawnY = HEIGHT + 100;
  static const halfCircleSpawnX = circleSpawnX / 2;
  static const halfCircleSpawnY = circleSpawnY / 2;
  ComponentMapper<Circle> cm;
  CircleSpawner() : super(750, Aspect.getAspectForAllOf([Player, Circle]));

  @override
  void processEntity(Entity entity) {
    var radius = cm.get(entity).radius;
    var x = halfCircleSpawnX - circleSpawnX * random.nextDouble();
    var y = halfCircleSpawnY - circleSpawnY * random.nextDouble();;
    if (x.abs() < halfCircleSpawnX) {
      y = 0.5 - random.nextDouble();
      if (y < 0.0) {
        y = -halfCircleSpawnY + y * 100;
      } else {
        y = halfCircleSpawnY + y * 100;
      }
    }
    x *= gameState.zoomFactor;
    y *= gameState.zoomFactor;
    var vx = -x.sign * (2.0 + random.nextDouble() * 18) * gameState.zoomFactor;
    var vy = -y.sign * (2.0 + random.nextDouble() * 18) * gameState.zoomFactor;

    world.createAndAddEntity([new Transform(x, y),
                              new Velocity(x: vx, y: vy),
                              new Lifetime(),
                              new Circle(0.5 * radius + random.nextDouble() * (2 * radius + gameState.zoomFactor / 10.0)),
                              new Color(hue: random.nextInt(360),
                                  saturation: random.nextDouble() * 100,
                                  lightness: random.nextDouble() * 100,
                                  opacity: 0.2 + random.nextDouble() * 0.8)]);
  }
}

class CircleRemover extends EntityProcessingSystem {
  static const outOfBoundsX = (WIDTH + 200) / 2;
  static const outOfBoundsY = (HEIGHT + 200) / 2;
  ComponentMapper<Lifetime> lm;
  ComponentMapper<Transform> tm;
  ComponentMapper<Circle> cm;
  CircleRemover() : super(Aspect.getAspectForAllOf([Lifetime, Transform, Circle]));

  @override
  void processEntity(Entity entity) {
    var lt = lm.get(entity);
    lt.lifetime -= world.delta;
    if (lt.lifetime <= 0.0) {
      var pos = tm.get(entity);
      if (pos.x.abs() > outOfBoundsX * gameState.zoomFactor ||
          pos.y.abs() > outOfBoundsY * gameState.zoomFactor ||
          cm.get(entity).radius / gameState.zoomFactor < 0.1) {
        entity.deleteFromWorld();
      }
    }
  }
}

class CircleCollisionDetectionSystem extends EntityProcessingSystem {
  TagManager tagManager;
  ComponentMapper<Transform> tm;
  ComponentMapper<Circle> cm;
  ComponentMapper<Color> com;
  Transform playerPos;
  Circle playerCircle;
  Color playerColor;

  CircleCollisionDetectionSystem() : super(Aspect.getAspectForAllOf([Circle, Transform, Color]).exclude([Player, Particle]));

  @override
  void begin() {
    var player = tagManager.getEntity(TAG_PLAYER);
    playerPos = tm.get(player);
    playerCircle = cm.get(player);
    playerColor = com.get(player);
  }


  @override
  void processEntity(Entity entity) {
    var pos = tm.get(entity);
    var circle = cm.get(entity);
    if (Utils.doCirclesCollide(pos.x, pos.y, circle.radius, playerPos.x, playerPos.y, playerCircle.radius)) {
      var playerArea = playerCircle.area;
      var area = circle.area;
      var color = com.get(entity);
      var ratio = area / playerArea;
      if (area / playerArea < 0.1) {
        playerArea += area;
        gameState.absorbed++;
        if (gameState.absorbed % 10 == 0) {
          eventBus.fire(analyticsTrackEvent, new AnalyticsTrackEvent('Circles absorbed', '${gameState.absorbed}'));
        }
        for (int i = 0; i < 3 * sqrt(area) / gameState.zoomFactor; i++) {
          var velocityAngle = 2 * PI * random.nextDouble();
          var velocityMult = 25.0 + random.nextDouble() * 50;
          world.createAndAddEntity([new Particle(),
                                    new Lifetime(),
                                    new Transform(pos.x + sin(-circle.radius + random.nextDouble() * 2 * circle.radius),
                                        pos.y + sin(-circle.radius + random.nextDouble() * 2 * circle.radius)),
                                    new Velocity(x: sin(velocityAngle) * velocityMult * gameState.zoomFactor,
                                        y: cos(velocityAngle) * velocityMult * gameState.zoomFactor),
                                    new Circle(random.nextDouble() * circle.radius),
                                    new Color(hue: color.hue, saturation: color.saturation, lightness: color.lightness, opacity: color.opacity)
                                    ]);
        }
        entity.deleteFromWorld();
      } else if (area > playerArea) {
        area += playerArea * 0.1;
        playerArea *= 0.9;
        circle.radius = sqrt(area / PI);
        ratio = 0.0;
      } else {
        playerArea += area * 0.1;
        area *= 0.9;
        ratio *= 0.1;
        circle.radius = sqrt(area / PI);
      }
      var hueDiff = color.hue - playerColor.hue;
      if (hueDiff > 180) {
        hueDiff = 180-hueDiff;
      }
      playerColor.hue += (hueDiff * ratio).toInt();
      playerColor.hue = playerColor.hue % 360;
      playerColor.saturation += (color.saturation - playerColor.saturation) * ratio;
      playerColor.lightness += (color.lightness - playerColor.lightness) * ratio;
      playerColor.opacity += (color.opacity - playerColor.opacity) * ratio;

      playerCircle.radius = sqrt(playerArea / PI);
      if (playerCircle.radius > gameState.bestRadius) {
        gameState.bestRadius = playerCircle.radius;
      }
    }
  }

  @override
  void end() {
    var playerZoomRatio = playerCircle.radius / gameState.tZoomFactor;
    while (playerZoomRatio > 10.0 * gameState.threshold) {
      gameState.zoomLevel++;
      if (gameState.zoomLevel.abs() % 10 == 0) {
        eventBus.fire(analyticsTrackEvent, new AnalyticsTrackEvent('Zoom Out', '${gameState.zoomLevel}'));
      }
      playerZoomRatio = playerCircle.radius / gameState.tZoomFactor;
    }
    if (playerZoomRatio < 10.0 / gameState.threshold) {
      gameState.zoomLevel--;
      if (gameState.zoomLevel.abs() % 10 == 0) {
        eventBus.fire(analyticsTrackEvent, new AnalyticsTrackEvent('Zoom In', '${gameState.zoomLevel}'));
      }
    }
  }
}
