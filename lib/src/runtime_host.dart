part of 'runtime.dart';

final class CrispRoot extends GRoot {
  CrispRoot({required CrispGame game, required CrispAtlas atlas})
    : runtime = CrispRuntime(game, atlas);

  final CrispRuntime runtime;
  late final _CrispSurface _surface;
  double _accumulator = 0;
  double _scale = 1;
  double _offsetX = 0;
  double _offsetY = 0;

  @override
  void attached() {
    _surface = addChild(_CrispSurface(runtime));
    runtime.step(
      const CrispInput(
        pressed: false,
        justPressed: false,
        justReleased: false,
        x: 0,
        y: 0,
      ),
    );
    updatesEnabled = true;
  }

  @override
  void resize(double w, double h) {
    final dpr = stage.devicePixelRatio;
    final fit = math.min(w / runtime.width, h / runtime.height);
    final physical = math.min(
      (w * dpr / runtime.width).floor(),
      (h * dpr / runtime.height).floor(),
    );
    final integer = physical >= 1 ? physical / dpr : fit;
    _scale = switch (runtime.game.config.scaleMode) {
      CrispScaleMode.integer => integer,
      CrispScaleMode.fit => fit,
      CrispScaleMode.auto => integer > 0 && integer / fit >= .9 ? integer : fit,
    };
    _offsetX = ((w - runtime.width * _scale) * .5 * dpr).round() / dpr;
    _offsetY = ((h - runtime.height * _scale) * .5 * dpr).round() / dpr;
    _surface
      ..setPosition(_offsetX, _offsetY)
      ..setScale(_scale);
  }

  @override
  void update(double delta) {
    _accumulator = math.min(_accumulator + delta, .1);
    const fixed = 1 / 60.0;
    var first = true;

    final pointer = stage.input.pointer;
    final input = CrispInput(
      pressed: pointer.isDown,
      justPressed: pointer.wasPressed,
      justReleased: pointer.wasReleased,
      x: (pointer.x - _offsetX) / _scale,
      y: (pointer.y - _offsetY) / _scale,
    );

    while (_accumulator >= fixed) {
      runtime.step(first ? input : input.withoutEdges());
      _accumulator -= fixed;
      first = false;
    }
    _surface.frameChanged();
  }
}

final class _CrispSurface extends GCanvasNode {
  _CrispSurface(this.runtime) {
    painter = (context) => runtime.paint(context.canvas);
  }

  final CrispRuntime runtime;

  @override
  void computeSelfBounds(GBounds out) {
    out.setXYWH(0, 0, runtime.width, runtime.height);
  }

  void frameChanged() => invalidatePaint();
}
