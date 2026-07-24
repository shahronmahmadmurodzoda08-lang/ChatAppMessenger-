import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ChatApp());
}

// ============================================================
// FIREBASE CONFIG
// ============================================================
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions барои ин платформа ҳоло танзим нашудааст. '
      'Лутфан аввал дар FlutLab/Web озмоиш кунед.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDO8rw1NvSAosX7Z0Nj4_eV1hkBAB6OW1A',
    authDomain: 'chatapp-57fb2.firebaseapp.com',
    projectId: 'chatapp-57fb2',
    storageBucket: 'chatapp-57fb2.firebasestorage.app',
    messagingSenderId: '712168365642',
    appId: '1:712168365642:web:6ea9ac370500cc8b6310b8',
    measurementId: 'G-D78QHLSTVN',
  );
}

// ============================================================
// APP ROOT
// ============================================================
class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}

// ============================================================
// THEME & COLORS
// ============================================================
class AppColors {
  static const Color background = Color(0xFF060B14);
  static const Color backgroundSecondary = Color(0xFF0B121F);
  static const Color surface = Color(0xFF101826);
  static const Color glassFill = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color neonEmerald = Color(0xFF12F7B5);
  static const Color neonCyan = Color(0xFF22D3EE);
  static const Color textPrimary = Color(0xFFEAF2F5);
  static const Color textSecondary = Color(0xFF8A9BAE);

  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonEmerald, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonEmerald,
        secondary: AppColors.neonCyan,
        surface: AppColors.surface,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}

// ============================================================
// УТИЛИТАИ УМУМӢ
// ============================================================
void showComingSoonSnack(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$feature ба зудӣ дастрас мешавад'),
      backgroundColor: AppColors.surface,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ============================================================
// МОДЕЛИ ПАЁМ (Firestore)
// ============================================================
class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final bool isAI;
  final DateTime? timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.isAI,
    this.timestamp,
  });

  factory ChatMessage.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ChatMessage(
      id: doc.id,
      text: (data['text'] ?? '') as String,
      senderId: (data['senderId'] ?? '') as String,
      isAI: (data['isAI'] ?? false) as bool,
      timestamp: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class ChatConversation {
  final String id;
  final String name;
  final IconData avatarIcon;
  final bool isAIChat;

  const ChatConversation({
    required this.id,
    required this.name,
    required this.avatarIcon,
    this.isAIChat = false,
  });
}

class AppChats {
  static const aiAssistant = ChatConversation(
    id: 'ai_assistant',
    name: 'AI Ассистент',
    avatarIcon: Icons.auto_awesome_rounded,
    isAIChat: true,
  );
  static const general = ChatConversation(
    id: 'general',
    name: 'Чати умумӣ',
    avatarIcon: Icons.groups_rounded,
    isAIChat: false,
  );
  static const List<ChatConversation> all = [aiAssistant, general];
}

class MockAIReplies {
  static const List<String> replies = [
    'Фаҳмидам! Ин дархостро дар лаҳзаи пайвастшавӣ ба Gemini API коркард мекунам.',
    'Хуб, ман ин масъаларо таҳлил карда, посух медиҳам.',
    'Ин фикри ҷолиб аст! Биёед дар бораи он бештар сӯҳбат кунем.',
    'Дархости шумо қабул шуд. Оё маълумоти иловагӣ доред?',
    'Ман ин ҷо ҳастам, то ба шумо кӯмак кунам. Лутфан идома диҳед.',
  ];
}

// ============================================================
// GLASSMORPHISM & БРЕНДИНГ
// ============================================================
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool glow;
  final Color glowColor;
  final double blur;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.glow = false,
    this.glowColor = AppColors.neonEmerald,
    this.blur = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.35),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: AppColors.glassBorder, width: 1.2),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.neonGradient,
        boxShadow: [
          BoxShadow(color: AppColors.neonEmerald.withOpacity(0.5), blurRadius: 16, spreadRadius: 0.5),
        ],
      ),
      child: Icon(Icons.bolt_rounded, color: AppColors.background, size: size * 0.6),
    );
  }
}

class NeonBackdrop extends StatelessWidget {
  final Widget child;
  const NeonBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.background, AppColors.backgroundSecondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(top: -80, left: -60, child: _blurCircle(AppColors.neonEmerald.withOpacity(0.25), 220)),
        Positioned(bottom: -100, right: -70, child: _blurCircle(AppColors.neonCyan.withOpacity(0.20), 260)),
        Positioned.fill(child: child),
      ],
    );
  }

  Widget _blurCircle(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

/// Тугмаи шинокунандаи неон бо аломати "+" — ҳамеша дар кунҷи поёни рост
/// (тавассути Scaffold.floatingActionButton + FloatingActionButtonLocation.endFloat),
/// айнан мисли WhatsApp.
class NeonFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  const NeonFab({super.key, required this.onPressed, this.icon = Icons.add_rounded});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.neonGradient,
        boxShadow: [
          BoxShadow(color: AppColors.neonEmerald.withOpacity(0.5), blurRadius: 20, spreadRadius: 1),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(icon, color: AppColors.background, size: 26),
        ),
      ),
    );
  }
}

// ============================================================
// AUTH GATE
// ============================================================
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<User?> _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = _ensureSignedIn();
  }

  Future<User?> _ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return auth.currentUser;
    final credential = await auth.signInAnonymously();
    return credential.user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _authFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoading();
        }
        if (snapshot.hasError || snapshot.data == null) {
          return _buildError(snapshot.error);
        }
        return const ChatListScreen();
      },
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NeonBackdrop(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 56),
              const SizedBox(height: 22),
              const CircularProgressIndicator(color: AppColors.neonEmerald),
              const SizedBox(height: 16),
              const Text('Пайвастшавӣ ба Firebase...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NeonBackdrop(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.neonCyan, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Пайвастшавӣ ба Firebase ноком шуд',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Санҷед, ки дар Firebase Console → Authentication → Sign-in method '
                    'усули "Anonymous" фаъол аст.\n\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonEmerald,
                      foregroundColor: AppColors.background,
                    ),
                    onPressed: () => setState(() => _authFuture = _ensureSignedIn()),
                    child: const Text('Аз нав кӯшиш кунед'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ЭКРАНИ АСОСӢ — Tabs + FAB ба услуби WhatsApp
// ============================================================
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openNewChatSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewChatSheet(),
    );
  }

  // Тугмаи шинокунанда — танҳо дар "Чатҳо" ва "Зангҳо" нишон дода мешавад,
  // дар "Танзимот" пинҳон аст (айнан мисли WhatsApp).
  Widget? _buildFab() {
    switch (_tabController.index) {
      case 0:
        return NeonFab(onPressed: _openNewChatSheet);
      case 1:
        return NeonFab(onPressed: () => showComingSoonSnack(context, 'Занг'));
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: NeonBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _ChatsTab(),
                    _CallsTab(),
                    _SettingsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppLogo(),
          Row(
            children: [
              _iconButton(Icons.search_rounded, onTap: () => showComingSoonSnack(context, 'Ҷустуҷӯ')),
              const SizedBox(width: 10),
              _iconButton(Icons.more_vert_rounded, onTap: () => showComingSoonSnack(context, 'Феҳристи иловагӣ')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: 14,
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }

  // TabBar-и болои феҳрист — "Чатҳо / Зангҳо / Танзимот", айнан ҷои
  // ин се бахши WhatsApp-ро иваз мекунад (навигатсияи шинос).
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(gradient: AppColors.neonGradient, borderRadius: BorderRadius.circular(12)),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.background,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Чатҳо'),
            Tab(text: 'Зангҳо'),
            Tab(text: 'Танзимот'),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// БАХШИ "ЧАТҲО" (феҳристи чат ба тарзи WhatsApp)
// ============================================================
class _ChatsTab extends StatelessWidget {
  const _ChatsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 90),
      children: const [
        _ChatTile(conversation: AppChats.aiAssistant, highlighted: true),
        SizedBox(height: 6),
        _ChatTile(conversation: AppChats.general),
      ],
    );
  }
}

/// Сатри чат — сохтори дуқабата (ном+вақт, паём+бирча) айнан мисли WhatsApp:
/// аватар дар чап, ном ва вақт дар сатри боло, паёми охирин дар сатри поён.
class _ChatTile extends StatelessWidget {
  final ChatConversation conversation;
  final bool highlighted;
  const _ChatTile({required this.conversation, this.highlighted = false});

  Stream<QuerySnapshot<Map<String, dynamic>>> get _lastMessageStream => FirebaseFirestore
      .instance
      .collection('chats')
      .doc(conversation.id)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .limit(1)
      .snapshots();

  String _formatTime(DateTime? t) {
    if (t == null) return '';
    final now = DateTime.now();
    if (now.difference(t).inDays >= 1) return '${t.day}/${t.month}';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(highlighted ? 18 : 10),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: conversation)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: highlighted
              ? BoxDecoration(
                  color: AppColors.neonEmerald.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.neonEmerald.withOpacity(0.3)),
                )
              : const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.glassBorder, width: 0.6)),
                ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: conversation.isAIChat ? AppColors.neonGradient : null,
                  color: conversation.isAIChat ? null : AppColors.surface,
                  border: conversation.isAIChat ? null : Border.all(color: AppColors.glassBorder),
                ),
                child: Icon(
                  conversation.avatarIcon,
                  color: conversation.isAIChat ? AppColors.background : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _lastMessageStream,
                  builder: (context, snapshot) {
                    String preview = conversation.isAIChat ? 'Ба ман чизе нависед...' : 'Оғози сӯҳбат кунед';
                    String time = '';
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final data = snapshot.data!.docs.first.data();
                      preview = (data['text'] ?? preview) as String;
                      time = _formatTime((data['createdAt'] as Timestamp?)?.toDate());
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // САТРИ БОЛО: ном (+ бирчаи AI) ......... вақт
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      conversation.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15.5,
                                      ),
                                    ),
                                  ),
                                  if (conversation.isAIChat) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.neonGradient,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'AI',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              time,
                              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 11.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        // САТРИ ПОЁН: паёми охирин
                        Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                        ),
                      ],
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

/// Феҳристи интихоби чат ҳангоми пахши тугмаи "+" (мисли пахши FAB дар WhatsApp)
class _NewChatSheet extends StatelessWidget {
  const _NewChatSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(color: AppColors.glassBorder, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const Text('Чати нав', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            ...AppChats.all.map(
              (c) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: c.isAIChat ? AppColors.neonGradient : null,
                    color: c.isAIChat ? null : AppColors.surface,
                    border: c.isAIChat ? null : Border.all(color: AppColors.glassBorder),
                  ),
                  child: Icon(c.avatarIcon, color: c.isAIChat ? AppColors.background : AppColors.textSecondary, size: 20),
                ),
                title: Text(c.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: c)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// БАХШИ "ЗАНГҲО" (ҳолати холии воқеӣ, мисли WhatsApp вақте занге нест)
// ============================================================
class _CallsTab extends StatelessWidget {
  const _CallsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.call_outlined, color: AppColors.textSecondary.withOpacity(0.5), size: 56),
            const SizedBox(height: 16),
            const Text('Ягон занг нест', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Зангҳои шумо дар ин ҷо намоён мешаванд',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// БАХШИ "ТАНЗИМОТ" (профили корбари беном + баромадан)
// ============================================================
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '—';
    final shortId = uid.length > 12 ? uid.substring(0, 12) : uid;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.neonGradient),
                child: const Icon(Icons.person_rounded, color: AppColors.background, size: 36),
              ),
              const SizedBox(height: 14),
              const Text('Корбари беном', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text('ID: $shortId...', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassContainer(
          borderRadius: 16,
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.neonCyan),
            title: const Text('Баромадан', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            onTap: () => _signOut(context),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ЭКРАНИ ДОХИЛИ ЧАТ
// ============================================================
class ChatDetailScreen extends StatefulWidget {
  final ChatConversation conversation;
  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAITyping = false;

  CollectionReference<Map<String, dynamic>> get _messagesRef => FirebaseFirestore.instance
      .collection('chats')
      .doc(widget.conversation.id)
      .collection('messages');

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    _controller.clear();

    await _messagesRef.add({
      'text': text,
      'senderId': uid,
      'isAI': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _scrollToBottom();

    if (widget.conversation.isAIChat) {
      _simulateAIReply();
    }
  }

  void _simulateAIReply() {
    setState(() => _isAITyping = true);
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 1400), () async {
      if (!mounted) return;
      final reply = MockAIReplies.replies[DateTime.now().millisecond % MockAIReplies.replies.length];
      await _messagesRef.add({
        'text': reply,
        'senderId': 'ai_bot',
        'isAI': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() => _isAITyping = false);
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final convo = widget.conversation;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: NeonBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(convo),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _messagesRef.orderBy('createdAt', descending: false).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Хатои Firestore: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.neonEmerald));
                    }
                    final docs = snapshot.data!.docs;
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      itemCount: docs.length + (_isAITyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isAITyping && index == docs.length) {
                          return const TypingBubble();
                        }
                        final message = ChatMessage.fromDoc(docs[index]);
                        return MessageBubble(message: message, isMe: message.senderId == currentUid);
                      },
                    );
                  },
                ),
              ),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  // Сарлавҳа бо ду тугмаи занг (video/voice), айнан ба тарзи WhatsApp
  Widget _buildHeader(ChatConversation convo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
      child: GlassContainer(
        borderRadius: 18,
        glow: convo.isAIChat,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: convo.isAIChat ? AppColors.neonGradient : null,
                color: convo.isAIChat ? null : AppColors.surface,
                border: convo.isAIChat ? null : Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(
                convo.avatarIcon,
                color: convo.isAIChat ? AppColors.background : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    convo.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    convo.isAIChat ? 'Ҳамеша дастрас' : 'Firestore · вақти воқеӣ',
                    style: const TextStyle(color: AppColors.neonEmerald, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => showComingSoonSnack(context, 'Занги видео'),
              icon: const Icon(Icons.videocam_rounded, color: AppColors.textSecondary, size: 22),
            ),
            IconButton(
              onPressed: () => showComingSoonSnack(context, 'Занг'),
              icon: const Icon(Icons.call_rounded, color: AppColors.textSecondary, size: 19),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Паём нависед...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.neonGradient),
                child: const Icon(Icons.arrow_upward_rounded, color: AppColors.background, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ВИҶЕТҲОИ ПАЁМ
// ============================================================
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final isAI = message.isAI;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isAI)
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.neonCyan),
                    const SizedBox(width: 4),
                    Text('AI Assistant', style: TextStyle(fontSize: 10, color: AppColors.neonCyan.withOpacity(0.9))),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: isMe ? AppColors.neonGradient : null,
                color: isMe ? null : AppColors.glassFill,
                border: isMe
                    ? null
                    : Border.all(color: isAI ? AppColors.neonCyan.withOpacity(0.4) : AppColors.glassBorder),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: isAI ? [BoxShadow(color: AppColors.neonCyan.withOpacity(0.15), blurRadius: 12)] : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? AppColors.background : AppColors.textPrimary,
                  fontSize: 14.5,
                  height: 1.3,
                  fontWeight: isMe ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? t) {
    if (t == null) return '...';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          border: Border.all(color: AppColors.neonCyan.withOpacity(0.4)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = (_controller.value + (i * 0.2)) % 1.0;
                final scale = 0.5 + (0.5 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0));
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.neonGradient),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
