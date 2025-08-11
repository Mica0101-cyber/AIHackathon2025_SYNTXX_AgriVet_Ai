import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/chat_viewmodel.dart';
import 'sidebar_menu.dart';

class ChatScreen extends StatelessWidget {
  /// Optionally pass a sessionId to resume a previous chat.
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final messages = vm.messages;
    final presets = vm.presetQuestions;
    final loading = vm.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const SidebarMenu(),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_florist),
            SizedBox(width: 8),
            Text('AgriVet Assistant'),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Preset questions
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: presets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) => ActionChip(
                  label: Text(presets[i], style: const TextStyle(fontSize: 14)),
                  onPressed: () {
                    vm.sendPresetMessage(presets[i]);
                    _scrollToTop();
                  },
                ),
              ),
            ),

            // Chat history
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (ctx, i) {
                  final msg = messages[messages.length - 1 - i];
                  final isUser = msg.role == 'user';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.local_florist),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.2)
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 0),
                                bottomRight: Radius.circular(isUser ? 0 : 16),
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4)
                              ],
                            ),
                            child: Text(msg.content),
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 8),
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Loading
            if (loading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),

            // Input bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    shape: const CircleBorder(),
                    color: Colors.lightGreen,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final txt = _controller.text.trim();
                        if (txt.isNotEmpty) {
                          vm.sendMessage(txt);
                          _controller.clear();
                          _scrollToTop();
                        }
                      },
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
}
