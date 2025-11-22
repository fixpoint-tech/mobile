import 'package:flutter/material.dart';
import '../../../core/models/branch_manager.dart';
import '../../../core/services/branch_manager_service.dart';
import '../../user/view/edit_gpm_details_page.dart';
import '../widgets/generic_list_tab_content.dart';
import '../widgets/list_item_card.dart';

class GPMsTabContent extends StatelessWidget {
  const GPMsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchManagerService service = BranchManagerService();

    return GenericListTabContent<BranchManager>(
      fetchItems: () async {
        final allBranchManagers = await service.getAllBranchManagers();
        return allBranchManagers.where((bm) => bm.branchId != null).toList();
      },
      emptyMessage: 'No GPMs found',
      itemBuilder: (context, gpm) {
        return ListItemCard(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF42A5F5),
            backgroundImage: gpm.profilePicture != null
                ? NetworkImage(gpm.profilePicture!)
                : null,
            child: gpm.profilePicture == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: gpm.name,
          subtitle: gpm.branchName != null ? 'GPM | ${gpm.branchName}' : 'GPM',
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditGPMDetailsPage(
                  gpmId: gpm.id,
                  gpmName: gpm.name,
                  gpmOutlet: gpm.branchName,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
