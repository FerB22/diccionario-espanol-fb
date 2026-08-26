import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Escalas de fuente disponibles (factor multiplicador sobre el tamaño base).
const List<double> _fontScales = [0.85, 1.0, 1.15, 1.3];

/// Claves para SharedPreferences
const String _keyFontSize  = 'font_size';
const String _keyDarkMode  = 'dark_mode';

/// Proveedor global de preferencias de la aplicación.
///
/// Gestiona:
/// - Escala de fuente (4 niveles: 0.85 / 1.0 / 1.15 / 1.3)
/// - Modo oscuro / claro
///
/// Persiste automáticamente los cambios en SharedPreferences.
class AppProvider extends ChangeNotifier {
  // ── Estado ─────────────────────────────────────────────────────────────────
  double _fontSize   = 1.0;
  bool   _isDarkMode = false;
  bool   _initialized = false;

  double get fontSize   => _fontSize;
  bool   get isDarkMode => _isDarkMode;
  bool   get initialized => _initialized;

  /// Índice actual dentro de [_fontScales].
  int get _currentScaleIndex =>
      _fontScales.indexWhere((s) => (s - _fontSize).abs() < 0.001);

  // ── Constructor ────────────────────────────────────────────────────────────

  AppProvider() {
    _loadPreferences();
  }

  // ── Persistencia ───────────────────────────────────────────────────────────

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize   = prefs.getDouble(_keyFontSize) ?? 1.0;
    _isDarkMode = prefs.getBool(_keyDarkMode)   ?? false;

    // Asegura que el valor cargado sea una escala válida
    if (!_fontScales.contains(_fontSize)) {
      _fontSize = 1.0;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, _fontSize);
    await prefs.setBool(_keyDarkMode,  _isDarkMode);
  }

  // ── Métodos públicos ───────────────────────────────────────────────────────

  /// Aumenta la escala de fuente un nivel (máximo: 1.3).
  void increaseFontSize() {
    final idx = _currentScaleIndex;
    if (idx < _fontScales.length - 1) {
      _fontSize = _fontScales[idx + 1];
      notifyListeners();
      _savePreferences();
    }
  }

  /// Reduce la escala de fuente un nivel (mínimo: 0.85).
  void decreaseFontSize() {
    final idx = _currentScaleIndex;
    if (idx > 0) {
      _fontSize = _fontScales[idx - 1];
      notifyListeners();
      _savePreferences();
    }
  }

  /// Establece la escala de fuente directamente; ignora valores inválidos.
  void setFontSize(double scale) {
    if (_fontScales.contains(scale) && scale != _fontSize) {
      _fontSize = scale;
      notifyListeners();
      _savePreferences();
    }
  }

  /// Alterna entre modo oscuro y claro.
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _savePreferences();
  }

  /// Establece el modo oscuro explícitamente.
  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
      _savePreferences();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Devuelve [true] si se puede aumentar la fuente.
  bool get canIncrease =>
      _currentScaleIndex < _fontScales.length - 1;

  /// Devuelve [true] si se puede reducir la fuente.
  bool get canDecrease => _currentScaleIndex > 0;

  /// Etiqueta legible para la escala actual.
  String get fontSizeLabel {
    switch (_fontSize) {
      case 0.85: return 'Pequeña';
      case 1.0:  return 'Normal';
      case 1.15: return 'Grande';
      case 1.3:  return 'Muy grande';
      default:   return 'Normal';
    }
  }
}