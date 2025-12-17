import 'package:flutter/material.dart';

class GenericListTabContent<T> extends StatefulWidget {
  final Future<List<T>> Function() fetchItems;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyMessage;
  final String? errorMessage;

  const GenericListTabContent({
    super.key,
    required this.fetchItems,
    required this.itemBuilder,
    required this.emptyMessage,
    this.errorMessage,
  });

  @override
  State<GenericListTabContent<T>> createState() => _GenericListTabContentState<T>();
}

class _GenericListTabContentState<T> extends State<GenericListTabContent<T>> {
  List<T> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await widget.fetchItems();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = widget.errorMessage ?? e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadItems,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Text(widget.emptyMessage),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadItems,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return widget.itemBuilder(context, _items[index]);
        },
      ),
    );
  }
}
