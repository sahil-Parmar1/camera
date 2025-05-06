import 'package:camera_app/logic/cameranotifier.dart';
import 'package:camera_app/logic/camerastate.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final CameraProvider=StateNotifierProvider<CameraNotifier,cameraState>((ref)=>CameraNotifier());

class CameraScreen extends ConsumerStatefulWidget
{
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState()=>_CameraScreen();
}

class _CameraScreen extends ConsumerState<CameraScreen>
{
  final shutterScaleProvider = StateProvider<double>((ref) => 1.0);
  @override
  void initState()
  {
    super.initState();
    Future.microtask((){
      ref.read(CameraProvider.notifier).InitCamera(null);
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cameraState = ref.watch(CameraProvider);
    final controller = ref.read(CameraProvider.notifier).controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: (cameraState.iscameraready && controller != null && controller.value.isInitialized)
            ? Stack(
          children: [
                Center(
                  child: CameraPreview(controller), ///after that add aspect ratio here
                ),

                // 🔝 Top row (at the top)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16, // respect notch + padding
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.timer, color: Colors.white),
                        onPressed: () {
                          // back or close
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.flash_on, color: Colors.white),
                        onPressed: () {
                          // flash toggle
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.flash_on, color: Colors.white),
                        onPressed: () {
                          // flash toggle
                        },
                      ),
                    ],
                  ),
                ),

            // 🔻 Bottom row
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.videocam, color: Colors.white),
                  GestureDetector(
                      onTapDown: (_) {
                        ref.read(shutterScaleProvider.notifier).state = 0.8; // shrink
                      },
                      onTapUp: (_) async {
                        // Capture Photo
                        await ref.read(CameraProvider.notifier).CapturePhoto();
                        // Reset scale after tap
                        ref.read(shutterScaleProvider.notifier).state = 1.0;
                      },
                      onTapCancel: () {
                        // If tap is canceled (finger moves away), reset scale
                        ref.read(shutterScaleProvider.notifier).state = 1.0;
                      },

                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.white,width: 2)
                        ),
                        child: AnimatedScale(
                            scale:ref.watch(shutterScaleProvider),
                            duration: Duration(milliseconds: 100),
                            child: Icon(Icons.circle_outlined, color: Colors.yellow, size: 64)),
                      )),
                  GestureDetector(
                      onTap: ()async{
                        await ref.read(CameraProvider.notifier).SwitchCamera();
                      },
                      child: Icon(Icons.cameraswitch, color: Colors.white)),
                ],
              ),
            ),
              ],
            )
            : CircularProgressIndicator(),
      ),
    );
  }

}


