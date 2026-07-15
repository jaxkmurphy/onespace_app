import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CalmingSoundCategoryConfig {
  final String id;
  final String nameEn;
  final String nameGa;
  final String emoji;
  final String iconName;
  final bool active;
  final bool isDefault;
  final int sortOrder;

  const CalmingSoundCategoryConfig({
    required this.id,
    required this.nameEn,
    required this.nameGa,
    required this.emoji,
    required this.iconName,
    required this.active,
    required this.isDefault,
    required this.sortOrder,
  });

  factory CalmingSoundCategoryConfig.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return CalmingSoundCategoryConfig(
      id: id,
      nameEn: data['nameEn'] as String? ?? '',
      nameGa: data['nameGa'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '🎧',
      iconName: data['iconName'] as String? ?? 'headphones',
      active: data['active'] != false,
      isDefault: data['isDefault'] == true,
      sortOrder: data['sortOrder'] as int? ?? 0,
    );
  }

  String nameForLocale(Locale locale) {
    if (locale.languageCode == 'ga' && nameGa.trim().isNotEmpty) {
      return nameGa.trim();
    }

    return nameEn.trim().isEmpty ? id : nameEn.trim();
  }

  Map<String, dynamic> toMap() {
    return {
      'nameEn': nameEn.trim(),
      'nameGa': nameGa.trim(),
      'emoji': emoji.trim().isEmpty ? '🎧' : emoji.trim(),
      'iconName': iconName.trim().isEmpty ? 'headphones' : iconName.trim(),
      'active': active,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CalmingSoundCategoryConfig copyWith({
    String? id,
    String? nameEn,
    String? nameGa,
    String? emoji,
    String? iconName,
    bool? active,
    bool? isDefault,
    int? sortOrder,
  }) {
    return CalmingSoundCategoryConfig(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameGa: nameGa ?? this.nameGa,
      emoji: emoji ?? this.emoji,
      iconName: iconName ?? this.iconName,
      active: active ?? this.active,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class StarterCalmingSound {
  final String id;
  final String titleEn;
  final String titleGa;
  final String assetPath;
  final String defaultCategoryId;
  final String categoryId;
  final bool active;
  final int sortOrder;

  const StarterCalmingSound({
    required this.id,
    required this.titleEn,
    required this.titleGa,
    required this.assetPath,
    required this.defaultCategoryId,
    required this.categoryId,
    required this.active,
    required this.sortOrder,
  });

  String titleForLocale(Locale locale) {
    if (locale.languageCode == 'ga' && titleGa.trim().isNotEmpty) {
      return titleGa.trim();
    }

    return titleEn.trim();
  }

  StarterCalmingSound withOverride(Map<String, dynamic>? data) {
    if (data == null) return this;

    return copyWith(
      categoryId: data['categoryId'] as String? ?? categoryId,
      active: data['active'] as bool? ?? active,
      sortOrder: data['sortOrder'] as int? ?? sortOrder,
    );
  }

  Map<String, dynamic> toOverrideMap() {
    return {
      'categoryId': categoryId,
      'active': active,
      'sortOrder': sortOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  StarterCalmingSound copyWith({
    String? id,
    String? titleEn,
    String? titleGa,
    String? assetPath,
    String? defaultCategoryId,
    String? categoryId,
    bool? active,
    int? sortOrder,
  }) {
    return StarterCalmingSound(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleGa: titleGa ?? this.titleGa,
      assetPath: assetPath ?? this.assetPath,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
      categoryId: categoryId ?? this.categoryId,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

const defaultCalmingSoundCategories = [
  CalmingSoundCategoryConfig(
    id: 'ocean',
    nameEn: 'Ocean',
    nameGa: 'Aigéan',
    emoji: '🌊',
    iconName: 'waves',
    active: true,
    isDefault: true,
    sortOrder: 0,
  ),
  CalmingSoundCategoryConfig(
    id: 'rain',
    nameEn: 'Rain',
    nameGa: 'Báisteach',
    emoji: '🌧️',
    iconName: 'rain',
    active: true,
    isDefault: true,
    sortOrder: 1,
  ),
  CalmingSoundCategoryConfig(
    id: 'wind',
    nameEn: 'Wind',
    nameGa: 'Gaoth',
    emoji: '🌬️',
    iconName: 'wind',
    active: true,
    isDefault: true,
    sortOrder: 2,
  ),
  CalmingSoundCategoryConfig(
    id: 'whiteNoise',
    nameEn: 'White Noise',
    nameGa: 'Torann Bán',
    emoji: '🤍',
    iconName: 'whiteNoise',
    active: true,
    isDefault: true,
    sortOrder: 3,
  ),
];

const defaultStarterCalmingSounds = [
  StarterCalmingSound(
    id: 'starter-ocean-1',
    titleEn: 'Gentle Waves',
    titleGa: 'Tonnta Séimhe',
    assetPath: 'sounds/ocean/oceanSound1.mp3',
    defaultCategoryId: 'ocean',
    categoryId: 'ocean',
    active: true,
    sortOrder: 0,
  ),
  StarterCalmingSound(
    id: 'starter-ocean-2',
    titleEn: 'Calm Beach',
    titleGa: 'Trá Chiúin',
    assetPath: 'sounds/ocean/oceanSound2.mp3',
    defaultCategoryId: 'ocean',
    categoryId: 'ocean',
    active: true,
    sortOrder: 1,
  ),
  StarterCalmingSound(
    id: 'starter-ocean-3',
    titleEn: 'Rolling Tide',
    titleGa: 'Taoide Réidh',
    assetPath: 'sounds/ocean/oceanSound3.mp3',
    defaultCategoryId: 'ocean',
    categoryId: 'ocean',
    active: true,
    sortOrder: 2,
  ),
  StarterCalmingSound(
    id: 'starter-ocean-4',
    titleEn: 'Soft Sea',
    titleGa: 'Farraige Bhog',
    assetPath: 'sounds/ocean/oceanSound4.mp3',
    defaultCategoryId: 'ocean',
    categoryId: 'ocean',
    active: true,
    sortOrder: 3,
  ),
  StarterCalmingSound(
    id: 'starter-ocean-5',
    titleEn: 'Deep Ocean',
    titleGa: 'Aigéan Domhain',
    assetPath: 'sounds/ocean/oceanSound5.mp3',
    defaultCategoryId: 'ocean',
    categoryId: 'ocean',
    active: true,
    sortOrder: 4,
  ),
  StarterCalmingSound(
    id: 'starter-rain-1',
    titleEn: 'Soft Rain',
    titleGa: 'Báisteach Bhog',
    assetPath: 'sounds/rain/rainSound1.mp3',
    defaultCategoryId: 'rain',
    categoryId: 'rain',
    active: true,
    sortOrder: 0,
  ),
  StarterCalmingSound(
    id: 'starter-rain-2',
    titleEn: 'Rainy Window',
    titleGa: 'Fuinneog Báistí',
    assetPath: 'sounds/rain/rainSound2.mp3',
    defaultCategoryId: 'rain',
    categoryId: 'rain',
    active: true,
    sortOrder: 1,
  ),
  StarterCalmingSound(
    id: 'starter-rain-3',
    titleEn: 'Gentle Shower',
    titleGa: 'Cith Séimh',
    assetPath: 'sounds/rain/rainSound3.mp3',
    defaultCategoryId: 'rain',
    categoryId: 'rain',
    active: true,
    sortOrder: 2,
  ),
  StarterCalmingSound(
    id: 'starter-rain-4',
    titleEn: 'Calm Rainfall',
    titleGa: 'Báisteach Chiúin',
    assetPath: 'sounds/rain/rainSound4.mp3',
    defaultCategoryId: 'rain',
    categoryId: 'rain',
    active: true,
    sortOrder: 3,
  ),
  StarterCalmingSound(
    id: 'starter-rain-5',
    titleEn: 'Peaceful Rain',
    titleGa: 'Báisteach Shuaimhneach',
    assetPath: 'sounds/rain/rainSound5.mp3',
    defaultCategoryId: 'rain',
    categoryId: 'rain',
    active: true,
    sortOrder: 4,
  ),
  StarterCalmingSound(
    id: 'starter-wind-1',
    titleEn: 'Soft Breeze',
    titleGa: 'Leoithne Bhog',
    assetPath: 'sounds/wind/windSound1.mp3',
    defaultCategoryId: 'wind',
    categoryId: 'wind',
    active: true,
    sortOrder: 0,
  ),
  StarterCalmingSound(
    id: 'starter-wind-2',
    titleEn: 'Gentle Wind',
    titleGa: 'Gaoth Shéimh',
    assetPath: 'sounds/wind/windSound2.mp3',
    defaultCategoryId: 'wind',
    categoryId: 'wind',
    active: true,
    sortOrder: 1,
  ),
  StarterCalmingSound(
    id: 'starter-wind-3',
    titleEn: 'Open Air',
    titleGa: 'Aer Oscailte',
    assetPath: 'sounds/wind/windSound3.mp3',
    defaultCategoryId: 'wind',
    categoryId: 'wind',
    active: true,
    sortOrder: 2,
  ),
  StarterCalmingSound(
    id: 'starter-wind-4',
    titleEn: 'Quiet Breeze',
    titleGa: 'Leoithne Chiúin',
    assetPath: 'sounds/wind/windSound4.mp3',
    defaultCategoryId: 'wind',
    categoryId: 'wind',
    active: true,
    sortOrder: 3,
  ),
  StarterCalmingSound(
    id: 'starter-wind-5',
    titleEn: 'Peaceful Wind',
    titleGa: 'Gaoth Shuaimhneach',
    assetPath: 'sounds/wind/windSound5.mp3',
    defaultCategoryId: 'wind',
    categoryId: 'wind',
    active: true,
    sortOrder: 4,
  ),
  StarterCalmingSound(
    id: 'starter-white-noise-1',
    titleEn: 'Soft Static',
    titleGa: 'Torann Bog',
    assetPath: 'sounds/whiteNoise/whiteNoiseSound1.mp3',
    defaultCategoryId: 'whiteNoise',
    categoryId: 'whiteNoise',
    active: true,
    sortOrder: 0,
  ),
  StarterCalmingSound(
    id: 'starter-white-noise-2',
    titleEn: 'Gentle Noise',
    titleGa: 'Torann Séimh',
    assetPath: 'sounds/whiteNoise/whiteNoiseSound2.mp3',
    defaultCategoryId: 'whiteNoise',
    categoryId: 'whiteNoise',
    active: true,
    sortOrder: 1,
  ),
  StarterCalmingSound(
    id: 'starter-white-noise-3',
    titleEn: 'Calm Hum',
    titleGa: 'Crónán Ciúin',
    assetPath: 'sounds/whiteNoise/whiteNoiseSound3.mp3',
    defaultCategoryId: 'whiteNoise',
    categoryId: 'whiteNoise',
    active: true,
    sortOrder: 2,
  ),
  StarterCalmingSound(
    id: 'starter-white-noise-4',
    titleEn: 'Steady Sound',
    titleGa: 'Fuaim Sheasta',
    assetPath: 'sounds/whiteNoise/whiteNoiseSound4.mp3',
    defaultCategoryId: 'whiteNoise',
    categoryId: 'whiteNoise',
    active: true,
    sortOrder: 3,
  ),
  StarterCalmingSound(
    id: 'starter-white-noise-5',
    titleEn: 'Focus Noise',
    titleGa: 'Torann Fócais',
    assetPath: 'sounds/whiteNoise/whiteNoiseSound5.mp3',
    defaultCategoryId: 'whiteNoise',
    categoryId: 'whiteNoise',
    active: true,
    sortOrder: 4,
  ),
];

IconData calmingSoundIcon(String iconName) {
  switch (iconName) {
    case 'waves':
      return Icons.waves_rounded;
    case 'rain':
      return Icons.water_drop_rounded;
    case 'wind':
      return Icons.air_rounded;
    case 'whiteNoise':
      return Icons.blur_on_rounded;
    case 'spa':
      return Icons.spa_rounded;
    case 'music':
      return Icons.music_note_rounded;
    case 'forest':
      return Icons.forest_rounded;
    case 'headphones':
    default:
      return Icons.headphones_rounded;
  }
}

List<Color> calmingSoundColors(String categoryId) {
  switch (categoryId) {
    case 'ocean':
      return const [Color(0xFF26A69A), Color(0xFF29B6F6)];
    case 'rain':
      return const [Color(0xFF42A5F5), Color(0xFF5C6BC0)];
    case 'wind':
      return const [Color(0xFF66BB6A), Color(0xFF26A69A)];
    case 'whiteNoise':
      return const [Color(0xFF78909C), Color(0xFFB0BEC5)];
    default:
      return const [Color(0xFF5E35B1), Color(0xFF26A69A)];
  }
}
