import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';
import '../../gestao/screens/denuncia_screen.dart';
import '../../gestao/screens/usuario_screen.dart';
import '../../moderacao/screens/comentario_screen.dart';
import '../../moderacao/screens/doacao_screen.dart';
import '../../moderacao/screens/forum_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  bool _hasNotifications = false;

  void _handleNavigation(int index) {
    Navigator.pop(context); // Fecha o drawer

    Widget? screen;
    switch (index) {
      case 0:
        // Já estamos no Dashboard
        break;
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
      case 6:
        screen = const SettingsPage();
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
    return Scaffold(
      appBar: CustomAppBar(
        hasNotifications: _hasNotifications,
        onNotificationPressed: () {
          // TODO: Implementar navegação para notificações
        },
      ),
      drawer: CustomDrawer(
        onNavigate: _handleNavigation,
      ),
      body: const DashboardHomePage(),
    );
  }
}

// Página inicial do Dashboard
class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dashboard Principal'),
    );
  }
}

// Página de Configurações
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Configurações',
      ),
      drawer: CustomDrawer(
        onNavigate: (index) {
          Navigator.pop(context); // Fecha o drawer
          if (index == 6) return; // Já estamos na página de configurações
          Navigator.pop(context); // Volta para o dashboard
        },
      ),
      body: const Center(
        child: Text('Configurações'),
      ),
    );
  }
}