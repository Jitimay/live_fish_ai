import 'package:camera/camera.dart';
import 'package:flutter/material.dart' hide BoxPainter;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_fish_ai/features/camera/bloc/camera_bloc.dart';
import 'package:live_fish_ai/features/camera/view/box_painter.dart';
import 'package:live_fish_ai/models/detection.dart';
import 'package:live_fish_ai/services/tflite_service.dart';
import 'package:live_fish_ai/theme/app_theme.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CameraBloc(
        tfliteService: context.read<TfliteService>(),
      )..add(CameraStarted()),
      child: const CameraBody(),
    );
  }
}

class CameraBody extends StatelessWidget {
  const CameraBody({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: AppTheme.glassMorphism,
          child: const Text(
            'LiveFish AI',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: BlocConsumer<CameraBloc, CameraState>(
        listener: (context, state) {
          if (state is CameraLogSuccess) {
            _showSuccessSnackBar(context);
          }
        },
        builder: (context, state) {
          if (state is CameraLoadInProgress || state is CameraInitial) {
            return _buildLoadingView(context);
          }
          if (state is CameraLoadFailure) {
            return _buildErrorView(context, state.message);
          }
          if (state is CameraReady) {
            final cameraController = context.read<CameraBloc>().cameraController;
            if (cameraController == null || !cameraController.value.isInitialized) {
              return _buildErrorView(context, 'Camera not available');
            }

            return _buildCameraView(context, state, cameraController, screenSize);
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.oceanGradient,
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Initializing Camera...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loading AI model for fish detection',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.oceanGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.coral,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView(BuildContext context, CameraReady state, CameraController cameraController, Size screenSize) {
    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: CameraPreview(cameraController),
        ),
        
        // Detection Overlay
        Positioned.fill(
          child: CustomPaint(
            painter: BoxPainter(
              detections: state.detections,
              previewSize: cameraController.value.previewSize!,
              screenSize: screenSize,
            ),
          ),
        ),

        // Detection Info Cards
        ..._buildDetectionCards(state.detections, screenSize, cameraController.value.previewSize!),

        // Top Status Bar
        _buildTopStatusBar(context, state.detections),

        // Bottom Controls
        _buildBottomControls(context, state.detections),

        // Side Panel (when fish detected)
        if (state.detections.isNotEmpty) _buildSidePanel(context, state.detections.first),
      ],
    );
  }

  Widget _buildTopStatusBar(BuildContext context, List<Detection> detections) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: AppTheme.glassMorphism,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: detections.isNotEmpty ? AppTheme.seaFoam : AppTheme.coral,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              detections.isNotEmpty 
                ? '${detections.length} Fish Detected' 
                : 'Scanning for Fish...',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.camera_alt,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, List<Detection> detections) {
    return Positioned(
      bottom: 40,
      left: 16,
      right: 16,
      child: Column(
        children: [
          if (detections.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.aqua],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppTheme.softShadow],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Log This Catch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confidence: ${(detections.first.confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ).onTap(() {
              HapticFeedback.lightImpact();
              context.read<CameraBloc>().add(CameraCatchLogged(detections.first));
            }),
            const SizedBox(height: 12),
          ],
          
          // Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.flash_auto,
                label: 'Flash',
                onTap: () {
                  // Toggle flash
                  HapticFeedback.selectionClick();
                },
              ),
              _buildActionButton(
                icon: Icons.straighten,
                label: 'Measure',
                onTap: () {
                  // Open measurement mode
                  HapticFeedback.selectionClick();
                },
              ),
              _buildActionButton(
                icon: Icons.info_outline,
                label: 'Info',
                onTap: () {
                  // Show fish info
                  HapticFeedback.selectionClick();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: AppTheme.glassMorphism,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context, Detection detection) {
    final isJuvenile = detection.box.width < 100;
    
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).padding.top + 120,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassMorphism,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isJuvenile ? Icons.warning : Icons.check_circle,
                  color: isJuvenile ? AppTheme.coral : AppTheme.seaFoam,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    isJuvenile ? 'Juvenile' : 'Adult',
                    style: TextStyle(
                      color: isJuvenile ? AppTheme.coral : AppTheme.seaFoam,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isJuvenile ? 'Consider Release' : 'Size OK',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
            Text(
              '${(detection.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetectionCards(List<Detection> detections, Size screenSize, Size previewSize) {
    final List<Widget> cards = [];
    final double scaleX = screenSize.width / previewSize.height;
    final double scaleY = screenSize.height / previewSize.width;

    for (int i = 0; i < detections.length && i < 3; i++) {
      final detection = detections[i];
      final bool isJuvenile = detection.box.width * scaleX < 100;
      
      cards.add(
        Positioned(
          top: (detection.box.top * scaleY) - 40,
          left: detection.box.left * scaleX,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isJuvenile ? AppTheme.coral : AppTheme.seaFoam,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${detection.className.toUpperCase()} ${(detection.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    return cards;
  }

  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.seaFoam,
            ),
            const SizedBox(width: 12),
            const Text(
              'Catch logged successfully!',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppTheme.deepOcean,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

extension WidgetExtensions on Widget {
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }
}

