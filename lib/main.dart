import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChatApp());
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
      home: const ChatListScreen(),
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
  static const Color glassFill = Color(0x14FFFFFF); // сафед 8%
  static const Color glassBorder = Color(0x26FFFFFF); // сафед 15%
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
// MODELS
// ============================================================

/// Модели ягонаи паём — ҳам барои паёмҳои корбар ва ҳам паёмҳои AI-бот.
/// isMe   -> паём аз тарафи корбари ҷорӣ фиристода шудааст
/// isAI   -> паём аз тарафи AI Assistant омадааст
class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final bool isAI;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    this.isAI = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Модели як суҳбат (чат) — метавонад суҳбати AI ё суҳбати оддии корбар бошад
class ChatConversation {
  final String id;
  final String name;
  final IconData avatarIcon;
  final bool isAIChat;
  String lastMessage;
  DateTime lastTime;
  bool online;
  final List<ChatMessage> messages;

  ChatConversation({
    required this.id,
    required this.name,
    required this.avatarIcon,
    this.isAIChat = false,
    this.lastMessage = '',
    DateTime? lastTime,
    this.online = false,
    List<ChatMessage>? messages,
  })  : lastTime = lastTime ?? DateTime.now(),
        messages = messages ?? [];
}

// ============================================================
// MOCK / LOCAL DATA (то пайвастшавии Firebase истифода мешавад)
// ============================================================
class MockData {
  static List<ChatConversation> getConversations() {
    return [
      ChatConversation(
        id: 'ai_assistant',
        name: 'AI Ассистент',
        avatarIcon: Icons.auto_awesome_rounded,
        isAIChat: true,
        online: true,
        lastMessage: 'Ба шумо чӣ тавр кӯмак карда метавонам?',
        messages: [
          ChatMessage(
            id: 'm1',
            text:
                'Салом! Ман ёрдамчии сунъии ҳушманди шумо ҳастам. Чӣ гуна метавонам кӯмак кунам?',
            isMe: false,
            isAI: true,
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
        ],
      ),
      ChatConversation(
        id: 'u1',
        name: 'Фаридун Раҳимов',
        avatarIcon: Icons.person_rounded,
        online: true,
        lastMessage: 'Хуб, пагоҳ вомехӯрем',
        messages: [
          ChatMessage(
              id: 'u1m1',
              text: 'Салом, корҳо чӣ хел?',
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(hours: 2))),
          ChatMessage(
              id: 'u1m2',
              text: 'Хуб, ташаккур! Ту чӣ?',
              isMe: true,
              timestamp: DateTime.now().subtract(const Duration(hours: 2))),
          ChatMessage(
              id: 'u1m3',
              text: 'Хуб, пагоҳ вомехӯрем',
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(hours: 1))),
        ],
      ),
      ChatConversation(
        id: 'u2',
        name: 'Мадина Каримова',
        avatarIcon: Icons.person_rounded,
        online: false,
        lastMessage: 'Раҳмат барои файл',
        messages: [
          ChatMessage(
              id: 'u2m1',
              text: 'Файлро фиристодед?',
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(days: 1))),
          ChatMessage(
              id: 'u2m2',
              text: 'Бале, дар боло',
              isMe: true,
              timestamp: DateTime.now().subtract(const Duration(days: 1))),
          ChatMessage(
              id: 'u2m3',
              text: 'Раҳмат барои файл',
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(hours: 20))),
        ],
      ),
      ChatConversation(
        id: 'u3',
        name: 'Гурӯҳи Дизайн',
        avatarIcon: Icons.groups_rounded,
        online: false,
        lastMessage: 'Ҷаласа соати 15:00',
        messages: [
          ChatMessage(
              id: 'u3m1',
              text: 'Ҷаласа соати 15:00',
              isMe: false,
              timestamp: DateTime.now().subtract(const Duration(hours: 6))),
        ],
      ),
    ];
  }

  static const List<String> aiReplies = [
    'Фаҳмидам! Ин дархостро дар лаҳзаи пайвастшавӣ ба Gemini API коркард мекунам.',
    'Хуб, ман ин масъаларо таҳлил карда, посух медиҳам.',
    'Ин фикри ҷолиб аст! Биёед дар бораи он бештар сӯҳбат кунем.',
    'Дархости шумо қабул шуд. Оё маълумоти иловагӣ доред?',
    'Ман ин ҷо ҳастам, то ба шумо кӯмак кунам. Лутфан идома диҳед.',
  ];
}

// ============================================================
// GLASSMORPHISM & БРЕНДИНГ (танҳо иконка, бе матн)
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

/// Логотипи барнома — танҳо иконкаи neon-градиентӣ, бе номи матнӣ
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
          BoxShadow(
            color: AppColors.neonEmerald.withOpacity(0.5),
            blurRadius: 16,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Icon(
        Icons.bolt_rounded,
        color: AppColors.background,
        size: size * 0.6,
      ),
    );
  }
}

/// Паси-замина бо нурҳои сабз/фирӯзаӣ барои умқи Glassmorphism
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
        Positioned(
          top: -80,
          left: -60,
          child: _blurCircle(AppColors.neonEmerald.withOpacity(0.25), 220),
        ),
        Positioned(
          bottom: -100,
          right: -70,
          child: _blurCircle(AppColors.neonCyan.withOpacity(0.20), 260),
        ),
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

// ============================================================
// ЭКРАНИ РӮЙХАТИ ЧАТҲО (Асосӣ)
// ============================================================
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late List<ChatConversation> _conversations;

  @override
  void initState() {
    super.initState();
    _conversations = MockData.getConversations();
  }

  void _openChat(ChatConversation convo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: convo)),
    );
    setState(() {}); // навсозии рӯйхат баъд аз бозгашт
  }

  @override
  Widget build(BuildContext context) {
    final aiChat = _conversations.firstWhere((c) => c.isAIChat);
    final userChats = _conversations.where((c) => !c.isAIChat).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NeonBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildAIAssistantTile(aiChat),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 6, bottom: 10),
                      child: Text(
                        'СӮҲБАТҲО',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...userChats.map((c) => _buildChatTile(c)),
                    const SizedBox(height: 24),
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
              _iconButton(Icons.search_rounded),
              const SizedBox(width: 10),
              _iconButton(Icons.more_vert_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return GlassContainer(
      borderRadius: 14,
      padding: const EdgeInsets.all(10),
      child: Icon(icon, color: AppColors.textPrimary, size: 20),
    );
  }

  Widget _buildAIAssistantTile(ChatConversation convo) {
    return GestureDetector(
      onTap: () => _openChat(convo),
      child: GlassContainer(
        borderRadius: 22,
        glow: true,
        glowColor: AppColors.neonEmerald,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.neonGradient,
              ),
              child: Icon(convo.avatarIcon,
                  color: AppColors.background, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'AI Ассистент',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: AppColors.neonGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    convo.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(ChatConversation convo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _openChat(convo),
        child: GlassContainer(
          borderRadius: 18,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Icon(convo.avatarIcon,
                        color: AppColors.textSecondary, size: 22),
                  ),
                  if (convo.online)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonEmerald,
                          border:
                              Border.all(color: AppColors.background, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      convo.name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      convo.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                _formatTime(convo.lastTime),
                style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    if (now.difference(t).inDays >= 1) {
      return '${t.day}/${t.month}';
    }
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
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

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      widget.conversation.messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isMe: true,
          isAI: false,
        ),
      );
      widget.conversation.lastMessage = text;
      widget.conversation.lastTime = DateTime.now();
      _controller.clear();
    });
    _scrollToBottom();

    if (widget.conversation.isAIChat) {
      _simulateAIReply();
    } else {
      _simulateContactReply();
    }
  }

  void _simulateAIReply() {
    setState(() => _isAITyping = true);
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final reply =
          MockData.aiReplies[DateTime.now().millisecond % MockData.aiReplies.length];
      setState(() {
        _isAITyping = false;
        widget.conversation.messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: reply,
            isMe: false,
            isAI: true,
          ),
        );
        widget.conversation.lastMessage = reply;
        widget.conversation.lastTime = DateTime.now();
      });
      _scrollToBottom();
    });
  }

  void _simulateContactReply() {
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      const reply = 'Хабаратонро гирифтам 👍';
      setState(() {
        widget.conversation.messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: reply,
            isMe: false,
            isAI: false,
          ),
        );
        widget.conversation.lastMessage = reply;
        widget.conversation.lastTime = DateTime.now();
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final convo = widget.conversation;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: NeonBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(convo),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  itemCount: convo.messages.length + (_isAITyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isAITyping && index == convo.messages.length) {
                      return const TypingBubble();
                    }
                    return MessageBubble(message: convo.messages[index]);
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

  Widget _buildHeader(ChatConversation convo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
      child: GlassContainer(
        borderRadius: 18,
        glow: convo.isAIChat,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 18),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: convo.isAIChat ? AppColors.neonGradient : null,
                color: convo.isAIChat ? null : AppColors.surface,
                border:
                    convo.isAIChat ? null : Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(
                convo.avatarIcon,
                color:
                    convo.isAIChat ? AppColors.background : AppColors.textSecondary,
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
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                  Text(
                    convo.isAIChat
                        ? 'Ҳамеша дастрас'
                        : (convo.online ? 'Онлайн' : 'Дар шабака набуд'),
                    style: TextStyle(
                      color: convo.online || convo.isAIChat
                          ? AppColors.neonEmerald
                          : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.neonGradient,
                ),
                child: const Icon(Icons.arrow_upward_rounded,
                    color: AppColors.background, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ВИҶЕТҲОИ ПАЁМ (Message Bubbles)
// ============================================================
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final isAI = message.isAI;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isAI)
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        size: 12, color: AppColors.neonCyan),
                    const SizedBox(width: 4),
                    Text('AI Assistant',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.neonCyan.withOpacity(0.9))),
                  ],
                ),
              ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: isMe ? AppColors.neonGradient : null,
                color: isMe ? null : AppColors.glassFill,
                border: isMe
                    ? null
                    : Border.all(
                        color: isAI
                            ? AppColors.neonCyan.withOpacity(0.4)
                            : AppColors.glassBorder,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: isAI
                    ? [
                        BoxShadow(
                            color: AppColors.neonCyan.withOpacity(0.15),
                            blurRadius: 12)
                      ]
                    : null,
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
                style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.6),
                    fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Нишондиҳандаи "AI дар ҳоли навиштан аст..."
class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
          ..repeat();
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
                final scale =
                    0.5 + (0.5 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0));
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, gradient: AppColors.neonGradient),
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
