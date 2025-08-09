import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/error_retry.dart';
import '../../../widgets/loading.dart';
import '../../../widgets/app_bar_custom.dart';
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
          CharacterQuery(
            name: _nameCtrl.text.trim(),
            status: _status,
            gender: _gender,
          ),
        );
  }

  void _setStatus(String value) {
    setState(() => _status = value.toLowerCase());
    _apply();
  }

  void _setGender(String value) {
    setState(() => _gender = value.toLowerCase());
    _apply();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charactersControllerProvider);

    return Scaffold(
      appBar: AppBarCustom.homeLarge(
        onMenu: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu tapped')),
          );
        },
        onProfile: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile tapped')),
          );
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _nameCtrl,
                onSubmitted: (_) => _apply(),
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  prefixIcon: null,
                  suffixIcon: IconButton(
                    onPressed: _apply,
                    icon: const Icon(Icons.search, color: Colors.white70),
                    tooltip: 'Search',
                  ),
                  border: const UnderlineInputBorder(),
                ),
              ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                _Choice(
                  label: 'Any status',
                  selected: _status.isEmpty,
                  onTap: () => _setStatus(''),
                ),
                _Choice(
                  label: 'Alive',
                  selected: _status == 'alive',
                  onTap: () => _setStatus('alive'),
                ),
                _Choice(
                  label: 'Dead',
                  selected: _status == 'dead',
                  onTap: () => _setStatus('dead'),
                ),
                _Choice(
                  label: 'Unknown',
                  selected: _status == 'unknown',
                  onTap: () => _setStatus('unknown'),
                ),
                const SizedBox(width: 12),
                _Choice(
                  label: 'Any gender',
                  selected: _gender.isEmpty,
                  onTap: () => _setGender(''),
                ),
                _Choice(
                  label: 'Male',
                  selected: _gender == 'male',
                  onTap: () => _setGender('male'),
                ),
                _Choice(
                  label: 'Female',
                  selected: _gender == 'female',
                  onTap: () => _setGender('female'),
                ),
                _Choice(
                  label: 'Genderless',
                  selected: _gender == 'genderless',
                  onTap: () => _setGender('genderless'),
                ),
              ]),
            ),

            Expanded(
              child: state.when(
                loading: () => const Center(child: Loading()),
                error: (e, _) => ErrorRetry(
                  message: e.toString(),
                  onRetry: () {
                    ref.read(charactersControllerProvider.notifier).refresh();
                  },
                ),
                data: (items) => RefreshIndicator(
                  onRefresh: () =>
                      ref.read(charactersControllerProvider.notifier).refresh(),
                  child: ListView.separated(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemBuilder: (_, i) => CharacterCard(
                      character: items[i],
                      onTap: () =>
                          context.push('/characters/detail/${items[i].id}'),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: items.length,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );
}
