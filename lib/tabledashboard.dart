import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Import your real booking page ──────────────────────────────
// Make sure this path matches where you saved table_slot_booking_page.dart
import 'package:snooker_app/table_slot_booking_page.dart';

// ── Theme constants (same as main.dart) ────────────────────────
const kGreen = Color(0xFF00E676);
const kRed = Color(0xFFFF3D57);
const kSurface = Color(0xFF141414);
const kSurface2 = Color(0xFF1C1C1C);
const kBorder = Color(0xFF242424);
const kMuted = Color(0xFF707070);

// ══════════════════════════════════════════════════════════════
//  TABLE DASHBOARD
// ══════════════════════════════════════════════════════════════
class TableDashboard extends StatefulWidget {
  const TableDashboard({super.key});

  @override
  State<TableDashboard> createState() => _TableDashboardState();
}

class _TableDashboardState extends State<TableDashboard> {
  static const int _totalTables = 10;

  Map<int, String> _tableStatuses = {};
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchTableStatus();
  }

  // ── Data fetching ─────────────────────────────────────────
  Future<void> _fetchTableStatus() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await Supabase.instance.client.rpc('get_table_status');

      final Map<int, String> newStatus = {};
      for (var item in response) {
        newStatus[item['table_id'] as int] = item['status'] as String;
      }

      if (mounted) {
        setState(() {
          _tableStatuses = newStatus;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('TableDashboard – fetch error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  // ── Derived counts ────────────────────────────────────────
  int get _availableCount => List.generate(
    _totalTables,
    (i) => i + 1,
  ).where((id) => (_tableStatuses[id] ?? 'available') != 'occupied').length;

  int get _occupiedCount => _totalTables - _availableCount;

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (!_isLoading && !_hasError) _buildSummaryRow(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'LIVE STATUS',
                style: TextStyle(
                  color: kMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'All Tables',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  height: 1.0,
                ),
              ),
            ],
          ),
          // Refresh button
          Material(
            color: kSurface2,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _fetchTableStatus,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: kGreen,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary chips ─────────────────────────────────────────
  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          _SummaryChip(
            color: kGreen,
            label: '$_availableCount Available',
            pulsing: _availableCount > 0,
          ),
          const SizedBox(width: 10),
          _SummaryChip(
            color: kRed,
            label: '$_occupiedCount Occupied',
            pulsing: _occupiedCount > 0,
          ),
        ],
      ),
    );
  }

  // ── Body states ───────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) return _buildLoadingState();
    if (_hasError) return _buildErrorState();
    return _buildGrid();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(color: kGreen, strokeWidth: 2.5),
          ),
          SizedBox(height: 16),
          Text(
            'Fetching table status…',
            style: TextStyle(color: kMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: kRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, color: kRed, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load tables',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _fetchTableStatus,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: kSurface2,
                foregroundColor: Colors.white,
                side: const BorderSide(color: kBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Table Grid ────────────────────────────────────────────
  Widget _buildGrid() {
    return RefreshIndicator(
      color: kGreen,
      backgroundColor: kSurface2,
      onRefresh: _fetchTableStatus,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.05,
        ),
        itemCount: _totalTables,
        itemBuilder: (context, index) {
          final tableId = index + 1;
          final isOccupied =
              (_tableStatuses[tableId] ?? 'available') == 'occupied';

          return _TableCard(
            tableId: tableId,
            isOccupied: isOccupied,
            onTap: () => _navigateToBooking(tableId, isOccupied),
          );
        },
      ),
    );
  }

  // ── Navigation ────────────────────────────────────────────
  void _navigateToBooking(int tableId, bool isOccupied) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TableSlotBookingPage(tableId: tableId, isOccupied: isOccupied),
      ),
    ).then((_) => _fetchTableStatus()); // refresh when returning
  }
}

// ══════════════════════════════════════════════════════════════
//  TABLE CARD WIDGET
// ══════════════════════════════════════════════════════════════
class _TableCard extends StatelessWidget {
  final int tableId;
  final bool isOccupied;
  final VoidCallback onTap;

  const _TableCard({
    required this.tableId,
    required this.isOccupied,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOccupied ? kRed : kGreen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.08),
        highlightColor: color.withOpacity(0.04),
        child: Ink(
          decoration: BoxDecoration(
            color: kSurface2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: icon + status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon box
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isOccupied
                            ? Icons.sports_bar_rounded
                            : Icons.circle_outlined,
                        color: color,
                        size: 18,
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pulsing dot for occupied
                          if (isOccupied) ...[
                            _PulsingDot(color: kRed),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            isOccupied ? 'PLAYING' : 'OPEN',
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Table number
                Text(
                  'Table',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '#${tableId.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 10),

                // CTA row
                Row(
                  children: [
                    Text(
                      isOccupied ? 'View slots' : 'Book now',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: color, size: 13),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SMALL REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════════
class _SummaryChip extends StatelessWidget {
  final Color color;
  final String label;
  final bool pulsing;

  const _SummaryChip({
    required this.color,
    required this.label,
    this.pulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          pulsing
              ? _PulsingDot(color: color)
              : Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Animated pulsing dot
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    ),
  );
}
