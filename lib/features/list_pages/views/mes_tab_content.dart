import 'package:flutter/material.dart';

class MEsTabContent extends StatelessWidget {
  const MEsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    const data = [
      {'name': 'Induwara Ranasinghe', 'meta': 'Maintenance Executive'},
      {'name': 'Chamath Perera', 'meta': 'Maintenance Executive'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      itemCount: data.length,
      itemBuilder: (_, i) {
        final m = data[i];
        return _personCard(name: m['name']!, subtitle: m['meta']!);
      },
    );
  }

  Widget _personCard({required String name, required String subtitle}) {
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
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF50B6DC),
            child: Icon(Icons.person, color: Colors.white),
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
