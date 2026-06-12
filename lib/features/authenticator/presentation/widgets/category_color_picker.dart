import 'package:flutter/material.dart';

/// Converts ARGB int to HSV (h 0-360, s 0-1, v 0-1).
void colorIntToHsv(int colorInt, List<double> outHsv) {
  final c = Color(colorInt);
  final hsv = HSVColor.fromColor(c);
  outHsv[0] = hsv.hue;
  outHsv[1] = hsv.saturation;
  outHsv[2] = hsv.value;
}

/// Converts HSV to ARGB int (alpha 1).
int hsvToColorInt(double h, double s, double v) {
  final c = HSVColor.fromAHSV(1.0, h, s, v).toColor();
  return c.toARGB32();
}

/// One hue bar: tap or drag anywhere to pick a color (S=1, V=1).
class CategoryColorPicker extends StatefulWidget {
  final int initialColor;
  final ValueChanged<int> onColorChanged;

  const CategoryColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<CategoryColorPicker> createState() => _CategoryColorPickerState();
}

class _CategoryColorPickerState extends State<CategoryColorPicker> {
  late double _hue;

  @override
  void initState() {
    super.initState();
    _hue = HSVColor.fromColor(Color(widget.initialColor)).hue;
  }

  @override
  void didUpdateWidget(CategoryColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialColor != widget.initialColor) {
      _hue = HSVColor.fromColor(Color(widget.initialColor)).hue;
    }
  }

  void _pick(double x, double w) {
    setState(() {
      _hue = (x.clamp(0.0, w) / w) * 360.0;
      widget.onColorChanged(hsvToColorInt(_hue, 1.0, 1.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color(hsvToColorInt(_hue, 1.0, 1.0));
    // Constrain max width so the bar doesn't look overly wide on large screens.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected color indicator: five-point star (slightly larger for better visibility).
            SizedBox(
              height: 36,
              child: Center(
                child: _ColorStar(
                  color: selectedColor,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                const barHeight = 20.0;
                const hitHeight = 32.0;
                return GestureDetector(
                  onHorizontalDragUpdate: (d) => _pick(d.localPosition.dx, w),
                  onTapDown: (d) => _pick(d.localPosition.dx, w),
                  child: SizedBox(
                    height: hitHeight,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomPaint(
                              size: Size(w, barHeight),
                              painter: _HueBarPainter(),
                            ),
                          ),
                        ),
                        Positioned(
                          left: ((_hue / 360.0) * w - 12).clamp(0.0, w - 24),
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _ColorStar(
                              color: selectedColor,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorStar extends StatelessWidget {
  final Color color;
  final double size;

  const _ColorStar({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    // Double-layer icon to simulate an outline for contrast on any background.
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.star,
          size: size + 3,
          color: Colors.white,
          shadows: const [
            Shadow(
              color: Colors.black45,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        Icon(
          Icons.star,
          size: size,
          color: color,
        ),
      ],
    );
  }
}

class _HueBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      colors: List.generate(7, (i) => HSVColor.fromAHSV(1, i * 60.0, 1, 1).toColor()),
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
