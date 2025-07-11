import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';
import '../../gestao/screens/denuncia_screen.dart';
import '../../gestao/screens/usuario_screen.dart';
import '../../moderacao/screens/comentario_screen.dart';
import '../../moderacao/screens/doacao_screen.dart';
import '../../moderacao/screens/forum_screen.dart';
import '../../gestao/screens/settings.dart';
import '../../moderacao/screens/notificacao_screen.dart';
import '../../gestao/screens/moderators_management_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  bool _hasNotifications = false;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget body;
    String appBarTitle;
    switch (_currentIndex) {
      case 1:
        body = const ForumScreen();
        appBarTitle = 'Fórum';
        break;
      case 2:
        body = const DoacaoScreen();
        appBarTitle = 'Doações';
        break;
      case 3:
        body = const ComentarioScreen();
        appBarTitle = 'Comentários';
        break;
      case 4:
        body = const DenunciaScreen();
        appBarTitle = 'Denúncias';
        break;
      case 5:
        body = const UsuarioScreen();
        appBarTitle = 'Usuários';
        break;
      case 6:
        body = const SettingsPage();
        appBarTitle = 'Configurações';
        break;
      case 7:
        body = const ModeratorsManagementScreen();
        appBarTitle = 'Moderadores';
        break;
      default:
        body = const DashboardHomePage();
        appBarTitle = 'Dashboard';
    }
    return Scaffold(
      appBar: CustomAppBar(
        title: appBarTitle,
        hasNotifications: _hasNotifications,
        onNotificationPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NotificacaoScreens(),
            ),
          );
        },
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
      ),
      drawer: CustomDrawer(
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: body,
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
