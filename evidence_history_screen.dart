import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:women_sos/services/api_service.dart';

class EvidenceHistoryScreen extends StatefulWidget {
  const EvidenceHistoryScreen({super.key});

  @override
  State<EvidenceHistoryScreen> createState() => _EvidenceHistoryScreenState();
}

class _EvidenceHistoryScreenState extends State<EvidenceHistoryScreen> {
  List<FileSystemEntity> _evidenceFiles = [];
  bool _isLoading = true;
  bool _isLocked = true;
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String _storedPin = "1234";

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _loadPin() async {
    final pin = await ApiService.getEvidencePin();
    setState(() {
      _storedPin = pin;
    });
  }

  Future<void> _loadEvidence() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final evidenceDir = Directory('${directory.path}/evidence');
      
      if (await evidenceDir.exists()) {
        final List<FileSystemEntity> files = evidenceDir.listSync();
        files.sort((a, b) => b.statSync().changed.compareTo(a.statSync().changed));
        setState(() {
          _evidenceFiles = files;
        });
      } else {
        setState(() {
          _evidenceFiles = [];
        });
      }
    } catch (e) {
      debugPrint("Error loading evidence: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _verifyPin() {
    if (_pinController.text == _storedPin) {
      setState(() {
        _isLocked = false;
      });
      _loadEvidence();
    } else {
      _pinController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect PIN. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showChangePinDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Evidence PIN"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Enter New PIN", counterText: ""),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm New PIN", counterText: ""),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_newPinController.text.length == 4 && _newPinController.text == _confirmPinController.text) {
                await ApiService.setEvidencePin(_newPinController.text);
                _storedPin = _newPinController.text;
                _newPinController.clear();
                _confirmPinController.clear();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PIN Changed Successfully"), backgroundColor: Colors.green),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PINs do not match or are invalid"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvidence(FileSystemEntity file) async {
    try {
      await file.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Evidence deleted successfully"), backgroundColor: Colors.green),
      );
      _loadEvidence();
    } catch (e) {
      debugPrint("Error deleting file: $e");
    }
  }

  void _showDeleteConfirmation(FileSystemEntity file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Evidence?"),
        content: const Text("Are you sure you want to permanently delete this evidence?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvidence(file);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewImage(File file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(child: Image.file(file)),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _viewVideo(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoFile: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return _buildLockScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Evidence History"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEvidence)
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : _evidenceFiles.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _evidenceFiles.length,
                  itemBuilder: (context, index) {
                    final file = _evidenceFiles[index];
                    final bool isPhoto = file.path.toLowerCase().contains("photo") || 
                                       file.path.toLowerCase().endsWith(".jpg") || 
                                       file.path.toLowerCase().endsWith(".png");
                    
                    return GestureDetector(
                      onTap: () {
                        if (isPhoto) {
                          _viewImage(File(file.path));
                        } else {
                          _viewVideo(File(file.path));
                        }
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: isPhoto
                                      ? Image.file(File(file.path), fit: BoxFit.cover)
                                      : Container(
                                          color: Colors.black87,
                                          child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(isPhoto ? Icons.image : Icons.videocam, size: 14, color: Colors.pink),
                                          const SizedBox(width: 5),
                                          Text(
                                            isPhoto ? "PHOTO" : "VIDEO",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.pink),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        file.statSync().changed.toString().split('.')[0],
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.8),
                                radius: 18,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () => _showDeleteConfirmation(file),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showChangePinDialog,
        backgroundColor: Colors.pink,
        icon: const Icon(Icons.password_rounded, color: Colors.white),
        label: const Text("CHANGE PIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLockScreen() {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Secure Access")),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_person_rounded, size: 80, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 30),
            Text(
              "Evidence Box is Locked",
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Enter your 4-digit PIN to access evidence",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onChanged: (value) {
                if (value.length == 4) {
                  _verifyPin();
                }
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _verifyPin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("UNLOCK ACCESS"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Default PIN: 1234",
              style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_photography_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("No evidence stored locally", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final File videoFile;
  const VideoPlayerScreen({super.key, required this.videoFile});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.file(widget.videoFile);
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      errorBuilder: (context, errorMessage) {
        return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.white)));
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Video Evidence"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(color: Colors.pink),
      ),
    );
  }
}
