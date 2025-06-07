///this is whole screen is for document scan and crop that and save to device storage
/// this screen use flutter_document_scanner package

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_document_scanner/flutter_document_scanner.dart';
import 'dart:io';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerState();
}

class _DocumentScannerState extends State<DocumentScannerScreen> {
  final _controller=DocumentScannerController();

  @override
  void dispose()
  {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DocumentScanner(
        controller: _controller,
        cropPhotoDocumentStyle: CropPhotoDocumentStyle(
          top: MediaQuery.of(context).padding.top,
        ),
        onSave: (Uint8List imageBytes) async{
          //when save is pressed...
          print("save to $imageBytes");
          // Create a folder in Pictures
          final String dirPath = '/storage/emulated/0/Pictures/CameraApp/Documents';
          final Directory dir = Directory(dirPath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          final String filePath='$dirPath/${DateTime.now().millisecondsSinceEpoch}.png';
          // Save file
          final file = File(filePath);
          await file.writeAsBytes(imageBytes);
        },
      ),
    );
  }
}
