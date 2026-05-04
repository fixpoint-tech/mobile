import 'package:flutter/material.dart';
import '../../../core/models/technician.dart';
import '../../../core/services/technician_service.dart';
import '../../user/view/edit_gpm_details_page.dart'; 
import '../widgets/generic_list_tab_content.dart';
import '../widgets/list_item_card.dart';

class GPMsTabContent extends StatelessWidget {
  const GPMsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final TechnicianService service = TechnicianService();

    return GenericListTabContent<Technician>(
      fetchItems: () async {
        return await service.getAllTechnicians();
      },
      emptyMessage: 'No GPMs found',
      itemBuilder: (context, technician) {
        return ListItemCard(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF42A5F5),
            backgroundImage: technician.profilePicture != null
                ? NetworkImage(technician.profilePicture!)
                : null,
            child: technician.profilePicture == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: technician.name,
          subtitle: '${technician.employeeId} | ${technician.specialization}',
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditGPMDetailsPage(
                  technicianId: technician.id,
                  technicianName: technician.name,
                  specialization: technician.specialization,
                ),
              ),
            ).then((value) {
              if (value == true) {
                // Refresh logic if needed (usually handled by GenericListTabContent)
              }
            });
          },
        );
      },
    );
  }
}
