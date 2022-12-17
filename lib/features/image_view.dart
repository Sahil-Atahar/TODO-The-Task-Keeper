import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

// ignore: must_be_immutable
class ImageViewer extends StatefulWidget {
  ImageViewer({required this.images, required this.imageIndex, super.key});
  List<Uint8List> images = [];
  int imageIndex = 0;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController pageController;
  @override
  void initState() {
    pageController = PageController(initialPage: widget.imageIndex);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${widget.imageIndex + 1}/${widget.images.length}'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: PhotoViewGallery.builder(
        pageController: pageController,
        backgroundDecoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        itemCount: widget.images.length,
        scrollPhysics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          widget.imageIndex = index;
          setState(() {});
        },
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: MemoryImage(widget.images.elementAt(index)),
            //initialScale: PhotoViewComputedScale.contained * 0.8,
          );
        },
      ),
    );
  }
}
