import 'package:flutter/material.dart';
import '../../../core/models/maintenance_executive.dart';
import '../../../core/services/maintenance_executive_service.dart';
import '../../user/view/edit_me_page.dart';
import '../widgets/generic_list_tab_content.dart';
import '../widgets/list_item_card.dart';

class MEsTabContent extends StatelessWidget {
  const MEsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final MaintenanceExecutiveService service = MaintenanceExecutiveService();

    return GenericListTabContent<MaintenanceExecutive>(
      fetchItems: service.getAllMaintenanceExecutives,
      emptyMessage: 'No Maintenance Executives found',
      itemBuilder: (context, me) {
        return ListItemCard(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF66BB6A),
            backgroundImage: me.profilePicture != null
                ? NetworkImage(me.profilePicture!)
                : null,
            child: me.profilePicture == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: me.name,
          subtitle: me.displaySubtitle,
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditMEPage(
                  meId: me.id,
                  meName: me.name,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
