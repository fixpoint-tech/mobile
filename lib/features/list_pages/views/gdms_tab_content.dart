import 'package:flutter/material.dart';
import '../../../core/models/branch_manager.dart';
import '../../../core/services/branch_manager_service.dart';
import '../../user/view/edit_gdm_details_page.dart';
import '../widgets/generic_list_tab_content.dart';
import '../widgets/list_item_card.dart';

class GDMsTabContent extends StatefulWidget {
  const GDMsTabContent({super.key});

  @override
  State<GDMsTabContent> createState() => _GDMsTabContentState();
}

class _GDMsTabContentState extends State<GDMsTabContent> {
  final BranchManagerService _service = BranchManagerService();
  int _refreshToken = 0;

  @override
  Widget build(BuildContext context) {
    return GenericListTabContent<BranchManager>(
      key: ValueKey(_refreshToken),
      fetchItems: () async {
        final allBranchManagers = await _service.getAllBranchManagers();
        return allBranchManagers.where((bm) => bm.branchId != null).toList();
      },
      emptyMessage: 'No GDMs found',
      itemBuilder: (context, gdm) {
        return ListItemCard(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFFA726),
            backgroundImage: gdm.profilePicture != null
                ? NetworkImage(gdm.profilePicture!)
                : null,
            child: gdm.profilePicture == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: gdm.name,
          subtitle: gdm.branchName != null
              ? '${gdm.employeeId} | ${gdm.branchName}'
              : 'GDM',
          onEdit: () async {
            final updated = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (context) => EditGDMDetailsPage(
                  gdmId: gdm.id,
                  gdmName: gdm.name,
                  gdmOutlet: gdm.branchName,
                ),
              ),
            );
            if (updated == true && mounted) {
              setState(() => _refreshToken++);
            }
          },
        );
      },
    );
  }
}
