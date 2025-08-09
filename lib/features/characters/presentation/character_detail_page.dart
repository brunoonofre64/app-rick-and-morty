import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils.dart';
import '../../../widgets/error_retry.dart';
import '../../../widgets/loading.dart';
import '../../../widgets/app_bar_custom.dart';

import '../data/character_model.dart';
import '../data/character_service.dart';
import '../../episodes/data/episode_model.dart';
import '../../episodes/data/episode_service.dart';

final characterDetailProvider =
    FutureProvider.family<Character, int>((ref, id) async {
  final s = ref.read(characterServiceProvider);
  return s.fetchCharacter(id);
});

final firstEpisodeProvider =
    FutureProvider.family<Episode?, Character>((ref, c) async {
  if (c.episodeUrls.isEmpty) return null;
  final eid = idFromUrl(c.episodeUrls.first);
  if (eid == null) return null;
  final epService = ref.read(episodeServiceProvider);
  return epService.fetchEpisode(eid);
});

class CharacterDetailPage extends ConsumerWidget {
  const CharacterDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(characterDetailProvider(id));

    return Scaffold(
      appBar: AppBarCustom.detail(
        onBack: () => Navigator.of(context).maybePop(),
        onProfile: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile tapped')),
          );
        },
      ),
      body: state.when(
        loading: () => const Center(child: Loading()),
        error: (e, _) => ErrorRetry(
          message: e.toString(),
          onRetry: () => ref.refresh(characterDetailProvider(id)),
        ),
        data: (c) {
          final firstEp = ref.watch(firstEpisodeProvider(c));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DetailCardJoined(
                character: c,
                firstEpisode: firstEp,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailCardJoined extends StatelessWidget {
  const _DetailCardJoined({
    required this.character,
    required this.firstEpisode,
  });

  final Character character;
  final AsyncValue<Episode?> firstEpisode;

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'alive':
        return const Color(0xFF25D366); 
      case 'dead':
        return const Color(0xFFD53C2E);
      default:
        return const Color(0xFFFFB020);
    }
  }

  @override
  Widget build(BuildContext context) {
    const radius = 10.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        color: const Color(0xFF87A1FA),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFF73D6F7)),
                  CachedNetworkImage(
                    imageUrl: character.image,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    character.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor(character.status),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${character.status} - ${character.species}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Last known location:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    character.locationName.isEmpty
                        ? 'Unknown'
                        : character.locationName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'First seen in:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  firstEpisode.when(
                    loading: () => const Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white),
                    ),
                    error: (_, __) => const Text(
                      'Unknown',
                      style: TextStyle(color: Colors.white),
                    ),
                    data: (ep) => Text(
                      ep?.name ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
