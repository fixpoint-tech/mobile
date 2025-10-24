import 'package:flutter/material.dart';

class GDMsTabContent extends StatelessWidget {
  const GDMsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final data = const [
      {'name': 'Nuwan Fernando', 'meta': 'GDM | Kottawa Outlet'},
      {'name': 'Name2', 'meta': 'GDM | Outlet2'},
      {'name': 'Name3', 'meta': 'GDM | Outlet3'},
      {'name': 'Name4', 'meta': 'GDM | Outlet4'},
      {'name': 'Name5', 'meta': 'GDM | Outlet5'},
      {'name': 'Name6', 'meta': 'GDM | Outlet6'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      itemCount: data.length,
      itemBuilder: (_, i) {
        final item = data[i];
        return _personCard(
          name: item['name']!,
          subtitle: item['meta']!,
          color: const Color(0xFFFFA726),
        );
      },
    );
  }

  Widget _personCard({
    required String name,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: Colors.black54,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
