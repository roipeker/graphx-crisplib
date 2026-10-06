import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:graphx_crisplib/graphx_crisplib.dart';

void main() {
  test('Crisp char cells stay 6x6 and sprite frames keep their size', () async {
    final clip = CrispSpriteClip(
      'sizes',
      frameTicks: 2,
      frames: const <String>[
        '''
llll
llll
''',
        '''
llllll
llllll
llllll
''',
      ],
    );

    final atlas = await CrispAtlas.build(
      const <CrispCharacterSet>[
        CrispCharacterSet('compat', <String>['l']),
      ],
      spriteSets: <CrispSpriteSet>[
        CrispSpriteSet('sizes', <CrispSpriteClip>[clip]),
      ],
    );

    final charRegion = atlas.character('compat', 'a')!;
    expect(charRegion.width, CrispAtlas.glyphWidth);
    expect(charRegion.height, CrispAtlas.glyphHeight);

    final frame0 = atlas.sprite('sizes', clip.frame(0))!;
    final frame1 = atlas.sprite('sizes', clip.frame(2))!;
    expect((frame0.width, frame0.height), (4, 2));
    expect((frame1.width, frame1.height), (6, 3));

    atlas.dispose();
  });

  test('runtime clips all drawing to the logical stage', () async {
    final game = _ClipGame();
    final atlas = await CrispAtlas.build(const <CrispCharacterSet>[]);
    final runtime = CrispRuntime(game, atlas);

    runtime.step(
      const CrispInput(
        pressed: false,
        justPressed: false,
        justReleased: false,
        x: 0,
        y: 0,
      ),
    );

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    runtime.paint(canvas);
    final picture = recorder.endRecording();
    final image = await picture.toImage(80, 80);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final data = bytes!.buffer.asUint8List();

    int alphaAt(int x, int y) => data[(y * 80 + x) * 4 + 3];

    expect(alphaAt(25, 25), greaterThan(0));
    expect(alphaAt(60, 25), 0);

    image.dispose();
    picture.dispose();
    atlas.dispose();
  });
}

final class _ClipGame extends CrispGame {
  @override
  final config = const CrispGameConfig(
    id: 'clip',
    title: 'T',
    width: 50,
    height: 50,
  );

  @override
  void frame(CrispContext g) {
    g.color(CrispColor.red);
    g.rect(-20, -20, 100, 100);
  }
}
