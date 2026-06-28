import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

enum AppIconCategory {
  learning,
  feelings,
  dailyLife,
  food,
  animals,
  play,
  health,
  nature,
  people,
  objects,
}

extension AppIconCategoryLabels on AppIconCategory {
  String get label {
    return switch (this) {
      AppIconCategory.learning => 'Learning',
      AppIconCategory.feelings => 'Feelings',
      AppIconCategory.dailyLife => 'Daily Life',
      AppIconCategory.food => 'Food',
      AppIconCategory.animals => 'Animals',
      AppIconCategory.play => 'Play',
      AppIconCategory.health => 'Health',
      AppIconCategory.nature => 'Nature',
      AppIconCategory.people => 'People',
      AppIconCategory.objects => 'Objects',
    };
  }
}

class AppIconOption {
  final String key;
  final String label;
  final IconData icon;
  final AppIconCategory category;
  final List<String> searchTerms;

  const AppIconOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.category,
    this.searchTerms = const [],
  });

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return key.toLowerCase().contains(normalized) ||
        label.toLowerCase().contains(normalized) ||
        category.label.toLowerCase().contains(normalized) ||
        searchTerms.any((term) => term.toLowerCase().contains(normalized));
  }
}

const List<AppIconOption> appIconCatalog = [
  // Learning
  AppIconOption(
    key: 'abc',
    label: 'ABC',
    icon: TablerIcons.abc,
    category: AppIconCategory.learning,
    searchTerms: ['letters', 'alphabet', 'words'],
  ),
  AppIconOption(
    key: 'abacus',
    label: 'Abacus',
    icon: TablerIcons.abacus,
    category: AppIconCategory.learning,
    searchTerms: ['maths', 'math', 'counting', 'numbers'],
  ),
  AppIconOption(
    key: 'book',
    label: 'Book',
    icon: TablerIcons.book,
    category: AppIconCategory.learning,
    searchTerms: ['reading', 'story', 'learning'],
  ),
  AppIconOption(
    key: 'brain',
    label: 'Brain',
    icon: TablerIcons.brain,
    category: AppIconCategory.learning,
    searchTerms: ['thinking', 'logic', 'mind'],
  ),
  AppIconOption(
    key: 'language',
    label: 'Language',
    icon: TablerIcons.language,
    category: AppIconCategory.learning,
    searchTerms: ['translation', 'irish', 'english'],
  ),
  AppIconOption(
    key: 'math',
    label: 'Math',
    icon: TablerIcons.math,
    category: AppIconCategory.learning,
    searchTerms: ['maths', 'numbers', 'counting'],
  ),
  AppIconOption(
    key: 'pencil',
    label: 'Pencil',
    icon: TablerIcons.pencil,
    category: AppIconCategory.learning,
    searchTerms: ['writing', 'draw', 'school'],
  ),
  AppIconOption(
    key: 'school',
    label: 'School',
    icon: TablerIcons.school,
    category: AppIconCategory.learning,
    searchTerms: ['classroom', 'teacher', 'learn'],
  ),

  // Feelings
  AppIconOption(
    key: 'heart',
    label: 'Heart',
    icon: TablerIcons.heart,
    category: AppIconCategory.feelings,
    searchTerms: ['love', 'care'],
  ),
  AppIconOption(
    key: 'mood_happy',
    label: 'Happy',
    icon: TablerIcons.mood_happy,
    category: AppIconCategory.feelings,
    searchTerms: ['smile', 'joy'],
  ),
  AppIconOption(
    key: 'mood_smile',
    label: 'Smile',
    icon: TablerIcons.mood_smile,
    category: AppIconCategory.feelings,
    searchTerms: ['calm', 'okay'],
  ),
  AppIconOption(
    key: 'mood_sad',
    label: 'Sad',
    icon: TablerIcons.mood_sad,
    category: AppIconCategory.feelings,
    searchTerms: ['upset', 'cry'],
  ),
  AppIconOption(
    key: 'mood_angry',
    label: 'Angry',
    icon: TablerIcons.mood_angry,
    category: AppIconCategory.feelings,
    searchTerms: ['mad', 'frustrated'],
  ),
  AppIconOption(
    key: 'sparkles',
    label: 'Sparkles',
    icon: TablerIcons.sparkles,
    category: AppIconCategory.feelings,
    searchTerms: ['special', 'magic', 'good'],
  ),

  // Daily life
  AppIconOption(
    key: 'backpack',
    label: 'Backpack',
    icon: TablerIcons.backpack,
    category: AppIconCategory.dailyLife,
    searchTerms: ['bag', 'school bag'],
  ),
  AppIconOption(
    key: 'bath',
    label: 'Bath',
    icon: TablerIcons.bath,
    category: AppIconCategory.dailyLife,
    searchTerms: ['wash', 'bathroom'],
  ),
  AppIconOption(
    key: 'bed',
    label: 'Bed',
    icon: TablerIcons.bed,
    category: AppIconCategory.dailyLife,
    searchTerms: ['sleep', 'rest'],
  ),
  AppIconOption(
    key: 'bell',
    label: 'Bell',
    icon: TablerIcons.bell,
    category: AppIconCategory.dailyLife,
    searchTerms: ['alert', 'sound', 'ring'],
  ),
  AppIconOption(
    key: 'bus',
    label: 'Bus',
    icon: TablerIcons.bus,
    category: AppIconCategory.dailyLife,
    searchTerms: ['transport', 'school bus'],
  ),
  AppIconOption(
    key: 'calendar',
    label: 'Calendar',
    icon: TablerIcons.calendar,
    category: AppIconCategory.dailyLife,
    searchTerms: ['day', 'date', 'schedule'],
  ),
  AppIconOption(
    key: 'clock',
    label: 'Clock',
    icon: TablerIcons.clock,
    category: AppIconCategory.dailyLife,
    searchTerms: ['time', 'timer'],
  ),
  AppIconOption(
    key: 'home',
    label: 'Home',
    icon: TablerIcons.home,
    category: AppIconCategory.dailyLife,
    searchTerms: ['house'],
  ),
  AppIconOption(
    key: 'shirt',
    label: 'Shirt',
    icon: TablerIcons.shirt,
    category: AppIconCategory.dailyLife,
    searchTerms: ['clothes', 'uniform'],
  ),
  AppIconOption(
    key: 'shoe',
    label: 'Shoe',
    icon: TablerIcons.shoe,
    category: AppIconCategory.dailyLife,
    searchTerms: ['shoes', 'feet'],
  ),

  // Food
  AppIconOption(
    key: 'apple',
    label: 'Apple',
    icon: TablerIcons.apple,
    category: AppIconCategory.food,
    searchTerms: ['fruit', 'snack'],
  ),
  AppIconOption(
    key: 'cake',
    label: 'Cake',
    icon: TablerIcons.cake,
    category: AppIconCategory.food,
    searchTerms: ['birthday', 'treat'],
  ),
  AppIconOption(
    key: 'carrot',
    label: 'Carrot',
    icon: TablerIcons.carrot,
    category: AppIconCategory.food,
    searchTerms: ['vegetable', 'rabbit'],
  ),
  AppIconOption(
    key: 'cup',
    label: 'Cup',
    icon: TablerIcons.cup,
    category: AppIconCategory.food,
    searchTerms: ['drink', 'water'],
  ),
  AppIconOption(
    key: 'ice_cream',
    label: 'Ice Cream',
    icon: TablerIcons.ice_cream,
    category: AppIconCategory.food,
    searchTerms: ['treat', 'dessert'],
  ),
  AppIconOption(
    key: 'pizza',
    label: 'Pizza',
    icon: TablerIcons.pizza,
    category: AppIconCategory.food,
    searchTerms: ['food', 'lunch'],
  ),
  AppIconOption(
    key: 'tools_kitchen_2',
    label: 'Kitchen',
    icon: TablerIcons.tools_kitchen_2,
    category: AppIconCategory.food,
    searchTerms: ['fork', 'knife', 'meal'],
  ),

  // Animals
  AppIconOption(
    key: 'cat',
    label: 'Cat',
    icon: TablerIcons.cat,
    category: AppIconCategory.animals,
  ),
  AppIconOption(
    key: 'dog',
    label: 'Dog',
    icon: TablerIcons.dog,
    category: AppIconCategory.animals,
  ),
  AppIconOption(
    key: 'fish',
    label: 'Fish',
    icon: TablerIcons.fish,
    category: AppIconCategory.animals,
  ),
  AppIconOption(
    key: 'paw',
    label: 'Paw',
    icon: TablerIcons.paw,
    category: AppIconCategory.animals,
    searchTerms: ['animal', 'pet'],
  ),

  // Play
  AppIconOption(
    key: 'ball_basketball',
    label: 'Basketball',
    icon: TablerIcons.ball_basketball,
    category: AppIconCategory.play,
    searchTerms: ['ball', 'sport'],
  ),
  AppIconOption(
    key: 'ball_football',
    label: 'Football',
    icon: TablerIcons.ball_football,
    category: AppIconCategory.play,
    searchTerms: ['ball', 'sport', 'soccer'],
  ),
  AppIconOption(
    key: 'balloon',
    label: 'Balloon',
    icon: TablerIcons.balloon,
    category: AppIconCategory.play,
    searchTerms: ['party', 'fun'],
  ),
  AppIconOption(
    key: 'device_gamepad_2',
    label: 'Game',
    icon: TablerIcons.device_gamepad_2,
    category: AppIconCategory.play,
    searchTerms: ['games', 'controller'],
  ),
  AppIconOption(
    key: 'lego',
    label: 'Blocks',
    icon: TablerIcons.lego,
    category: AppIconCategory.play,
    searchTerms: ['lego', 'toy', 'build'],
  ),
  AppIconOption(
    key: 'music',
    label: 'Music',
    icon: TablerIcons.music,
    category: AppIconCategory.play,
    searchTerms: ['song', 'sound'],
  ),
  AppIconOption(
    key: 'puzzle',
    label: 'Puzzle',
    icon: TablerIcons.puzzle,
    category: AppIconCategory.play,
    searchTerms: ['game', 'thinking'],
  ),
  AppIconOption(
    key: 'rocket',
    label: 'Rocket',
    icon: TablerIcons.rocket,
    category: AppIconCategory.play,
    searchTerms: ['space', 'launch'],
  ),

  // Health
  AppIconOption(
    key: 'accessible',
    label: 'Accessible',
    icon: TablerIcons.accessible,
    category: AppIconCategory.health,
    searchTerms: ['accessibility', 'support'],
  ),
  AppIconOption(
    key: 'activity_heartbeat',
    label: 'Heartbeat',
    icon: TablerIcons.activity_heartbeat,
    category: AppIconCategory.health,
    searchTerms: ['body', 'health'],
  ),
  AppIconOption(
    key: 'dental',
    label: 'Dental',
    icon: TablerIcons.dental,
    category: AppIconCategory.health,
    searchTerms: ['tooth', 'teeth'],
  ),
  AppIconOption(
    key: 'first_aid_kit',
    label: 'First Aid',
    icon: TablerIcons.first_aid_kit,
    category: AppIconCategory.health,
    searchTerms: ['hurt', 'injury', 'medical'],
  ),
  AppIconOption(
    key: 'medicine_syrup',
    label: 'Medicine',
    icon: TablerIcons.medicine_syrup,
    category: AppIconCategory.health,
  ),
  AppIconOption(
    key: 'nurse',
    label: 'Nurse',
    icon: TablerIcons.nurse,
    category: AppIconCategory.health,
    searchTerms: ['doctor', 'medical'],
  ),
  AppIconOption(
    key: 'stethoscope',
    label: 'Doctor',
    icon: TablerIcons.stethoscope,
    category: AppIconCategory.health,
    searchTerms: ['health', 'medical'],
  ),
  AppIconOption(
    key: 'vaccine',
    label: 'Vaccine',
    icon: TablerIcons.vaccine,
    category: AppIconCategory.health,
    searchTerms: ['needle', 'medical'],
  ),

  // Nature
  AppIconOption(
    key: 'cloud',
    label: 'Cloud',
    icon: TablerIcons.cloud,
    category: AppIconCategory.nature,
    searchTerms: ['weather'],
  ),
  AppIconOption(
    key: 'droplet',
    label: 'Water',
    icon: TablerIcons.droplet,
    category: AppIconCategory.nature,
    searchTerms: ['drop', 'rain'],
  ),
  AppIconOption(
    key: 'flower',
    label: 'Flower',
    icon: TablerIcons.flower,
    category: AppIconCategory.nature,
  ),
  AppIconOption(
    key: 'leaf',
    label: 'Leaf',
    icon: TablerIcons.leaf,
    category: AppIconCategory.nature,
    searchTerms: ['plant', 'nature'],
  ),
  AppIconOption(
    key: 'moon',
    label: 'Moon',
    icon: TablerIcons.moon,
    category: AppIconCategory.nature,
    searchTerms: ['night', 'sleep'],
  ),
  AppIconOption(
    key: 'plant',
    label: 'Plant',
    icon: TablerIcons.plant,
    category: AppIconCategory.nature,
  ),
  AppIconOption(
    key: 'rainbow',
    label: 'Rainbow',
    icon: TablerIcons.rainbow,
    category: AppIconCategory.nature,
    searchTerms: ['colour', 'color'],
  ),
  AppIconOption(
    key: 'sun',
    label: 'Sun',
    icon: TablerIcons.sun,
    category: AppIconCategory.nature,
    searchTerms: ['day', 'weather'],
  ),
  AppIconOption(
    key: 'tree',
    label: 'Tree',
    icon: TablerIcons.tree,
    category: AppIconCategory.nature,
  ),
  AppIconOption(
    key: 'umbrella',
    label: 'Umbrella',
    icon: TablerIcons.umbrella,
    category: AppIconCategory.nature,
    searchTerms: ['rain'],
  ),

  // People
  AppIconOption(
    key: 'baby_carriage',
    label: 'Baby',
    icon: TablerIcons.baby_carriage,
    category: AppIconCategory.people,
  ),
  AppIconOption(
    key: 'face_id',
    label: 'Face',
    icon: TablerIcons.face_id,
    category: AppIconCategory.people,
  ),
  AppIconOption(
    key: 'user',
    label: 'Person',
    icon: TablerIcons.user,
    category: AppIconCategory.people,
  ),
  AppIconOption(
    key: 'users',
    label: 'People',
    icon: TablerIcons.users,
    category: AppIconCategory.people,
    searchTerms: ['group', 'class'],
  ),
  AppIconOption(
    key: 'wheelchair',
    label: 'Wheelchair',
    icon: TablerIcons.wheelchair,
    category: AppIconCategory.people,
    searchTerms: ['accessibility'],
  ),

  // Objects
  AppIconOption(
    key: 'award',
    label: 'Award',
    icon: TablerIcons.award,
    category: AppIconCategory.objects,
    searchTerms: ['prize', 'badge'],
  ),
  AppIconOption(
    key: 'brush',
    label: 'Brush',
    icon: TablerIcons.brush,
    category: AppIconCategory.objects,
    searchTerms: ['paint', 'art'],
  ),
  AppIconOption(
    key: 'camera',
    label: 'Camera',
    icon: TablerIcons.camera,
    category: AppIconCategory.objects,
    searchTerms: ['photo'],
  ),
  AppIconOption(
    key: 'color_swatch',
    label: 'Colours',
    icon: TablerIcons.color_swatch,
    category: AppIconCategory.objects,
    searchTerms: ['color', 'paint'],
  ),
  AppIconOption(
    key: 'flag',
    label: 'Flag',
    icon: TablerIcons.flag,
    category: AppIconCategory.objects,
  ),
  AppIconOption(
    key: 'gift',
    label: 'Gift',
    icon: TablerIcons.gift,
    category: AppIconCategory.objects,
    searchTerms: ['reward', 'present'],
  ),
  AppIconOption(
    key: 'paint',
    label: 'Paint',
    icon: TablerIcons.paint,
    category: AppIconCategory.objects,
    searchTerms: ['art'],
  ),
  AppIconOption(
    key: 'palette',
    label: 'Palette',
    icon: TablerIcons.palette,
    category: AppIconCategory.objects,
    searchTerms: ['art', 'paint'],
  ),
  AppIconOption(
    key: 'scissors',
    label: 'Scissors',
    icon: TablerIcons.scissors,
    category: AppIconCategory.objects,
    searchTerms: ['cut', 'craft'],
  ),
  AppIconOption(
    key: 'shield',
    label: 'Shield',
    icon: TablerIcons.shield,
    category: AppIconCategory.objects,
    searchTerms: ['safe', 'protect'],
  ),
  AppIconOption(
    key: 'star',
    label: 'Star',
    icon: TablerIcons.star,
    category: AppIconCategory.objects,
    searchTerms: ['favourite', 'favorite', 'reward'],
  ),
  AppIconOption(
    key: 'trophy',
    label: 'Trophy',
    icon: TablerIcons.trophy,
    category: AppIconCategory.objects,
    searchTerms: ['win', 'award'],
  ),

  // Expanded learning and classroom icons.
  AppIconOption(
    key: 'alphabet_latin',
    label: 'Alphabet',
    icon: TablerIcons.alphabet_latin,
    category: AppIconCategory.learning,
    searchTerms: ['letters', 'abc', 'phonics'],
  ),
  AppIconOption(
    key: 'books',
    label: 'Books',
    icon: TablerIcons.books,
    category: AppIconCategory.learning,
    searchTerms: ['reading', 'library', 'story'],
  ),
  AppIconOption(
    key: 'book_download',
    label: 'Read',
    icon: TablerIcons.book_download,
    category: AppIconCategory.learning,
    searchTerms: ['reading', 'learn'],
  ),
  AppIconOption(
    key: 'book_upload',
    label: 'Share Book',
    icon: TablerIcons.book_upload,
    category: AppIconCategory.learning,
    searchTerms: ['show', 'tell', 'share'],
  ),
  AppIconOption(
    key: 'bulb',
    label: 'Idea',
    icon: TablerIcons.bulb,
    category: AppIconCategory.learning,
    searchTerms: ['think', 'answer', 'idea'],
  ),
  AppIconOption(
    key: 'clipboard',
    label: 'Clipboard',
    icon: TablerIcons.clipboard,
    category: AppIconCategory.learning,
    searchTerms: ['work', 'task', 'list'],
  ),
  AppIconOption(
    key: 'clipboard_check',
    label: 'Checklist',
    icon: TablerIcons.clipboard_check,
    category: AppIconCategory.learning,
    searchTerms: ['done', 'finished', 'complete'],
  ),
  AppIconOption(
    key: 'clipboard_list',
    label: 'List',
    icon: TablerIcons.clipboard_list,
    category: AppIconCategory.learning,
    searchTerms: ['steps', 'routine', 'tasks'],
  ),
  AppIconOption(
    key: 'keyboard',
    label: 'Keyboard',
    icon: TablerIcons.keyboard,
    category: AppIconCategory.learning,
    searchTerms: ['typing', 'computer'],
  ),
  AppIconOption(
    key: 'paperclip',
    label: 'Paperclip',
    icon: TablerIcons.paperclip,
    category: AppIconCategory.learning,
    searchTerms: ['attach', 'paper'],
  ),
  AppIconOption(
    key: 'pencil_plus',
    label: 'Write',
    icon: TablerIcons.pencil_plus,
    category: AppIconCategory.learning,
    searchTerms: ['writing', 'add', 'draw'],
  ),
  AppIconOption(
    key: 'printer',
    label: 'Printer',
    icon: TablerIcons.printer,
    category: AppIconCategory.learning,
    searchTerms: ['print', 'paper'],
  ),
  AppIconOption(
    key: 'scale',
    label: 'Scale',
    icon: TablerIcons.scale,
    category: AppIconCategory.learning,
    searchTerms: ['measure', 'maths', 'science'],
  ),
  AppIconOption(
    key: 'target',
    label: 'Target',
    icon: TablerIcons.target,
    category: AppIconCategory.learning,
    searchTerms: ['goal', 'aim', 'focus'],
  ),
  AppIconOption(
    key: 'writing',
    label: 'Writing',
    icon: TablerIcons.writing,
    category: AppIconCategory.learning,
    searchTerms: ['write', 'pencil', 'sentence'],
  ),
  AppIconOption(
    key: 'writing_sign',
    label: 'Sign Writing',
    icon: TablerIcons.writing_sign,
    category: AppIconCategory.learning,
    searchTerms: ['signature', 'write'],
  ),

  // Expanded feelings and communication icons.
  AppIconOption(
    key: 'ear',
    label: 'Listen',
    icon: TablerIcons.ear,
    category: AppIconCategory.feelings,
    searchTerms: ['hear', 'sound', 'listen'],
  ),
  AppIconOption(
    key: 'eye',
    label: 'Look',
    icon: TablerIcons.eye,
    category: AppIconCategory.feelings,
    searchTerms: ['see', 'watch', 'look'],
  ),
  AppIconOption(
    key: 'hand_finger',
    label: 'Point',
    icon: TablerIcons.hand_finger,
    category: AppIconCategory.feelings,
    searchTerms: ['choose', 'tap', 'point'],
  ),
  AppIconOption(
    key: 'hand_love_you',
    label: 'Love You',
    icon: TablerIcons.hand_love_you,
    category: AppIconCategory.feelings,
    searchTerms: ['love', 'kind', 'care'],
  ),
  AppIconOption(
    key: 'hand_stop',
    label: 'Stop',
    icon: TablerIcons.hand_stop,
    category: AppIconCategory.feelings,
    searchTerms: ['wait', 'pause', 'no'],
  ),
  AppIconOption(
    key: 'mood_annoyed',
    label: 'Annoyed',
    icon: TablerIcons.mood_annoyed,
    category: AppIconCategory.feelings,
    searchTerms: ['frustrated', 'upset'],
  ),
  AppIconOption(
    key: 'mood_confuzed',
    label: 'Confused',
    icon: TablerIcons.mood_confuzed,
    category: AppIconCategory.feelings,
    searchTerms: ['unsure', 'question'],
  ),
  AppIconOption(
    key: 'mood_empty',
    label: 'Calm Face',
    icon: TablerIcons.mood_empty,
    category: AppIconCategory.feelings,
    searchTerms: ['blank', 'calm', 'quiet'],
  ),
  AppIconOption(
    key: 'mood_kid',
    label: 'Kid',
    icon: TablerIcons.mood_kid,
    category: AppIconCategory.feelings,
    searchTerms: ['child', 'happy'],
  ),
  AppIconOption(
    key: 'mood_sick',
    label: 'Sick Face',
    icon: TablerIcons.mood_sick,
    category: AppIconCategory.feelings,
    searchTerms: ['sick', 'unwell'],
  ),
  AppIconOption(
    key: 'mood_wink',
    label: 'Wink',
    icon: TablerIcons.mood_wink,
    category: AppIconCategory.feelings,
    searchTerms: ['playful', 'joke'],
  ),
  AppIconOption(
    key: 'microphone',
    label: 'Speak',
    icon: TablerIcons.microphone,
    category: AppIconCategory.feelings,
    searchTerms: ['talk', 'voice', 'say'],
  ),
  AppIconOption(
    key: 'phone',
    label: 'Phone',
    icon: TablerIcons.phone,
    category: AppIconCategory.feelings,
    searchTerms: ['call', 'contact'],
  ),
  AppIconOption(
    key: 'speakerphone',
    label: 'Announcement',
    icon: TablerIcons.speakerphone,
    category: AppIconCategory.feelings,
    searchTerms: ['loud', 'talk', 'announce'],
  ),

  // Expanded daily life and places.
  AppIconOption(
    key: 'basket',
    label: 'Basket',
    icon: TablerIcons.basket,
    category: AppIconCategory.dailyLife,
    searchTerms: ['carry', 'shopping'],
  ),
  AppIconOption(
    key: 'bike',
    label: 'Bike',
    icon: TablerIcons.bike,
    category: AppIconCategory.dailyLife,
    searchTerms: ['cycle', 'transport'],
  ),
  AppIconOption(
    key: 'building',
    label: 'Building',
    icon: TablerIcons.building,
    category: AppIconCategory.dailyLife,
    searchTerms: ['place', 'town'],
  ),
  AppIconOption(
    key: 'building_community',
    label: 'Community',
    icon: TablerIcons.building_community,
    category: AppIconCategory.dailyLife,
    searchTerms: ['school', 'community', 'classroom'],
  ),
  AppIconOption(
    key: 'building_cottage',
    label: 'Cottage',
    icon: TablerIcons.building_cottage,
    category: AppIconCategory.dailyLife,
    searchTerms: ['home', 'house'],
  ),
  AppIconOption(
    key: 'building_hospital',
    label: 'Hospital',
    icon: TablerIcons.building_hospital,
    category: AppIconCategory.dailyLife,
    searchTerms: ['doctor', 'health'],
  ),
  AppIconOption(
    key: 'building_store',
    label: 'Shop',
    icon: TablerIcons.building_store,
    category: AppIconCategory.dailyLife,
    searchTerms: ['store', 'shopping'],
  ),
  AppIconOption(
    key: 'bus_stop',
    label: 'Bus Stop',
    icon: TablerIcons.bus_stop,
    category: AppIconCategory.dailyLife,
    searchTerms: ['bus', 'transport', 'wait'],
  ),
  AppIconOption(
    key: 'clothes_rack',
    label: 'Clothes',
    icon: TablerIcons.clothes_rack,
    category: AppIconCategory.dailyLife,
    searchTerms: ['coat', 'clothes', 'change'],
  ),
  AppIconOption(
    key: 'door',
    label: 'Door',
    icon: TablerIcons.door,
    category: AppIconCategory.dailyLife,
    searchTerms: ['enter', 'exit', 'room'],
  ),
  AppIconOption(
    key: 'ironing',
    label: 'Ironing',
    icon: TablerIcons.ironing,
    category: AppIconCategory.dailyLife,
    searchTerms: ['clothes', 'laundry'],
  ),
  AppIconOption(
    key: 'lamp',
    label: 'Lamp',
    icon: TablerIcons.lamp,
    category: AppIconCategory.dailyLife,
    searchTerms: ['light', 'quiet'],
  ),
  AppIconOption(
    key: 'map',
    label: 'Map',
    icon: TablerIcons.map,
    category: AppIconCategory.dailyLife,
    searchTerms: ['place', 'where', 'travel'],
  ),
  AppIconOption(
    key: 'toilet_paper',
    label: 'Toilet',
    icon: TablerIcons.toilet_paper,
    category: AppIconCategory.dailyLife,
    searchTerms: ['bathroom', 'toilet'],
  ),
  AppIconOption(
    key: 'traffic_cone',
    label: 'Traffic Cone',
    icon: TablerIcons.traffic_cone,
    category: AppIconCategory.dailyLife,
    searchTerms: ['road', 'safety'],
  ),
  AppIconOption(
    key: 'train',
    label: 'Train',
    icon: TablerIcons.train,
    category: AppIconCategory.dailyLife,
    searchTerms: ['transport', 'travel'],
  ),
  AppIconOption(
    key: 'truck',
    label: 'Truck',
    icon: TablerIcons.truck,
    category: AppIconCategory.dailyLife,
    searchTerms: ['transport', 'delivery'],
  ),
  AppIconOption(
    key: 'wash_machine',
    label: 'Washing Machine',
    icon: TablerIcons.wash_machine,
    category: AppIconCategory.dailyLife,
    searchTerms: ['wash', 'laundry', 'clothes'],
  ),

  // Expanded food and drink.
  AppIconOption(
    key: 'baby_bottle',
    label: 'Bottle',
    icon: TablerIcons.baby_bottle,
    category: AppIconCategory.food,
    searchTerms: ['drink', 'milk'],
  ),
  AppIconOption(
    key: 'bottle',
    label: 'Water Bottle',
    icon: TablerIcons.bottle,
    category: AppIconCategory.food,
    searchTerms: ['water', 'drink'],
  ),
  AppIconOption(
    key: 'bowl',
    label: 'Bowl',
    icon: TablerIcons.bowl,
    category: AppIconCategory.food,
    searchTerms: ['food', 'cereal'],
  ),
  AppIconOption(
    key: 'bread',
    label: 'Bread',
    icon: TablerIcons.bread,
    category: AppIconCategory.food,
    searchTerms: ['toast', 'sandwich'],
  ),
  AppIconOption(
    key: 'burger',
    label: 'Burger',
    icon: TablerIcons.burger,
    category: AppIconCategory.food,
    searchTerms: ['food', 'lunch'],
  ),
  AppIconOption(
    key: 'candy',
    label: 'Candy',
    icon: TablerIcons.candy,
    category: AppIconCategory.food,
    searchTerms: ['sweet', 'treat'],
  ),
  AppIconOption(
    key: 'chef_hat',
    label: 'Cooking',
    icon: TablerIcons.chef_hat,
    category: AppIconCategory.food,
    searchTerms: ['chef', 'cook', 'kitchen'],
  ),
  AppIconOption(
    key: 'cheese',
    label: 'Cheese',
    icon: TablerIcons.cheese,
    category: AppIconCategory.food,
  ),
  AppIconOption(
    key: 'cherry',
    label: 'Cherries',
    icon: TablerIcons.cherry,
    category: AppIconCategory.food,
    searchTerms: ['fruit'],
  ),
  AppIconOption(
    key: 'coffee',
    label: 'Hot Drink',
    icon: TablerIcons.coffee,
    category: AppIconCategory.food,
    searchTerms: ['drink', 'cup'],
  ),
  AppIconOption(
    key: 'cookie',
    label: 'Cookie',
    icon: TablerIcons.cookie,
    category: AppIconCategory.food,
    searchTerms: ['biscuit', 'snack'],
  ),
  AppIconOption(
    key: 'egg',
    label: 'Egg',
    icon: TablerIcons.egg,
    category: AppIconCategory.food,
  ),
  AppIconOption(
    key: 'egg_fried',
    label: 'Fried Egg',
    icon: TablerIcons.egg_fried,
    category: AppIconCategory.food,
  ),
  AppIconOption(
    key: 'glass',
    label: 'Glass',
    icon: TablerIcons.glass,
    category: AppIconCategory.food,
    searchTerms: ['drink', 'water'],
  ),
  AppIconOption(
    key: 'grill',
    label: 'Grill',
    icon: TablerIcons.grill,
    category: AppIconCategory.food,
    searchTerms: ['food', 'cook'],
  ),
  AppIconOption(
    key: 'lemon',
    label: 'Lemon',
    icon: TablerIcons.lemon,
    category: AppIconCategory.food,
    searchTerms: ['fruit'],
  ),
  AppIconOption(
    key: 'lollipop',
    label: 'Lollipop',
    icon: TablerIcons.lollipop,
    category: AppIconCategory.food,
    searchTerms: ['sweet', 'treat'],
  ),
  AppIconOption(
    key: 'meat',
    label: 'Meat',
    icon: TablerIcons.meat,
    category: AppIconCategory.food,
  ),
  AppIconOption(
    key: 'melon',
    label: 'Melon',
    icon: TablerIcons.melon,
    category: AppIconCategory.food,
    searchTerms: ['fruit'],
  ),
  AppIconOption(
    key: 'milk',
    label: 'Milk',
    icon: TablerIcons.milk,
    category: AppIconCategory.food,
    searchTerms: ['drink'],
  ),
  AppIconOption(
    key: 'mug',
    label: 'Mug',
    icon: TablerIcons.mug,
    category: AppIconCategory.food,
    searchTerms: ['drink', 'cup'],
  ),
  AppIconOption(
    key: 'salad',
    label: 'Salad',
    icon: TablerIcons.salad,
    category: AppIconCategory.food,
  ),
  AppIconOption(
    key: 'sausage',
    label: 'Sausage',
    icon: TablerIcons.sausage,
    category: AppIconCategory.food,
  ),
  AppIconOption(
    key: 'soup',
    label: 'Soup',
    icon: TablerIcons.soup,
    category: AppIconCategory.food,
  ),
  AppIconOption(
    key: 'teapot',
    label: 'Teapot',
    icon: TablerIcons.teapot,
    category: AppIconCategory.food,
    searchTerms: ['drink', 'tea'],
  ),

  // Expanded animals.
  AppIconOption(
    key: 'bat',
    label: 'Bat',
    icon: TablerIcons.bat,
    category: AppIconCategory.animals,
  ),
  AppIconOption(
    key: 'butterfly',
    label: 'Butterfly',
    icon: TablerIcons.butterfly,
    category: AppIconCategory.animals,
    searchTerms: ['insect'],
  ),
  AppIconOption(
    key: 'deer',
    label: 'Deer',
    icon: TablerIcons.deer,
    category: AppIconCategory.animals,
  ),
  AppIconOption(
    key: 'fish_bone',
    label: 'Fish Bone',
    icon: TablerIcons.fish_bone,
    category: AppIconCategory.animals,
    searchTerms: ['fish'],
  ),
  AppIconOption(
    key: 'horse',
    label: 'Horse',
    icon: TablerIcons.horse,
    category: AppIconCategory.animals,
  ),
  AppIconOption(
    key: 'pig',
    label: 'Pig',
    icon: TablerIcons.pig,
    category: AppIconCategory.animals,
  ),
  AppIconOption(
    key: 'spider',
    label: 'Spider',
    icon: TablerIcons.spider,
    category: AppIconCategory.animals,
    searchTerms: ['insect', 'bug'],
  ),

  // Expanded play, movement, rewards, and sensory options.
  AppIconOption(
    key: 'ball_baseball',
    label: 'Baseball',
    icon: TablerIcons.ball_baseball,
    category: AppIconCategory.play,
    searchTerms: ['sport', 'ball'],
  ),
  AppIconOption(
    key: 'ball_bowling',
    label: 'Bowling',
    icon: TablerIcons.ball_bowling,
    category: AppIconCategory.play,
    searchTerms: ['sport', 'ball'],
  ),
  AppIconOption(
    key: 'ball_tennis',
    label: 'Tennis',
    icon: TablerIcons.ball_tennis,
    category: AppIconCategory.play,
    searchTerms: ['sport', 'ball'],
  ),
  AppIconOption(
    key: 'ball_volleyball',
    label: 'Volleyball',
    icon: TablerIcons.ball_volleyball,
    category: AppIconCategory.play,
    searchTerms: ['sport', 'ball'],
  ),
  AppIconOption(
    key: 'bow',
    label: 'Bow',
    icon: TablerIcons.bow,
    category: AppIconCategory.play,
    searchTerms: ['dress up', 'present'],
  ),
  AppIconOption(
    key: 'device_tablet',
    label: 'Tablet',
    icon: TablerIcons.device_tablet,
    category: AppIconCategory.play,
    searchTerms: ['ipad', 'screen', 'game'],
  ),
  AppIconOption(
    key: 'dice',
    label: 'Dice',
    icon: TablerIcons.dice,
    category: AppIconCategory.play,
    searchTerms: ['game', 'choice'],
  ),
  AppIconOption(
    key: 'headphones',
    label: 'Headphones',
    icon: TablerIcons.headphones,
    category: AppIconCategory.play,
    searchTerms: ['music', 'sound', 'quiet'],
  ),
  AppIconOption(
    key: 'horse_toy',
    label: 'Toy Horse',
    icon: TablerIcons.horse_toy,
    category: AppIconCategory.play,
    searchTerms: ['toy', 'play'],
  ),
  AppIconOption(
    key: 'paint_filled',
    label: 'Paint Filled',
    icon: TablerIcons.paint_filled,
    category: AppIconCategory.play,
    searchTerms: ['art', 'paint'],
  ),
  AppIconOption(
    key: 'play_football',
    label: 'Football Play',
    icon: TablerIcons.play_football,
    category: AppIconCategory.play,
    searchTerms: ['sport', 'football', 'outside'],
  ),
  AppIconOption(
    key: 'pool',
    label: 'Pool',
    icon: TablerIcons.pool,
    category: AppIconCategory.play,
    searchTerms: ['swim', 'water'],
  ),
  AppIconOption(
    key: 'run',
    label: 'Run',
    icon: TablerIcons.run,
    category: AppIconCategory.play,
    searchTerms: ['movement', 'exercise'],
  ),
  AppIconOption(
    key: 'soccer_field',
    label: 'Soccer Field',
    icon: TablerIcons.soccer_field,
    category: AppIconCategory.play,
    searchTerms: ['football', 'outside', 'sport'],
  ),
  AppIconOption(
    key: 'swimming',
    label: 'Swimming',
    icon: TablerIcons.swimming,
    category: AppIconCategory.play,
    searchTerms: ['pool', 'water'],
  ),
  AppIconOption(
    key: 'walk',
    label: 'Walk',
    icon: TablerIcons.walk,
    category: AppIconCategory.play,
    searchTerms: ['movement', 'outside'],
  ),

  // Expanded health and support.
  AppIconOption(
    key: 'lifebuoy',
    label: 'Support',
    icon: TablerIcons.lifebuoy,
    category: AppIconCategory.health,
    searchTerms: ['help', 'safe'],
  ),
  AppIconOption(
    key: 'yin_yang',
    label: 'Calm',
    icon: TablerIcons.yin_yang,
    category: AppIconCategory.health,
    searchTerms: ['calm', 'balance', 'relax'],
  ),

  // Expanded nature and outdoors.
  AppIconOption(
    key: 'feather',
    label: 'Feather',
    icon: TablerIcons.feather,
    category: AppIconCategory.nature,
    searchTerms: ['bird', 'soft'],
  ),
  AppIconOption(
    key: 'globe',
    label: 'Globe',
    icon: TablerIcons.globe,
    category: AppIconCategory.nature,
    searchTerms: ['world', 'earth'],
  ),
  AppIconOption(
    key: 'kayak',
    label: 'Kayak',
    icon: TablerIcons.kayak,
    category: AppIconCategory.nature,
    searchTerms: ['water', 'outside'],
  ),
  AppIconOption(
    key: 'sailboat',
    label: 'Boat',
    icon: TablerIcons.sailboat,
    category: AppIconCategory.nature,
    searchTerms: ['water', 'sea'],
  ),
  AppIconOption(
    key: 'seeding',
    label: 'Seedling',
    icon: TablerIcons.seeding,
    category: AppIconCategory.nature,
    searchTerms: ['plant', 'grow'],
  ),
  AppIconOption(
    key: 'snowflake',
    label: 'Snowflake',
    icon: TablerIcons.snowflake,
    category: AppIconCategory.nature,
    searchTerms: ['cold', 'winter'],
  ),
  AppIconOption(
    key: 'tent',
    label: 'Tent',
    icon: TablerIcons.tent,
    category: AppIconCategory.nature,
    searchTerms: ['camp', 'outside'],
  ),

  // Expanded people and social icons.
  AppIconOption(
    key: 'friends',
    label: 'Friends',
    icon: TablerIcons.friends,
    category: AppIconCategory.people,
    searchTerms: ['friend', 'together', 'group'],
  ),

  // Expanded objects and creative tools.
  AppIconOption(
    key: 'backhoe',
    label: 'Digger',
    icon: TablerIcons.backhoe,
    category: AppIconCategory.objects,
    searchTerms: ['construction', 'vehicle'],
  ),
  AppIconOption(
    key: 'building_blocks',
    label: 'Blocks',
    icon: TablerIcons.box,
    category: AppIconCategory.objects,
    searchTerms: ['blocks', 'toy', 'build'],
  ),
  AppIconOption(
    key: 'color_picker',
    label: 'Colour Picker',
    icon: TablerIcons.color_picker,
    category: AppIconCategory.objects,
    searchTerms: ['color', 'colour', 'paint'],
  ),
  AppIconOption(
    key: 'photo',
    label: 'Photo',
    icon: TablerIcons.photo,
    category: AppIconCategory.objects,
    searchTerms: ['picture', 'image'],
  ),
];

const Map<String, String> legacyAppIconKeyAliases = {
  // Word learning pack styles.
  'words': 'abc',
  'school': 'school',
  'home': 'home',
  'animals': 'paw',
  'feelings': 'heart',
  'world': 'tree',
  'fun': 'sparkles',

  // Quiz / learning style keys.
  'quiz': 'brain',
  'numbers': 'abacus',
  'science': 'brain',
  'memory': 'brain',

  // When-then option keys.
  'task': 'pencil',
  'book': 'book',
  'clean': 'sparkles',
  'toys': 'lego',
  'outside': 'tree',
  'break': 'cup',
  'homework': 'book',
  'clean_up': 'sparkles',
  'finish_work': 'pencil',
  'calming_sounds': 'music',
  'playtime': 'lego',
  'outside_time': 'tree',

  // Point reward keys.
  'game': 'device_gamepad_2',
  'art': 'palette',
  'outdoors': 'tree',
  'choice': 'star',

  // Voice line keys.
  'voice': 'music',
  'toilet': 'toilet_paper',
  'help': 'heart',
  'hurt': 'first_aid_kit',
  'food': 'tools_kitchen_2',
  'drink': 'bottle',
  'quiet': 'headphones',
  'sick': 'mood_sick',
  'hot': 'sun',
  'cold': 'cloud',
  'happy': 'mood_happy',
  'sad': 'mood_sad',
  'angry': 'mood_angry',
  'worried': 'mood_confuzed',
  'tired': 'bed',
  'finished': 'star',
  'yes': 'star',
  'no': 'shield',
  'again': 'run',
  'teacher': 'school',

  // Schedule activity keys.
  'learning': 'book',
  'movement': 'ball_football',
  'therapy': 'stethoscope',
  'creative': 'palette',
  'arrival': 'backpack',
  'other': 'star',

  // Older profile/icon naming.
  'ball': 'ball_football',
  'car': 'bus',
  'apple': 'apple',
  'dog': 'dog',
  'sun': 'sun',
};

bool appIconKeyExists(String key) {
  final cleanedKey = key.trim();

  if (cleanedKey.isEmpty) return false;

  return appIconCatalog.any((option) => option.key == cleanedKey);
}

String appIconKeyFor(String key, {String fallbackKey = 'star'}) {
  final cleanedKey = key.trim();

  if (appIconKeyExists(cleanedKey)) {
    return cleanedKey;
  }

  final alias = legacyAppIconKeyAliases[cleanedKey];

  if (alias != null && appIconKeyExists(alias)) {
    return alias;
  }

  if (appIconKeyExists(fallbackKey)) {
    return fallbackKey;
  }

  return appIconCatalog.first.key;
}

AppIconOption appIconOptionForKey(String key, {String fallbackKey = 'star'}) {
  final resolvedKey = appIconKeyFor(key, fallbackKey: fallbackKey);

  return appIconCatalog.firstWhere(
    (option) => option.key == resolvedKey,
    orElse: () => appIconCatalog.first,
  );
}

IconData appIconForKey(String key, {String fallbackKey = 'star'}) {
  return appIconOptionForKey(key, fallbackKey: fallbackKey).icon;
}

List<AppIconOption> appIconOptionsForCategory(AppIconCategory category) {
  return appIconCatalog.where((option) => option.category == category).toList();
}

List<AppIconOption> searchAppIcons(String query) {
  return appIconCatalog.where((option) => option.matches(query)).toList();
}
