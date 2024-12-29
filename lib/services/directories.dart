import 'package:path_provider/path_provider.dart';



void DirectoryCheck() async {
  // Retrieve the application documents directory
  final appDocumentsDir = await getApplicationDocumentsDirectory();
  print('Application Documents Directory: ${appDocumentsDir.path}');

  // Retrieve the application support directory
  final appSupportDir = await getApplicationSupportDirectory();
  print('Application Support Directory: ${appSupportDir.path}');

  // Retrieve the external storage directory (SD card)
  final externalStorageDir = await getExternalStorageDirectory();
  print('External Storage Directory: ${externalStorageDir?.path}');

  // Retrieve the temporary directory
  final tempDir = await getTemporaryDirectory();
  print('Temporary Directory: ${tempDir.path}');
}


