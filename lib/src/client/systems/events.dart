part of client;


class InputHandlingSystem extends GenericInputHandlingSystem {
  ComponentMapper<Acceleration> am;
  InputHandlingSystem() : super(Aspect.getAspectForAllOf([Player, Acceleration]));

  @override
  void processEntity(Entity entity) {
    var a = am.get(entity);
    var max = a.max;
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