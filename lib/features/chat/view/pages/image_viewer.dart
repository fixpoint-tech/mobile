import 'package:flutter/material.dart';

class ImageGalleryViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  final String heroTagPrefix;

  const ImageGalleryViewer({
    super.key,
    required this.urls,
    this.initialIndex = 0,
    this.heroTagPrefix = '',
  });

  @override
  State<ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<ImageGalleryViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.urls.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${_index + 1}/${widget.urls.length}'),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.urls.length,
            itemBuilder: (context, i) {
              final url = widget.urls[i];
              return Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Hero(
                    tag: '${widget.heroTagPrefix}${url}_$i',
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stackTrace) => const Icon(
                        Icons.broken_image_outlined,
                        size: 64,
                        color: Colors.white70,
                      ),
                    ),
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
