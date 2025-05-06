import 'package:camera/camera.dart';
import 'package:camera_app/logic/camerastate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';
import 'dart:io';
class CameraNotifier extends StateNotifier<cameraState>
{
   CameraNotifier():super(const cameraState());
   CameraController? controller;

   //initcamera
   Future<void> InitCamera(int? cameraIndex,{ResolutionPreset resolution=ResolutionPreset.medium})async
   {
     // Request permissions
     await [
       Permission.camera,
       Permission.storage,
       Permission.microphone
     ].request();

     List<CameraDescription> _cameras=await availableCameras();
     controller=CameraController(_cameras[cameraIndex??0], resolution,enableAudio: true);
     await controller!.initialize();
     double minZoom=await controller!.getMinZoomLevel();
     double maxZoom=await controller!.getMaxZoomLevel();
     state=state.copyWith(iscameraready: true,cameras: _cameras,minZoom: minZoom,maxZoom: maxZoom);
   }

   //switch camera
    Future<void> SwitchCamera()async
    {
      if(state.cameras.length<2) return; //only one camera available
      var currentindex=state.currentCameraIndex;
      currentindex=(currentindex+1)%state.cameras.length;
      await InitCamera(currentindex);
    }

   Future<void> ToggleFlash()async{
     FlashMode newMode;
     switch (state.flashMode) {
       case FlashMode.off:
         newMode = FlashMode.auto;
         break;
       case FlashMode.auto:
         newMode = FlashMode.torch;
         break;
       case FlashMode.torch:
         newMode = FlashMode.off;
         break;
       default:
         newMode = FlashMode.off;
     }
     state=state.copyWith(flashMode: newMode);
   }

   //capturephoto
    Future<void> CapturePhoto()async
    {
      try
          {
            if(!controller!.value.isInitialized)return;
            final XFile photo=await controller!.takePicture();
            // Create a folder in Pictures
            final String dirPath = '/storage/emulated/0/Pictures/CameraApp';
            final Directory dir = Directory(dirPath);
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
            final String filePath='$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
            await photo.saveTo(filePath);
            final file=File(filePath);
            if(await file.exists())
              print("photo captured and saved at:$filePath");
            else
              print("falid to save photo");
          }
          catch(e)
          {
         print("error captureing photo: $e");
          }

    }

    Future<void> StartRecording()async
    {
      try
          {
            if(!controller!.value.isInitialized)return;
            await controller!.startVideoRecording();
          }
          catch(e)
          {
            print("error in recording the video :$e");
          }
    }

    Future<void> StopRecording()async
    {
      try
          {
            if(!controller!.value.isInitialized)return;
            final XFile video=await controller!.stopVideoRecording();
            //create a folder in Movies
            final String dirPath='/storage/emulated/0/Movies/CameraApp';
            final Directory dir=Directory(dirPath);
            if(!await dir.exists())
            {
              await dir.create(recursive: true);
            }
            //create file path
            final String filePath='$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';
            await video.saveTo(filePath);
            final file=File(filePath);
            if(await file.exists())
              print("video recorded and save at : $filePath");
            else
              print("failed to save video");
          }
          catch(e)
          {
           print("error in stopping and saveing the video $e");
          }
    }

   Future<void> TaptoFocus(TapDownDetails details,BoxConstraints constraints)async
   {
     if(!controller!.value.isInitialized)return;
     final tapPos=details.localPosition;
     final normalizedOffset=Offset(
       tapPos.dx/constraints.maxWidth,
       tapPos.dy/constraints.maxWidth,
     );
     await controller!.setFocusPoint(normalizedOffset);
     await controller!.setExposurePoint(normalizedOffset);
   }


}