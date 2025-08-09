import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/error_retry.dart';
import '../../../widgets/loading.dart';
import 'episodes_controller.dart';

class EpisodesPage extends ConsumerStatefulWidget {
  const EpisodesPage({super.key});
  @override
  ConsumerState<EpisodesPage> createState() => _EpisodesPageState();
}

class _EpisodesPageState extends ConsumerState<EpisodesPage> {
  final _scroll = ScrollController();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 200) {
        ref.read(episodesControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(episodesControllerProvider);

    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            Expanded(child: TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Filter by name'))),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: TextField(controller: _codeCtrl, decoration: const InputDecoration(hintText: 'S01E01')),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => ref.read(episodesControllerProvider.notifier)
                .refresh(name: _nameCtrl.text.trim(), code: _codeCtrl.text.trim()),
              child: const Text('Apply'),
            ),
          ]),
        ),
        Expanded(
          child: state.when(
            loading: () => const Center(child: Loading()),
            error: (e, _) => ErrorRetry(message: e.toString(), onRetry: () {
              ref.read(episodesControllerProvider.notifier).refresh();
            }),
            data: (items) => RefreshIndicator(
              onRefresh: () => ref.read(episodesControllerProvider.notifier).refresh(),
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, i) => ListTile(
                  title: Text(items[i].name),
                  subtitle: Text('${items[i].code} • ${items[i].airDate}'),
                  onTap: () => context.push('/episodes/detail/${items[i].id}'),
                ),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: items.length,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
