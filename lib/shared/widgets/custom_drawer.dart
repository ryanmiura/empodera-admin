import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onNavigate;
  final AuthService _authService = AuthService();

  CustomDrawer({
    super.key,
    required this.onNavigate,
  });

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        switch (index) {
          case 0:
            context.push('/dashboard');
            break;
          case 1:
            context.push('/forum');
            break;
          case 2:
            context.push('/doacao');
            break;
          case 3:
            context.push('/comentario');
            break;
          case 4:
            context.push('/denuncia');
            break;
          case 5:
            context.push('/usuario');
            break;
          case 6:
            context.push('/settings');
            break;
          case 7:
            context.push('/moderators_management');
            break;
          case 8:
            context.push('/promote_moderators');
            break;
          case 100:
            context.push('/profile');
            break;
          case 101:
            context.push('/denuncia_post');
            break;
          case 102:
            context.push('/denuncia_doacao');
            break;
          case 103:
            context.push('/denuncia_comentario_post');
            break;
          case 104:
            context.push('/denuncia_comentario_doacao');
            break;
          case 105:
            context.push('/denuncia_chat');
            break;
          case 10:
            context.push('/events');
            break;
          default:
            if (onNavigate != null) onNavigate(index);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(_authService.currentUser?.email ?? 'Moderador'),
                  accountEmail: const Text('Painel de Moderação'),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.person, color: Color(0xFF663572)),
                                  title: const Text('Meu Perfil'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // TODO: Implementar navegação para perfil
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF663572)),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Color(0xFF663572)),
                  title: const Text('Perfil'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/profile');
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                ),
                const Divider(),
const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'DENÚNCIAS',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.article, color: Color(0xFF663572)),
                  title: const Text('Posts'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/denuncia_post');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.card_giftcard, color: Color(0xFF663572)),
                  title: const Text('Doações'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/denuncia_doacao');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.comment, color: Color(0xFF663572)),
                  title: const Text('Comentários em Posts'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/denuncia_comentario_post');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.comment_bank, color: Color(0xFF663572)),
                  title: const Text('Comentários em Doações'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/denuncia_comentario_doacao');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: Color(0xFF663572)),
                  title: const Text('Chats'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/denuncia_chat');
                  },
                ),
                const Divider(),

                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'MODERAÇÃO',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.forum,
                  title: 'Fórum',
                  index: 1,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.card_giftcard,
                  title: 'Doações',
                  index: 2,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.comment,
                  title: 'Comentários',
                  index: 3,
                ),
                const Divider(),

                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'GESTÃO',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.warning,
                  title: 'Denúncias',
                  index: 4,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.event,
                  title: 'Eventos',
                  index: 10,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.people,
                  title: 'Usuários',
                  index: 5,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.person_pin,
                  title: 'Conta Profissional',
                  index: 9,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.admin_panel_settings,
                  title: 'Gerenciar Moderadores',
                  index: 7,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.upgrade,
                  title: 'Promover Moderadores',
                  index: 8,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings,
                  title: 'Configurações',
                  index: 6,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0, top: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                label: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  await _authService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Fecha o Drawer
                    context.go('/login'); // login deve ser replace
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}