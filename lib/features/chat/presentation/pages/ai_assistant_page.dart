import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/theme/app_colors.dart';

class _ChatMessage {
  String text;
  final bool isUser;
  final DateTime timestamp;
  bool isStreaming;

  _ChatMessage({required this.text, required this.isUser, this.isStreaming = false})
    : timestamp = DateTime.now();
}

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  final _history = <Map<String, String>>[];
  final _recorder = AudioRecorder();

  bool _isLoading = false;
  bool _isRecording = false;
  bool _isTranscribing = false;
  StreamSubscription? _streamSub;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _messages.add(
      _ChatMessage(
        text:
            'Xin chào! 👋 Tôi là Trợ lý Học thuật AI. Hãy đặt câu hỏi về kiến thức, kỹ năng học tập hoặc định hướng nghề nghiệp — tôi sẵn sàng hỗ trợ bạn!',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _pulseController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = overrideText ?? _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final aiMessage = _ChatMessage(text: '', isUser: false, isStreaming: true);
      setState(() => _messages.add(aiMessage));
      _scrollToBottom();

      final request = http.Request(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/ai/stream-assistant'),
      );
      request.headers['Content-Type'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.body = jsonEncode({'question': text, 'history': _history});

      final client = http.Client();
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode == 200) {
        final completer = Completer<void>();
        var buffer = '';

        _streamSub = streamedResponse.stream
            .transform(utf8.decoder)
            .listen(
          (chunk) {
            buffer += chunk;
            final lines = buffer.split('\n');
            buffer = lines.removeLast();

            for (final line in lines) {
              final trimmed = line.trim();
              if (trimmed.isEmpty || !trimmed.startsWith('data: ')) continue;
              final data = trimmed.substring(6);

              if (data == '[DONE]') {
                setState(() {
                  aiMessage.isStreaming = false;
                  _isLoading = false;
                });
                _history.add({'role': 'user', 'content': text});
                _history.add({'role': 'assistant', 'content': aiMessage.text});
                if (_history.length > 20) _history.removeRange(0, 2);
                return;
              }

              try {
                final json = jsonDecode(data) as Map<String, dynamic>;
                if (json.containsKey('token')) {
                  setState(() {
                    aiMessage.text += json['token'] as String;
                  });
                  _scrollToBottom();
                }
              } catch (_) {}
            }
          },
          onDone: () {
            if (aiMessage.isStreaming) {
              setState(() {
                aiMessage.isStreaming = false;
                _isLoading = false;
              });
              if (aiMessage.text.isNotEmpty) {
                _history.add({'role': 'user', 'content': text});
                _history.add({'role': 'assistant', 'content': aiMessage.text});
                if (_history.length > 20) _history.removeRange(0, 2);
              }
            }
            client.close();
            if (!completer.isCompleted) completer.complete();
          },
          onError: (e) {
            setState(() {
              aiMessage.text = 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại.';
              aiMessage.isStreaming = false;
              _isLoading = false;
            });
            client.close();
            if (!completer.isCompleted) completer.complete();
          },
        );

        await completer.future;
      } else {
        setState(() {
          aiMessage.text = 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại.';
          aiMessage.isStreaming = false;
          _isLoading = false;
        });
        client.close();
      }
    } catch (e) {
      if (_messages.isNotEmpty && _messages.last.isStreaming) {
        setState(() {
          _messages.last.text = 'Không thể kết nối đến server. Kiểm tra lại mạng.';
          _messages.last.isStreaming = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add(
            _ChatMessage(
              text: 'Không thể kết nối đến server. Kiểm tra lại mạng.',
              isUser: false,
            ),
          );
          _isLoading = false;
        });
      }
    }
    _scrollToBottom();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (kIsWeb) return;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );

    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _isTranscribing = true;
    });

    if (path == null) {
      setState(() => _isTranscribing = false);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/ai/speech-to-text'),
      );
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('audio', path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['text'] as String;
        if (text.isNotEmpty) {
          setState(() => _isTranscribing = false);
          await _sendMessage(text);
          return;
        }
      }
    } catch (_) {}

    setState(() => _isTranscribing = false);

    try {
      if (!kIsWeb) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.darkBackground;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trợ lý Học thuật AI',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isLoading
                        ? 'Đang trả lời...'
                        : _isTranscribing
                        ? 'Đang nhận diện giọng nói...'
                        : 'Sẵn sàng hỗ trợ',
                    style: TextStyle(
                      color: _isLoading || _isTranscribing
                          ? AppColors.primary
                          : subTextColor,
                      fontSize: 12,
                      fontStyle: _isLoading || _isTranscribing
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: subTextColor),
            onPressed: () {
              _streamSub?.cancel();
              setState(() {
                _messages.clear();
                _history.clear();
                _isLoading = false;
                _messages.add(
                  _ChatMessage(
                    text:
                        'Cuộc trò chuyện đã được xóa. Hãy đặt câu hỏi mới! 🎓',
                    isUser: false,
                  ),
                );
              });
            },
            tooltip: 'Xóa lịch sử',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg.isStreaming && msg.text.isEmpty) {
                  return _buildTypingIndicator(isDark);
                }
                return _buildMessageBubble(
                  msg,
                  isDark,
                  textColor,
                  subTextColor,
                );
              },
            ),
          ),
          if (_isRecording) _buildRecordingOverlay(isDark),
          _buildInputBar(bgColor, cardColor, textColor, subTextColor),
        ],
      ),
    );
  }

  Widget _buildRecordingOverlay(bool isDark) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final scale = 1.0 + (_pulseController.value * 0.3);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Colors.red.withAlpha(isDark ? 30 : 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Đang ghi âm... Nhấn mic để dừng',
                style: TextStyle(
                  color: Colors.red[isDark ? 300 : 700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 48, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 600 + (i * 200)),
                  builder: (context, value, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withAlpha(
                            (100 + 155 * value).toInt(),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    _ChatMessage msg,
    bool isDark,
    Color textColor,
    Color subTextColor,
  ) {
    final isMe = msg.isUser;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 48 : 0,
        right: isMe ? 0 : 48,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
          if (!isMe) const SizedBox(width: 6),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primary
                    : (isDark ? AppColors.darkCard : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SelectableText(
                    msg.text + (msg.isStreaming ? '▊' : ''),
                    style: TextStyle(
                      color: isMe ? Colors.white : textColor,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withAlpha(170)
                          : (isDark ? Colors.grey[500] : Colors.grey[400]),
                      fontSize: 11,
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

  Widget _buildInputBar(
    Color bgColor,
    Color cardColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isLoading || _isTranscribing ? null : _toggleRecording,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isRecording
                    ? Colors.red
                    : (_isTranscribing ? Colors.orange : AppColors.accent),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isRecording
                    ? Icons.stop_rounded
                    : (_isTranscribing
                          ? Icons.hourglass_top_rounded
                          : Icons.mic_rounded),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(color: textColor),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isLoading && !_isTranscribing,
              decoration: InputDecoration(
                hintText: _isTranscribing
                    ? 'Đang nhận diện giọng nói...'
                    : 'Hỏi bất cứ điều gì về học tập...',
                hintStyle: TextStyle(color: subTextColor),
                filled: true,
                fillColor: bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            decoration: BoxDecoration(
              color: _isLoading ? Colors.grey : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _isLoading || _isTranscribing
                  ? null
                  : () => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }
}
