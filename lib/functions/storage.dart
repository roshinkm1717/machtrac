import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qrscan/qrscan.dart' as scanner;

Future<String> getImageFromCamera() async {
  PickedFile pickedFile = await ImagePicker.platform.pickImage(source: ImageSource.camera, imageQuality: 50);
  return pickedFile.path;
}

Future<String> getImageFromStorage() async {
  FilePickerResult result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
  );
  return result.paths[0];
}

Future<String> getLinkFromQR() async {
  String cameraScanResult = await scanner.scan();
  print(cameraScanResult);
  return cameraScanResult;
}
