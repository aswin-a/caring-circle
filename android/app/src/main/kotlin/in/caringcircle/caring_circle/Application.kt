package `in`.caringcircle.caring_circle

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.geofencing.GeofencingService

import io.flutter.plugins.geofencing.GeofencingPlugin
import io.flutter.plugins.firebase.cloudfirestore.CloudFirestorePlugin
import io.flutter.plugins.firebaseauth.FirebaseAuthPlugin
import com.baseflow.geolocator.GeolocatorPlugin

class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate();
        GeofencingService.setPluginRegistrant(this);
    }

    override fun registerWith(registry: PluginRegistry) {
        if (!registry!!.hasPlugin("io.flutter.plugins.geofencing")) {
            GeofencingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.geofencing"));
        }
        if (!registry!!.hasPlugin("io.flutter.plugins.firebase.cloudfirestore")) {
            CloudFirestorePlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebase.cloudfirestore"));
        }
        if (!registry!!.hasPlugin("io.flutter.plugins.firebaseauth")) {
            FirebaseAuthPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebaseauth"));
        }
        if (!registry!!.hasPlugin("com.baseflow.geolocator")) {
            GeolocatorPlugin.registerWith(registry?.registrarFor("com.baseflow.geolocator"));
        }
    }
}