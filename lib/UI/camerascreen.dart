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
  final isvideocam = StateProvider<bool>((ref) => false);

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
    final controller = ref.watch(CameraProvider.notifier).controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: (cameraState.iscameraready && controller != null && controller.value.isInitialized)
            ? Stack(
          children: [
                Center(
                  child: LayoutBuilder(
                    builder: (context,constraints) {
                      return GestureDetector(
                          onTapDown: (details)=>ref.read(CameraProvider.notifier).TaptoFocus(details, constraints),  //for tap to focus square
                          child: Stack(
                            children: [
                              CameraPreview(controller),
                              //Tap focus indicator
                              if(cameraState.tapPosition!=null)
                                Positioned(
                                    left: cameraState.tapPosition!.dx - 20,
                                    top: cameraState.tapPosition!.dy - 20,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.yellow, width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    )),
                            ],
                          ));
                    }
                  ), ///after that add aspect ratio here
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
                      icon: ref.read(CameraProvider.notifier).getFlashIcon(),
                      onPressed: () async{
                        // flash toggle
                        ref.read(CameraProvider.notifier).ToggleFlash();
                      },
                    ),
                      IconButton(
                        icon: Icon(Icons.timer, color: Colors.white),
                        onPressed: () {
                          // back or close
                        },
                      ),
                      IconButton(
                        icon: ref.read(CameraProvider.notifier).getResolutionIcon(),
                        onPressed: ()async {
                          await ref.read(CameraProvider.notifier).showresolution(context);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          // back or close
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
                  GestureDetector(
                      onTap:()async{
                        if(ref.read(isvideocam.notifier).state)
                          {
                           await ref.read(CameraProvider.notifier).CapturePhoto();
                          }
                        else
                          {
                            await ref.read(CameraProvider.notifier).StartRecording();
                            ref.read(isvideocam.notifier).state=true;
                          }
                        },
                      child: Icon(ref.watch(isvideocam)?Icons.camera:Icons.videocam, color: Colors.white)),
                  GestureDetector(
                      onTapDown: (_) {
                        ref.read(shutterScaleProvider.notifier).state = 0.8; // shrink
                      },
                      onTapUp: (_) async {
                        // Capture Photo
                        if(ref.read(isvideocam.notifier).state)
                          {
                            ref.read(isvideocam.notifier).state=false;
                            await ref.read(CameraProvider.notifier).StopRecording();
                          }
                        else
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
                            child: ref.watch(isvideocam)?Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.stop,color: Colors.red,size: 40,),
                            ):Icon(Icons.circle_outlined, color: Colors.yellow, size: 64)),
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


