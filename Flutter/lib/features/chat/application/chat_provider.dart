import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_cliente/features/chat/domain/chat_model.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState());

  Future<void> loadMessages(int incidentId) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = ChatState(
      messages: [
        ChatMessage(id: 1, text: 'Hola, ya estamos en camino. ¿Podría confirmar su ubicación?', isMe: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
        ChatMessage(id: 2, text: 'Sí, estoy en la Av. Arequipa con Av. Javier Prado', isMe: true,
            timestamp: DateTime.now().subtract(const Duration(minutes: 14))),
        ChatMessage(id: 3, text: 'Perfecto, llegaremos en aproximadamente 20 minutos.', isMe: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 13))),
      ],
    );
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final msg = ChatMessage(
      id: state.messages.length + 1,
      text: text.trim(),
      isMe: true,
    );
    state = state.copyWith(messages: [...state.messages, msg]);

    // Simular respuesta automática
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final reply = ChatMessage(
        id: state.messages.length + 1,
        text: 'Entendido, lo tendremos en cuenta.',
        isMe: false,
      );
      state = state.copyWith(messages: [...state.messages, reply]);
    });
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
