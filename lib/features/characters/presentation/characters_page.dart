import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/error_retry.dart';
import '../../../widgets/loading.dart';
import 'character_card.dart';
import 'characters_controller.dart';

class CharactersPage extends ConsumerStatefulWidget {
  const CharactersPage({super.key});
  @override
  ConsumerState<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends ConsumerState<CharactersPage> {
  final _scroll = ScrollController();
  final _nameCtrl = TextEditingController();
  String _status = '';
  String _gender = '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 200) {
        ref.read(charactersControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    ref.read(charactersControllerProvider.notifier).applyFilters(
          CharacterQuery(name: _nameCtrl.text.trim(), status: _status, gender: _gender),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charactersControllerProvider);

    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _nameCtrl,
                onSubmitted: (_) => _apply(),
                decoration: const InputDecoration(
                  hintText: 'Search by name',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(onPressed: _apply, icon: const Icon(Icons.tune), label: const Text('Apply')),
          ]),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            _Choice(label: 'Any status', selected: _status.isEmpty, onTap: ()=>setState(()=>_status='')),
            _Choice(label: 'Alive', selected: _status=='alive', onTap: ()=>setState(()=>_status='alive')),
            _Choice(label: 'Dead', selected: _status=='dead', onTap: ()=>setState(()=>_status='dead')),
            _Choice(label: 'Unknown', selected: _status=='unknown', onTap: ()=>setState(()=>_status='unknown')),
            const SizedBox(width: 12),
            _Choice(label: 'Any gender', selected: _gender.isEmpty, onTap: ()=>setState(()=>_gender='')),
            _Choice(label: 'Male', selected: _gender=='male', onTap: ()=>setState(()=>_gender='male')),
            _Choice(label: 'Female', selected: _gender=='female', onTap: ()=>setState(()=>_gender='female')),
            _Choice(label: 'Genderless', selected: _gender=='genderless', onTap: ()=>setState(()=>_gender='genderless')),
          ]),
        ),
        Expanded(
          child: state.when(
            loading: () => const Center(child: Loading()),
            error: (e, _) => ErrorRetry(message: e.toString(), onRetry: () {
              ref.read(charactersControllerProvider.notifier).refresh();
            }),
            data: (items) => RefreshIndicator(
              onRefresh: () => ref.read(charactersControllerProvider.notifier).refresh(),
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemBuilder: (_, i) => CharacterCard(
                  character: items[i],
                  onTap: () => context.push('/characters/detail/${items[i].id}'),
                ),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: items.length,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_)=>onTap()),
  );
}
