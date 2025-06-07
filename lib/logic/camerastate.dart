
import 'dart:ui';

import 'package:camera/camera.dart';

class cameraState
{
  final bool mode;
  final List<CameraDescription> cameras;
  final bool iscameraready;
  final int currentCameraIndex;
  final ResolutionPreset selectedResolution;
  final FlashMode flashMode;
  final int? countDown;
  final double currentZoom;
  final double baseZoom;
  final double minZoom;
  final double maxZoom;
  final Offset? tapPosition;

  const cameraState({
    this.mode=true,
    this.iscameraready=false,
    this.cameras=const[],
    this.currentCameraIndex=0,
    this.selectedResolution=ResolutionPreset.medium,
    this.flashMode=FlashMode.off,
    this.countDown,
    this.currentZoom=1.0,
    this.baseZoom=1.0,
    this.minZoom=1.0,
    this.maxZoom=4.0,
    this.tapPosition,
  });

  cameraState copyWith({
    bool? mode,
    bool? iscameraready,
    List<CameraDescription>? cameras,
    int? currentCameraIndex,
    ResolutionPreset? selectedResolution,
    FlashMode? flashMode,
    int? countDown,
    double? currentZoom,
    double? baseZoom,
    double? minZoom,
    double? maxZoom,
    Offset? tapPosition,
  }){
    return cameraState(
      mode: mode??this.mode,
      iscameraready: iscameraready??this.iscameraready,
      cameras: cameras??this.cameras,
      currentCameraIndex: currentCameraIndex??this.currentCameraIndex,
      selectedResolution: selectedResolution??this.selectedResolution,
      flashMode: flashMode??this.flashMode,
      countDown: countDown,
      currentZoom: currentZoom??this.currentZoom,
      baseZoom: baseZoom??this.baseZoom,
      minZoom: minZoom??this.minZoom,
      maxZoom: maxZoom??this.maxZoom,
      tapPosition: tapPosition,
    );
  }
}