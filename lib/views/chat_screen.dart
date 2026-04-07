import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/chat_viewmodel.dart';
import 'sidebar_menu.dart';

// ── Brand palette (mirrors dashboard) ─────────────────────────────────────────
const Color _primaryGreen = Color(0xFF2E7D32);
const Color _accentGreen  = Color(0xFF43A047);
const Color _lightGreen   = Color(0xFFE8F5E9);
const Color _bgGrey       = Color(0xFFF4F6F8);
const Color _textDark     = Color(0xFF1A2332);
const Color _textMuted    = Color(0xFF90A4AE);

class ChatScreen extends StatelessWidget {
  final String? sessionId;
  const ChatScreen({Key? key, this.sessionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatViewModel>(
      create: (_) => ChatViewModel(sessionId: sessionId),
      child: const _ChatScreenBody(),
    );
  }
}

class _ChatScreenBody extends StatefulWidget {
  const _ChatScreenBody({Key? key}) : super(key: key);

  @override
  State<_ChatScreenBody> createState() => _ChatScreenBodyState();
}

class _ChatScreenBodyState extends State<_ChatScreenBody> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _send() {
    final txt = _controller.text.trim();
    if (txt.isNotEmpty) {
      context.read<ChatViewModel>().sendMessage(txt);
      _controller.clear();
      _scrollToTop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm       = context.watch<ChatViewModel>();
    final messages = vm.messages;
    final presets  = vm.presetQuestions;
    final loading  = vm.isLoading;

    return Scaffold(
      backgroundColor: _bgGrey,
      drawer: const SidebarMenu(),
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        elevation: 0,
        centerTitle: false,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AgriVet Assistant',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.3),
                ),
                Text(
                  'AI-powered livestock advisor',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ── Preset chips ────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: presets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) => GestureDetector(
                    onTap: () {
                      vm.sendPresetMessage(presets[i]);
                      _scrollToTop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFA5D6A7), width: 1),
                      ),
                      child: Text(
                        presets[i],
                        style: const TextStyle(
                            fontSize: 12,
                            color: _primaryGreen,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Chat list ───────────────────────────────────────────────────
            Expanded(
              child: messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: messages.length,
                      itemBuilder: (ctx, i) {
                        final msg    = messages[messages.length - 1 - i];
                        final isUser = msg.role == 'user';
                        return _buildMessageBubble(msg.content, isUser);
                      },
                    ),
            ),

            // ── Typing indicator ────────────────────────────────────────────
            if (loading)
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                          color: _lightGreen, shape: BoxShape.circle),
                      child: const Icon(Icons.smart_toy_outlined,
                          color: _primaryGreen, size: 17),
                    ),
                    const SizedBox(width: 10),
                    _TypingDots(),
                  ],
                ),
              ),

            // ── Input bar ───────────────────────────────────────────────────
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: _lightGreen, shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_outlined,
                color: _primaryGreen, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'AgriVet Assistant',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ask me anything about your livestock.',
            style: TextStyle(fontSize: 13, color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // AI avatar
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                  color: _lightGreen, shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy_outlined,
                  color: _primaryGreen, size: 17),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isUser ? _primaryGreen : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Text(
                content,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: isUser ? Colors.white : _textDark),
              ),
            ),
          ),

          // User avatar
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                  color: _accentGreen, shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.white, size: 17),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _bgGrey,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFDDE1E7), width: 1),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontSize: 14, color: _textDark),
                decoration: const InputDecoration(
                  hintText: 'Ask about your livestock…',
                  hintStyle: TextStyle(fontSize: 13, color: _textMuted),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  color: _primaryGreen, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated typing dots ───────────────────────────────────────────────────────
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          children: List.generate(3, (i) {
            final opacity =
                (0.3 + 0.7 * (((_ctrl.value * 3 - i) % 1 + 1) % 1))
                    .clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: _primaryGreen, shape: BoxShape.circle),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
