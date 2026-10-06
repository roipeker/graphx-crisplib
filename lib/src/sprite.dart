final class CrispHitbox {
  const CrispHitbox(
    this.width,
    this.height, {
    this.offsetX = 0,
    this.offsetY = 0,
  });

  final double width;
  final double height;
  final double offsetX;
  final double offsetY;
}

final class CrispSpriteClip {
  CrispSpriteClip(
    this.id, {
    required List<String> frames,
    this.frameTicks = 6,
    this.loop = true,
    this.hitbox,
  }) : assert(frames.isNotEmpty),
       assert(frameTicks > 0),
       frames = List<String>.unmodifiable(frames) {
    _frameRefs = List<CrispSpriteFrame>.generate(
      frames.length,
      (index) => CrispSpriteFrame._(this, index),
      growable: false,
    );
  }

  final String id;
  final List<String> frames;
  final int frameTicks;
  final bool loop;
  final CrispHitbox? hitbox;

  late final List<CrispSpriteFrame> _frameRefs;

  int get frameCount => _frameRefs.length;

  CrispSpriteFrame frame(int tick) {
    var index = tick ~/ frameTicks;
    if (loop) {
      index %= frameCount;
    } else {
      index = index.clamp(0, frameCount - 1);
    }
    return _frameRefs[index];
  }

  CrispSpriteFrame at(int index) => _frameRefs[index.clamp(0, frameCount - 1)];
}

final class CrispSpriteFrame {
  const CrispSpriteFrame._(this.clip, this.index);

  final CrispSpriteClip clip;
  final int index;
}

final class CrispSpriteSet {
  const CrispSpriteSet(this.gameId, this.clips);

  final String gameId;
  final List<CrispSpriteClip> clips;
}
