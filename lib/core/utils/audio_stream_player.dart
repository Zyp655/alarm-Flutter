import 'dart:convert';
import 'package:just_audio/just_audio.dart';

class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

class AudioStreamPlayer {
  static final AudioStreamPlayer _instance = AudioStreamPlayer._internal();
  factory AudioStreamPlayer() => _instance;
  AudioStreamPlayer._internal();

  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(
    useLazyPreparation: true,
    children: [],
  );

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await _player.setAudioSource(_playlist);
    _isInitialized = true;
    
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.ready && !state.playing) {
        _player.play();
      }
    });
  }

  Future<void> queueAudioBase64(String base64Audio) async {
    if (!_isInitialized) await init();
    try {
      final bytes = base64Decode(base64Audio);
      final source = MyCustomSource(bytes);
      await _playlist.add(source);
      
      if (_player.processingState == ProcessingState.completed) {
        if (_player.hasNext) {
          await _player.seekToNext();
        }
        _player.play();
      } else if (!_player.playing) {
        _player.play();
      }
    } catch (e) {
      print('Error queuing audio: $e');
    }
  }

  Future<void> stopAndClear() async {
    await _player.stop();
    await _playlist.clear();
  }
  
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
}
