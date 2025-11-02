import 'package:flutter/material.dart';
import '../../../core/models/branch_manager.dart';
import '../../../core/services/branch_manager_service.dart';
import '../../user/view/edit_gpm_details_page.dart';

class GPMsTabContent extends StatefulWidget {
  const GPMsTabContent({super.key});

  @override
  State<GPMsTabContent> createState() => _GPMsTabContentState();
}

class _GPMsTabContentState extends State<GPMsTabContent> {
  final BranchManagerService _service = BranchManagerService();
  List<BranchManager> _gpms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGPMs();
  }

  Future<void> _loadGPMs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allBranchManagers = await _service.getAllBranchManagers();
      // Filter for GPMs (those with branch assignment)
      setState(() {
        _gpms = allBranchManagers.where((bm) => bm.branchId != null).toList();
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
              onPressed: _loadGPMs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_gpms.isEmpty) {
      return const Center(
        child: Text('No GPMs found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGPMs,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        itemCount: _gpms.length,
        itemBuilder: (_, i) {
          final gpm = _gpms[i];
          return _personCard(
            context: context,
            gpm: gpm,
            color: const Color(0xFF42A5F5),
          );
        },
      ),
    );
  }

  Widget _personCard({
    required BuildContext context,
    required BranchManager gpm,
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
            backgroundImage: gpm.profilePicture != null
                ? NetworkImage(gpm.profilePicture!)
                : null,
            child: gpm.profilePicture == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gpm.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gpm.branchName != null ? 'GPM | ${gpm.branchName}' : 'GPM',
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
                  builder: (context) => EditGPMDetailsPage(
                    gpmId: gpm.id,
                    gpmName: gpm.name,
                    gpmOutlet: gpm.branchName,
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
