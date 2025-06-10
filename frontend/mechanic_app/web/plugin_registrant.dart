import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:permission_handler_web/permission_handler_web.dart';
import 'package:flutter_secure_storage_web/flutter_secure_storage_web.dart';

void registerPlugins(Registrar registrar) {
  PermissionHandlerWeb.registerWith(registrar);
  FlutterSecureStorageWeb.registerWith(registrar);
  registrar.registerMessageHandler();
}
