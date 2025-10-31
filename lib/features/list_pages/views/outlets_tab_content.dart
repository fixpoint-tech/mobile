import 'package:flutter/material.dart';
import '../../user/view/edit_outlet_page.dart';

class OutletsTabContent extends StatelessWidget {
  const OutletsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    const outlets = [
      {
        'name': "Domino's Pizza - Kolonnawa",
        'address': 'No. 445, Wellampitiya Road, Kolonnawa',
      },
      {
        'name': "Domino's Pizza - Nugegoda",
        'address': '161 High Level Road, Nugegoda 10250',
      },
      {
        'name': "Domino's Pizza - Kadawatha",
        'address': '309 Kandy Road, Kadawatha',
      },
      {
        'name': "Domino's Pizza - Ragama",
        'address': 'No. 1/34 Mahabage Road, Ragama',
      },
      {
        'name': "Domino's Pizza - Panadura",
        'address': 'No. 111B, Galle Road, Panadura',
      },
      {
        'name': "Domino's Pizza - Peradeniya",
        'address': 'No. 432, Peradeniya Road, Kandy',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      itemCount: outlets.length,
      itemBuilder: (_, i) {
        final o = outlets[i];
        return _outletCard(
          context: context,
          name: o['name']!,
          address: o['address']!,
        );
      },
    );
  }

  Widget _outletCard({
    required BuildContext context,
    required String name,
    required String address,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'lib/features/list_pages/widgets/dominoz-logo.png',
              width: 42,
              height: 42,
              fit: BoxFit.cover,
            ),
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
                  address,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: Colors.black54,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditOutletPage(outletName: name, outletAddress: address),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
