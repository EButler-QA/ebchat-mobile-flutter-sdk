import 'dart:typed_data';
import 'package:ebchat/src/lib/Theme/my_theme.dart';
import 'package:ebchat/src/lib/config/config.dart';
import 'package:ebchat/src/lib/widgets/ebutler_map.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as lcp;
import 'package:image_picker/image_picker.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class UserInfoDialog extends StatefulWidget {
  const UserInfoDialog({
    Key? key,
    required this.questionType,
    required this.question,
  }) : super(key: key);
  final String questionType;
  final String question;

  @override
  State<UserInfoDialog> createState() => _SetvalueDialogState();
}

class _SetvalueDialogState extends State<UserInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? bytes;
  XFile? pickedFile;
  bool loading = false;
  TextEditingController? _valueController;

  String? _valueInputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'value cannot be empty';
    }
    return null;
  }

  _addvalue(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_valueController!.value.text);
    }
  }

  chooseImage() async {
    final NavigatorState navigator = Navigator.of(context);
    pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      bytes = await pickedFile!.readAsBytes();
      AttachmentFile? file = AttachmentFile(
        size: bytes!.length,
        path: pickedFile!.path,
        bytes: bytes,
      );
      final mimeType =
          file.name?.mediaType?.mimeType ?? file.path!.split('/').last.mediaType?.mimeType;

      final extraDataMap = <String, Object>{};

      if (mimeType != null) {
        extraDataMap['mime_type'] = mimeType.toLowerCase();
      }

      extraDataMap['file_size'] = file.size!;

      String attachmentType = 'image';

      /*  attachmentType = 'video';
  
      attachmentType = 'file';*/

      final Attachment attachment = Attachment(
        file: file,
        type: attachmentType,
        uploadState: const UploadState.preparing(),
        extraData: extraDataMap,
      );
      navigator.pop(attachment);
    }
  }

  @override
  void initState() {
    _valueController = TextEditingController();

    super.initState();
  }

  @override
  Dialog build(BuildContext context) {
    Widget child;
    switch (widget.questionType) {
      case "EditText":
        child = Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  style: const TextStyle(color: Colors.black),
                  controller: _valueController,
                  validator: _valueInputValidator,
                  decoration: InputDecoration(
                    label: Text(widget.question),
                    labelStyle: const TextStyle(color: Colors.black),
                    fillColor: Colors.black,
                    border: const OutlineInputBorder(),
                    hintStyle: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => _addvalue(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.secndaryLight,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: AppColors.secndaryLight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: SizedBox(
                    width: 350,
                    height: 40,
                    child: Center(
                      child: Text(
                        "Submit",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );

        break;
      case "PickFile":
        child = Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                Text(
                  widget.question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => chooseImage(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.secndaryLight,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: AppColors.secndaryLight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.upload,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(getTranslated("Upload file"))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        break;

      ///location
      default:
        child = Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: loading
                ? const CircularProgressIndicator(
                    color: AppColors.secondary,
                  )
                : Column(
                    children: [
                      Text(
                        widget.question,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            loading = true;
                          });
                          lcp.Location location = lcp.Location();

                          bool serviceEnabled;
                          lcp.PermissionStatus permissionGranted;
                          lcp.LocationData locationData;

                          final NavigatorState navigator =
                              Navigator.of(context);

                          serviceEnabled = await location.serviceEnabled();
                          if (!serviceEnabled) {
                            serviceEnabled = await location.requestService();
                            if (!serviceEnabled) {
                              return;
                            }
                          }

                          permissionGranted = await location.hasPermission();
                          if (permissionGranted ==
                              lcp.PermissionStatus.denied) {
                            permissionGranted =
                                await location.requestPermission();
                            if (permissionGranted !=
                                lcp.PermissionStatus.granted) {
                              return;
                            }
                          }

                          locationData = await location.getLocation();

                          navigator.pop(
                            "http://maps.google.com/maps?q=${locationData.latitude},${locationData.longitude}",
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.secndaryLight,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: AppColors.secndaryLight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(getTranslated("Send your current location"))
                            ],
                          ),
                        ),
                      ),
                      if (Config.azureMapsApiKey != null)
                        ElevatedButton(
                          onPressed: () async {
                            final NavigatorState navigator =
                                Navigator.of(context);
                            setState(() {
                              loading = true;
                            });
                            lcp.Location location = lcp.Location();

                            bool serviceEnabled;
                            lcp.PermissionStatus permissionGranted;
                            lcp.LocationData locationData;

                            serviceEnabled = await location.serviceEnabled();
                            if (!serviceEnabled) {
                              serviceEnabled = await location.requestService();
                              if (!serviceEnabled) {
                                return;
                              }
                            }

                            permissionGranted = await location.hasPermission();
                            if (permissionGranted ==
                                lcp.PermissionStatus.denied) {
                              permissionGranted =
                                  await location.requestPermission();
                              if (permissionGranted !=
                                  lcp.PermissionStatus.granted) {
                                return;
                              }
                            }
                            locationData = await location.getLocation();
                            LatLng currentPositon = LatLng(
                              locationData.latitude!,
                              locationData.longitude!,
                            );

                            navigator
                                .push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EbutlerMap(currentPositon),
                              ),
                            )
                                .then((value) {
                              if (value != null) {
                                LatLng selectedPos = value as LatLng;
                                Navigator.of(context).pop(
                                  "http://maps.google.com/maps?q=${selectedPos.latitude},${selectedPos.longitude}",
                                );
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.secndaryLight,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: AppColors.secndaryLight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.map,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(getTranslated("Send location"))
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        );
    }
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: SizedBox(height: 300, child: SingleChildScrollView(child: child)),
    );
  }
}
