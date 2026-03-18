import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:snooker_app/table_slot_booking_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────
// ONLINE BOOKING PAGE  –  Table Grid Overview
// ─────────────────────────────────────────────
class OnlineBookingPage extends StatefulWidget {
  const OnlineBookingPage({super.key});

  @override
  State<OnlineBookingPage> createState() => _OnlineBookingPageState();
}

class _OnlineBookingPageState extends State<OnlineBookingPage> {
  Map<int, String> _tableStatuses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTableStatuses();
  }

  Future<void> _fetchTableStatuses() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.rpc('get_table_status');
      final Map<int, String> newStatus = {};
      for (var item in response) {
        newStatus[item['table_id'] as int] = item['status'] as String;
      }
      if (mounted) setState(() => _tableStatuses = newStatus);
    } catch (e) {
      debugPrint('Error fetching table statuses: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _availableCount => List.generate(
    10,
    (i) => i + 1,
  ).where((id) => (_tableStatuses[id] ?? 'available') != 'occupied').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (!_isLoading) _buildSummaryBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00E676),
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF00E676),
                      backgroundColor: const Color(0xFF1E1E1E),
                      onRefresh: _fetchTableStatuses,
                      child: _buildTableGrid(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Book a Table',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tap any table to view slots',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          IconButton(
            onPressed: _fetchTableStatuses,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00E676)),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Row(
        children: [
          _SummaryChip(
            color: const Color(0xFF00E676),
            label: '$_availableCount Available',
          ),
          const SizedBox(width: 12),
          _SummaryChip(
            color: const Color(0xFFFF5252),
            label: '${10 - _availableCount} Occupied',
          ),
        ],
      ),
    );
  }

  Widget _buildTableGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        final tableId = index + 1;
        final status = _tableStatuses[tableId] ?? 'available';
        final isOccupied = status == 'occupied';

        return _TableCard(
          tableId: tableId,
          isOccupied: isOccupied,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TableSlotBookingPage(
                  tableId: tableId,
                  isOccupied: isOccupied,
                ),
              ),
            ).then((_) => _fetchTableStatuses()); // Refresh on return
          },
        );
      },
    );
  }
}

// ─────────────────────────────────
// Small summary chip widget
// ─────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final Color color;
  final String label;
  const _SummaryChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────
// Individual Table Card
// ─────────────────────────────────
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
    final Color accentColor = isOccupied
        ? const Color(0xFFFF5252)
        : const Color(0xFF00E676);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.35), width: 1.5),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.sports_bar_rounded, // billiard-ish icon
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isOccupied ? 'PLAYING' : 'OPEN',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Table name
              Text(
                'Table',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '#${tableId.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 12),

              // CTA row
              Row(
                children: [
                  Text(
                    isOccupied ? 'View slots' : 'Book now',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: accentColor, size: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
