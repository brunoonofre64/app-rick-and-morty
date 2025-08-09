import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../data/character_model.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({super.key, required this.character, this.onTap});
  final Character character;
  final VoidCallback? onTap;

  Color _dot(String s) {
    switch (s.toLowerCase()) {
      case 'alive': return Colors.greenAccent;
      case 'dead': return Colors.redAccent;
      default: return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: character.image, width: double.infinity, height: 180, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(character.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.circle, size: 10, color: _dot(character.status)),
                const SizedBox(width: 6),
                Text('${character.status} • ${character.species}'),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
