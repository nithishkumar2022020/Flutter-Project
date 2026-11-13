import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/profile_settings.dart';
import '../../domain/repositories/i_profile_settings_repository.dart';

class ProfileSettingsRepository implements IProfileSettingsRepository {
  static const _kApiKey = 'rag_pref_api_key';
  static const _kSseEndpoint = 'rag_pref_sse_endpoint';
  static const _kNocturneMode = 'rag_pref_nocturne_mode';
  static const _kDenseOnly = 'rag_pref_dense_only';
  static const _kSimilarityThreshold = 'rag_pref_similarity_threshold';
  static const _kTopK = 'rag_pref_top_k';
  static const _kIsAuthenticated = 'rag_pref_is_authenticated';
  static const _kResearcherName = 'rag_pref_researcher_name';
  static const _kCallSign = 'rag_pref_call_sign';
  static const _kClearanceLevel = 'rag_pref_clearance_level';
  static const _kIsGuest = 'rag_pref_is_guest';
  static const _kUseOfflineSim = 'rag_pref_use_offline_sim';

  @override
  Future<ProfileSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final defaults = ProfileSettings.defaults();
      var endpoint = prefs.getString(_kSseEndpoint) ?? defaults.sseEndpoint;
      if (endpoint.contains('rag-internal.local') ||
          endpoint == 'http://localhost:8000/questions' ||
          endpoint == 'http://127.0.0.1:8000/questions') {
        endpoint = defaults.sseEndpoint;
      }

      return ProfileSettings(
        apiKey: prefs.getString(_kApiKey) ?? defaults.apiKey,
        sseEndpoint: endpoint,
        isNocturneMode: prefs.getBool(_kNocturneMode) ?? defaults.isNocturneMode,
        enableDenseOnly: prefs.getBool(_kDenseOnly) ?? defaults.enableDenseOnly,
        similarityThreshold: prefs.getDouble(_kSimilarityThreshold) ?? defaults.similarityThreshold,
        topK: prefs.getInt(_kTopK) ?? defaults.topK,
        isAuthenticated: prefs.getBool(_kIsAuthenticated) ?? defaults.isAuthenticated,
        researcherName: prefs.getString(_kResearcherName) ?? defaults.researcherName,
        callSign: prefs.getString(_kCallSign) ?? defaults.callSign,
        clearanceLevel: prefs.getString(_kClearanceLevel) ?? defaults.clearanceLevel,
        isGuest: prefs.getBool(_kIsGuest) ?? defaults.isGuest,
        useOfflineSimulation: prefs.getBool(_kUseOfflineSim) ?? defaults.useOfflineSimulation,
      );
    } catch (_) {
      return ProfileSettings.defaults();
    }
  }

  @override
  Future<void> saveSettings(ProfileSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kApiKey, settings.apiKey);
      await prefs.setString(_kSseEndpoint, settings.sseEndpoint);
      await prefs.setBool(_kNocturneMode, settings.isNocturneMode);
      await prefs.setBool(_kDenseOnly, settings.enableDenseOnly);
      await prefs.setDouble(_kSimilarityThreshold, settings.similarityThreshold);
      await prefs.setInt(_kTopK, settings.topK);
      await prefs.setBool(_kIsAuthenticated, settings.isAuthenticated);
      await prefs.setString(_kResearcherName, settings.researcherName);
      await prefs.setString(_kCallSign, settings.callSign);
      await prefs.setString(_kClearanceLevel, settings.clearanceLevel);
      await prefs.setBool(_kIsGuest, settings.isGuest);
      await prefs.setBool(_kUseOfflineSim, settings.useOfflineSimulation);
    } catch (_) {
      // Fallback in test/mock environment without SharedPreferences native binding
    }
  }
}
