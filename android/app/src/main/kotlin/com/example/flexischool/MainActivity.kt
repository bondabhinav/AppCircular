package flexischoolerpapp.sapinfotek.com

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge for Android 15 compatibility
        // This tells the system that our app will draw behind system bars
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
