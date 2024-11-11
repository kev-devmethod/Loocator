import 'package:google_navigation_flutter/google_navigation_flutter.dart';

Future<bool> requestTermsAndConditionsAcceptance() async {
  return (await GoogleMapsNavigator.areTermsAccepted()) ||
      (await GoogleMapsNavigator.showTermsAndConditionsDialog(
        'Example title',
        'Example company',
      ));
}
