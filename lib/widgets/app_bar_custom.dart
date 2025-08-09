import 'package:flutter/material.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustom._({
    required this.mode,
    this.onBack,
    this.onMenu,
    this.onProfile,
    super.key,
  });

  const AppBarCustom.home({VoidCallback? onMenu, VoidCallback? onProfile})
      : this._(mode: _Mode.home, onMenu: onMenu, onProfile: onProfile);

  const AppBarCustom.detail({VoidCallback? onBack, VoidCallback? onProfile})
      : this._(mode: _Mode.detail, onBack: onBack, onProfile: onProfile);

  final _Mode mode;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final VoidCallback? onProfile;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDetail = mode == _Mode.detail;

    return AppBar(
      elevation: 0,
      backgroundColor: cs.surface,
      centerTitle: true,
      leading: IconButton(
        tooltip: isDetail ? 'Back' : 'Menu',
        icon: Icon(isDetail ? Icons.arrow_back : Icons.menu),
        onPressed: () {
          if (isDetail) {
            if (onBack != null) return onBack!();
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          } else {
            onMenu?.call();
          }
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Troque a imagem se mudar o caminho do asset
          Image.asset(
            'assets/images/logo.png',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.image_not_supported_outlined, size: 22),
          ),
          const SizedBox(width: 8),
          Text(
            'RICK AND MORTY API',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Profile',
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: onProfile,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

enum _Mode { home, detail }
