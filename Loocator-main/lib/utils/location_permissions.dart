import 'package:permission_handler/permission_handler.dart';

Future<bool> requestLocationDialogAcceptance() async {
  return (await Permission.locationWhenInUse.isGranted) ||
      (await Permission.locationWhenInUse.request()) ==
          PermissionStatus.granted;
}
