import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart'; // CHANGED: Import gal
import 'package:permission_handler/permission_handler.dart';
import '../models.dart';
import '../services/api_service.dart';

class ImageEnhancerScreen extends StatefulWidget {
  const ImageEnhancerScreen({super.key});

  @override
  State<ImageEnhancerScreen> createState() => _ImageEnhancerScreenState();
}

class _ImageEnhancerScreenState extends State<ImageEnhancerScreen> {
  File? _image;
  final TextEditingController _descController = TextEditingController();
  bool _loading = false;
  AiResult? _result;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = null;
      });
    }
  }

  Future<void> _enhance() async {
    if (_image == null || _descController.text.isEmpty) return;
    setState(() => _loading = true);
    final res = await ApiService.enhanceImage(_image!, _descController.text);
    setState(() {
      _result = res;
      _loading = false;
    });
  }

  Future<void> _downloadImage(String path, bool isUrl) async {
    // Gal handles permissions internally for newer Android versions,
    // but explicit request is safer for older ones.
    if (Platform.isAndroid) {
       await Permission.storage.request();
       await Permission.photos.request();
    }

    try {
      // 1. Get the bytes
      Uint8List bytes;
      if (isUrl) {
        final response = await http.get(Uri.parse(path));
        bytes = response.bodyBytes;
      } else {
        bytes = base64Decode(path);
      }

      // 2. Save using Gal
      // It automatically saves to the gallery without needing complex configuration
      await Gal.putImageBytes(bytes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image saved to Gallery!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: _image != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_image!, fit: BoxFit.cover))
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.add_a_photo, size: 50, color: Colors.pink), Text("Upload Raw Photo")],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Describe the product (e.g. Handmade ceramic vase...)",
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _enhance,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Enhance Photo"),
            ),
          ),
          const SizedBox(height: 24),
          if (_result != null)
            Column(
              children: [
                const Text("Enhanced Result:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildResultDisplay(),
                const SizedBox(height: 16),
                 if (_result!.type == 'image' || _result!.type == 'url')
                  ElevatedButton.icon(
                    onPressed: () => _downloadImage(_result!.data, _result!.type == 'url'),
                    icon: const Icon(Icons.download),
                    label: const Text("Download Enhanced Image"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildResultDisplay() {
    if (_result!.type == 'url') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _result!.data,
          loadingBuilder: (c, child, progress) => progress == null ? child : const CircularProgressIndicator(),
          errorBuilder: (c,e,s) => const Text("Failed to load image"),
        ),
      );
    } else if (_result!.type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(base64Decode(_result!.data))
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Text(_result!.data),
      );
    }
  }
}
