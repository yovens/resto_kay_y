
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color teal = Color(0xFF087F8C);
  static const Color background = Color(0xFFF5F7FA);

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _user = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ApiClient.instance.get('/me');

      if (!mounted) return;

      if (response is Map) {
        final data = response['user'] ?? response['data'] ?? response;
        if (data is Map) {
          setState(() {
            _user = Map<String, dynamic>.from(data);
            _loading = false;
          });
          return;
        }
      }

      setState(() {
        _loading = false;
        _error = 'Enfòmasyon pwofil la pa nan bon fòma.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String _getValue(List<String> keys, {String fallback = 'Pa disponib'}) {
    for (final key in keys) {
      final value = _user[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  String get _name =>
      _getValue(['name', 'nom', 'username'], fallback: 'Itilizatè');

  String get _email =>
      _getValue(['email', 'courriel'], fallback: 'Pa gen imèl');

  String get _phone =>
      _getValue(['telephone', 'phone', 'tel'], fallback: 'Pa gen telefòn');

  String get _role =>
      _getValue(['role', 'fonction'], fallback: 'Kliyan');

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dekonekte'),
        content: const Text(
          'Èske ou sèten ou vle dekonekte sou kont ou?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Anile'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Dekonekte'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ApiClient.instance.post('/logout', body: {});
    } catch (_) {
      // Menm si sèvè a pa reponn, retire token lokal la.
    }

    await ApiClient.instance.clearToken();

    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Pwofil mwen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172B36),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadProfile,
            tooltip: 'Rafrechi',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: teal),
            )
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  color: teal,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Enfòmasyon pèsonèl'),
                      const SizedBox(height: 12),
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Kont mwen'),
                      const SizedBox(height: 12),
                      _buildMenuCard(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Kòmand mwen yo',
                        subtitle: 'Gade kòmand ou pase yo',
                        onTap: () => context.push('/orders'),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuCard(
                        icon: Icons.restaurant_menu,
                        title: 'Dekouvri meni an',
                        subtitle: 'Chwazi plat ou pi renmen yo',
                        onTap: () => context.go('/menu'),
                      ),
                      const SizedBox(height: 12),
                      _buildMenuCard(
                        icon: Icons.lock_outline,
                        title: 'Sekirite kont',
                        subtitle: 'Pwoteje enfòmasyon ou yo',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fonksyon sekirite a poko aktive.',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Dekonekte'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'Resto Kay-Y • Bon manje, bon moman ❤️',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 56,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nou pa kapab chaje pwofil ou.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Eseye ankò'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final initial = _name.trim().isNotEmpty
        ? _name.trim().substring(0, 1).toUpperCase()
        : 'U';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [teal, Color(0xFF12A6A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 43,
            backgroundColor: Colors.white,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: teal,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _role.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF172B36),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.person_outline,
            'Non konplè',
            _name,
          ),
          const Divider(height: 28),
          _infoRow(
            Icons.email_outlined,
            'Imèl',
            _email,
          ),
          const Divider(height: 28),
          _infoRow(
            Icons.phone_outlined,
            'Telefòn',
            _phone,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: teal.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: teal, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF172B36),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: teal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: teal, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
