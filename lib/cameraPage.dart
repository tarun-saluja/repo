import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memob/uploadAttachment.dart' as UploadAttachment;
import 'package:memob/utilities.dart' as utilities;
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  final String meetingUuid;
  final String meetingTitle;

  double height;
  double width;

  CameraPage(this.meetingTitle, this.meetingUuid);

  @override
  _CameraPageState createState() => _CameraPageState();
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw new ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraPageState extends State<CameraPage> {
  CameraController controller;
  String imagePath;

  String userToken;

  bool pictureClicked = false;

  List<CameraDescription> cameras;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // For Initialization
  Future<Null> initCamera() async {
    try {
      cameras = await availableCameras();
      await availableCameras().then((onValue) {
        onNewCameraSelected(cameras[0]);
      });
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
  }

  Future<Null> fetchData() async {
    Future<String> token = utilities.getTokenData();
    token.then((value) {
      if (value != null) {
        userToken = value;
      } else {
        utilities.showLongToast(value);
      }
    });
  }

  @override
  @protected
  @mustCallSuper
  void initState() {
    initCamera();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    widget.height = MediaQuery.of(context).size.height;
    widget.width = MediaQuery.of(context).size.width;

    return new MaterialApp(
        home: new Scaffold(
            key: _scaffoldKey,
            body: new Container(
              child: pictureClicked == false
                  ? new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _cameraPreviewWidget(),
                        _captureControlRowWidget(),
                      ],
                    )
                  : new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _thumbnailWidget(),
                        _cameraSaveController()
                      ],
                    ),
            )));
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return new AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: new CameraPreview(controller),
      );
    }
  }

  Widget _cameraSaveController() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        new RaisedButton(
            child: new Icon(
              Icons.check,
              color: Colors.green,
            ),
            onPressed: () {
              //Save Pic
              UploadAttachment.uploadAttachment(
                  userToken, imagePath, widget.meetingUuid);

              Navigator.pop(context);
            }),
        new RaisedButton(
            child: new Icon(Icons.close, color: Colors.red),
            onPressed: () {
              Navigator.pop(context);
            })
      ],
    );
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return new Container(
        child: imagePath == null
            ? null
            : new Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new SizedBox(
                        child: new Container(
                            child: new Image.file(new File(imagePath))),
                        width: widget.width,
                        height: widget.height * 0.70,
                      ),
                    ],
                  ),
                ],
              ));
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new Center(
          child: new IconButton(
            icon: const Icon(Icons.camera_alt),
            color: Colors.blue,
            onPressed: controller != null &&
                    controller.value.isInitialized &&
                    !controller.value.isRecordingVideo
                ? onTakePictureButtonPressed
                : null,
          ),
        ),
      ],
    );
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = new CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          pictureClicked = true;
        });
      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/Image_${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
