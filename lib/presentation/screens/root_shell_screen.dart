import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/utils/smooth_page_route.dart';
import '../widgets/mini_dock.dart';
import 'chunk_inspector_screen.dart';
import 'graph_telemetry_screen.dart';
import 'ingestion_screen.dart';
import 'matrix_overview_screen.dart';
import 'query_canvas_screen.dart';

class RootShellScreen extends StatefulWidget {
  const RootShellScreen({super.key});

  @override
  State<RootShellScreen> createState() => RootShellScreenState();
}

class RootShellScreenState extends State<RootShellScreen> {
  late final PageController _pageController;
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(1);
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageNotifier.value);
    _pages = [
      RepaintBoundary(
        child: IngestionScreen(
          onNavigateToQuery: autoRouteToQueryCanvas,
        ),
      ),
      RepaintBoundary(
        child: QueryCanvasScreen(
          onNavigateToCorpus: () => navigateToPage(0),
        ),
      ),
      const RepaintBoundary(
        child: MatrixOverviewScreen(),
      ),
      const RepaintBoundary(
        child: GraphTelemetryScreen(),
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  void navigateToPage(int page) {
    if (page == _currentPageNotifier.value) return;
    _currentPageNotifier.value = page;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
    );
  }

  void autoRouteToQueryCanvas() {
    navigateToPage(1);
  }

  void inspectChunkInMatrix(String chunkId) {
    Navigator.of(context).push(
      SmoothPageRoute(
        page: ChunkInspectorScreen(chunkId: chunkId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        dragStartBehavior: DragStartBehavior.down,
        physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
        onPageChanged: (page) {
          if (_currentPageNotifier.value != page) {
            _currentPageNotifier.value = page;
          }
        },
        children: _pages,
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _currentPageNotifier,
        builder: (context, activeIndex, _) {
          return MiniDock(
            currentIndex: activeIndex,
            onTabSelected: navigateToPage,
          );
        },
      ),
    );
  }
}
