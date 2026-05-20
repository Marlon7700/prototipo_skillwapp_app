import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Base64Image extends StatefulWidget {
  final String base64Data;
  final double width;
  final double height;
  final BoxFit fit;

  const Base64Image({
    super.key,
    required this.base64Data,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<Base64Image> createState() => _Base64ImageState();
}

class _Base64ImageState extends State<Base64Image> {
  late Uint8List _bytes;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(Base64Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64Data != widget.base64Data) {
      _decode();
    }
  }

  void _decode() {
    try {
      _bytes = base64Decode(widget.base64Data);
      _error = false;
    } catch (e) {
      _error = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Icon(Icons.person, color: Colors.grey),
      );
    }
    return Image.memory(
      _bytes,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (_, __, ___) => Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Icon(Icons.person, color: Colors.grey),
      ),
    );
  }
}
