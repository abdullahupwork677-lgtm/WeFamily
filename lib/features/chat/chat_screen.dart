import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/colors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/mock_data.dart';

final chatMessagesProvider =
    NotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(ChatMessagesNotifier.new);

class ChatMessagesNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => MockData.messages;

  void addText(String text) {
    final msg = ChatMessage(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      senderUid: MockData.currentUser.id,
      senderName: MockData.currentUser.name.split(' ').first,
      type: 'text',
      text: text,
      createdAt: DateTime.now(),
    );
    state = [...state, msg];
  }

  void addLocation() {
    final msg = ChatMessage(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      senderUid: MockData.currentUser.id,
      senderName: MockData.currentUser.name.split(' ').first,
      type: 'location',
      lat: 24.7136,
      lng: 46.6753,
      createdAt: DateTime.now(),
    );
    state = [...state, msg];
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<ChatMessage> messages = ref.watch(chatMessagesProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chat)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                final isMe = m.senderUid == MockData.currentUser.id;
                return _MessageBubble(message: m, isMe: isMe);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _QuickChip(
                  label: l10n.sendLocation,
                  icon: Icons.location_on_outlined,
                  onTap: () {
                    ref.read(chatMessagesProvider.notifier).addLocation();
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: l10n.typeMessage,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      onSubmitted: (_) => _send(l10n),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _send(l10n),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: AhlColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send(AppLocalizations l10n) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(chatMessagesProvider.notifier).addText(text);
    _controller.clear();
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AhlColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AhlColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AhlColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AhlColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(message.createdAt.toLocal());

    return Align(
      alignment: isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AhlColors.primary : AhlColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: isMe ? null : AhlColors.softShadowSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.senderName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AhlColors.primary),
              ),
            if (message.type == 'location')
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 16, color: isMe ? Colors.white : AhlColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '📍 ${message.lat?.toStringAsFixed(3)}, ${message.lng?.toStringAsFixed(3)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isMe ? Colors.white : AhlColors.ink,
                        ),
                  ),
                ],
              )
            else
              Text(
                message.text ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isMe ? Colors.white : AhlColors.ink,
                    ),
              ),
            const SizedBox(height: 2),
            Text(
              time,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isMe ? Colors.white70 : AhlColors.inkLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
