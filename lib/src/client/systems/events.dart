part of client;


class InputHandlingSystem extends GenericInputHandlingSystem {
  ComponentMapper<Acceleration> am;
  InputHandlingSystem() : super(Aspect.getAspectForAllOf([Player, Acceleration]));

  @override
  void processEntity(Entity entity) {
    var a = am.get(entity);
    var max = a.max * gameState.zoomFactor;
    if ((up || down) && (left || right)) {
      max *= sin(PI/4);
    }
    if (up) {
      a.value.y = -max;
    } else if (down) {
      a.value.y = max;
    }
    if (left) {
      a.value.x = -max;
    } else if (right) {
      a.value.x = max;
    }
  }

  bool get up => keyState[KeyCode.W] == true || keyState[KeyCode.UP] == true;
  bool get down => keyState[KeyCode.S] == true || keyState[KeyCode.DOWN] == true;
  bool get left => keyState[KeyCode.A] == true || keyState[KeyCode.LEFT] == true;
  bool get right => keyState[KeyCode.D] == true || keyState[KeyCode.RIGHT] == true;
}


class HighScoreSavingSystem extends IntervalEntitySystem {
  static const ABSORBED = 'absorbed';
  static const RADIUS = 'radius';
  Store store;
  double bestRadius = 10.0;
  int bestAbsorbed = 0;
  HighScoreSavingSystem() : super(1000, Aspect.getEmpty());

  initialize() {
    store = new Store('3hgj_merge', 'stats');
    store.open().then((_) {
      store.getByKey(ABSORBED).then((value) {
        if (null != value) {
          gameState.bestAbsorbed = value;
          bestAbsorbed = value;
        }
      });
      store.getByKey(RADIUS).then((value) {
        if (null != value) {
          gameState.bestRadius = value;
          bestRadius = value;
        }
      });
    });
  }

  @override
  processEntities(_) {
    if (gameState.bestAbsorbed > bestAbsorbed) {
      bestAbsorbed = gameState.bestAbsorbed;
      save(ABSORBED, bestAbsorbed);
    }
    if (gameState.bestRadius > bestRadius) {
      bestRadius = gameState.bestRadius;
      save(RADIUS, bestRadius);
    }
  }

  void save(String key, Object newValue) {
    store.getByKey(key).then((value) {
      store.save(newValue, key);
    });
  }
}