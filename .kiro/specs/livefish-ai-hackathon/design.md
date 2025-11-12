# LiveFish AI Hackathon Design Document

## Overview

LiveFish AI is a Flutter-based mobile application that leverages YOLOv8 Nano for real-time fish detection on Arm-based Android devices. The application combines computer vision, AR measurement capabilities, and offline data storage to create a comprehensive tool for sustainable fishing and conservation efforts. The design prioritizes on-device AI processing, optimal performance on Arm architecture, and seamless user experience for hackathon demonstration.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    LiveFish AI Mobile App                   │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer (Flutter UI)                           │
│  ├── Camera View Screen                                     │
│  ├── Detection Overlay Widget                              │
│  ├── Measurement Interface                                 │
│  └── Catch Log Screen                                      │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer                                      │
│  ├── Detection Service                                     │
│  ├── Measurement Service                                   │
│  ├── Data Logging Service                                  │
│  └── State Management (Provider)                           │
├─────────────────────────────────────────────────────────────┤
│  AI/ML Layer                                              │
│  ├── YOLOv8 Nano TFLite Model                            │
│  ├── TensorFlow Lite Runtime                              │
│  ├── Image Preprocessing Pipeline                         │
│  └── Inference Engine (Arm Optimized)                     │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                               │
│  ├── Hive Local Database                                  │
│  ├── Model Asset Manager                                  │
│  └── File System Storage                                  │
├─────────────────────────────────────────────────────────────┤
│  Platform Layer                                           │
│  ├── Camera API (Android)                                 │
│  ├── GPS/Location Services                                │
│  ├── Device Sensors                                       │
│  └── Arm NPU/CPU Acceleration                             │
└─────────────────────────────────────────────────────────────┘
```

### System Flow

1. **Camera Initialization**: App requests camera permissions and initializes camera stream
2. **Real-time Processing**: Each camera frame is preprocessed and fed to YOLOv8 model
3. **Detection Pipeline**: Model outputs bounding boxes, confidence scores processed
4. **UI Overlay**: Detection results rendered as overlay on camera preview
5. **Measurement Mode**: User can activate AR-based size measurement
6. **Data Logging**: Catch information stored locally with GPS and timestamp
7. **Performance Monitoring**: System tracks inference time and resource usage

## Components and Interfaces

### 1. AI Detection Engine

**Purpose**: Core component responsible for fish detection using YOLOv8 Nano model

**Key Classes**:
- `DetectionEngine`: Main interface for AI model operations
- `ModelLoader`: Handles TFLite model loading and initialization
- `ImageProcessor`: Preprocesses camera frames for model input
- `ResultParser`: Processes model outputs into detection objects

**Interfaces**:
```dart
abstract class DetectionEngine {
  Future<void> initialize();
  Future<List<Detection>> detectFish(CameraImage image);
  void dispose();
}

class Detection {
  final Rect boundingBox;
  final double confidence;
  final String label;
  final int frameTimestamp;
}
```

**Implementation Details**:
- Model file: `assets/models/yolov8n_fish_320.tflite` (≤6MB)
- Input format: 320x320x3 RGB normalized [0,1]
- Output format: [x, y, w, h, confidence, class]
- Optimization: INT8 quantization for Arm efficiency
- Threading: Isolate-based processing to prevent UI blocking

### 2. Camera Management System

**Purpose**: Handles camera stream, frame capture, and real-time processing coordination

**Key Classes**:
- `CameraController`: Manages camera lifecycle and stream
- `FrameProcessor`: Coordinates frame processing pipeline
- `PreviewRenderer`: Renders camera preview with detection overlays

**Interfaces**:
```dart
abstract class CameraManager {
  Future<void> initialize();
  Stream<CameraImage> get frameStream;
  Future<void> startDetection();
  Future<void> stopDetection();
}
```

**Implementation Details**:
- Target resolution: 1280x720 for balance of quality and performance
- Frame rate: 30 FPS input, 15-20 FPS processing
- Buffer management: Circular buffer to prevent memory leaks
- Preview aspect ratio: Maintained across device orientations

### 3. AR Measurement Module

**Purpose**: Provides size measurement capabilities using reference objects and depth estimation

**Key Classes**:
- `MeasurementCalculator`: Core measurement algorithms
- `ReferenceDetector`: Identifies reference objects (coins, cards)
- `DepthEstimator`: Uses device sensors for depth-based measurement
- `CalibrationManager`: Handles measurement calibration

**Interfaces**:
```dart
abstract class MeasurementService {
  Future<void> calibrateWithReference(Detection reference, double realSize);
  Future<double> measureFish(Detection fishDetection);
  bool get isCalibrated;
}
```

**Implementation Details**:
- Reference objects: Standard coin (24mm), credit card (85.6mm)
- Calculation: `fish_length = (fish_bbox_px / ref_bbox_px) * ref_length_cm`
- Accuracy target: ±2cm for fish 10-50cm length
- Fallback: Manual calibration if auto-detection fails

### 4. Data Storage and Logging

**Purpose**: Manages offline data storage, catch logging, and data persistence

**Key Classes**:
- `CatchRepository`: CRUD operations for catch data
- `HiveDatabase`: Local database implementation
- `DataExporter`: Handles data export and sync preparation
- `StorageManager`: Manages storage space and cleanup

**Data Models**:
```dart
@HiveType(typeId: 0)
class CatchRecord extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime timestamp;
  
  @HiveField(2)
  final double fishLength;
  
  @HiveField(3)
  final double confidence;
  
  @HiveField(4)
  final GeoLocation location;
  
  @HiveField(5)
  final String imagePath;
}
```

**Implementation Details**:
- Database: Hive NoSQL for fast local storage
- Storage limit: 500MB with automatic cleanup
- Backup: JSON export capability for data portability
- Indexing: Timestamp and location-based queries

### 5. User Interface Components

**Purpose**: Provides intuitive interface for camera operation, detection visualization, and data management

**Screen Architecture**:
- `HomeScreen`: Main navigation and app overview
- `CameraScreen`: Live detection with overlay
- `MeasurementScreen`: AR measurement interface
- `LogScreen`: Catch history and statistics
- `SettingsScreen`: App configuration and model management

**Key Widgets**:
- `DetectionOverlay`: Renders bounding boxes and labels
- `MeasurementOverlay`: Shows measurement lines and results
- `CatchCard`: Displays individual catch records
- `StatisticsChart`: Visual data representation

## Data Models

### Core Data Structures

```dart
// Detection result from AI model
class FishDetection {
  final String id;
  final Rect boundingBox;
  final double confidence;
  final DateTime timestamp;
  final Size imageSize;
  
  bool get isHighConfidence => confidence >= 0.7;
}

// Measurement result
class FishMeasurement {
  final String detectionId;
  final double lengthCm;
  final double accuracy;
  final MeasurementMethod method;
  final String referenceObject;
}

// Geographic location
class GeoLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
}

// App configuration
class AppSettings {
  final double confidenceThreshold;
  final bool enableGPS;
  final bool enableSound;
  final String modelVersion;
  final MeasurementUnit unit;
}
```

### Database Schema

**Hive Boxes**:
- `catches`: Stores CatchRecord objects
- `settings`: App configuration
- `calibration`: Measurement calibration data
- `statistics`: Aggregated usage statistics

**Relationships**:
- One-to-many: CatchRecord → DetectionData
- One-to-one: CatchRecord → GeoLocation
- Many-to-one: CatchRecord → CalibrationData

## Error Handling

### Error Categories and Strategies

**1. AI Model Errors**:
- Model loading failure: Fallback to basic detection, user notification
- Inference timeout: Skip frame, continue processing
- Memory allocation error: Reduce processing frequency, garbage collection

**2. Camera Errors**:
- Permission denied: Show permission request dialog
- Camera unavailable: Display error message, retry mechanism
- Frame processing lag: Drop frames to maintain real-time performance

**3. Storage Errors**:
- Disk full: Automatic cleanup of old records, user notification
- Database corruption: Rebuild database, backup recovery
- Export failure: Retry mechanism, alternative export formats

**4. Measurement Errors**:
- Calibration failure: Manual calibration option
- Reference object not found: User guidance, alternative methods
- Depth estimation unavailable: Fallback to reference-based measurement

**Error Recovery Patterns**:
```dart
class ErrorHandler {
  static Future<T> withRetry<T>(
    Future<T> Function() operation,
    {int maxRetries = 3, Duration delay = const Duration(seconds: 1)}
  ) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(delay);
      }
    }
    throw Exception('Max retries exceeded');
  }
}
```

## Testing Strategy

### Unit Testing

**AI Model Testing**:
- Model loading and initialization
- Inference accuracy with test images
- Performance benchmarks on target devices
- Memory usage and cleanup

**Business Logic Testing**:
- Detection result processing
- Measurement calculations
- Data storage operations
- State management

**Test Coverage Target**: 80% code coverage

### Integration Testing

**Camera Integration**:
- Camera permission handling
- Frame processing pipeline
- Real-time detection flow
- UI overlay synchronization

**Database Integration**:
- CRUD operations
- Data migration
- Storage limits and cleanup
- Export functionality

### Performance Testing

**Benchmarks**:
- Inference time: Target ≤50ms per frame
- Memory usage: ≤100MB total app memory
- Battery consumption: Baseline measurement
- Frame rate: Maintain 15+ FPS processing

**Test Devices**:
- Primary: Snapdragon 8 Gen 2 device
- Secondary: MediaTek Dimensity 9000
- Minimum: Snapdragon 660 (baseline performance)

### User Acceptance Testing

**Demo Scenarios**:
1. Live fish detection in various lighting conditions
2. Size measurement with different reference objects
3. Catch logging and data export
4. App performance during extended use
5. Error recovery and edge cases

**Success Criteria**:
- 95% detection accuracy in demo conditions
- Measurement accuracy within ±2cm
- Zero crashes during 10-minute demo
- Smooth UI interactions (<500ms response)

## Performance Optimization

### Arm Architecture Optimizations

**CPU Optimizations**:
- NEON SIMD instructions for image preprocessing
- Multi-threading for parallel processing
- Cache-friendly memory access patterns
- ARM64 assembly optimizations where applicable

**NPU Utilization**:
- TensorFlow Lite delegate for Arm NPU
- Model quantization for NPU compatibility
- Batch processing optimization
- Memory bandwidth optimization

**Memory Management**:
- Object pooling for frequent allocations
- Efficient image buffer management
- Garbage collection optimization
- Memory-mapped model loading

### Real-time Processing Pipeline

**Frame Processing Strategy**:
```dart
class FrameProcessor {
  final Queue<CameraImage> _frameQueue = Queue();
  final Isolate _processingIsolate;
  
  void processFrame(CameraImage frame) {
    if (_frameQueue.length > 2) {
      _frameQueue.removeFirst(); // Drop old frames
    }
    _frameQueue.add(frame);
    _triggerProcessing();
  }
}
```

**Optimization Techniques**:
- Frame dropping to maintain real-time performance
- Adaptive quality based on device performance
- Background processing in isolates
- Efficient data serialization between isolates

## Security and Privacy

### Data Protection

**Local Data Security**:
- Hive database encryption for sensitive data
- Secure file storage for images
- No personal data transmission without consent
- Automatic data cleanup after retention period

**Privacy Considerations**:
- GPS data stored locally only
- No cloud sync without explicit user consent
- Image data processed locally, not transmitted
- Clear privacy policy and data usage disclosure

### Model Security

**AI Model Protection**:
- Model file integrity verification
- Secure model loading and validation
- Protection against model tampering
- Version control and update mechanism

## Deployment and Distribution

### Build Configuration

**Android Build Settings**:
- Target SDK: Android 14 (API 34)
- Minimum SDK: Android 7.0 (API 24)
- Architecture: arm64-v8a, armeabi-v7a
- Proguard: Enabled for release builds

**Flutter Configuration**:
- Flutter version: 3.24+
- Dart version: 3.5+
- Build mode: Release with optimizations
- Tree shaking: Enabled

### Asset Management

**Model Assets**:
- YOLOv8 Nano model: `assets/models/yolov8n_fish.tflite`
- Model metadata: `assets/models/model_info.json`
- Calibration data: `assets/calibration/references.json`

**UI Assets**:
- App icons: Multiple resolutions for Android
- Splash screen: Adaptive for different screen sizes
- Instruction images: Measurement guidance visuals

### Hackathon Submission Requirements

**Repository Structure**:
```
live_fish_ai/
├── README.md (Build instructions)
├── LICENSE (Open source license)
├── lib/ (Flutter source code)
├── assets/ (Models and resources)
├── android/ (Android configuration)
├── docs/ (Documentation)
├── demo/ (Demo videos and screenshots)
└── scripts/ (Build and deployment scripts)
```

**Documentation Requirements**:
- Step-by-step build instructions for Arm devices
- API documentation for key components
- Performance benchmarks and test results
- Demo video showcasing all features
- Technical architecture explanation

This design provides a comprehensive foundation for implementing LiveFish AI as a winning hackathon submission that demonstrates advanced on-device AI capabilities on Arm architecture while solving a real-world conservation problem.