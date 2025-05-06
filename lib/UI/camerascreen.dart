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
    final cameraState = ref.watch(CameraProvider);
    final controller = ref.read(CameraProvider.notifier).controller;
    return Scaffold(
      body: Center(
        child: (cameraState.iscameraready && controller != null && controller.value.isInitialized)
            ? AspectRatio(
            aspectRatio: 20/9,//cameraState.aspectRatio,
            child: CameraPreview(controller))
            : CircularProgressIndicator(),
      ),
    );
  }

}


