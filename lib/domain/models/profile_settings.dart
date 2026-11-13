class ProfileSettings {
  final String apiKey;
  final String sseEndpoint;
  final bool isNocturneMode;
  final bool enableDenseOnly;
  final double similarityThreshold;
  final int topK;
  final bool isAuthenticated;
  final String researcherName;
  final String callSign;
  final String clearanceLevel;
  final bool isGuest;
  final bool useOfflineSimulation;

  const ProfileSettings({
    required this.apiKey,
    required this.sseEndpoint,
    required this.isNocturneMode,
    required this.enableDenseOnly,
    required this.similarityThreshold,
    required this.topK,
    this.isAuthenticated = false,
    this.researcherName = 'Nithish R.',
    this.callSign = 'ARCH-9942',
    this.clearanceLevel = 'Level-3 Architect',
    this.isGuest = false,
    this.useOfflineSimulation = false,
  });

  factory ProfileSettings.defaults() {
    return const ProfileSettings(
      apiKey: '',
      sseEndpoint: 'http://localhost:8000/questions/stream',
      isNocturneMode: false,
      enableDenseOnly: false,
      similarityThreshold: 0.75,
      topK: 5,
      isAuthenticated: false,
      researcherName: 'Nithish R.',
      callSign: 'ARCH-9942',
      clearanceLevel: 'Level-3 Architect',
      isGuest: false,
      useOfflineSimulation: false,
    );
  }

  ProfileSettings copyWith({
    String? apiKey,
    String? sseEndpoint,
    bool? isNocturneMode,
    bool? enableDenseOnly,
    double? similarityThreshold,
    int? topK,
    bool? isAuthenticated,
    String? researcherName,
    String? callSign,
    String? clearanceLevel,
    bool? isGuest,
    bool? useOfflineSimulation,
  }) {
    return ProfileSettings(
      apiKey: apiKey ?? this.apiKey,
      sseEndpoint: sseEndpoint ?? this.sseEndpoint,
      isNocturneMode: isNocturneMode ?? this.isNocturneMode,
      enableDenseOnly: enableDenseOnly ?? this.enableDenseOnly,
      similarityThreshold: similarityThreshold ?? this.similarityThreshold,
      topK: topK ?? this.topK,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      researcherName: researcherName ?? this.researcherName,
      callSign: callSign ?? this.callSign,
      clearanceLevel: clearanceLevel ?? this.clearanceLevel,
      isGuest: isGuest ?? this.isGuest,
      useOfflineSimulation: useOfflineSimulation ?? this.useOfflineSimulation,
    );
  }
}
