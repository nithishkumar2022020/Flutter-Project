import 'package:flutter/foundation.dart';
import '../../domain/models/profile_settings.dart';
import '../../domain/repositories/i_profile_settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final IProfileSettingsRepository _repository;
  ProfileSettings _settings = ProfileSettings.defaults();
  bool _isLoaded = false;

  SettingsProvider({required IProfileSettingsRepository repository})
    : _repository = repository {
    _load();
  }

  ProfileSettings get settings => _settings;
  bool get isLoaded => _isLoaded;
  bool get isNocturneMode => _settings.isNocturneMode;
  bool get isAuthenticated => _settings.isAuthenticated;
  String get researcherName => _settings.researcherName;
  String get callSign => _settings.callSign;
  String get clearanceLevel => _settings.clearanceLevel;
  bool get isGuest => _settings.isGuest;

  Future<void> _load() async {
    _settings = await _repository.loadSettings();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateSettings(ProfileSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await _repository.saveSettings(newSettings);
  }

  Future<void> toggleNocturneMode() async {
    final updated = _settings.copyWith(
      isNocturneMode: !_settings.isNocturneMode,
    );
    await updateSettings(updated);
  }

  Future<void> signIn({
    required String callSign,
    required String passkey,
  }) async {
    final updated = _settings.copyWith(
      isAuthenticated: true,
      isGuest: false,
      callSign: callSign.isNotEmpty ? callSign : 'ARCH-9942',
      researcherName:
          _settings.researcherName.isNotEmpty
              ? _settings.researcherName
              : 'Nithish R.',
    );
    await updateSettings(updated);
  }

  Future<void> signUp({
    required String researcherName,
    required String callSign,
    required String clearanceLevel,
    required String passkey,
  }) async {
    final updated = _settings.copyWith(
      isAuthenticated: true,
      isGuest: false,
      researcherName: researcherName.isNotEmpty ? researcherName : 'Nithish R.',
      callSign: callSign.isNotEmpty ? callSign : 'ARCH-9942',
      clearanceLevel:
          clearanceLevel.isNotEmpty ? clearanceLevel : 'Level-3 Architect',
    );
    await updateSettings(updated);
  }

  Future<void> enterAsGuest() async {
    final updated = _settings.copyWith(
      isAuthenticated: true,
      isGuest: true,
      researcherName: 'Observer (Guest)',
      callSign: 'GUEST-OBSERVER',
      clearanceLevel: 'Level-1 Reader',
    );
    await updateSettings(updated);
  }

  Future<void> signOut() async {
    final updated = _settings.copyWith(isAuthenticated: false, isGuest: false);
    await updateSettings(updated);
  }
}
