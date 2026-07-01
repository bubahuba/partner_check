import 'dart:io' show Platform;

bool get isWeb => false;
bool get isAndroid => Platform.isAndroid;
bool get isIOS => Platform.isIOS;
bool get isMacOS => Platform.isMacOS;
bool get supportsDeviceContacts =>
    Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
bool get autoDetectsSelfContact => Platform.isAndroid;
bool get needsSelfContactPickPrompt => Platform.isIOS;
bool get supportsPlasmaMotionSensors => Platform.isAndroid || Platform.isIOS;
