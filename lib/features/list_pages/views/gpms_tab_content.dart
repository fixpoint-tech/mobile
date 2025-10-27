import 'package:flutter/material.dart';

class GPMsTabContent extends StatelessWidget {
  const GPMsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final data = const [
      {'name': 'Nuwan Fernando', 'meta': 'GPM | Kottawa Outlet'},
      {'name': 'Name2', 'meta': 'GPM | Outlet12'},
      {'name': 'Name3', 'meta': 'GPM | Outlet13'},
      {'name': 'Name4', 'meta': 'GPM | Outlet14'},
      {'name': 'Name5', 'meta': 'GPM | Outlet15'},
      {'name': 'Name6', 'meta': 'GPM | Outlet16'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      itemCount: data.length,
      itemBuilder: (_, i) {
        final item = data[i];
        return _personCard(
          name: item['name']!,
          subtitle: item['meta']!,
          color: const Color(0xFF42A5F5),
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
            color: Colors.black.withValues(alpha: 0.06),
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
