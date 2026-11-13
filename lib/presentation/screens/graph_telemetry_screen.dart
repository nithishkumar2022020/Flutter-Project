import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/smooth_page_route.dart';
import '../../data/repositories/mock_graph_repository.dart';
import '../../domain/models/knowledge_graph.dart';
import '../providers/settings_provider.dart';
import '../providers/telemetry_provider.dart';
import '../widgets/brutalist_container.dart';
import 'user_profile_screen.dart';

class GraphTelemetryScreen extends StatefulWidget {
  const GraphTelemetryScreen({super.key});

  @override
  State<GraphTelemetryScreen> createState() => _GraphTelemetryScreenState();
}

class _GraphTelemetryScreenState extends State<GraphTelemetryScreen>
    with AutomaticKeepAliveClientMixin {
  final MockGraphRepository _graphRepo = MockGraphRepository();
  KnowledgeGraphData? _graphData;
  late TextEditingController _apiKeyController;
  late TextEditingController _sseUrlController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _sseUrlController = TextEditingController();
    _loadGraph();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.read<SettingsProvider>().settings;
    if (_apiKeyController.text.isEmpty) {
      _apiKeyController.text = settings.apiKey;
    }
    if (_sseUrlController.text.isEmpty) {
      _sseUrlController.text = settings.sseEndpoint;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _sseUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadGraph() async {
    final g = await _graphRepo.getKnowledgeGraph();
    if (mounted) {
      setState(() {
        _graphData = g;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.nocturneText : AppTheme.parchmentText;
    final mutedText =
        isDark ? AppTheme.nocturneMutedText : AppTheme.parchmentMutedText;
    final vermilion =
        isDark ? AppTheme.nocturneVermilion : AppTheme.parchmentVermilion;
    final borderColor =
        isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;
    final surfaceColor =
        isDark ? AppTheme.nocturneSurface : AppTheme.parchmentSurface;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // Top Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TELEMETRY & GRAPH DIAGNOSTICS',
                      style: AppTheme.monospace(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Consumer<SettingsProvider>(
                      builder:
                          (context, settingsProv, _) => GestureDetector(
                            onTap: () => settingsProv.toggleNocturneMode(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              color:
                                  isDark
                                      ? AppTheme.nocturneAmber
                                      : AppTheme.parchmentAmber,
                              child: Text(
                                isDark ? '☀️ PARCHMENT' : '🌙 NOCTURNE',
                                style: AppTheme.monospace(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Telemetry Section
                  Text(
                    'REAL-TIME RETRIEVAL TELEMETRY',
                    style: AppTheme.monospace(
                      color: mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Consumer<TelemetryProvider>(
                    builder: (context, telemetryProv, _) {
                      final t = telemetryProv.telemetry;
                      if (t == null) {
                        return Center(
                          child: Text(
                            'MEASURING...',
                            style: AppTheme.monospace(
                              color: mutedText,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: BrutalistContainer(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TOTAL LATENCY',
                                        style: AppTheme.monospace(
                                          color: mutedText,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${t.totalLatencyMs} ms',
                                        style: AppTheme.monospace(
                                          color: vermilion,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Target: <200ms',
                                        style: AppTheme.monospace(
                                          color: mutedText,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: BrutalistContainer(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'RERANK OVERHEAD',
                                        style: AppTheme.monospace(
                                          color: mutedText,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${t.rerankLatencyMs} ms',
                                        style: AppTheme.monospace(
                                          color: textColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        t.rerankerModel,
                                        style: AppTheme.monospace(
                                          color: mutedText,
                                          fontSize: 8,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          BrutalistContainer(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'DENSE COSINE SCORE',
                                      style: AppTheme.monospace(
                                        color: textColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      t.denseRetrievalScore.toStringAsFixed(3),
                                      style: AppTheme.monospace(
                                        color: vermilion,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'SPARSE BM25 SCORE',
                                      style: AppTheme.monospace(
                                        color: textColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      t.sparseBM25Score.toStringAsFixed(2),
                                      style: AppTheme.monospace(
                                        color: textColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'CANDIDATES PRUNED',
                                      style: AppTheme.monospace(
                                        color: mutedText,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      '${t.prunedCandidates} / ${t.totalCandidates}',
                                      style: AppTheme.monospace(
                                        color: mutedText,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Knowledge Graph Manifest
                  Text(
                    'KNOWLEDGE GRAPH TOPOLOGY',
                    style: AppTheme.monospace(
                      color: mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BrutalistContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_graphData?.nodes.length ?? 0} NODES • ${_graphData?.edges.length ?? 0} TYPED EDGES',
                          style: AppTheme.monospace(
                            color: vermilion,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              (_graphData?.nodes ?? []).map((node) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${node.label} (${node.category})',
                                    style: AppTheme.monospace(
                                      color: textColor,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Operator Field Dossier Link
                  Text(
                    'OPERATOR CLEARANCE & IDENTITY',
                    style: AppTheme.monospace(
                      color: mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<SettingsProvider>(
                    builder:
                        (context, settingsProv, _) => GestureDetector(
                          key: const Key('telemetry_view_dossier_btn'),
                          onTap: () {
                            Navigator.of(context).push(
                              SmoothPageRoute(page: const UserProfileScreen()),
                            );
                          },
                          child: BrutalistContainer(
                            backgroundColor: surfaceColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      settingsProv.researcherName.toUpperCase(),
                                      style: AppTheme.slabHeader(
                                        color: textColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'CLEARANCE: ${settingsProv.clearanceLevel}',
                                      style: AppTheme.monospace(
                                        color: vermilion,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  color: vermilion,
                                  child: Text(
                                    'VIEW DOSSIER ➔',
                                    style: AppTheme.monospace(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Settings Persistence
                  Text(
                    'PROFILE & ENDPOINT CONFIGURATION',
                    style: AppTheme.monospace(
                      color: mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  BrutalistContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BACKEND QUESTION ENDPOINT (JSON / SSE)',
                          style: AppTheme.monospace(
                            color: mutedText,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          color: surfaceColor,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                            controller: _sseUrlController,
                            style: AppTheme.monospace(
                              color: textColor,
                              fontSize: 12,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'API AUTH TOKEN (OPTIONAL)',
                          style: AppTheme.monospace(
                            color: mutedText,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          color: surfaceColor,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                            controller: _apiKeyController,
                            obscureText: true,
                            style: AppTheme.monospace(
                              color: textColor,
                              fontSize: 12,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Consumer<SettingsProvider>(
                          builder:
                              (context, prov, _) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'OFFLINE DEMO SIMULATION',
                                    style: AppTheme.monospace(
                                      color: textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Switch(
                                    value: prov.settings.useOfflineSimulation,
                                    activeThumbColor: vermilion,
                                    onChanged: (val) {
                                      prov.updateSettings(
                                        prov.settings.copyWith(
                                          useOfflineSimulation: val,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            final prov = context.read<SettingsProvider>();
                            prov.updateSettings(
                              prov.settings.copyWith(
                                sseEndpoint: _sseUrlController.text.trim(),
                                apiKey: _apiKeyController.text.trim(),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Settings saved locally.',
                                  style: AppTheme.monospace(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: vermilion,
                              ),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            color: vermilion,
                            child: Text(
                              'PERSIST CONFIGURATION',
                              style: AppTheme.monospace(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
