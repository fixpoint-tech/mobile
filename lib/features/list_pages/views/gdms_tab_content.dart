import 'package:flutter/material.dart';
import '../../../core/models/branch_manager.dart';
import '../../../core/services/branch_manager_service.dart';
import '../../user/view/edit_gdm_details_page.dart';

class GDMsTabContent extends StatefulWidget {
  const GDMsTabContent({super.key});

  @override
  State<GDMsTabContent> createState() => _GDMsTabContentState();
}

class _GDMsTabContentState extends State<GDMsTabContent> {
  final BranchManagerService _service = BranchManagerService();
  List<BranchManager> _gdms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGDMs();
  }

  Future<void> _loadGDMs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allBranchManagers = await _service.getAllBranchManagers();
      // Filter for GDMs (those without specific branch assignment)
      setState(() {
        _gdms = allBranchManagers.where((bm) => bm.branchId == null).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGDMs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_gdms.isEmpty) {
      return const Center(
        child: Text('No GDMs found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGDMs,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        itemCount: _gdms.length,
        itemBuilder: (_, i) {
          final gdm = _gdms[i];
          return _personCard(
            context: context,
            gdm: gdm,
            color: const Color(0xFFFFA726),
          );
        },
      ),
    );
  }

  Widget _personCard({
    required BuildContext context,
    required BranchManager gdm,
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
            backgroundImage: gdm.profilePicture != null
                ? NetworkImage(gdm.profilePicture!)
                : null,
            child: gdm.profilePicture == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gdm.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'GDM',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                  builder: (context) => EditGDMDetailsPage(
                    gdmId: gdm.id,
                    gdmName: gdm.name,
                    gdmOutlet: gdm.branchName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
