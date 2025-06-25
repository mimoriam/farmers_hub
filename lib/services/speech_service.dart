import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();

  factory SpeechService() => _instance;

  SpeechService._internal();

  SpeechToText? _speechToText;

  bool _speechEnabled = false;
  bool _speechListening = false;
  String _lastWords = '';
  String _errorMessage = '';
  List<LocaleName> _availableLocales = [];
  String? _currentLocale;

  // Getters
  bool get isInitialized => _speechEnabled;

  bool get isListening => _speechListening;

  String get lastWords => _lastWords;

  String get errorMessage => _errorMessage;

  List<LocaleName> get availableLocales => _availableLocales;

  String? get currentLocale => _currentLocale;

  // Callbacks
  Function(String)? onSpeechResult;
  Function(String)? onError;
  Function(bool)? onListeningStateChanged;
  Function(List<LocaleName>)? onLocalesLoaded;

  /// Initialize the speech service with proper error handling
  Future<bool> initialize() async {
    try {
      // Create instance only when initializing
      _speechToText = SpeechToText();

      // First check if speech recognition is available
      bool available = await _speechToText!.initialize();

      if (!available) {
        _errorMessage =
            'Speech recognition not available on this device. Please check if Google Speech Services is installed and enabled in Settings > Apps > Default apps > Voice input.';
        onError?.call(_errorMessage);
        return false;
      }

      // Get available locales after successful initialization
      await _loadAvailableLocales();

      // Set up proper initialization with callbacks
      _speechEnabled = await _speechToText!.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
        debugLogging: true, // Enable for debugging
      );

      if (!_speechEnabled) {
        _errorMessage =
            'Failed to initialize speech recognition. Try restarting the app or check your device settings.';
        onError?.call(_errorMessage);
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage =
          'Speech recognition initialization failed: $e. Make sure you have Google Speech Services installed and microphone permissions granted.';
      onError?.call(_errorMessage);
      return false;
    }
  }

  /// Load available locales and set a default one
  Future<void> _loadAvailableLocales() async {
    try {
      if (_speechToText == null) return;

      _availableLocales = await _speechToText!.locales();

      if (_availableLocales.isNotEmpty) {
        // Try to find English locale first (most common)
        LocaleName? englishLocale = _availableLocales.firstWhere(
          (locale) => locale.localeId.startsWith('en'),
          orElse: () => _availableLocales.first,
        );

        _currentLocale = englishLocale.localeId;
        onLocalesLoaded?.call(_availableLocales);
      }
    } catch (e) {
      print('Error loading locales: $e');
      // Don't fail initialization for this
    }
  }

  /// Check if speech recognition is actually available
  Future<bool> checkAvailability() async {
    try {
      if (_speechToText == null) {
        _speechToText = SpeechToText();
      }
      return await _speechToText!.initialize();
    } catch (e) {
      return false;
    }
  }

  /// Start listening with better error handling and locale selection
  Future<void> startListening({String? localeId, Duration? listenFor, Duration? pauseFor}) async {
    if (_speechToText == null || !_speechEnabled) {
      _errorMessage = 'Speech service not initialized. Please restart the app.';
      onError?.call(_errorMessage);
      return;
    }

    if (_speechListening) {
      await stopListening();
      // Small delay to ensure previous session is fully stopped
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _lastWords = '';
    _errorMessage = '';

    // Use provided locale or fall back to current/default
    String useLocale = localeId ?? _currentLocale ?? 'en_US';

    // Verify the locale exists
    if (_availableLocales.isNotEmpty) {
      bool localeExists = _availableLocales.any((locale) => locale.localeId == useLocale);
      if (!localeExists) {
        // Fall back to first available locale
        useLocale = _availableLocales.first.localeId;
        print('Locale $useLocale not found, using ${_availableLocales.first.localeId}');
      }
    }

    try {
      await _speechToText!.listen(
        onResult: _onSpeechResult,
        localeId: useLocale,
        listenFor: listenFor ?? const Duration(seconds: 30),
        pauseFor: pauseFor ?? const Duration(seconds: 2),
        // Shorter pause
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
        sampleRate: 16000, // Standard sample rate
      );

      _currentLocale = useLocale;
    } catch (e) {
      _errorMessage = 'Failed to start listening: $e. Check microphone permissions and try again.';
      onError?.call(_errorMessage);
    }
  }

  /// Stop listening with proper cleanup
  Future<void> stopListening() async {
    try {
      if (_speechToText != null && _speechListening) {
        await _speechToText!.stop();
      }
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  /// Cancel current speech recognition
  Future<void> cancelListening() async {
    try {
      if (_speechToText != null && _speechListening) {
        await _speechToText!.cancel();
      }
    } catch (e) {
      print('Error cancelling speech recognition: $e');
    }
  }

  /// Set the locale for speech recognition
  void setLocale(String localeId) {
    if (_availableLocales.any((locale) => locale.localeId == localeId)) {
      _currentLocale = localeId;
    }
  }

  /// Get system default locale
  String getSystemLocale() {
    if (_availableLocales.isEmpty) return 'en_US';

    // Try to match system locale or fall back to English
    return _availableLocales
        .firstWhere((locale) => locale.localeId.startsWith('en'), orElse: () => _availableLocales.first)
        .localeId;
  }

  /// Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    onSpeechResult?.call(_lastWords);

    // Clear any previous errors on successful recognition
    if (_lastWords.isNotEmpty && _errorMessage.isNotEmpty) {
      _errorMessage = '';
    }
  }

  /// Handle speech recognition errors with detailed messages
  void _onSpeechError(SpeechRecognitionError error) {
    String errorMsg = 'Speech error: ';

    switch (error.errorMsg.toLowerCase()) {
      case 'error_no_match':
        errorMsg = 'No speech detected. Please speak louder or closer to the microphone.';
        break;
      case 'error_speech_timeout':
        errorMsg = 'Speech timeout. Please try speaking again.';
        break;
      case 'error_audio':
        errorMsg = 'Audio recording error. Check microphone permissions.';
        break;
      case 'error_server':
        errorMsg = 'Server error. Check your internet connection.';
        break;
      case 'error_client':
        errorMsg = 'Client error. Try restarting the app.';
        break;
      case 'error_network':
        errorMsg = 'Network error. Check your internet connection.';
        break;
      case 'error_network_timeout':
        errorMsg = 'Network timeout. Check your internet connection.';
        break;
      case 'error_recognizer_busy':
        errorMsg = 'Speech recognizer busy. Please wait and try again.';
        break;
      default:
        errorMsg = 'Speech recognition error: ${error.errorMsg}';
    }

    _errorMessage = errorMsg;
    onError?.call(_errorMessage);
  }

  /// Handle speech recognition status changes
  void _onSpeechStatus(String status) {
    print('Speech status: $status'); // For debugging

    bool wasListening = _speechListening;
    _speechListening = status == 'listening';

    if (wasListening != _speechListening) {
      onListeningStateChanged?.call(_speechListening);
    }

    // Clear error when listening starts successfully
    if (_speechListening && _errorMessage.isNotEmpty) {
      _errorMessage = '';
    }

    // Handle specific status messages
    if (status == 'notListening' && wasListening) {
      // Listening session ended
      print('Listening session ended');
    }
  }

  /// Dispose resources properly
  void dispose() {
    try {
      _speechToText?.cancel();
      _speechToText = null;
      _speechEnabled = false;
      _speechListening = false;
    } catch (e) {
      print('Error disposing speech service: $e');
    }
  }

  /// Reset the service (useful for troubleshooting)
  Future<void> reset() async {
    await cancelListening();
    dispose();
    await Future.delayed(const Duration(milliseconds: 500));
    await initialize();
  }
}
