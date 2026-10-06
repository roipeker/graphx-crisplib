import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:graphx/graphx.dart';

import 'atlas.dart';
import 'sprite.dart';

part 'runtime_geometry.dart';
part 'runtime_host.dart';

enum CrispScaleMode { auto, integer, fit }

final class CrispGameConfig {
  const CrispGameConfig({
    required this.id,
    required this.title,
    this.description,
    this.seed = 1,
    this.width = 320,
    this.height = 180,
    this.scaleMode = CrispScaleMode.auto,
  });

  final String id;
  final String title;
  final String? description;
  final int seed;
  final double width;
  final double height;
  final CrispScaleMode scaleMode;

  double get aspectRatio => width / height;
}

abstract class CrispGame {
  CrispGameConfig get config;
  List<String> get characters => const <String>[];
  List<CrispSpriteClip> get sprites => const <CrispSpriteClip>[];

  void frame(CrispContext g);
}

final class CrispInput {
  const CrispInput({
    required this.pressed,
    required this.justPressed,
    required this.justReleased,
    required this.x,
    required this.y,
  });

  final bool pressed;
  final bool justPressed;
  final bool justReleased;
  final double x;
  final double y;

  CrispInput withoutEdges() => CrispInput(
    pressed: pressed,
    justPressed: false,
    justReleased: false,
    x: x,
    y: y,
  );
}

final class CrispContext {
  CrispContext._(this._runtime);

  final CrispRuntime _runtime;
  CrispInput _input = const CrispInput(
    pressed: false,
    justPressed: false,
    justReleased: false,
    x: 0,
    y: 0,
  );

  int get tick => _runtime.tick;
  int get ticks => tick;
  double get time => tick / 60.0;
  double get difficulty => 1 + tick / 3600.0;
  double get width => _runtime.width;
  double get height => _runtime.height;
  int get scoreValue => _runtime.scoreValue;
  CrispInput get input => _input;

  void color(CrispColor value) => _runtime.currentColor = value;

  CrispHit rect(
    double x,
    double y,
    double w,
    double h, {
    bool collision = true,
  }) => _runtime.rect(x, y, w, h, collision: collision);

  CrispHit box(double x, double y, double w, [double? h]) =>
      _runtime.box(x, y, w, h ?? w);

  CrispHit line(
    double x1,
    double y1,
    double x2,
    double y2, [
    double thickness = 1,
  ]) => _runtime.line(x1, y1, x2, y2, thickness);

  CrispHit bar(
    double x,
    double y,
    double length,
    double thickness,
    double angle,
  ) {
    final hx = math.cos(angle) * length * .5;
    final hy = math.sin(angle) * length * .5;
    return line(x - hx, y - hy, x + hx, y + hy, thickness);
  }

  CrispHit arc(
    double x,
    double y,
    double radius, [
    double thickness = 3,
    double from = 0,
    double to = math.pi * 2,
  ]) => _runtime.arc(x, y, radius, thickness, from, to);

  CrispHit circle(double x, double y, double radius, [double thickness = 3]) =>
      arc(x, y, radius, thickness);

  CrispHit char(String char, double x, double y, {double scale = 1}) =>
      _runtime.character(char, x, y, scale: scale);

  CrispHit sprite(
    CrispSpriteFrame frame,
    double x,
    double y, {
    double scale = 1,
    bool flipX = false,
    bool flipY = false,
    CrispColor? tint,
    CrispHitbox? hitbox,
  }) => _runtime.sprite(
    frame,
    x,
    y,
    scale: scale,
    flipX: flipX,
    flipY: flipY,
    tint: tint,
    hitbox: hitbox,
  );

  void text(String value, double x, double y, {double scale = 1}) =>
      _runtime.text(value, x, y, scale: scale);

  void particles(
    double x,
    double y, {
    int count = 8,
    double speed = 1.5,
    double angle = 0,
    double spread = math.pi * 2,
  }) => _runtime.spawnParticles(
    x,
    y,
    count: count,
    speed: speed,
    angle: angle,
    spread: spread,
  );

  void addScore(int amount) => _runtime.scoreValue += amount;
  void score(int amount) => addScore(amount);
  void end() => _runtime.ended = true;

  double rnd([double min = 0, double max = 1]) => _runtime.rng.next(min, max);
  int rndi([int min = 0, int? max]) {
    if (max == null) {
      max = min;
      min = 0;
    }
    return _runtime.rng.nextInt(min, max);
  }
}

final class CrispHit {
  const CrispHit._(this.isColliding);
  static const none = CrispHit._(CrispCollisions._());

  final CrispCollisions isColliding;
}

final class CrispCollisions {
  const CrispCollisions._({
    this.rectMask = 0,
    this.textMask = 0,
    this.charMask = 0,
    this.spriteMask = 0,
  });

  final int rectMask;
  final int textMask;
  final int charMask;
  final int spriteMask;

  CrispCollisions merge(CrispCollisions other) => CrispCollisions._(
    rectMask: rectMask | other.rectMask,
    textMask: textMask | other.textMask,
    charMask: charMask | other.charMask,
    spriteMask: spriteMask | other.spriteMask,
  );

  CrispCollisionColors get rect => CrispCollisionColors(rectMask);
  CrispCollisionColors get text => CrispCollisionColors(textMask);
  CrispCollisionColors get char => CrispCollisionColors(charMask);
  CrispCollisionColors get sprite => CrispCollisionColors(spriteMask);
}

final class CrispCollisionColors {
  const CrispCollisionColors(this.mask);

  final int mask;

  bool has(CrispColor color) => (mask & color.bit) != 0;
  bool get white => has(CrispColor.white);
  bool get red => has(CrispColor.red);
  bool get green => has(CrispColor.green);
  bool get yellow => has(CrispColor.yellow);
  bool get blue => has(CrispColor.blue);
  bool get purple => has(CrispColor.purple);
  bool get cyan => has(CrispColor.cyan);
  bool get black => has(CrispColor.black);
  bool get lightRed => has(CrispColor.lightRed);
  bool get lightGreen => has(CrispColor.lightGreen);
  bool get lightYellow => has(CrispColor.lightYellow);
  bool get lightBlue => has(CrispColor.lightBlue);
  bool get lightPurple => has(CrispColor.lightPurple);
  bool get lightCyan => has(CrispColor.lightCyan);
  bool get lightBlack => has(CrispColor.lightBlack);
}

final class CrispRuntime {
  CrispRuntime(this.game, this.atlas) {
    config = game.config;
    rng = CrispRandom(config.seed);
    context = CrispContext._(this);
  }

  double get width => config.width;
  double get height => config.height;

  final CrispGame game;
  final CrispAtlas atlas;
  late final CrispGameConfig config;
  late final CrispRandom rng;
  late final CrispContext context;

  final List<_DrawCommand> _commands = <_DrawCommand>[];
  final List<_Collider> _colliders = <_Collider>[];
  final List<_Particle> _particles = <_Particle>[];
  int _commandCount = 0;
  int _colliderCount = 0;

  int tick = 0;
  int scoreValue = 0;
  bool ended = false;
  CrispColor currentColor = CrispColor.black;

  void step(CrispInput input) {
    _commandCount = 0;
    _colliderCount = 0;
    currentColor = CrispColor.black;
    context._input = input;

    _updateParticles();

    if (ended) {
      _centerOverlayText('GAME OVER', height * .38, CrispColor.black);
      _centerOverlayText('SCORE $scoreValue', height * .48, CrispColor.black);
      _centerOverlayText('TAP TO RETRY', height * .60, CrispColor.black);
      if (input.justPressed) {
        tick = 0;
        scoreValue = 0;
        ended = false;
        rng.reset(config.seed);
        _particles.clear();
      }
      return;
    }

    game.frame(context);
    _drawOverlayText(config.title, 4, 4, CrispColor.black, 1);
    final scoreText = scoreValue.toString();
    _drawOverlayText(
      scoreText,
      width - 4 - scoreText.length * CrispAtlas.advance,
      4,
      CrispColor.black,
      1,
    );
    final description = config.description;
    if (tick < 120 && description != null && description.isNotEmpty) {
      _drawOverlayText(
        description.toUpperCase(),
        4,
        height - 16,
        CrispColor.lightBlack,
        1,
      );
    }
    tick++;
  }

  CrispHit rect(
    double x,
    double y,
    double w,
    double h, {
    bool collision = true,
  }) {
    final x0 = math.min(x, x + w);
    final y0 = math.min(y, y + h);
    final rw = w.abs();
    final rh = h.abs();
    final shape = _Collider.rect(
      x0,
      y0,
      rw,
      rh,
      currentColor,
      _CollisionKind.rect,
    );
    final hit = _test(shape);
    if (currentColor != CrispColor.transparent) {
      _rectCommand(x0, y0, rw, rh, currentColor);
      if (collision) _register(shape);
    }
    return hit;
  }

  CrispHit box(double x, double y, double w, double h) =>
      rect(x - w * .5, y - h * .5, w, h);

  CrispHit line(double x1, double y1, double x2, double y2, double thickness) =>
      _line(x1, y1, x2, y2, thickness, testLimit: _colliderCount);

  CrispHit arc(
    double x,
    double y,
    double radius,
    double thickness,
    double angleFrom,
    double angleTo,
  ) {
    var from = angleFrom;
    var sweep = angleTo - angleFrom;
    if (sweep < 0) {
      from = angleTo;
      sweep = angleFrom - angleTo;
    }
    sweep = sweep.clamp(0.0, math.pi * 2);
    if (sweep < .01 || radius <= 0) return CrispHit.none;

    final segmentCount = (sweep * math.sqrt(radius * .25)).ceil().clamp(1, 36);
    final step = sweep / segmentCount;
    final testLimit = _colliderCount;
    var masks = const CrispCollisions._();

    var angle = from;
    var x1 = x + math.cos(angle) * radius;
    var y1 = y + math.sin(angle) * radius;
    for (var i = 0; i < segmentCount; i++) {
      angle += step;
      final x2 = x + math.cos(angle) * radius;
      final y2 = y + math.sin(angle) * radius;
      masks = masks.merge(
        _line(x1, y1, x2, y2, thickness, testLimit: testLimit).isColliding,
      );
      x1 = x2;
      y1 = y2;
    }
    return CrispHit._(masks);
  }

  CrispHit _line(
    double x1,
    double y1,
    double x2,
    double y2,
    double thickness, {
    required int testLimit,
  }) {
    final shape = _Collider.line(
      x1,
      y1,
      x2,
      y2,
      math.max(1, thickness),
      currentColor,
    );
    final hit = _test(shape, limit: testLimit);
    if (currentColor != CrispColor.transparent) {
      _nextCommand(_DrawKind.line)
        ..x = x1
        ..y = y1
        ..x2 = x2
        ..y2 = y2
        ..w = math.max(1, thickness)
        ..color = currentColor;
      _register(shape);
    }
    return hit;
  }

  CrispHit character(String char, double x, double y, {double scale = 1}) {
    final customRegion = atlas.character(config.id, char);
    final region = customRegion ?? atlas.textGlyph(char);
    if (region == null) return CrispHit.none;
    final w = region.width * scale;
    final h = region.height * scale;
    final shape = _Collider.rect(
      x - w * .5,
      y - h * .5,
      w,
      h,
      currentColor,
      _CollisionKind.char,
    );
    final hit = _test(shape);
    if (currentColor != CrispColor.transparent) {
      _nextCommand(_DrawKind.glyph)
        ..x = x - w * .5
        ..y = y - h * .5
        ..w = w
        ..h = h
        ..color = currentColor
        ..region = region
        ..tint = customRegion == null || currentColor != CrispColor.black;
      _register(shape);
    }
    return hit;
  }

  CrispHit sprite(
    CrispSpriteFrame frame,
    double x,
    double y, {
    double scale = 1,
    bool flipX = false,
    bool flipY = false,
    CrispColor? tint,
    CrispHitbox? hitbox,
  }) {
    final region = atlas.sprite(config.id, frame);
    if (region == null) return CrispHit.none;

    final w = region.width * scale;
    final h = region.height * scale;
    final resolvedHitbox = hitbox ?? frame.clip.hitbox;
    final hitW = (resolvedHitbox?.width ?? region.width) * scale;
    final hitH = (resolvedHitbox?.height ?? region.height) * scale;
    final hitX = x + (resolvedHitbox?.offsetX ?? 0) * scale;
    final hitY = y + (resolvedHitbox?.offsetY ?? 0) * scale;
    final shape = _Collider.rect(
      hitX - hitW * .5,
      hitY - hitH * .5,
      hitW,
      hitH,
      currentColor,
      _CollisionKind.sprite,
    );
    final hit = _test(shape);
    if (currentColor != CrispColor.transparent) {
      _nextCommand(_DrawKind.glyph)
        ..x = x - w * .5
        ..y = y - h * .5
        ..w = w
        ..h = h
        ..color = tint ?? CrispColor.white
        ..region = region
        ..tint = tint != null
        ..flipX = flipX
        ..flipY = flipY;
      _register(shape);
    }
    return hit;
  }

  void text(String value, double x, double y, {double scale = 1}) =>
      _text(value, x, y, scale, collision: true);

  void _text(
    String value,
    double x,
    double y,
    double scale, {
    required bool collision,
  }) {
    var px = x;
    for (final rune in value.runes) {
      final ch = String.fromCharCode(rune);
      if (ch == '\n') {
        px = x;
        y += CrispAtlas.glyphHeight * scale;
        continue;
      }
      final region = atlas.textGlyph(ch);
      if (region != null && currentColor != CrispColor.transparent) {
        final w = region.width * scale;
        final h = region.height * scale;
        _nextCommand(_DrawKind.glyph)
          ..x = px
          ..y = y
          ..w = w
          ..h = h
          ..color = currentColor
          ..region = region
          ..tint = true;
        if (collision) {
          final shape = _Collider.rect(
            px,
            y,
            w,
            h,
            currentColor,
            _CollisionKind.text,
          );
          _test(shape);
          _register(shape);
        }
      }
      px += CrispAtlas.advance * scale;
    }
  }

  void spawnParticles(
    double x,
    double y, {
    required int count,
    required double speed,
    required double angle,
    required double spread,
  }) {
    for (var i = 0; i < count; i++) {
      final a = angle + rng.next(-spread * .5, spread * .5);
      final s = speed * rng.next(.45, 1.05);
      _particles.add(
        _Particle(
          x,
          y,
          math.cos(a) * s,
          math.sin(a) * s,
          currentColor,
          24 + rng.nextInt(0, 18),
        ),
      );
    }
  }

  void _updateParticles() {
    for (var i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.vy += .025;
      p.life--;
      if (p.life <= 0) {
        _particles.removeAt(i);
        continue;
      }
      _rectCommand(p.x, p.y, 1, 1, p.color);
    }
  }

  void _centerOverlayText(String value, double y, CrispColor color) {
    final x = (width - value.length * CrispAtlas.advance) * .5;
    _drawOverlayText(value, x, y, color, 1);
  }

  void _drawOverlayText(
    String value,
    double x,
    double y,
    CrispColor color,
    double scale,
  ) {
    final previous = currentColor;
    currentColor = color;
    _text(value, x, y, scale, collision: false);
    currentColor = previous;
  }

  void _rectCommand(double x, double y, double w, double h, CrispColor color) {
    _nextCommand(_DrawKind.rect)
      ..x = x
      ..y = y
      ..w = w
      ..h = h
      ..color = color;
  }

  _DrawCommand _nextCommand(_DrawKind kind) {
    final _DrawCommand cmd;
    if (_commandCount < _commands.length) {
      cmd = _commands[_commandCount];
    } else {
      cmd = _DrawCommand();
      _commands.add(cmd);
    }
    _commandCount++;
    return cmd
      ..kind = kind
      ..region = null
      ..tint = false
      ..flipX = false
      ..flipY = false;
  }

  CrispHit _test(_Collider current, {int? limit}) {
    var rectMask = 0;
    var textMask = 0;
    var charMask = 0;
    var spriteMask = 0;
    final end = limit ?? _colliderCount;
    for (var i = 0; i < end; i++) {
      final other = _colliders[i];
      if (!_intersects(current, other)) continue;
      switch (other.kind) {
        case _CollisionKind.rect:
          rectMask |= other.color.bit;
        case _CollisionKind.text:
          textMask |= other.color.bit;
        case _CollisionKind.char:
          charMask |= other.color.bit;
        case _CollisionKind.sprite:
          spriteMask |= other.color.bit;
      }
    }
    if ((rectMask | textMask | charMask | spriteMask) == 0) {
      return CrispHit.none;
    }
    return CrispHit._(
      CrispCollisions._(
        rectMask: rectMask,
        textMask: textMask,
        charMask: charMask,
        spriteMask: spriteMask,
      ),
    );
  }

  void _register(_Collider source) {
    final _Collider target;
    if (_colliderCount < _colliders.length) {
      target = _colliders[_colliderCount];
      target.copyFrom(source);
    } else {
      target = source.clone();
      _colliders.add(target);
    }
    _colliderCount++;
  }

  void paint(ui.Canvas canvas) {
    canvas.save();
    canvas.clipRect(ui.Rect.fromLTWH(0, 0, width, height));

    final background = ui.Paint()
      ..isAntiAlias = false
      ..color = const ui.Color(0xfff4f4f2);
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, width, height), background);

    final paint = ui.Paint()
      ..isAntiAlias = false
      ..filterQuality = ui.FilterQuality.none;

    for (var i = 0; i < _commandCount; i++) {
      final cmd = _commands[i];
      switch (cmd.kind) {
        case _DrawKind.rect:
          paint
            ..color = cmd.color.value
            ..colorFilter = null;
          final l = cmd.x.roundToDouble();
          final t = cmd.y.roundToDouble();
          final r = (cmd.x + cmd.w).roundToDouble();
          final b = (cmd.y + cmd.h).roundToDouble();
          if (r > l && b > t) {
            canvas.drawRect(ui.Rect.fromLTRB(l, t, r, b), paint);
          }
        case _DrawKind.line:
          paint
            ..color = cmd.color.value
            ..colorFilter = null;
          _paintPixelLine(canvas, paint, cmd.x, cmd.y, cmd.x2, cmd.y2, cmd.w);
        case _DrawKind.glyph:
          final region = cmd.region;
          if (region == null) continue;
          paint
            ..color = const ui.Color(0xffffffff)
            ..colorFilter = cmd.tint
                ? ui.ColorFilter.mode(cmd.color.value, ui.BlendMode.srcIn)
                : null;
          final dx = cmd.x.roundToDouble();
          final dy = cmd.y.roundToDouble();
          final dw = math.max(1.0, cmd.w.roundToDouble());
          final dh = math.max(1.0, cmd.h.roundToDouble());
          if (cmd.flipX || cmd.flipY) {
            canvas.save();
            canvas.translate(dx + dw * .5, dy + dh * .5);
            canvas.scale(cmd.flipX ? -1 : 1, cmd.flipY ? -1 : 1);
            canvas.drawImageRect(
              atlas.image,
              region.source,
              ui.Rect.fromLTWH(-dw * .5, -dh * .5, dw, dh),
              paint,
            );
            canvas.restore();
          } else {
            canvas.drawImageRect(
              atlas.image,
              region.source,
              ui.Rect.fromLTWH(dx, dy, dw, dh),
              paint,
            );
          }
      }
    }

    canvas.restore();
  }
}

final class _Particle {
  _Particle(this.x, this.y, this.vx, this.vy, this.color, this.life);

  double x;
  double y;
  double vx;
  double vy;
  CrispColor color;
  int life;
}

final class CrispRandom {
  CrispRandom(int seed) {
    reset(seed);
  }

  int _state = 1;

  void reset(int seed) {
    _state = seed == 0 ? 1 : seed & 0x7fffffff;
  }

  double unit() {
    _state = (1103515245 * _state + 12345) & 0x7fffffff;
    return _state / 0x80000000;
  }

  double next([double min = 0, double max = 1]) => min + (max - min) * unit();

  int nextInt(int min, int max) {
    if (max <= min) return min;
    return min + (unit() * (max - min)).floor();
  }
}
