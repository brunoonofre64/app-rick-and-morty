import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils.dart';
import '../../../widgets/error_retry.dart';
import '../../../widgets/loading.dart';
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
  final id = idFromUrl(c.episodeUrls.first);
  if (id == null) return null;
  final epService = ref.read(episodeServiceProvider);
  return epService.fetchEpisode(id);
});

class CharacterDetailPage extends ConsumerWidget {
  const CharacterDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(characterDetailProvider(id));

    Color dot(String s) {
      switch (s.toLowerCase()) {
        case 'alive': return Colors.greenAccent;
        case 'dead': return Colors.redAccent;
        default: return Colors.orangeAccent;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rick and Morty API')),
      body: state.when(
        loading: () => const Center(child: Loading()),
        error: (e, _) => ErrorRetry(message: e.toString(), onRetry: () {
          ref.refresh(characterDetailProvider(id));
        }),
        data: (c) {
          final firstEp = ref.watch(firstEpisodeProvider(c));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(imageUrl: c.image, height: 260, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Row(children: [
                    Icon(Icons.circle, size: 12, color: dot(c.status)),
                    const SizedBox(width: 8),
                    Text('${c.status} - ${c.species}'),
                  ]),
                  const SizedBox(height: 20),
                  Text('Last known location:', style: Theme.of(context).textTheme.titleMedium),
                  Text(c.locationName),
                  const SizedBox(height: 16),
                  Text('First seen in:', style: Theme.of(context).textTheme.titleMedium),
                  firstEp.when(
                    loading: () => const Text('Loading...'),
                    error: (_, __) => const Text('Unknown'),
                    data: (ep) => Text(ep?.name ?? 'Unknown'),
                  ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}
