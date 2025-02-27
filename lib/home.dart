import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import halaman-halaman yang diperlukan (anggap sudah ada)
import 'produk/produk.dart';
import 'pelanggan.dart';
import 'transaksi.dart';
import 'riwayat.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Transaksi sebagai halaman default (indeks 0)
  bool _isDrawerOpen = true;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi halaman-halaman (TransaksiPage ada di indeks 0)
    _pages = [
      const TransaksiPage(),
      const ProdukPage(),
      const PelangganPage(),
      const RiwayatPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _getTitleForSelectedIndex(),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleDrawer,
        ),
      ),
      body: Row(
        children: [
          // Collapsible Sidebar Navigation
          if (_isDrawerOpen)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 280,
              child: Drawer(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header with user info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Circle avatar with first letter of email
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    (widget.user.email ?? '').isNotEmpty
                                        ? (widget.user.email ?? '')[0]
                                            .toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                                // Close drawer button
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: _toggleDrawer,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // User email
                            Text(
                              widget.user.email ?? 'User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),

                            const SizedBox(height: 8),

                            // Logout button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.logout, size: 18),
                                label: const Text('Logout'),
                                onPressed: _logout,
                                style: OutlinedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  side: const BorderSide(color: Colors.red),
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),
                            const Divider(),
                          ],
                        ),
                      ),

                      // Navigation items
                      ListTile(
                        leading: const Icon(Icons.shopping_cart),
                        title: const Text('Transaksi'),
                        selected: _selectedIndex == 0,
                        selectedTileColor: Colors.blue.withOpacity(0.1),
                        selectedColor: Colors.blue,
                        onTap: () => _onItemTapped(0),
                      ),
                      ListTile(
                        leading: const Icon(Icons.inventory),
                        title: const Text('Produk'),
                        selected: _selectedIndex == 1,
                        selectedTileColor: Colors.blue.withOpacity(0.1),
                        selectedColor: Colors.blue,
                        onTap: () => _onItemTapped(1),
                      ),
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text('Pelanggan'),
                        selected: _selectedIndex == 2,
                        selectedTileColor: Colors.blue.withOpacity(0.1),
                        selectedColor: Colors.blue,
                        onTap: () => _onItemTapped(2),
                      ),
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('Riwayat'),
                        selected: _selectedIndex == 3,
                        selectedTileColor: Colors.blue.withOpacity(0.1),
                        selectedColor: Colors.blue,
                        onTap: () => _onItemTapped(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Main content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }

  // Helper method to get the appropriate title based on selected index
  Widget _getTitleForSelectedIndex() {
    switch (_selectedIndex) {
      case 0:
        return const Text('Transaksi');
      case 1:
        return const Text('Produk');
      case 2:
        return const Text('Pelanggan');
      case 3:
        return const Text('Riwayat');
      default:
        return const Text('Aplikasi');
    }
  }
}
