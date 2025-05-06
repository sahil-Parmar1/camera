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
                  Icon(Icons.photo_library, color: Colors.white),
                  GestureDetector(
                      onTap: ()async{
                        await ref.read(CameraProvider.notifier).CapturePhoto();
                      },
                      child: Icon(Icons.circle, color: Colors.white, size: 64)),
                  Icon(Icons.cameraswitch, color: Colors.white),
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


