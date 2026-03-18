import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────
// TABLE SLOT BOOKING PAGE  –  View & book time slots
// ─────────────────────────────────────────────────────────
class TableSlotBookingPage extends StatefulWidget {
  final int tableId;
  final bool isOccupied;

  const TableSlotBookingPage({
    super.key,
    required this.tableId,
    required this.isOccupied,
  });

  @override
  State<TableSlotBookingPage> createState() => _TableSlotBookingPageState();
}

class _TableSlotBookingPageState extends State<TableSlotBookingPage> {
  // ── Config ──────────────────────────────────────
  static const int _pricePerHour = 25;
  static const int _openHour = 10;
  static const int _closeHour = 24; // midnight
  static const List<int> _durations = [1, 2, 3, 4, 5];

  // ── State ────────────────────────────────────────
  DateTime _selectedDate = DateTime.now();
  int _selectedHour = -1;
  int _durationHours = 2;
  List<int> _bookedSlots = [];
  bool _isLoading = true;
  bool _isBooking = false;

  final List<int> _operatingHours = List.generate(
    _closeHour - _openHour,
    (i) => _openHour + i,
  );

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  // ── Data fetching ────────────────────────────────
  Future<void> _fetchBookedSlots() async {
    setState(() => _isLoading = true);
    try {
      // Fetch bookings from Supabase for this table on the selected date
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      final response = await Supabase.instance.client
          .from('bookings')
          .select('start_hour, duration_hours')
          .eq('table_id', widget.tableId)
          .eq('booking_date', dateStr);

      final List<int> booked = [];
      for (var booking in response) {
        final int start = booking['start_hour'] as int;
        final int duration = booking['duration_hours'] as int;
        for (int h = start; h < start + duration; h++) {
          booked.add(h);
        }
      }

      if (mounted) setState(() => _bookedSlots = booked);
    } catch (e) {
      debugPrint('Error fetching booked slots: $e');
      // Fallback to empty – user can still attempt booking
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Validation helpers ────────────────────────────
  bool _isSlotAvailable(int hour) {
    for (int h = hour; h < hour + _durationHours; h++) {
      if (_bookedSlots.contains(h)) return false;
    }
    return true;
  }

  bool _wouldConflict(int hour) {
    // Would selecting this hour with current duration cause conflict?
    for (int h = hour; h < hour + _durationHours; h++) {
      if (_bookedSlots.contains(h)) return true;
    }
    return false;
  }

  bool get _canBook =>
      _selectedHour != -1 && _isSlotAvailable(_selectedHour) && !_isBooking;

  // ── Date picker ───────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E676),
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedHour = -1; // Reset selection on date change
      });
      _fetchBookedSlots();
    }
  }

  // ── Booking action ────────────────────────────────
  Future<void> _confirmBooking() async {
    if (!_canBook) return;
    setState(() => _isBooking = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      await Supabase.instance.client.from('bookings').insert({
        'table_id': widget.tableId,
        'user_id': user?.id,
        'booking_date': dateStr,
        'start_hour': _selectedHour,
        'duration_hours': _durationHours,
        'total_amount': _pricePerHour * _durationHours,
        'status': 'confirmed',
      });

      if (mounted) {
        final dateDisplay =
            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
        final timeDisplay =
            '$_selectedHour:00 – ${_selectedHour + _durationHours}:00';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSuccessPage(
              tableId: widget.tableId,
              date: dateDisplay,
              time: timeDisplay,
              amount: _pricePerHour * _durationHours,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  // ── UI ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table #${widget.tableId.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.isOccupied ? 'Currently occupied' : 'Available now',
              style: TextStyle(
                fontSize: 12,
                color: widget.isOccupied
                    ? const Color(0xFFFF5252)
                    : const Color(0xFF00E676),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00E676)),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateSelector(),
                        const SizedBox(height: 28),
                        _buildSlotLegend(),
                        const SizedBox(height: 16),
                        _buildTimeGrid(),
                        const SizedBox(height: 28),
                        _buildDurationSelector(),
                        const SizedBox(height: 28),
                        _buildBookingSummary(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Date Selector ─────────────────────────────────
  Widget _buildDateSelector() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    final isTomorrow = _isSameDay(
      _selectedDate,
      DateTime.now().add(const Duration(days: 1)),
    );
    final label = isToday
        ? 'Today'
        : isTomorrow
        ? 'Tomorrow'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Select Date'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00E676).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF00E676),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_dayName(_selectedDate)}, ${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (label != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Legend ────────────────────────────────────────
  Widget _buildSlotLegend() {
    return Row(
      children: [
        _LegendDot(
          color: const Color(0xFF1A1A1A),
          label: 'Available',
          border: const Color(0xFF333333),
        ),
        const SizedBox(width: 16),
        _LegendDot(color: const Color(0xFF00E676), label: 'Selected'),
        const SizedBox(width: 16),
        _LegendDot(
          color: const Color(0xFF2A2A2A),
          label: 'Booked',
          textColor: Colors.grey,
        ),
      ],
    );
  }

  // ── Time Grid ─────────────────────────────────────
  Widget _buildTimeGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Pick Start Time'),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _operatingHours.length,
          itemBuilder: (context, index) {
            final hour = _operatingHours[index];
            final isBooked = _bookedSlots.contains(hour);
            final isSelected = _selectedHour == hour;
            final wouldConflict =
                !isBooked && _selectedHour != hour && _wouldConflict(hour);

            Color bgColor;
            Color textColor;
            Color? borderColor;

            if (isSelected) {
              bgColor = const Color(0xFF00E676);
              textColor = Colors.black;
              borderColor = null;
            } else if (isBooked) {
              bgColor = const Color(0xFF2A2A2A);
              textColor = Colors.grey.shade700;
              borderColor = null;
            } else {
              bgColor = const Color(0xFF1A1A1A);
              textColor = Colors.white;
              borderColor = const Color(0xFF333333);
            }

            return GestureDetector(
              onTap: isBooked
                  ? null
                  : () => setState(() => _selectedHour = hour),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: borderColor != null
                      ? Border.all(color: borderColor)
                      : null,
                ),
                child: Center(
                  child: Text(
                    _formatHour(hour),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Duration Selector ─────────────────────────────
  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Duration'),
        const SizedBox(height: 10),
        Row(
          children: _durations.map((d) {
            final isSelected = _durationHours == d;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _durationHours = d;
                    // Re-validate selection
                    if (_selectedHour != -1 &&
                        !_isSlotAvailable(_selectedHour)) {
                      _selectedHour = -1;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: d != _durations.last ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00E676)
                        : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? null
                        : Border.all(color: const Color(0xFF333333)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$d',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        d == 1 ? 'hr' : 'hrs',
                        style: TextStyle(
                          color: isSelected ? Colors.black87 : Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Booking Summary ───────────────────────────────
  Widget _buildBookingSummary() {
    if (_selectedHour == -1) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 18),
            SizedBox(width: 10),
            Text(
              'Select a start time to see your booking summary',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final endHour = _selectedHour + _durationHours;
    final total = _pricePerHour * _durationHours;
    final isConflict = !_isSlotAvailable(_selectedHour);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConflict
            ? const Color(0xFFFF5252).withOpacity(0.08)
            : const Color(0xFF00E676).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isConflict
              ? const Color(0xFFFF5252).withOpacity(0.4)
              : const Color(0xFF00E676).withOpacity(0.4),
        ),
      ),
      child: isConflict
          ? const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFF5252),
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This duration overlaps a booked slot. Try a shorter duration or different time.',
                    style: TextStyle(color: Color(0xFFFF5252), fontSize: 13),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _SummaryRow(
                  label: 'Table',
                  value: '#${widget.tableId.toString().padLeft(2, '0')}',
                ),
                const Divider(color: Color(0xFF2A2A2A), height: 20),
                _SummaryRow(
                  label: 'Time',
                  value:
                      '${_formatHour(_selectedHour)} – ${_formatHour(endHour)}',
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Duration',
                  value: '$_durationHours hour${_durationHours > 1 ? 's' : ''}',
                ),
                const Divider(color: Color(0xFF2A2A2A), height: 20),
                _SummaryRow(
                  label: 'Total',
                  value: 'RM ${total.toStringAsFixed(0)}',
                  valueColor: const Color(0xFF00E676),
                  bold: true,
                ),
              ],
            ),
    );
  }

  // ── Bottom Action Bar ─────────────────────────────
  Widget _buildBottomBar() {
    final total = _selectedHour != -1 ? _pricePerHour * _durationHours : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedHour != -1 && _isSlotAvailable(_selectedHour))
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  Text(
                    'RM ${total.toStringAsFixed(0)}.00',
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: _canBook ? _confirmBooking : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                disabledBackgroundColor: const Color(0xFF2A2A2A),
                disabledForegroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isBooking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _selectedHour == -1
                          ? 'SELECT A TIME SLOT'
                          : 'CONFIRM BOOKING',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatHour(int hour) {
    if (hour >= 24) hour = hour - 24;
    final suffix = hour < 12 ? 'AM' : 'PM';
    final display = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$display$suffix';
  }

  String _dayName(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}

// ── Reusable small widgets ─────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Colors.grey,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final Color? border;
  final Color? textColor;

  const _LegendDot({
    required this.color,
    required this.label,
    this.border,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: border != null ? Border.all(color: border!) : null,
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(color: textColor ?? Colors.grey, fontSize: 12),
      ),
    ],
  );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      Text(
        value,
        style: TextStyle(
          color: valueColor ?? Colors.white,
          fontSize: bold ? 16 : 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────
// BOOKING SUCCESS PAGE
// ─────────────────────────────────────────────────────────
class BookingSuccessPage extends StatelessWidget {
  final int tableId;
  final String date;
  final String time;
  final int amount;

  const BookingSuccessPage({
    super.key,
    required this.tableId,
    required this.date,
    required this.time,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Success icon with glow effect
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF00E676),
                      size: 72,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Booking Confirmed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'See you at the table 🎱',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),

              const SizedBox(height: 36),

              // Receipt card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00E676).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _receiptRow(
                      'Table',
                      '#${tableId.toString().padLeft(2, '0')}',
                    ),
                    const Divider(color: Color(0xFF2A2A2A), height: 24),
                    _receiptRow('Date', date),
                    const SizedBox(height: 10),
                    _receiptRow('Time', time),
                    const Divider(color: Color(0xFF2A2A2A), height: 24),
                    _receiptRow(
                      'Total Paid',
                      'RM $amount.00',
                      valueColor: const Color(0xFF00E676),
                      bold: true,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action buttons
              FilledButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'BACK TO HOME',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Back to booking page
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF333333)),
                  minimumSize: const Size.fromHeight(54),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'BOOK ANOTHER SLOT',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(
    String label,
    String value, {
    Color? valueColor,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: bold ? 18 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
