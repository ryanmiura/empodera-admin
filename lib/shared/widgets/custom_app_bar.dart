import 'package:flutter/material.dart';
import '../../features/gestao/screens/denuncia_screen.dart';
import '../../features/gestao/screens/usuario_screen.dart';
import '../../features/moderacao/screens/comentario_screen.dart';
import '../../features/moderacao/screens/doacao_screen.dart';
import '../../features/moderacao/screens/forum_screen.dart';
import '../../services/auth_service.dart';
import 'custom_drawer.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final bool hasNotifications;
  final bool showDrawer;
  final Function(int)? onNavigate;

  const CustomAppBar({
    super.key,
    this.title = 'Moderação',
    this.onMenuPressed,
    this.onNotificationPressed,
    this.hasNotifications = false,
    this.showDrawer = true,
    this.onNavigate,
  });

  void _handleNavigation(BuildContext context, int index) {
    Navigator.pop(context); // Fecha o drawer

    if (onNavigate != null) {
      onNavigate!(index);
      return;
    }

    // Navegação padrão se onNavigate não for fornecido
    Widget? screen;
    switch (index) {
      case 1:
        screen = const ForumScreen();
        break;
      case 2:
        screen = const DoacaoScreen();
        break;
      case 3:
        screen = const ComentarioScreen();
        break;
      case 4:
        screen = const DenunciaScreen();
        break;
      case 5:
        screen = const UsuarioScreen();
        break;
    }

    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFC191CD),
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuPressed ?? () {
            if (showDrawer) {
              Scaffold.of(context).openDrawer();
            }
          },
        ),
      ),
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              'assets/logo_horizontal.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: onNotificationPressed,
            ),
            if (hasNotifications)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 