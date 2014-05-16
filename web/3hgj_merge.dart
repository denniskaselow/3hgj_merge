import 'package:3hgj_merge/client.dart';

@MirrorsUsed(targets: const [CircleRenderingSystem, InputHandlingSystem,
                             AcccelerationSystem, MovementSystem,
                             CanvasCleaningSystem, CircleSpawner,
                             CircleRemover, CircleCollisionDetectionSystem,
                             WallBouncingSystem
                            ])
import 'dart:mirrors';

void main() {
  new Game().start();
}

class Game extends GameBase {

  Game() : super.noAssets('3hgj_merge', 'canvas', 500, 500);

  void createEntities() {
    TagManager tm = world.getManager(TagManager);
    var e= addEntity([new Transform(0, 0), new Circle(10), new Color(opacity: 0.6), new Player(), new Acceleration(), new Velocity()]);
    tm.register(e, TAG_PLAYER);
  }

  List<EntitySystem> getSystems() {
    return [
            new TweeningSystem(),
            new CircleSpawner(),
            new InputHandlingSystem(),
            new AcccelerationSystem(),
            new MovementSystem(),
            new WallBouncingSystem(),
            new CircleCollisionDetectionSystem(),
            new CanvasCleaningSystem(canvas),
            new CircleRenderingSystem(ctx),
//            new FpsRenderingSystem(ctx),
            new CircleRemover(),
            new AnalyticsSystem(AnalyticsSystem.ITCHIO, '3hgj_merge')
    ];
  }

  onInit() {
    world.addManager(new TagManager());
  }
}
