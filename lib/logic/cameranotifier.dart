import 'dart:async';
import 'package:camera/camera.dart';
import 'package:camera_app/logic/camerastate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';
import 'dart:io';

class CameraNotifier extends StateNotifier<cameraState>
{
   CameraNotifier():super(const cameraState());
   CameraController? controller;
   Timer? _countdownTimer;

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
     state=state.copyWith(selectedResolution: resolution,currentCameraIndex: cameraIndex??0,iscameraready: true,cameras: _cameras,minZoom: minZoom,maxZoom: maxZoom);
   }

   //switch camera
    Future<void> SwitchCamera()async
    {
      if(state.cameras.length<2) return; //only one camera available
      var currentindex=state.currentCameraIndex;
      currentindex=(currentindex+1)%state.cameras.length;
      controller!.dispose();
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
     await controller!.setFlashMode(newMode);
     state=state.copyWith(flashMode: newMode);
   }

   Icon getFlashIcon() {
     switch (state.flashMode) {
       case FlashMode.off:
         return Icon(Icons.flash_off, size: 25, color: Colors.white);
       case FlashMode.auto:
         return Icon(Icons.flash_auto, size: 25, color: Colors.yellow);
       case FlashMode.torch:
         return Icon(Icons.flash_on, size: 25, color: Colors.yellow);
       default:
         return Icon(Icons.flash_off, size: 25, color: Colors.white);
     }
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

     print("taptofocus was called ....");
     if(!controller!.value.isInitialized)return;
     final tapPos=details.localPosition;
     final normalizedOffset=Offset(
       tapPos.dx/constraints.maxWidth,
       tapPos.dy/constraints.maxHeight,
     );

     //validate for invalid offset values
     if (normalizedOffset.dx >= 0 &&
         normalizedOffset.dx <= 1 &&
         normalizedOffset.dy >= 0 &&
         normalizedOffset.dy <= 1) {
       // safe to apply
       state=state.copyWith(tapPosition: tapPos);
       await controller!.setFocusPoint(normalizedOffset);
       await controller!.setExposurePoint(normalizedOffset);

       // Optional: Add small delay then remove tap marker
       Future.delayed(const Duration(seconds: 1), () {
         state=state.copyWith(tapPosition: null);
         print("now it is null ");
       });
     } else {
       return; // or print error
     }


   }

   Future<void> showresolution(BuildContext context)async
   {
     // Add your shutter button functionality here
     final Map<String, ResolutionPreset> resolutionOptions = {
   'Low  352x288': ResolutionPreset.low,
   'Medium   720x480': ResolutionPreset.medium,
   'High   1280x720': ResolutionPreset.high,
   'Very High    1920x1080': ResolutionPreset.veryHigh,
   'Ultra High   3840x2160': ResolutionPreset.ultraHigh,
   'Max': ResolutionPreset.max,
   };
     ResolutionPreset _selectedResolution=state.selectedResolution;
     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
           backgroundColor: Colors.grey[900],
           title: Text('Choose Resolution',style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold),),
           content: SingleChildScrollView(
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: resolutionOptions.entries.map((entry) {
                 return Card(
                   color: _selectedResolution==entry.value?Colors.blueGrey[700]:Colors.grey[850],
                   shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(10)
                   ),
                   child: ListTile(
                     leading: getResolutionIcon(resolution: entry.value),
                     trailing: _selectedResolution==entry.value?Icon(Icons.check_circle,color: Colors.green,):null,
                     title: Text(entry.key,style: TextStyle(color: Colors.white),),
                     onTap: () {
                       Navigator.pop(context); // Close popup
                      _selectedResolution=entry.value??ResolutionPreset.medium;
                      InitCamera(state.currentCameraIndex,resolution: _selectedResolution);
                       // Re-initialize camera
                     },
                   ),
                 );
               }).toList(),
             ),
           ),
         );
       },
     );
   }


   Icon getResolutionIcon({ResolutionPreset? resolution}) {
     resolution??=state.selectedResolution;
     switch (resolution) {
       case ResolutionPreset.low:
         return Icon(Icons.low_priority, color: Colors.blue,size: 25,);
       case ResolutionPreset.medium:
         return Icon(Icons.picture_in_picture_alt, color: Colors.green,size: 25,);
       case ResolutionPreset.high:
         return Icon(Icons.high_quality, color: Colors.orange,size: 25,);
       case ResolutionPreset.veryHigh:
         return Icon(Icons.photo_size_select_actual, color: Colors.orange,size: 25,);
       case ResolutionPreset.ultraHigh:
         return Icon(Icons.camera_enhance, color: Colors.purple,size: 25,);
       case ResolutionPreset.max:
         return Icon(Icons.home_max, color: Colors.red,size: 25,);
       default:
         return Icon(Icons.camera_alt, color: Colors.white,size: 25,);
     }
   }

   Future<void> startCountdownAndCapture(int seconds)async
   {
     int current=seconds;
     state=state.copyWith(countDown: current);
     _countdownTimer?.cancel();
     _countdownTimer=Timer.periodic(const Duration(seconds: 1), (timer)async{
       current-=1;
       if(current>0)
         {
           state=state.copyWith(countDown: current);
           print("\n\n\n\n seconds ===>> $current");
         }
       else
         {
           timer.cancel();
           state=state.copyWith(countDown: null);
           CapturePhoto();
         }
     });
   }

}