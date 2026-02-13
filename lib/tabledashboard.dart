import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TableDashboard extends StatefulWidget {
  const TableDashboard({super.key});

  @override
  State<TableDashboard> createState() => _TableDashboardState();
}

class _TableDashboardState extends State<TableDashboard> {
  // Store status of 10 tables (default is empty until we fetch)
  Map<int, String> tableStatuses = {};
  final int totalTables = 10;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTableStatus();
  }

  // Fetch real-time status from Supabase
  Future<void> _fetchTableStatus() async {
    try {
      // Calls the SQL function we created: get_table_status()
      final response = await Supabase.instance.client.rpc('get_table_status');

      final Map<int, String> newStatus = {};

      // Parse the response (List of maps)
      // Example data: [{'table_id': 1, 'status': 'occupied'}, ...]
      for (var item in response) {
        newStatus[item['table_id']] = item['status'];
      }

      if (mounted) {
        setState(() {
          tableStatuses = newStatus;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching tables: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Table Status"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTableStatus, // Allow manual refresh
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 Tables side-by-side
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4, // Width vs Height ratio
                ),
                itemCount: totalTables,
                itemBuilder: (context, index) {
                  final tableId = index + 1;
                  // If status is missing, assume available.
                  // If 'occupied', show red. Else green.
                  final isOccupied = tableStatuses[tableId] == 'occupied';

                  return GestureDetector(
                    onTap: () {
                      // Navigate to the Booking Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingSchedulePage(tableId: tableId),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isOccupied
                            ? Colors.red.shade400
                            : Colors.green.shade600,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.circle, // Represents a Snooker ball
                            size: 30,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Table $tableId",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isOccupied ? "PLAYING NOW" : "OPEN",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// --- TEMPORARY PLACEHOLDER PAGE ---
// This ensures your code runs even though we haven't built the schedule page yet.
class BookingSchedulePage extends StatelessWidget {
  final int tableId;
  const BookingSchedulePage({super.key, required this.tableId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Table $tableId")),
      body: Center(child: Text("Schedule for Table $tableId goes here")),
    );
  }
}
