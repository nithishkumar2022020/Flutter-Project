import '../models/profile_settings.dart';

abstract class IProfileSettingsRepository {
  Future<ProfileSettings> loadSettings();
  Future<void> saveSettings(ProfileSettings settings);
}
