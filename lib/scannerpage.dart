import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert'; // To parse the JSON

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  // To prevent multiple scans happening in 1 second
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Table QR")),
      body: MobileScanner(
        onDetect: (capture) {
          if (!_isScanning) return; // Stop if we already found one

          final List<Barcode> barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              final String code = barcode.rawValue!;
              debugPrint('QR Code found! $code');

              _handleScanResult(code);
              break; // Only handle the first code found
            }
          }
        },
      ),
    );
  }

  void _handleScanResult(String rawData) {
    setState(() {
      _isScanning = false; // Stop scanning temporarily
    });

    try {
      // 1. Try to parse the JSON data
      // Expecting: {"sid":"SHOP_01","tid":"TABLE_05"}
      Map<String, dynamic> data = jsonDecode(rawData);

      String tableId = data['tid'];
      String shopId = data['sid'];

      // 2. Show Success Dialog (Later this will open Booking Page)
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Table Found!"),
          content: Text("Shop: $shopId\nTable: $tableId"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                setState(() => _isScanning = true); // Resume scanning
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      // If the QR code is garbage or not ours
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid QR Code Format")));
      setState(() => _isScanning = true);
    }
  }
}
