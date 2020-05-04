package `in`.caringcircle.caring_circle

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.geofencing.GeofencingService
import io.flutter.plugins.GeneratedPluginRegistrant

class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate();
        GeofencingService.setPluginRegistrant(this);
    }

    override fun registerWith(registry: PluginRegistry) {
        registry?.registrarFor("io.flutter.plugins.geofencing.GeofencingPlugin");
  }
}