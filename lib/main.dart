import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  bool camera=true;
  late CameraController controller;
  XFile? capturedImage;
  List<CameraDescription> _cameras=[];
  int _currentCameraIndex=0;
  bool _isCameraInitialized = false;
  final ValueNotifier<double> _scaleNotifier=ValueNotifier(1.0);
  final AudioPlayer _player=AudioPlayer();
  ResolutionPreset _selectedResolution = ResolutionPreset.medium;
  final Map<String, ResolutionPreset> resolutionOptions = {
    'Low  352x288': ResolutionPreset.low,
    'Medium   720x480': ResolutionPreset.medium,
    'High   1280x720': ResolutionPreset.high,
    'Very High    1920x1080': ResolutionPreset.veryHigh,
    'Ultra High   3840x2160': ResolutionPreset.ultraHigh,
    'Max': ResolutionPreset.max,
  };

  @override
  void initState() {
    super.initState();
    _initCamera(_currentCameraIndex);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }



//function to init camera
  Future<void> _initCamera(int cameraIndex,{ResolutionPreset resolution=ResolutionPreset.high}) async {
    _cameras = await availableCameras(); // Load available cameras

    controller = CameraController(
      _cameras[cameraIndex],
      resolution,
      enableAudio: true,
    );

    await controller.initialize();
    if(mounted)
    {
      setState(() {
        _isCameraInitialized=true;
      });
    }
  }
  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return; // Only one camera available

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

    // Dispose current controller
    await controller.dispose();

    // Initialize new camera
    await _initCamera(_currentCameraIndex);

    setState(() {}); // Rebuild UI with new camera
  }

  Future<void> playShutterSound() async {
    await _player.play(AssetSource('shutter.mp3'));
  }

  //function to capture photo and save into CameraApp folder
  Future<void> _capturePhoto(BuildContext context, CameraController controller) async {
    try {
      if (!controller.value.isInitialized) return;

      // Request permissions
      await [
        Permission.camera,
        Permission.storage,
      ].request();

      // Take the picture
      final XFile photo = await controller.takePicture();
      playShutterSound();
      // Create a folder in Pictures
      final String dirPath = '/storage/emulated/0/Pictures/CameraApp';
      final Directory dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Create file path
      final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Save captured photo to new path
      await photo.saveTo(filePath);

      // Verify if saved
      final file = File(filePath);
      if (await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo captured and saved at: $filePath')),
        );
        print('Photo saved: $filePath');
      } else {
        print('Failed to save photo.');
      }
    } catch (e) {
      print('Error capturing photo: $e');
    }
  }


  //function to capture video
  Future<void> _startrecording(BuildContext context,CameraController controller)async
  {
    try
    {
      if(!controller.value.isInitialized)return;
      //request permissions
      await [
        Permission.camera,
        Permission.storage,
        Permission.microphone
      ].request();

      //start recording
      await controller.startVideoRecording();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("recording started...")));
    }
    catch(e)
    {
      print("error recording video:$e");
    }
  }

  Future<void> _stoprecording(BuildContext context,CameraController controller)async
  {
    try
    {
      final XFile video=await controller.stopVideoRecording();
      //create a folder in Movies
      final String dirPath='/storage/emulated/0/Movies/CameraApp';
      final Directory dir=Directory(dirPath);
      if(!await dir.exists())
      {
        await dir.create(recursive: true);
      }
      //create file path
      final String filePath='$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';
      //save captured video to new path
      await video.saveTo(filePath);
      final file=File(filePath);
      if(await file.exists())
      {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("video recorded and saved at: $filePath"))
        );
        print("video saved:$filePath");
      }
      else
      {
        print("failed to save video");
      }

    }
    catch(e)
    {
      print("error in stoping the video $e");
    }
  }


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        body: _isCameraInitialized?Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.black
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add your shutter button functionality here
                      if(camera==false)
                        _capturePhoto(context,controller);

                      setState(() {
                        camera=false;
                      });

                    },
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),

                        backgroundColor: Colors.transparent// Button size
                    ),
                    child: Icon(
                      Icons.flash_off_sharp,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          // Add your shutter button functionality here
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
                                          leading: getResolutionIcon(entry.value),
                                          trailing: _selectedResolution==entry.value?Icon(Icons.check_circle,color: Colors.green,):null,
                                          title: Text(entry.key,style: TextStyle(color: Colors.white),),
                                          onTap: () {
                                            Navigator.pop(context); // Close popup
                                            _selectedResolution = entry.value;
                                            _initCamera(_currentCameraIndex,resolution: entry.value); // Re-initialize camera
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(10),

                            backgroundColor: Colors.transparent// Button size
                        ),
                        child: getResolutionIcon(_selectedResolution),

                      );
                    }
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add your shutter button functionality here
                      if(camera==false)
                        _capturePhoto(context,controller);

                      setState(() {
                        camera=false;
                      });

                    },
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),

                        backgroundColor: Colors.transparent// Button size
                    ),
                    child: Icon(
                      camera?Icons.videocam:Icons.camera,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add your shutter button functionality here

                      print("Shutter button pressed!");
                    },
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),

                        backgroundColor: Colors.transparent// Button size
                    ),
                    child: Icon(
                      Icons.settings,
                      size: 25.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.74,
                child: CameraPreview(controller)),
            Container(
              decoration: BoxDecoration(
                  color: Colors.black
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add your shutter button functionality here
                      if(camera==false)
                        _capturePhoto(context,controller);
                      else if(camera==true)
                        _startrecording(context, controller);
                      setState(() {
                        camera=false;
                      });

                    },
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),

                        backgroundColor: Colors.transparent// Button size
                    ),
                    child: Icon(
                      camera?Icons.videocam:Icons.camera,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: _scaleNotifier,
                    builder: (context,scale,child) {
                      return AnimatedScale(
                        scale: scale,
                        duration: Duration(milliseconds: 100),
                        child: ElevatedButton(
                          onPressed: () async{
                            // Add your shutter button functionality here
                            _scaleNotifier.value=0.85;
                            await Future.delayed(Duration(milliseconds: 100));
                            _scaleNotifier.value=1.0;
                            print("Shutter button pressed!");
                            if(camera)
                            {
                              _capturePhoto(context,controller);
                            }
                            else if(camera==false)
                            {
                              _stoprecording(context, controller);
                            }
                            setState(() {
                              camera=true;
                            });

                          },
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(
                                side: BorderSide(
                                    color: camera?Colors.white:Colors.red,
                                    width: 1.0
                                )
                            ),
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.all(20), // Button size
                          ),
                          child: Icon(
                            camera?Icons.camera_alt:Icons.square,
                            size: 30.0,
                            color: camera?Colors.white:Colors.red,
                          ),
                        ),
                      );
                    }
                  ),
                  ElevatedButton(
                    onPressed: () async{
                      // Add your shutter button functionality here
                      await _switchCamera();
                      print("Shutter button pressed!");
                    },
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),

                        backgroundColor: Colors.transparent// Button size
                    ),
                    child: Icon(
                      Icons.cameraswitch,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          ],
        ):Center(child: const CircularProgressIndicator()),
      ),
    );



  }


  Icon getResolutionIcon(ResolutionPreset resolution) {
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



}
