import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          if (index == 8) {
            Navigator.of(context).pushNamed('/promote_moderators');
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
      body: body,
    );
  }
}



class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tipos = [
      {
        'titulo': 'Posts',
        'icone': Icons.article_outlined,
        'cor': Colors.purple,
        'contentType': 'post',
        'descricao': 'Denúncias relacionadas a posts publicados na plataforma.',
        'tela': '/denuncia_post',
      },
      {
        'titulo': 'Doações',
        'icone': Icons.volunteer_activism_outlined,
        'cor': Colors.orange,
        'contentType': 'donation',
        'descricao': 'Denúncias sobre doações cadastradas.',
        'tela': '/denuncia_doacao',
      },
      {
        'titulo': 'Comentários em Posts',
        'icone': Icons.comment_outlined,
        'cor': Colors.blue,
        'contentType': 'comment',
        'descricao': 'Denúncias de comentários feitos em posts.',
        'tela': '/denuncia_comentario_post',
      },
      {
        'titulo': 'Comentários em Doações',
        'icone': Icons.chat_bubble_outline,
        'cor': Colors.green,
        'contentType': 'donation_comment',
        'descricao': 'Denúncias de comentários feitos em doações.',
        'tela': '/denuncia_comentario_doacao',
      },
      {
        'titulo': 'Chats',
        'icone': Icons.forum_outlined,
        'cor': Colors.red,
        'contentType': 'chat',
        'descricao': 'Denúncias de conversas privadas (chat).',
        'tela': '/denuncia_chat',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Visão Geral das Denúncias',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF663572),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Acompanhe o volume e tendências das denúncias por tipo.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: tipos.length,
                      itemBuilder: (context, idx) {
                        final tipo = tipos[idx];
                        return ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 260, minHeight: 180),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              final rota = tipo['tela'] as String?;
                              if (rota != null) {
                                Navigator.of(context).pushNamed(rota);
                              }
                            },
                            child: _DenunciaCardFirestore(
                              titulo: tipo['titulo'] as String,
                              icone: tipo['icone'] as IconData,
                              cor: tipo['cor'] as Color,
                              contentType: tipo['contentType'] as String,
                              descricao: tipo['descricao'] as String,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DenunciaCardFirestore extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Color cor;
  final String contentType;
  final String descricao;

  const _DenunciaCardFirestore({
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.contentType,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final agora = DateTime.now();
    final seteDiasAtras = agora.subtract(const Duration(days: 7));

    final totalQuery = firestore
        .collection('report')
        .where('contentType', isEqualTo: contentType);

    final ultimos7diasQuery = firestore
        .collection('report')
        .where('contentType', isEqualTo: contentType)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(seteDiasAtras));

    return FutureBuilder<List<int>>(
      future: Future.wait([
        totalQuery.count().get().then((v) => v.count ?? 0),
        ultimos7diasQuery.count().get().then((v) => v.count ?? 0),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Loga o erro completo no console
          debugPrint('Erro ao carregar card de denúncias:\n${snapshot.error}');
          return Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red[300], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Erro ao carregar',
                    style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Card(
            child: Center(
              child: Text('Sem dados'),
            ),
          );
        }
        final total = snapshot.data![0];
        final ultimos7dias = snapshot.data![1];

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // CircleAvatar(
                    //   backgroundColor: cor.withOpacity(0.15),
                    //   child: Icon(icone, color: cor, size: 28),
                    // ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: cor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tooltip(
                      message: descricao,
                      child: const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$total',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: cor,
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey[300]),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.trending_up, size: 18, color: Colors.black45),
                      const SizedBox(width: 4),
                      const Text(
                        'Últimos 7 dias: ',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      Text(
                        '$ultimos7dias',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: cor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
