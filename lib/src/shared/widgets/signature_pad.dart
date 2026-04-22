import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignaturePad extends StatefulWidget {
  final Color strokeColor;
  final double strokeWidth;
  final VoidCallback? onDrawStart;
  final VoidCallback? onDrawEnd;

  const SignaturePad({
    super.key,
    this.strokeColor = const Color(0xFF002B4B),
    this.strokeWidth = 3.0,
    this.onDrawStart,
    this.onDrawEnd,
  });

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final List<Offset?> _points = [];
  final GlobalKey _paintKey = GlobalKey();

  void clear() {
    setState(() {
      _points.clear();
    });
  }

  bool get isEmpty => _points.isEmpty;

  /// Exports the signature as PNG bytes with transparent background.
  Future<Uint8List?> exportPng() async {
    if (_points.isEmpty) return null;

    final boundary = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (boundary == null) return null;

    final size = boundary.size;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Paint the signature
    final paint = Paint()
      ..color = widget.strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = widget.strokeWidth;

    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (_points.isEmpty)
              Center(
                child: Text(
                  'Área de firma',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF99AAB7).withValues(alpha: 0.5),
                  ),
                ),
              ),
            GestureDetector(
              key: _paintKey,
              onPanStart: (details) {
                if (widget.onDrawStart != null) widget.onDrawStart!();
                _addPoint(details.localPosition);
              },
              onPanUpdate: (details) {
                _addPoint(details.localPosition);
              },
              onPanEnd: (details) {
                _addPoint(null);
                if (widget.onDrawEnd != null) widget.onDrawEnd!();
              },
              child: CustomPaint(
                painter: _SignaturePainter(
                  points: _points,
                  color: widget.strokeColor,
                  strokeWidth: widget.strokeWidth,
                ),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPoint(Offset? point) {
    setState(() {
      _points.add(point);
    });
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  _SignaturePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}
