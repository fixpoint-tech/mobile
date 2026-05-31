import 'package:flutter/material.dart';
import '../../../core/models/branch.dart';
import '../../../core/services/branch_service.dart';
import '../../user/view/edit_outlet_page.dart';
import '../widgets/generic_list_tab_content.dart';
import '../widgets/list_item_card.dart';

class OutletsTabContent extends StatefulWidget {
  const OutletsTabContent({super.key});

  @override
  State<OutletsTabContent> createState() => _OutletsTabContentState();
}

class _OutletsTabContentState extends State<OutletsTabContent> {
  final BranchService _service = BranchService();
  int _refreshToken = 0;

  @override
  Widget build(BuildContext context) {
    return GenericListTabContent<Branch>(
      key: ValueKey(_refreshToken),
      fetchItems: _service.getAllBranches,
      emptyMessage: 'No outlets found',
      itemBuilder: (context, outlet) {
        return ListItemCard(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'lib/features/list_pages/widgets/dominoz-logo.png',
              width: 42,
              height: 42,
              fit: BoxFit.cover,
            ),
          ),
          title: outlet.displayName,
          subtitle: outlet.displayAddress,
          onEdit: () async {
            final updated = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (context) => EditOutletPage(
                  outletId: outlet.id,
                  outletName: outlet.name,
                  outletAddress: outlet.location,
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
