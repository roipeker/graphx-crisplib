part of 'runtime.dart';

enum _DrawKind { rect, line, glyph }

enum _CollisionKind { rect, text, char, sprite }

enum _ShapeKind { rect, line }

final class _DrawCommand {
  _DrawKind kind = _DrawKind.rect;
  double x = 0;
  double y = 0;
  double x2 = 0;
  double y2 = 0;
  double w = 0;
  double h = 0;
  CrispColor color = CrispColor.black;
  CrispAtlasRegion? region;
  bool tint = false;
  bool flipX = false;
  bool flipY = false;
}

final class _Collider {
  _Collider.rect(this.x, this.y, this.w, this.h, this.color, this.kind)
    : shape = _ShapeKind.rect,
      x2 = 0,
      y2 = 0,
      thickness = 0;

  _Collider.line(this.x, this.y, this.x2, this.y2, this.thickness, this.color)
    : shape = _ShapeKind.line,
      kind = _CollisionKind.rect,
      w = 0,
      h = 0;

  _ShapeKind shape;
  _CollisionKind kind;
  CrispColor color;
  double x;
  double y;
  double x2;
  double y2;
  double w;
  double h;
  double thickness;

  _Collider clone() {
    final out = _Collider.rect(x, y, w, h, color, kind);
    out
      ..shape = shape
      ..x2 = x2
      ..y2 = y2
      ..thickness = thickness;
    return out;
  }

  void copyFrom(_Collider other) {
    shape = other.shape;
    kind = other.kind;
    color = other.color;
    x = other.x;
    y = other.y;
    x2 = other.x2;
    y2 = other.y2;
    w = other.w;
    h = other.h;
    thickness = other.thickness;
  }
}

bool _intersects(_Collider a, _Collider b) {
  if (a.shape == _ShapeKind.rect && b.shape == _ShapeKind.rect) {
    return a.x < b.x + b.w &&
        a.x + a.w > b.x &&
        a.y < b.y + b.h &&
        a.y + a.h > b.y;
  }
  if (a.shape == _ShapeKind.line && b.shape == _ShapeKind.rect) {
    return _lineHitsRect(a, b);
  }
  if (a.shape == _ShapeKind.rect && b.shape == _ShapeKind.line) {
    return _lineHitsRect(b, a);
  }
  if (a.shape == _ShapeKind.line && b.shape == _ShapeKind.line) {
    return _lineHitsLine(a, b);
  }
  return false;
}

bool _lineHitsLine(_Collider a, _Collider b) {
  final threshold = (a.thickness + b.thickness) * .5;
  final aMinX = math.min(a.x, a.x2) - threshold;
  final aMaxX = math.max(a.x, a.x2) + threshold;
  final aMinY = math.min(a.y, a.y2) - threshold;
  final aMaxY = math.max(a.y, a.y2) + threshold;
  final bMinX = math.min(b.x, b.x2);
  final bMaxX = math.max(b.x, b.x2);
  final bMinY = math.min(b.y, b.y2);
  final bMaxY = math.max(b.y, b.y2);
  if (aMaxX < bMinX || aMinX > bMaxX || aMaxY < bMinY || aMinY > bMaxY) {
    return false;
  }
  if (_segmentsIntersect(a.x, a.y, a.x2, a.y2, b.x, b.y, b.x2, b.y2)) {
    return true;
  }
  final d2 = math.min(
    math.min(
      _pointSegmentDistanceSquared(a.x, a.y, b.x, b.y, b.x2, b.y2),
      _pointSegmentDistanceSquared(a.x2, a.y2, b.x, b.y, b.x2, b.y2),
    ),
    math.min(
      _pointSegmentDistanceSquared(b.x, b.y, a.x, a.y, a.x2, a.y2),
      _pointSegmentDistanceSquared(b.x2, b.y2, a.x, a.y, a.x2, a.y2),
    ),
  );
  return d2 <= threshold * threshold;
}

bool _segmentsIntersect(
  double ax,
  double ay,
  double bx,
  double by,
  double cx,
  double cy,
  double dx,
  double dy,
) {
  final abx = bx - ax;
  final aby = by - ay;
  final cdx = dx - cx;
  final cdy = dy - cy;
  final denominator = abx * cdy - aby * cdx;
  if (denominator.abs() < 1e-9) return false;
  final acx = cx - ax;
  final acy = cy - ay;
  final t = (acx * cdy - acy * cdx) / denominator;
  final u = (acx * aby - acy * abx) / denominator;
  return t >= 0 && t <= 1 && u >= 0 && u <= 1;
}

double _pointSegmentDistanceSquared(
  double px,
  double py,
  double ax,
  double ay,
  double bx,
  double by,
) {
  final dx = bx - ax;
  final dy = by - ay;
  final lengthSquared = dx * dx + dy * dy;
  if (lengthSquared <= 1e-12) {
    final ox = px - ax;
    final oy = py - ay;
    return ox * ox + oy * oy;
  }
  final t = (((px - ax) * dx + (py - ay) * dy) / lengthSquared).clamp(0.0, 1.0);
  final qx = ax + dx * t;
  final qy = ay + dy * t;
  final ox = px - qx;
  final oy = py - qy;
  return ox * ox + oy * oy;
}

bool _lineHitsRect(_Collider line, _Collider rect) {
  final pad = line.thickness * .5;
  final left = rect.x - pad;
  final top = rect.y - pad;
  final right = rect.x + rect.w + pad;
  final bottom = rect.y + rect.h + pad;

  var t0 = 0.0;
  var t1 = 1.0;
  final dx = line.x2 - line.x;
  final dy = line.y2 - line.y;
  final p = <double>[-dx, dx, -dy, dy];
  final q = <double>[
    line.x - left,
    right - line.x,
    line.y - top,
    bottom - line.y,
  ];

  for (var i = 0; i < 4; i++) {
    if (p[i] == 0) {
      if (q[i] < 0) return false;
      continue;
    }
    final r = q[i] / p[i];
    if (p[i] < 0) {
      if (r > t1) return false;
      if (r > t0) t0 = r;
    } else {
      if (r < t0) return false;
      if (r < t1) t1 = r;
    }
  }
  return true;
}

void _paintPixelLine(
  ui.Canvas canvas,
  ui.Paint paint,
  double ax,
  double ay,
  double bx,
  double by,
  double thickness,
) {
  var x0 = ax.round();
  var y0 = ay.round();
  final x1 = bx.round();
  final y1 = by.round();
  final dx = (x1 - x0).abs();
  final sx = x0 < x1 ? 1 : -1;
  final dy = -(y1 - y0).abs();
  final sy = y0 < y1 ? 1 : -1;
  var err = dx + dy;
  final size = math.max(1, thickness.round());
  final half = size ~/ 2;

  while (true) {
    canvas.drawRect(
      ui.Rect.fromLTWH(
        (x0 - half).toDouble(),
        (y0 - half).toDouble(),
        size.toDouble(),
        size.toDouble(),
      ),
      paint,
    );
    if (x0 == x1 && y0 == y1) break;
    final e2 = 2 * err;
    if (e2 >= dy) {
      err += dy;
      x0 += sx;
    }
    if (e2 <= dx) {
      err += dx;
      y0 += sy;
    }
  }
}
