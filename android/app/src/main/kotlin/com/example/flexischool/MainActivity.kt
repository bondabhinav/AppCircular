package flexischoolerpapp.sapinfotek.com

import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.enableEdgeToEdge
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // For Android 10+ (API 29+), use the modern approach
            try {
                // Try to use the new enableEdgeToEdge method if available
                (this as? ComponentActivity)?.enableEdgeToEdge(
                    statusBarStyle = SystemBarStyle.auto(
                        android.graphics.Color.TRANSPARENT,
                        android.graphics.Color.TRANSPARENT
                    ),
                    navigationBarStyle = SystemBarStyle.auto(
                        android.graphics.Color.TRANSPARENT,
                        android.graphics.Color.TRANSPARENT
                    )
                )
            } catch (e: NoSuchMethodError) {
                // Fallback to WindowCompat if enableEdgeToEdge is not available
                WindowCompat.setDecorFitsSystemWindows(window, false)
            }
        } else {
            // For older Android versions, use WindowCompat
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
    }
}
