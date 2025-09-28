import 'package:flutter/foundation.dart';
import '../models/w3w_models.dart';
import '../services/w3w_api_service.dart';

class W3WProvider extends ChangeNotifier {
  final W3WApiService _apiService;

  W3WProvider({required String apiKey})
      : _apiService = W3WApiService(apiKey: apiKey);

  // State variables
  bool _isLoading = false;
  W3WError? _error;
  W3WAddress? _currentAddress;
  List<W3WSuggestion> _suggestions = [];
  W3WGridSection? _gridSection;

  // Getters
  bool get isLoading => _isLoading;
  W3WError? get error => _error;
  W3WAddress? get currentAddress => _currentAddress;
  List<W3WSuggestion> get suggestions => _suggestions;
  W3WGridSection? get gridSection => _gridSection;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Convert coordinates to What3words address
  Future<void> convertToWords({
    required double lat,
    required double lng,
    String language = 'en',
  }) async {
    _setLoading(true);
    try {
      _currentAddress = await _apiService.convertToWords(
        lat: lat,
        lng: lng,
        language: language,
      );
      _error = null;
    } catch (e) {
      _error =
          e is W3WError ? e : W3WError(code: 'unknown', message: e.toString());
      _currentAddress = null;
    }
    _setLoading(false);
  }

  // Convert What3words address to coordinates
  Future<void> convertToCoordinates({required String words}) async {
    _setLoading(true);
    try {
      _currentAddress = await _apiService.convertToCoordinates(words: words);
      _error = null;
    } catch (e) {
      _error =
          e is W3WError ? e : W3WError(code: 'unknown', message: e.toString());
      _currentAddress = null;
    }
    _setLoading(false);
  }

  // Get AutoSuggest suggestions
  Future<void> autoSuggest({
    required String input,
    String language = 'en',
    int nResults = 10,
    W3WCoordinates? focus,
    String? clipToCountry,
  }) async {
    if (input.trim().isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    try {
      _suggestions = await _apiService.autoSuggest(
        input: input,
        language: language,
        nResults: nResults,
        focus: focus,
        clipToCountry: clipToCountry,
      );
      _error = null;
    } catch (e) {
      _error =
          e is W3WError ? e : W3WError(code: 'unknown', message: e.toString());
      _suggestions = [];
    }
    notifyListeners();
  }

  // Get grid section for map overlay
  Future<void> getGridSection({required String boundingBox}) async {
    try {
      _gridSection = await _apiService.getGridSection(boundingBox: boundingBox);
      _error = null;
    } catch (e) {
      _error =
          e is W3WError ? e : W3WError(code: 'unknown', message: e.toString());
      _gridSection = null;
    }
    notifyListeners();
  }

  // Clear current address
  void clearAddress() {
    _currentAddress = null;
    notifyListeners();
  }

  // Clear suggestions
  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
