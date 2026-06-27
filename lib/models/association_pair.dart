import 'package:flutter/material.dart';

class AssociationPairPack {
  final String id;
  final String titleEN;
  final String titleGA;
  final String descriptionEN;
  final String descriptionGA;
  final List<AssociationPair> pairs;

  const AssociationPairPack({
    required this.id,
    required this.titleEN,
    required this.titleGA,
    required this.descriptionEN,
    required this.descriptionGA,
    required this.pairs,
  });
}

class AssociationPair {
  final String id;
  final AssociationPairItem first;
  final AssociationPairItem second;

  const AssociationPair({
    required this.id,
    required this.first,
    required this.second,
  });
}

class AssociationPairItem {
  final String labelEN;
  final String labelGA;
  final IconData icon;
  final Color color;

  const AssociationPairItem({
    required this.labelEN,
    required this.labelGA,
    required this.icon,
    required this.color,
  });
}
