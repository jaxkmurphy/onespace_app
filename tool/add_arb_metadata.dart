import 'dart:convert';
import 'dart:io';

void main() {
  const paths = ['lib/l10n/app_en.arb', 'lib/l10n/app_ga.arb'];

  for (final path in paths) {
    final file = File(path);
    final source = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    final output = <String, dynamic>{};

    for (final entry in source.entries) {
      if (entry.key.startsWith('@@')) {
        output[entry.key] = entry.value;
      }
    }

    for (final entry in source.entries) {
      final key = entry.key;

      if (key.startsWith('@')) continue;

      output[key] = entry.value;

      final existingMetadata = source['@$key'];
      final metadata =
          existingMetadata is Map
              ? Map<String, dynamic>.from(existingMetadata)
              : <String, dynamic>{};

      metadata.putIfAbsent(
        'description',
        () => 'Text used in the app for ${_readableName(key)}.',
      );

      if (entry.value is String) {
        final message = entry.value as String;
        final existingPlaceholders = metadata['placeholders'];
        final existingDefinitions =
            existingPlaceholders is Map
                ? Map<String, dynamic>.from(existingPlaceholders)
                : <String, dynamic>{};
        final placeholders = <String, dynamic>{};

        for (final placeholder in _placeholderNames(message)) {
          final existingDefinition = existingDefinitions[placeholder];
          final definition =
              existingDefinition is Map
                  ? Map<String, dynamic>.from(existingDefinition)
                  : <String, dynamic>{};

          if (_isNumericIcuPlaceholder(message, placeholder)) {
            definition.putIfAbsent('type', () => 'num');
          }

          placeholders[placeholder] = definition;
        }

        if (placeholders.isNotEmpty) {
          metadata['placeholders'] = placeholders;
        } else {
          metadata.remove('placeholders');
        }
      }

      output['@$key'] = metadata;
    }

    const encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync('${encoder.convert(output)}\n');

    print('Metadata updated: $path');
  }
}

Set<String> _placeholderNames(String message) {
  final names = <String>{};
  final pattern = RegExp(r'\{([A-Za-z_][A-Za-z0-9_]*)\s*(?:,|\})');

  for (final match in pattern.allMatches(message)) {
    if (match.start > 0 &&
        RegExp(r'[A-Za-z0-9_=]').hasMatch(message[match.start - 1])) {
      continue;
    }

    final name = match.group(1);
    if (name != null) names.add(name);
  }

  return names;
}

bool _isNumericIcuPlaceholder(String message, String placeholder) {
  final escapedName = RegExp.escape(placeholder);
  return RegExp(
    '\\{$escapedName\\s*,\\s*(?:plural|selectordinal)\\s*,',
  ).hasMatch(message);
}

String _readableName(String key) {
  return key
      .replaceAll('_', ' ')
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .toLowerCase();
}
