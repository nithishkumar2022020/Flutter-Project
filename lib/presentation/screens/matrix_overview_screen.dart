import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/smooth_page_route.dart';
import '../widgets/brutalist_container.dart';
import 'chunk_inspector_screen.dart';

class MatrixOverviewScreen extends StatefulWidget {
  const MatrixOverviewScreen({super.key});

  @override
  State<MatrixOverviewScreen> createState() => _MatrixOverviewScreenState();
}

class _MatrixOverviewScreenState extends State<MatrixOverviewScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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

    final sampleChunks = const [
      (
        id: 'chk_784f_neural',
        label: 'Neural IR Foundations [Chunk #1]',
        score: 0.948,
      ),
      (
        id: 'chk_993b_rerank',
        label: 'Cross-Attention Reranking [Chunk #2]',
        score: 0.912,
      ),
      (
        id: 'chk_410a_context',
        label: 'Sliding-Window Attention [Chunk #3]',
        score: 0.876,
      ),
      (
        id: 'chk_102e_quant',
        label: 'HNSW Graph Quantization [Chunk #4]',
        score: 0.841,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // Header
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
                      'VECTOR MATRIX REPOSITORY',
                      style: AppTheme.monospace(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '1536-D PROJECTION',
                      style: AppTheme.monospace(
                        color: vermilion,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
                  Text(
                    'CHUNK EMBEDDING EXPLORER',
                    style: AppTheme.monospace(
                      color: mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select any chunk to drill down into its 1536-D tensor values and BM25 lexical token weights.',
                    style: AppTheme.readingSerif(
                      color: mutedText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),

            // Chunk cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = sampleChunks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BrutalistContainer(
                      onTap: () {
                        Navigator.of(context).push(
                          SmoothPageRoute(
                            page: ChunkInspectorScreen(chunkId: item.id),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: AppTheme.slabHeader(
                                    color: textColor,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'CHUNK REF: ${item.id}',
                                  style: AppTheme.monospace(
                                    color: mutedText,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            color: vermilion,
                            child: Text(
                              'INSPECT ➔',
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
                  );
                }, childCount: sampleChunks.length),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
