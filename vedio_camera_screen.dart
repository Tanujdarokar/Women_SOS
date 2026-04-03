import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:women_sos/main.dart';
import 'package:women_sos/services/api_service.dart';
import 'package:women_sos/services/sms_services.dart';

class CameraVideoScreen extends StatefulWidget {
  final String mode;
  const CameraVideoScreen({super.key, required this.mode});
  @override
  State<CameraVideoScreen> createState() => _CameraVideoScreenState();
}

class _CameraVideoScreenState extends State<CameraVideoScreen> with WidgetsBindingObserver {
  CameraController? controller;
  bool isInitialized = false;
  bool isRecording = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initializeCamera();
    }
  }

  Future<void> initializeCamera() async {
    if (cameras.isEmpty) {
      debugPrint("No cameras available");
      return;
    }

    // Optimization: Quick disposal if already exists
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium, // Optimization: Medium preset for faster init
      enableAudio: widget.mode == "Video", // Only enable audio if needed
      imageFormatGroup: ImageFormatGroup.yuv420, // Fixed: Changed ImageFormatType to ImageFormatGroup
    );

    try {
      await controller!.initialize();
      if (mounted) setState(() => isInitialized = true);
    } catch (e) {
      debugPrint("Camera Init Error: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  Future<void> _handleAction() async {
    if (controller == null || !controller!.value.isInitialized) return;

    if (widget.mode == "Camera") {
      await _takePicture();
    } else {
      if (isRecording) {
        await _stopRecording();
      } else {
        await _startRecording();
      }
    }
  }

  Future<String> _saveLocally(XFile file, String type) async {
    final directory = await getApplicationDocumentsDirectory();
    final evidenceDir = Directory('${directory.path}/evidence');
    if (!await evidenceDir.exists()) {
      await evidenceDir.create(recursive: true);
    }

    String ext = path.extension(file.path);
    if (type == "Video" && (ext.isEmpty || ext == ".temp")) {
      ext = ".mp4";
    } else if (type == "Photo" && (ext.isEmpty || ext == ".temp")) {
      ext = ".jpg";
    }

    final String fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final String localPath = '${evidenceDir.path}/$fileName';
    await File(file.path).copy(localPath);
    return localPath;
  }

  Future<void> _takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return;

    setState(() => isUploading = true);
    try {
      final XFile photo = await controller!.takePicture();
      // Optimization: Fire and forget saving/uploading to keep UI responsive
      _processEvidence(photo, "Photo");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Photo evidence captured and processing!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Take Picture Error: $e");
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> _processEvidence(XFile file, String type) async {
    final path = await _saveLocally(file, type);
    await ApiService.uploadEvidence(path, type);
    final contacts = await ApiService.getContacts();
    await SMSService.sendEvidenceAlert(type, contacts);
  }

  Future<void> _startRecording() async {
    if (controller == null || !controller!.value.isInitialized || isRecording) return;

    try {
      await controller!.startVideoRecording();
      if (mounted) setState(() => isRecording = true);
    } catch (e) {
      debugPrint("Start Recording Error: $e");
    }
  }

  Future<void> _stopRecording() async {
    if (controller == null || !controller!.value.isInitialized || !isRecording) return;

    setState(() {
      isRecording = false;
      isUploading = true;
    });

    try {
      final XFile video = await controller!.stopVideoRecording();
      _processEvidence(video, "Video");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Video evidence recorded and processing!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Stop Recording Error: $e");
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (!isInitialized || controller == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.pink),
              const SizedBox(height: 20),
              Text("Initializing ${widget.mode}...", style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Immserive Camera Preview
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.previewSize?.height ?? 1,
                height: controller!.value.previewSize?.width ?? 1,
                child: CameraPreview(controller!),
              ),
            ),
          ),

          // Top Header Overlay
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Icon(widget.mode == "Camera" ? Icons.camera_alt_rounded : Icons.videocam_rounded, 
                           color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        widget.mode.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isRecording)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.fiber_manual_record, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text("REC", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Controls Overlay
          Container(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 100),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(theme),
              ],
            ),
          ),

          // Uploading State Overlay (Non-blocking)
          if (isUploading)
            Positioned(
              top: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.pink)),
                    SizedBox(width: 12),
                    Text("Securing Evidence...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    final bool isCamera = widget.mode == "Camera";
    final Color btnColor = isRecording ? Colors.white : (isCamera ? theme.colorScheme.primary : Colors.red);
    
    return GestureDetector(
      onTap: isUploading ? null : _handleAction,
      child: Container(
        height: 85,
        width: 85,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: btnColor,
            boxShadow: [
              BoxShadow(
                color: btnColor.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            isRecording ? Icons.stop_rounded : (isCamera ? Icons.camera_alt_rounded : Icons.videocam_rounded),
            color: isRecording ? Colors.red : Colors.white,
            size: 35,
          ),
        ),
      ),
    );
  }
}
