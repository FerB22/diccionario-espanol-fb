import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Servicio singleton para pronunciación de palabras mediante Text-to-Speech (TTS).
class TtsService {
  TtsService._internal();
  static final TtsService instance = TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final ValueNotifier<bool> isSpeakingNotifier = ValueNotifier<bool>(false);
  bool _isInitialized = false;

  bool get isSpeaking => isSpeakingNotifier.value;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('es');
      await _flutterTts.setSpeechRate(0.50);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        isSpeakingNotifier.value = true;
      });

      _flutterTts.setCompletionHandler(() {
        isSpeakingNotifier.value = false;
      });

      _flutterTts.setCancelHandler(() {
        isSpeakingNotifier.value = false;
      });

      _flutterTts.setErrorHandler((msg) {
        isSpeakingNotifier.value = false;
        debugPrint('TTS Error: $msg');
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error inicializando TtsService: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      await stop();
      final cleanText = text.trim();
      if (cleanText.isNotEmpty) {
        isSpeakingNotifier.value = true;
        await _flutterTts.speak(cleanText);
      }
    } catch (e) {
      isSpeakingNotifier.value = false;
      debugPrint('Error al reproducir voz: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      isSpeakingNotifier.value = false;
    } catch (e) {
      debugPrint('Error deteniendo TTS: $e');
    }
  }
}
