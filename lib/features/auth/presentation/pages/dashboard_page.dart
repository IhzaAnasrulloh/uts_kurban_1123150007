import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/auth_provider.dart';
import 'package:uts_kurban_1123150007/features/auth/presentation/providers/product_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    // Fetch produk begitu halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final product = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Background gelap
      appBar: AppBar(
        backgroundColor: const Color(0xFF311B92), // Ungu gelap
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard Kurban', style: TextStyle(fontSize: 18, color: Colors.white)),
            Text(
              'Halo Kurban Mania, ${auth.firebaseUser?.displayName ?? 'User'}!',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await auth.logout();
              if (!mounted) return;

              Navigator.pushReplacementNamed(
                context,
                AppRouter.login, // Bagian ini tetap aman, Blayy!
              );
            },
          ),
        ],
      ),

      body: switch (product.status) {
        // Loading
        ProductStatus.loading || ProductStatus.initial =>
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.purpleAccent),
                SizedBox(height: 16),
                Text(
                  'Memuat produk Kurban Uhuyyyy...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

        // Error
        ProductStatus.error =>
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  product.error ?? 'Aduhh Salah Ada Salah Ni Blayy',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi Blayy'),
                  onPressed: () => product.fetchProducts(),
                ),
              ],
            ),
          ),

        // Loaded
        ProductStatus.loaded =>
          RefreshIndicator(
            color: Colors.purpleAccent,
            onRefresh: () => product.fetchProducts(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: product.products.length,
              itemBuilder: (context, i) {
                final p = product.products[i];

                return Card(
                  color: const Color(0xFF1E1E1E), // Card gelap
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          p.imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 120,
                            color: Colors.grey.shade900,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white24,
                              size: 40,
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Rp ${p.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.purpleAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
                              ),
                              child: Text(
                                p.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      },
    );
  }
}