package io.github.photowey.keeauth;

import android.os.Bundle;
import android.view.WindowManager;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterFragmentActivity {
    private static final String CHANNEL = "keeauth/security";
    private boolean isSecure = true; // Default to secure mode (no screenshots)

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "setSecure":
                        Boolean enabled = call.argument("enabled");
                        if (enabled != null) {
                            setSecure(enabled);
                            result.success(null);
                        } else {
                            result.error("INVALID_ARGUMENT", "enabled argument is required", null);
                        }
                        break;
                    case "isSecure":
                        result.success(isSecure);
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Apply secure flag by default
        applySecureFlag(isSecure);
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Re-apply secure flag when resuming
        applySecureFlag(isSecure);
    }

    private void setSecure(boolean enabled) {
        isSecure = enabled;
        applySecureFlag(enabled);
    }

    private void applySecureFlag(boolean enabled) {
        if (enabled) {
            getWindow().setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            );
        } else {
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
        }
    }
}
