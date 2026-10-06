import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'font_data.dart';
import 'sprite.dart';

enum CrispColor {
  transparent,
  white,
  red,
  green,
  yellow,
  blue,
  purple,
  cyan,
  black,
  lightRed,
  lightGreen,
  lightYellow,
  lightBlue,
  lightPurple,
  lightCyan,
  lightBlack,
}

extension CrispColorValue on CrispColor {
  ui.Color get value => switch (this) {
    CrispColor.transparent => const ui.Color(0x00000000),
    CrispColor.white => const ui.Color(0xffeeeeee),
    CrispColor.red => const ui.Color(0xffe91e63),
    CrispColor.green => const ui.Color(0xff4caf50),
    CrispColor.yellow => const ui.Color(0xffffc107),
    CrispColor.blue => const ui.Color(0xff3f51b5),
    CrispColor.purple => const ui.Color(0xff9c27b0),
    CrispColor.cyan => const ui.Color(0xff03a9f4),
    CrispColor.black => const ui.Color(0xff616161),
    CrispColor.lightRed => const ui.Color(0xffeb869f),
    CrispColor.lightGreen => const ui.Color(0xff9dcf9e),
    CrispColor.lightYellow => const ui.Color(0xffffd97a),
    CrispColor.lightBlue => const ui.Color(0xff969fcf),
    CrispColor.lightPurple => const ui.Color(0xffc596cf),
    CrispColor.lightCyan => const ui.Color(0xff79cdf1),
    CrispColor.lightBlack => const ui.Color(0xffa7a7a7),
  };

  int get bit => 1 << index;
}

final class CrispCharacterSet {
  const CrispCharacterSet(this.gameId, this.patterns);

  final String gameId;
  final List<String> patterns;
}

final class CrispAtlasRegion {
  const CrispAtlasRegion(
    this.source, {
    required this.width,
    required this.height,
  });

  final ui.Rect source;
  final int width;
  final int height;
}

final class CrispAtlas {
  CrispAtlas._(this.image, this._regions);

  final ui.Image image;
  final Map<String, CrispAtlasRegion> _regions;

  static const int glyphWidth = 6;
  static const int glyphHeight = 6;
  static const int advance = 6;

  CrispAtlasRegion? textGlyph(String char) {
    if (char.length != 1 || char == ' ') return null;
    final code = char.codeUnitAt(0);
    if (code < 0x21 || code > 0x7e) return null;
    return _regions['text:$code'];
  }

  CrispAtlasRegion? character(String gameId, String char) =>
      _regions['char:$gameId:$char'];

  CrispAtlasRegion? sprite(String gameId, CrispSpriteFrame frame) =>
      _regions['sprite:$gameId:${frame.clip.id}:${frame.index}'];

  static Future<CrispAtlas> build(
    List<CrispCharacterSet> characterSets, {
    List<CrispSpriteSet> spriteSets = const <CrispSpriteSet>[],
  }) async {
    final entries = <_AtlasEntry>[
      for (var i = 0; i < crispTextPatterns.length; i++)
        _AtlasEntry(
          'text:${0x21 + i}',
          crispTextPatterns[i],
          textOnly: true,
          fixedWidth: glyphWidth,
          fixedHeight: glyphHeight,
        ),
      for (final set in characterSets)
        for (var i = 0; i < set.patterns.length; i++)
          _AtlasEntry(
            'char:${set.gameId}:${String.fromCharCode(0x61 + i)}',
            set.patterns[i],
            fixedWidth: glyphWidth,
            fixedHeight: glyphHeight,
          ),
      for (final set in spriteSets)
        for (final clip in set.clips)
          for (var i = 0; i < clip.frames.length; i++)
            _AtlasEntry('sprite:${set.gameId}:${clip.id}:$i', clip.frames[i]),
    ];

    final prepared = <_PreparedEntry>[
      for (final entry in entries) _PreparedEntry.from(entry),
    ];

    const preferredWidth = 256;
    const gutter = 1;
    final widest = prepared.fold<int>(
      1,
      (value, entry) => math.max(value, entry.width + gutter * 2),
    );
    final atlasWidth = math.max(preferredWidth, widest);

    var x = gutter;
    var y = gutter;
    var rowHeight = 0;
    for (final entry in prepared) {
      if (x + entry.width + gutter > atlasWidth) {
        x = gutter;
        y += rowHeight + gutter;
        rowHeight = 0;
      }
      entry
        ..x = x
        ..y = y;
      x += entry.width + gutter;
      rowHeight = math.max(rowHeight, entry.height);
    }
    final atlasHeight = math.max(1, y + rowHeight + gutter);

    final pixels = Uint8List(atlasWidth * atlasHeight * 4);
    final regions = <String, CrispAtlasRegion>{};

    for (final preparedEntry in prepared) {
      final entry = preparedEntry.entry;
      final lines = preparedEntry.lines;

      for (var py = 0; py < preparedEntry.height; py++) {
        final line = py < lines.length ? lines[py] : '';
        for (var px = 0; px < preparedEntry.width; px++) {
          final c = px < line.length ? line[px] : ' ';
          if (c == ' ') continue;
          final color = entry.textOnly ? CrispColor.white : _patternColor(c);
          if (color == CrispColor.transparent) continue;
          _writePixel(
            pixels,
            atlasWidth,
            preparedEntry.x + px,
            preparedEntry.y + py,
            color.value,
          );
        }
      }

      regions[entry.key] = CrispAtlasRegion(
        ui.Rect.fromLTWH(
          preparedEntry.x.toDouble(),
          preparedEntry.y.toDouble(),
          preparedEntry.width.toDouble(),
          preparedEntry.height.toDouble(),
        ),
        width: preparedEntry.width,
        height: preparedEntry.height,
      );
    }

    final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: atlasWidth,
      height: atlasHeight,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    final frameInfo = await codec.getNextFrame();
    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
    return CrispAtlas._(frameInfo.image, regions);
  }

  void dispose() => image.dispose();
}

final class _AtlasEntry {
  const _AtlasEntry(
    this.key,
    this.pattern, {
    this.textOnly = false,
    this.fixedWidth,
    this.fixedHeight,
  });

  final String key;
  final String pattern;
  final bool textOnly;
  final int? fixedWidth;
  final int? fixedHeight;
}

final class _PreparedEntry {
  _PreparedEntry._(this.entry, this.lines, this.width, this.height);

  factory _PreparedEntry.from(_AtlasEntry entry) {
    final lines = _patternLines(entry.pattern);
    var contentWidth = 0;
    for (final line in lines) {
      contentWidth = math.max(contentWidth, line.length);
    }
    final width = entry.fixedWidth ?? math.max(1, contentWidth);
    final height = entry.fixedHeight ?? math.max(1, lines.length);
    return _PreparedEntry._(entry, lines, width, height);
  }

  final _AtlasEntry entry;
  final List<String> lines;
  final int width;
  final int height;

  int x = 0;
  int y = 0;
}

List<String> _patternLines(String pattern) {
  final lines = pattern.replaceAll('\r', '').split('\n');
  while (lines.isNotEmpty && lines.first.isEmpty) {
    lines.removeAt(0);
  }
  while (lines.isNotEmpty && lines.last.isEmpty) {
    lines.removeLast();
  }
  return lines;
}

CrispColor _patternColor(String c) => switch (c) {
  't' => CrispColor.transparent,
  'w' => CrispColor.white,
  'r' => CrispColor.red,
  'g' => CrispColor.green,
  'y' => CrispColor.yellow,
  'b' => CrispColor.blue,
  'p' => CrispColor.purple,
  'c' => CrispColor.cyan,
  'l' => CrispColor.black,
  'R' => CrispColor.lightRed,
  'G' => CrispColor.lightGreen,
  'Y' => CrispColor.lightYellow,
  'B' => CrispColor.lightBlue,
  'P' => CrispColor.lightPurple,
  'C' => CrispColor.lightCyan,
  'L' => CrispColor.lightBlack,
  _ => CrispColor.black,
};

void _writePixel(Uint8List bytes, int width, int x, int y, ui.Color color) {
  final i = (y * width + x) * 4;
  bytes[i] = (color.r * 255).round();
  bytes[i + 1] = (color.g * 255).round();
  bytes[i + 2] = (color.b * 255).round();
  bytes[i + 3] = (color.a * 255).round();
}
