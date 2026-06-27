import 'package:flutter/material.dart';
import '../models/association_pair.dart';

const List<AssociationPairPack> associationPairPacks = [
  AssociationPairPack(
    id: 'things_that_go_together',
    titleEN: 'Things That Go Together',
    titleGA: 'Rudaí a Théann le Chéile',
    descriptionEN: 'Match each thing with what belongs with it.',
    descriptionGA: 'Meaitseáil gach rud leis an rud a théann leis.',
    pairs: [
      AssociationPair(
        id: 'rabbit_carrot',
        first: AssociationPairItem(
          labelEN: 'Rabbit',
          labelGA: 'Coinín',
          icon: Icons.cruelty_free_rounded,
          color: Color(0xFF8E7CFF),
        ),
        second: AssociationPairItem(
          labelEN: 'Carrot',
          labelGA: 'Cairéad',
          icon: Icons.eco_rounded,
          color: Color(0xFFFF8A65),
        ),
      ),
      AssociationPair(
        id: 'rain_umbrella',
        first: AssociationPairItem(
          labelEN: 'Rain',
          labelGA: 'Báisteach',
          icon: Icons.water_drop_rounded,
          color: Color(0xFF42A5F5),
        ),
        second: AssociationPairItem(
          labelEN: 'Umbrella',
          labelGA: 'Scáth báistí',
          icon: Icons.umbrella_rounded,
          color: Color(0xFF5C6BC0),
        ),
      ),
      AssociationPair(
        id: 'dog_bone',
        first: AssociationPairItem(
          labelEN: 'Dog',
          labelGA: 'Madra',
          icon: Icons.pets_rounded,
          color: Color(0xFF8D6E63),
        ),
        second: AssociationPairItem(
          labelEN: 'Bone',
          labelGA: 'Cnámh',
          icon: Icons.dining_rounded,
          color: Color(0xFFFFB300),
        ),
      ),
      AssociationPair(
        id: 'toothbrush_toothpaste',
        first: AssociationPairItem(
          labelEN: 'Toothbrush',
          labelGA: 'Scuab fiacla',
          icon: Icons.cleaning_services_rounded,
          color: Color(0xFF26A69A),
        ),
        second: AssociationPairItem(
          labelEN: 'Toothpaste',
          labelGA: 'Taos fiacla',
          icon: Icons.medication_liquid_rounded,
          color: Color(0xFF66BB6A),
        ),
      ),
      AssociationPair(
        id: 'shoe_sock',
        first: AssociationPairItem(
          labelEN: 'Shoe',
          labelGA: 'Bróg',
          icon: Icons.directions_walk_rounded,
          color: Color(0xFF78909C),
        ),
        second: AssociationPairItem(
          labelEN: 'Sock',
          labelGA: 'Stoca',
          icon: Icons.checkroom_rounded,
          color: Color(0xFFAB47BC),
        ),
      ),
      AssociationPair(
        id: 'moon_star',
        first: AssociationPairItem(
          labelEN: 'Moon',
          labelGA: 'Gealach',
          icon: Icons.nightlight_round,
          color: Color(0xFF5C6BC0),
        ),
        second: AssociationPairItem(
          labelEN: 'Star',
          labelGA: 'Réalta',
          icon: Icons.star_rounded,
          color: Color(0xFFFFCA28),
        ),
      ),
    ],
  ),
  AssociationPairPack(
    id: 'numbers_and_amounts',
    titleEN: 'Numbers and Amounts',
    titleGA: 'Uimhreacha agus Méideanna',
    descriptionEN: 'Match each number with the same amount.',
    descriptionGA: 'Meaitseáil gach uimhir leis an méid céanna.',
    pairs: [
      AssociationPair(
        id: 'one_one_dot',
        first: AssociationPairItem(
          labelEN: '1',
          labelGA: '1',
          icon: Icons.looks_one_rounded,
          color: Color(0xFF7E57C2),
        ),
        second: AssociationPairItem(
          labelEN: 'One dot',
          labelGA: 'Ponc amháin',
          icon: Icons.circle_rounded,
          color: Color(0xFF26A69A),
        ),
      ),
      AssociationPair(
        id: 'two_two_dots',
        first: AssociationPairItem(
          labelEN: '2',
          labelGA: '2',
          icon: Icons.looks_two_rounded,
          color: Color(0xFFFF7043),
        ),
        second: AssociationPairItem(
          labelEN: 'Two dots',
          labelGA: 'Dhá phonc',
          icon: Icons.more_horiz_rounded,
          color: Color(0xFF42A5F5),
        ),
      ),
      AssociationPair(
        id: 'three_three_dots',
        first: AssociationPairItem(
          labelEN: '3',
          labelGA: '3',
          icon: Icons.looks_3_rounded,
          color: Color(0xFFFFB300),
        ),
        second: AssociationPairItem(
          labelEN: 'Three dots',
          labelGA: 'Trí phonc',
          icon: Icons.blur_on_rounded,
          color: Color(0xFFAB47BC),
        ),
      ),
      AssociationPair(
        id: 'four_four_dots',
        first: AssociationPairItem(
          labelEN: '4',
          labelGA: '4',
          icon: Icons.looks_4_rounded,
          color: Color(0xFF5C6BC0),
        ),
        second: AssociationPairItem(
          labelEN: 'Four dots',
          labelGA: 'Ceithre phonc',
          icon: Icons.grid_view_rounded,
          color: Color(0xFF66BB6A),
        ),
      ),
      AssociationPair(
        id: 'five_five_dots',
        first: AssociationPairItem(
          labelEN: '5',
          labelGA: '5',
          icon: Icons.looks_5_rounded,
          color: Color(0xFFEF5350),
        ),
        second: AssociationPairItem(
          labelEN: 'Five dots',
          labelGA: 'Cúig phonc',
          icon: Icons.apps_rounded,
          color: Color(0xFF26C6DA),
        ),
      ),
      AssociationPair(
        id: 'six_six_dots',
        first: AssociationPairItem(
          labelEN: '6',
          labelGA: '6',
          icon: Icons.looks_6_rounded,
          color: Color(0xFF00897B),
        ),
        second: AssociationPairItem(
          labelEN: 'Six dots',
          labelGA: 'Sé phonc',
          icon: Icons.dialpad_rounded,
          color: Color(0xFFFF8A65),
        ),
      ),
    ],
  ),
];
