import 'package:flutter/material.dart';
import '../../../core/models/maintenance_executive.dart';
import '../../../core/services/maintenance_executive_service.dart';
import '../../user/view/edit_me_page.dart';

class MEsTabContent extends StatefulWidget {
  const MEsTabContent({super.key});

  @override
  State<MEsTabContent> createState() => _MEsTabContentState();
}

class _MEsTabContentState extends State<MEsTabContent> {
  final MaintenanceExecutiveService _service = MaintenanceExecutiveService();
  List<MaintenanceExecutive> _mes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMEs();
  }

  Future<void> _loadMEs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final mes = await _service.getAllMaintenanceExecutives();
      setState(() {
        _mes = mes;
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
              onPressed: _loadMEs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_mes.isEmpty) {
      return const Center(
        child: Text('No Maintenance Executives found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMEs,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        itemCount: _mes.length,
        itemBuilder: (_, i) {
          final me = _mes[i];
          return _personCard(
            context: context,
            me: me,
          );
        },
      ),
    );
  }

  Widget _personCard({
    required BuildContext context,
    required MaintenanceExecutive me,
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
            backgroundColor: const Color(0xFF66BB6A),
            backgroundImage: me.profilePicture != null
                ? NetworkImage(me.profilePicture!)
                : null,
            child: me.profilePicture == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  me.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  me.displaySubtitle,
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
                  builder: (context) => EditMEPage(
                    meId: me.id,
                    meName: me.name,
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
