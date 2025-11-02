import 'package:flutter/material.dart';
import '../../../core/models/branch.dart';
import '../../../core/services/branch_service.dart';
import '../../user/view/edit_outlet_page.dart';

class OutletsTabContent extends StatefulWidget {
  const OutletsTabContent({super.key});

  @override
  State<OutletsTabContent> createState() => _OutletsTabContentState();
}

class _OutletsTabContentState extends State<OutletsTabContent> {
  final BranchService _service = BranchService();
  List<Branch> _outlets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOutlets();
  }

  Future<void> _loadOutlets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final outlets = await _service.getAllBranches();
      setState(() {
        _outlets = outlets;
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
              onPressed: _loadOutlets,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_outlets.isEmpty) {
      return const Center(
        child: Text('No outlets found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOutlets,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        itemCount: _outlets.length,
        itemBuilder: (_, i) {
          final outlet = _outlets[i];
          return _outletCard(
            context: context,
            outlet: outlet,
          );
        },
      ),
    );
  }

  Widget _outletCard({
    required BuildContext context,
    required Branch outlet,
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
                  outlet.displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  outlet.displayAddress,
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
                  builder: (context) => EditOutletPage(
                    outletId: outlet.id,
                    outletName: outlet.name,
                    outletAddress: outlet.location,
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
