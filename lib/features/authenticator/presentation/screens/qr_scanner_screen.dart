import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/add_authenticator_preview_sheet.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _scannerController;
  String? _error;
  bool _isTorchOn = false;

  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n?.scanQrCode ?? 'Scan QR Code',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
            onPressed: _pickFromGallery,
            tooltip: 'Gallery',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller:
                _scannerController ??= MobileScannerController(
                  detectionSpeed: DetectionSpeed.normal,
                  facing: CameraFacing.back,
                ),
            onDetect: _onDetect,
          ),

          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ScanOverlayPainter(
                  scanProgress: _scanAnimation.value,
                  accentColor: colorScheme.primary,
                ),
              );
            },
          ),

          // Help text below cutout
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.28,
            child: Text(
              l10n?.scanHelpText ??
                  'Align QR code within the frame to scan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 20,
                          left: 24,
                          right: 24,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Flash toggle - circular icon button
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isTorchOn
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.15),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isTorchOn ? Icons.flash_on : Icons.flash_off,
                          color: _isTorchOn ? Colors.black : Colors.white,
                        ),
                        iconSize: 28,
                        onPressed: _toggleTorch,
                        tooltip: _isTorchOn
                            ? (l10n?.flashOn ?? 'Flash On')
                            : (l10n?.flashOff ?? 'Flash Off'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null) return;

    if (code.startsWith('otpauth://') || code.startsWith('steam://')) {
      _scannerController?.stop();
      _showPreview(code);
    } else {
      setState(() {
        _error =
            AppLocalizations.of(context)?.invalidQrCode ??
            'Invalid QR code. Please scan an authenticator QR code.';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _error = null);
      });
    }
  }

  void _showPreview(String uri) async {
    _animationController.stop();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAuthenticatorPreviewSheet(uri: uri),
    );

    if (result == true && mounted) {
      Navigator.pop(context, uri);
    } else {
      _scannerController?.start();
      _animationController.repeat(reverse: true);
    }
  }

  void _toggleTorch() async {
    await _scannerController?.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
  }

  void _pickFromGallery() async {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.galleryPickerNotImplemented ??
              'Gallery picker not implemented yet',
        ),
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  final double scanProgress;
  final Color accentColor;

  _ScanOverlayPainter({
    required this.scanProgress,
    required this.accentColor,
  });

  static const _scanGreen = Color(0xFF00E676);
  static const _scanGreenBright = Color(0xFF69F0AE);

  @override
  void paint(Canvas canvas, Size size) {
    final cutoutSize = size.width * 0.78;
    final cutoutLeft = (size.width - cutoutSize) / 2;
    final cutoutTop = (size.height - cutoutSize) / 2 - 40;

    // Sharp rectangle cutout (no rounded corners)
    final cutoutRect = Rect.fromLTWH(
      cutoutLeft, cutoutTop, cutoutSize, cutoutSize,
    );

    // Dark overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.60)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cutoutRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);

    // Subtle border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(cutoutRect, borderPaint);

    // Corner brackets
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final bracketLen = cutoutSize * 0.10;
    final cL = cutoutLeft;
    final cT = cutoutTop;
    final cR = cutoutLeft + cutoutSize;
    final cB = cutoutTop + cutoutSize;

    canvas.drawLine(Offset(cL, cT + bracketLen), Offset(cL, cT), cornerPaint);
    canvas.drawLine(Offset(cL, cT), Offset(cL + bracketLen, cT), cornerPaint);
    canvas.drawLine(Offset(cR - bracketLen, cT), Offset(cR, cT), cornerPaint);
    canvas.drawLine(Offset(cR, cT), Offset(cR, cT + bracketLen), cornerPaint);
    canvas.drawLine(Offset(cL, cB - bracketLen), Offset(cL, cB), cornerPaint);
    canvas.drawLine(Offset(cL, cB), Offset(cL + bracketLen, cB), cornerPaint);
    canvas.drawLine(Offset(cR - bracketLen, cB), Offset(cR, cB), cornerPaint);
    canvas.drawLine(Offset(cR, cB), Offset(cR, cB - bracketLen), cornerPaint);

    // ── Scan line: wave shape (thick center → tapers to zero at edges) ──
    final scanY = cT + 6 + (cutoutSize - 12) * scanProgress;
    final halfW = (cutoutSize - 12) / 2;
    final centerX = cutoutLeft + cutoutSize / 2;

    // Outer soft glow wave (peak height: 6px each side)
    const glowPeak = 6.0;
    final glowPath = Path()
      ..moveTo(centerX - halfW, scanY)
      ..quadraticBezierTo(centerX, scanY - glowPeak, centerX + halfW, scanY)
      ..quadraticBezierTo(centerX, scanY + glowPeak, centerX - halfW, scanY)
      ..close();

    final glowBounds = glowPath.getBounds();
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          _scanGreen.withValues(alpha: 0.25),
          _scanGreen.withValues(alpha: 0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(glowBounds)
      ..style = PaintingStyle.fill;

    canvas.drawPath(glowPath, glowPaint);

    // Core bright wave (peak height: 2px each side)
    const corePeak = 2.0;
    final corePath = Path()
      ..moveTo(centerX - halfW, scanY)
      ..quadraticBezierTo(centerX, scanY - corePeak, centerX + halfW, scanY)
      ..quadraticBezierTo(centerX, scanY + corePeak, centerX - halfW, scanY)
      ..close();

    final coreBounds = corePath.getBounds();
    final corePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          _scanGreenBright.withValues(alpha: 0.7),
          _scanGreenBright,
          _scanGreenBright.withValues(alpha: 0.7),
          Colors.transparent,
        ],
        stops: const [0.0, 0.15, 0.5, 0.85, 1.0],
      ).createShader(coreBounds)
      ..style = PaintingStyle.fill;

    canvas.drawPath(corePath, corePaint);

    // Trailing afterglow wave (follows scan direction)
    const trailPeak = 10.0;
    final trailDir = scanProgress < 0.5 ? 1.0 : -1.0;
    final trailY = scanY + trailDir * 2;

    final trailPath = Path()
      ..moveTo(centerX - halfW, trailY)
      ..quadraticBezierTo(
        centerX, trailY + trailDir * trailPeak,
        centerX + halfW, trailY,
      )
      ..lineTo(centerX + halfW, scanY)
      ..quadraticBezierTo(centerX, scanY, centerX - halfW, scanY)
      ..close();

    final trailBounds = trailPath.getBounds();
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: trailDir > 0 ? Alignment.topCenter : Alignment.bottomCenter,
        end: trailDir > 0 ? Alignment.bottomCenter : Alignment.topCenter,
        colors: [
          _scanGreen.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(trailBounds)
      ..style = PaintingStyle.fill;

    canvas.drawPath(trailPath, trailPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress;
  }
}
