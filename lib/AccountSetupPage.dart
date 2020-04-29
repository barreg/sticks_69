import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'DatabaseService.dart';
import 'Models.dart';
import 'LoadingBarrier.dart';

class AccountSetupPage extends StatefulWidget {
  @override
  _AccountSetupPageState createState() => _AccountSetupPageState();
}

class _AccountSetupPageState extends State<AccountSetupPage> {
  String _nameError;
  bool _bLoading = false;
  File _croppedPath;
  int _currentStep = 0;
  final _fullnameController = new TextEditingController();
  final _descriptionController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Account Setup"),
      ),
      body: Stack(
        children: <Widget>[
          _stepper(),
          LoadingBarrier(
            text: "Loading...",
            bIsLoading: _bLoading,
          )
        ],
      ),
    );
  }

  Widget _stepper() => Stepper(
        currentStep: this._currentStep,
        type: StepperType.vertical,
        controlsBuilder: (BuildContext context,
            {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          return Row(
            children: <Widget>[
              RaisedButton(
                onPressed: onStepContinue,
                child: const Text('Continue'),
              ),
              FlatButton(
                onPressed: onStepCancel,
                child: const Text('Back'),
              ),
            ],
          );
        },
        onStepCancel: () {
          _onWillPop();
        },
        onStepContinue: () {
          setState(() {
            if (_currentStep == 0) {
              if (_fullnameController.text != "") {
                _currentStep++;
                _nameError = null;
              } else
                _nameError = "Please enter a name.";
            } else if (_currentStep == 1) {
              _currentStep++;
            } else if (_currentStep == 2) {
              _submitData();
            }
          });
        },
        steps: [
          Step(
            title: Text("Full Name"),
            subtitle: _fullnameController.text != ""
                ? Text(_fullnameController.text)
                : null,
            state: _fullnameController.text == ""
                ? StepState.indexed
                : StepState.complete,
            isActive: _currentStep == 0,
            content: TextField(
              textCapitalization: TextCapitalization.words,
              controller: _fullnameController,
              decoration:
                  InputDecoration(hintText: "Full Name", errorText: _nameError),
            ),
          ),
          Step(
            title: Text("Description (Optional)"),
            subtitle: _descriptionController.text != ""
                ? Text(_descriptionController.text)
                : null,
            isActive: _currentStep == 1,
            state: _descriptionController.text == ""
                ? StepState.indexed
                : StepState.complete,
            content: TextField(
              textCapitalization: TextCapitalization.words,
              controller: _descriptionController,
              decoration: InputDecoration(hintText: "Description"),
            ),
          ),
          Step(
            title: Text("Image (Optional)"),
            isActive: _currentStep == 2,
            state:
                _croppedPath == null ? StepState.indexed : StepState.complete,
            content: Column(children: [
              _croppedPath != null
                  ? Stack(children: [
                      Image.file(_croppedPath, height: 100, width: 100),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: IconButton(
                          iconSize: 30,
                          icon: Icon(
                            Icons.cancel,
                          ),
                          onPressed: () {
                            setState(() {
                              _croppedPath = null;
                            });
                          },
                          color: Colors.red.withOpacity(0.8),
                        ),
                      )
                    ])
                  : Image.asset("assets/default_user.png",
                      height: 100, width: 100),
              FlatButton.icon(
                  label: Text("Select from Library"),
                  icon: Icon(Icons.photo_library),
                  onPressed: () {
                    _importImageFromGallery();
                  }),
              SizedBox(
                height: 20,
              )
            ]),
          ),
        ],
      );

  bool _onWillPop() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      FirebaseAuth.instance.signOut();
    }
    return true;
  }

  _importImageFromGallery() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    File croppedFile = await ImageCropper.cropImage(
      sourcePath: file.path,
      androidUiSettings: AndroidUiSettings(
          toolbarColor: Theme.of(context).primaryColor,
          cropFrameColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Theme.of(context).primaryColorLight,
          hideBottomControls: true),
      iosUiSettings: IOSUiSettings(
          aspectRatioPickerButtonHidden: true,
          resetButtonHidden: true,
          rotateButtonsHidden: true,
          rotateClockwiseButtonHidden: true,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false),
      aspectRatioPresets: [CropAspectRatioPreset.square],
      maxWidth: 250,
      maxHeight: 250,
    );
    if (croppedFile == null) return;

    setState(() {
      this._croppedPath = croppedFile;
    });
  }

  _submitData() async {
    String url;
    Userdata user = Provider.of<Userdata>(context);
    if (_croppedPath != null) {
      setState(() {
        this._bLoading = true;
      });

      StorageTaskSnapshot task = await FirebaseStorage.instance
          .ref()
          .child("users")
          .child(user.uid)
          .child("photo")
          .putFile(_croppedPath)
          .onComplete;
      url = await task.ref.getDownloadURL();
      setState(() {
        this._bLoading = false;
      });
    }

    Userdata userdata = new Userdata(user.uid, _fullnameController.text,
        _descriptionController.text, url, 0, false);
    await Provider.of<DatabaseService>(context).updateUserdata(userdata);
    Navigator.pop(context);
  }
}
