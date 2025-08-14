import 'package:go_router/go_router.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/profile/screens/user_profile_screen.dart';
import '../features/denuncias/denuncia_post_screen.dart';
import '../features/denuncias/denuncia_doacao_screen.dart';
import '../features/denuncias/denuncia_comentario_post_screen.dart';
import '../features/denuncias/denuncia_comentario_doacao_screen.dart';
import '../features/denuncias/denuncia_chat_screen.dart';
import '../features/moderacao/screens/forum_screen.dart';
import '../features/moderacao/screens/doacao_screen.dart';
import '../features/moderacao/screens/comentario_screen.dart';
import '../features/gestao/screens/denuncia_screen.dart';
import '../features/gestao/screens/usuario_screen.dart';
import '../features/gestao/screens/moderators_management_screen.dart';
import '../features/gestao/screens/promote_moderators_screen.dart';
import '../features/gestao/screens/settings.dart';
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const UserProfileScreen(),
    ),
    GoRoute(
      path: '/denuncia_post',
      builder: (context, state) => const DenunciaPostScreen(),
    ),
    GoRoute(
      path: '/denuncia_doacao',
      builder: (context, state) => const DenunciaDoacaoScreen(),
    ),
    GoRoute(
      path: '/denuncia_comentario_post',
      builder: (context, state) => const DenunciaComentarioPostScreen(),
    ),
    GoRoute(
      path: '/denuncia_comentario_doacao',
      builder: (context, state) => const DenunciaComentarioDoacaoScreen(),
    ),
    GoRoute(
      path: '/denuncia_chat',
      builder: (context, state) => const DenunciaChatScreen(),
    ),
    GoRoute(
      path: '/forum',
      builder: (context, state) => const ForumScreen(),
    ),
    GoRoute(
      path: '/doacao',
      builder: (context, state) => const DoacaoScreen(),
    ),
    GoRoute(
      path: '/comentario',
      builder: (context, state) => const ComentarioScreen(),
    ),
    GoRoute(
      path: '/denuncia',
      builder: (context, state) => const DenunciaScreen(),
    ),
    GoRoute(
      path: '/usuario',
      builder: (context, state) => const UsuarioScreen(),
    ),
    GoRoute(
      path: '/moderators_management',
      builder: (context, state) => const ModeratorsManagementScreen(),
    ),
    GoRoute(
      path: '/promote_moderators',
      builder: (context, state) => const PromoteModeratorsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
  // Você pode adicionar redirects, guards, etc. aqui
);
