import 'package:hive/hive.dart';

part 'fish_catch.g.dart';

@HiveType(typeId: 0)
class FishCatch extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String species;

  @HiveField(2)
  final double length;

  @HiveField(3)
  final double confidence;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final bool isJuvenile;

  @HiveField(6)
  final double? latitude;

  @HiveField(7)
  final double? longitude;

  // @HiveField(8)
  // final Uint8List image;

  FishCatch({
    required this.id,
    required this.species,
    required this.length,
    required this.confidence,
    required this.timestamp,
    required this.isJuvenile,
    this.latitude,
    this.longitude,
    // required this.image,
  });
}
