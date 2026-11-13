import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/mock_vector_inspector_repository.dart';
import '../../domain/models/vector_inspection.dart';
import '../widgets/brutalist_container.dart';

class ChunkInspectorScreen extends StatefulWidget {
  final String chunkId;

  const ChunkInspectorScreen({
    super.key,
    required this.chunkId,
  });

  @override
  State<ChunkInspectorScreen> createState() => _ChunkInspectorScreenState();
}

class _ChunkInspectorScreenState extends State<ChunkInspectorScreen> {
  final MockVectorInspectorRepository _inspectorRepo = MockVectorInspectorRepository();
  VectorInspectionData? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInspection();
  }

  Future<void> _loadInspection() async {
    final res = await _inspectorRepo.getChunkInspection(widget.chunkId);
    if (mounted) {
      setState(() {
        _data = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.nocturneText : AppTheme.parchmentText;
    final mutedText = isDark ? AppTheme.nocturneMutedText : AppTheme.parchmentMutedText;
    final vermilion = isDark ? AppTheme.nocturneVermilion : AppTheme.parchmentVermilion;
    final borderColor = isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VECTOR MATRIX INSPECTOR',
          style: AppTheme.monospace(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: borderColor, height: 2),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Text(
                'COMPUTING VECTOR PROJECTIONS...',
                style: AppTheme.monospace(color: mutedText, fontSize: 13),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chunk Metadata Pill
                  BrutalistContainer(
                    backgroundColor: vermilion.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CHUNK ID: ${widget.chunkId}',
                          style: AppTheme.monospace(color: vermilion, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_data?.dimension ?? 1536}-D DENSE',
                          style: AppTheme.monospace(color: textColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Document Context
                  Text(
                    'ORIGIN DOCUMENT',
                    style: AppTheme.monospace(color: mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _data?.documentTitle ?? '',
                    style: AppTheme.slabHeader(color: textColor, fontSize: 18),
                  ),
                  const SizedBox(height: 16),

                  // Raw text snippet
                  Text(
                    'EVIDENCE PASSAGE',
                    style: AppTheme.monospace(color: mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  BrutalistContainer(
                    child: Text(
                      _data?.rawChunkText ?? '',
                      style: AppTheme.readingSerif(color: textColor, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Vector Statistics
                  Text(
                    'MANIFOLD TENSOR STATS',
                    style: AppTheme.monospace(color: mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: BrutalistContainer(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('L2 NORM', style: AppTheme.monospace(color: mutedText, fontSize: 10)),
                              const SizedBox(height: 4),
                              Text('${_data?.vectorMagnitude.toStringAsFixed(4)}',
                                  style: AppTheme.monospace(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BrutalistContainer(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TENSOR MEAN', style: AppTheme.monospace(color: mutedText, fontSize: 10)),
                              const SizedBox(height: 4),
                              Text('${_data?.vectorMean.toStringAsFixed(4)}',
                                  style: AppTheme.monospace(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: BrutalistContainer(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RANGE', style: AppTheme.monospace(color: mutedText, fontSize: 10)),
                              const SizedBox(height: 4),
                              Text('[${_data?.vectorMin.toStringAsFixed(2)}, ${_data?.vectorMax.toStringAsFixed(2)}]',
                                  style: AppTheme.monospace(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 1536-D Vector Embedding Preview (Matrix Grid)
                  Text(
                    '1536-D LATENT PROJECTION (SAMPLE SLICE)',
                    style: AppTheme.monospace(color: mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  BrutalistContainer(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: (_data?.previewEmbedding ?? []).map((val) {
                            final intensity = val.abs().clamp(0.1, 1.0);
                            final isPositive = val >= 0;
                            return Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: isPositive
                                    ? vermilion.withValues(alpha: intensity)
                                    : (isDark ? AppTheme.nocturneAmber : AppTheme.parchmentAmber).withValues(alpha: intensity),
                                border: Border.all(color: borderColor, width: 1),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Showing 64 sampled coordinate projections • Unit Normalized',
                          style: AppTheme.monospace(color: mutedText, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // BM25 Token Weight Distribution
                  Text(
                    'SPARSE BM25 TOKEN WEIGHT MAP',
                    style: AppTheme.monospace(color: mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...?_data?.bm25TokenWeights.entries.map((entry) {
                    final normalizedScore = (entry.value / 5.0).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: BrutalistContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shadowOffset: const Offset(2, 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                entry.key,
                                style: AppTheme.monospace(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: normalizedScore,
                                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                color: vermilion,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              entry.value.toStringAsFixed(2),
                              style: AppTheme.monospace(color: textColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
