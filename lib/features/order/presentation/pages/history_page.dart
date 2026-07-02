import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_kurban_1123150007/features/order/presentation/providers/history_provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Histori Pembelian', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          if (provider.orders.isEmpty) {
            return const Center(
              child: Text('Belum ada histori pembelian', style: TextStyle(color: Colors.white70)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.orders.length,
            itemBuilder: (context, index) {
              final order = provider.orders[index];
              final itemText = order.items.map((i) => '${i.product.name} (${i.quantity}x)').join(', ');
              
              return Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.check_circle, color: Colors.green, size: 40),
                  title: Text('Order #${order.orderId}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${order.status} · Rp ${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text('Item: $itemText', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () {
                    // Bisa ditambahkan dialog detail order
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
