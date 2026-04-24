import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/utils/audio_stream_player.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

class AiAssistantBloc extends Bloc<AiAssistantEvent, AiAssistantState> {
  final ApiClient apiClient;

  AiAssistantBloc({required this.apiClient}) : super(AiInitial()) {
    on<AskAiQuestion>(_onAskQuestion);
    on<SummarizeLesson>(_onSummarize);
    on<ClearChat>(_onClearChat);
    on<LoadChatHistory>(_onLoadHistory);
    on<GenerateConceptMap>(_onGenerateConceptMap);
  }

  Future<void> _onLoadHistory(
    LoadChatHistory event,
    Emitter<AiAssistantState> emit,
  ) async {
    try {
      final lessonId = event.lessonId ?? 0;
      final response = await apiClient.get(
        '/ai/chat-history?userId=${event.userId}&lessonId=$lessonId',
      );
      final data = response as Map<String, dynamic>;
      final rawMessages = data['messages'] as List? ?? [];

      if (rawMessages.isEmpty) {
        emit(AiInitial());
        return;
      }

      final messages = rawMessages.map((m) {
        final msg = m as Map<String, dynamic>;
        return AiChatMessage(
          role: msg['role'] as String,
          content: msg['content'] as String,
          timestamp: DateTime.tryParse(msg['timestamp'] as String? ?? '') ??
              DateTime.now(),
        );
      }).toList();

      emit(AiChatLoaded(messages));
    } catch (_) {
      emit(AiInitial());
    }
  }

  Future<void> _onAskQuestion(
    AskAiQuestion event,
    Emitter<AiAssistantState> emit,
  ) async {
    final currentMessages = <AiChatMessage>[];
    if (state is AiChatLoaded) {
      currentMessages.addAll((state as AiChatLoaded).messages);
    } else if (state is AiChatLoading) {
      currentMessages.addAll((state as AiChatLoading).messages);
    } else if (state is AiError &&
        (state as AiError).previousMessages != null) {
      currentMessages.addAll((state as AiError).previousMessages!);
    }

    currentMessages.add(
      AiChatMessage(
        role: 'user',
        content: event.question,
        timestamp: DateTime.now(),
      ),
    );

    currentMessages.add(
      AiChatMessage(
        role: 'assistant',
        content: '',
        timestamp: DateTime.now(),
      ),
    );

    emit(AiChatLoaded(List.from(currentMessages)));

    _persistMessage(event.userId, event.lessonId, 'user', event.question);

    try {
      final history = currentMessages
          .where((m) => m != currentMessages[currentMessages.length - 2] && m != currentMessages.last)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final wsUrl = Uri.parse(ApiConstants.baseUrl.replaceFirst('http', 'ws') + '/ai/chat_stream');
      final channel = WebSocketChannel.connect(wsUrl);

      channel.sink.add(jsonEncode({
        'lessonTitle': event.lessonTitle,
        'textContent': event.textContent,
        'history': history,
        'question': event.question,
        if (event.persona != null) 'persona': event.persona,
        if (event.imageBase64 != null) 'imageBase64': event.imageBase64,
        'lessonId': event.lessonId,
      }));

      String streamingAnswer = '';

      await emit.forEach(
        channel.stream,
        onData: (message) {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          if (data['type'] == 'text') {
            streamingAnswer += data['content'] as String;
            currentMessages.last = AiChatMessage(
              role: 'assistant',
              content: streamingAnswer,
              timestamp: DateTime.now(),
            );
            return AiChatLoaded(List.from(currentMessages));
          } else if (data['type'] == 'audio') {
            AudioStreamPlayer().queueAudioBase64(data['base64'] as String);
          } else if (data['type'] == 'done') {
            channel.sink.close();
          } else if (data['error'] != null) {
            throw Exception(data['error']);
          }
          return state;
        },
        onError: (e, s) {
          return AiError(
            'Lỗi kết nối AI stream: ${e.toString()}',
            previousMessages: currentMessages,
          );
        },
      );

      _persistMessage(event.userId, event.lessonId, 'assistant', streamingAnswer);

    } catch (e) {
      emit(
        AiError(
          'Không thể kết nối AI: ${e.toString()}',
          previousMessages: currentMessages,
        ),
      );
    }
  }

  void _persistMessage(int? userId, int? lessonId, String role, String content) {
    if (userId == null) return;
    apiClient.post('/ai/chat-history', {
      'userId': userId,
      'lessonId': lessonId ?? 0,
      'role': role,
      'content': content,
    }).catchError((_) => null);
  }

  Future<void> _onSummarize(
    SummarizeLesson event,
    Emitter<AiAssistantState> emit,
  ) async {
    emit(AiSummaryLoading());

    try {
      final response = await apiClient.post('/ai/summarize', {
        'lessonTitle': event.lessonTitle,
        'textContent': event.textContent,
      });

      final data = response as Map<String, dynamic>;
      final summary = data['summary'] as String? ?? '';
      final keyPoints =
          (data['keyPoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final keywords =
          (data['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      emit(
        AiSummaryLoaded(
          summary: summary,
          keyPoints: keyPoints,
          keywords: keywords,
        ),
      );
    } catch (e) {
      emit(AiError('Không thể tóm tắt bài giảng: ${e.toString()}'));
    }
  }

  Future<void> _onClearChat(ClearChat event, Emitter<AiAssistantState> emit) async {
    if (event.userId != null) {
      apiClient.delete(
        '/ai/chat-history?userId=${event.userId}&lessonId=${event.lessonId ?? 0}',
      ).catchError((_) => null);
    }
    emit(AiInitial());
  }

  Future<void> _onGenerateConceptMap(
    GenerateConceptMap event,
    Emitter<AiAssistantState> emit,
  ) async {
    emit(AiConceptMapLoading());

    try {
      final response = await apiClient.post('/ai/concept-map', {
        'lessonTitle': event.lessonTitle,
        'textContent': event.textContent,
      });

      final data = response as Map<String, dynamic>;
      final rawNodes = data['nodes'] as List? ?? [];
      final rawEdges = data['edges'] as List? ?? [];

      final nodes = rawNodes.map((n) {
        final m = n as Map<String, dynamic>;
        return ConceptNode(
          id: m['id'] as String? ?? '',
          label: m['label'] as String? ?? '',
          description: m['description'] as String? ?? '',
          type: m['type'] as String? ?? 'sub',
        );
      }).toList();

      final edges = rawEdges.map((e) {
        final m = e as Map<String, dynamic>;
        return ConceptEdge(
          from: m['from'] as String? ?? '',
          to: m['to'] as String? ?? '',
          label: m['label'] as String? ?? '',
        );
      }).toList();

      emit(AiConceptMapLoaded(nodes: nodes, edges: edges));
    } catch (e) {
      emit(AiError('Không thể tạo concept map: ${e.toString()}'));
    }
  }
}
