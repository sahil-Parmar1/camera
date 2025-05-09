import "package:camera_app/UI/camerascreen.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

void main()=>runApp(const ProviderScope(
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),),
));

class MyApp extends StatelessWidget
{
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context)
  {
    return CameraScreen();
  }
}