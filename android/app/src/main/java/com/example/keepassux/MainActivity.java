package com.example.keepassux;

import android.content.Intent;
import android.net.Uri;
import android.view.WindowManager;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterFragmentActivity {
    private static final String CHANNEL = "com.example.keepassux/saf";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("takePersistableUriPermission")) {
                    String uriString = call.argument("uri");
                    try {
                        Uri uri = Uri.parse(uriString);
                        int takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                                | Intent.FLAG_GRANT_WRITE_URI_PERMISSION;
                        getContentResolver().takePersistableUriPermission(uri, takeFlags);
                        result.success(true);
                    } catch (Exception e) {
                        result.success(false);
                    }
                } else if (call.method.equals("setFlagSecure")) {
                    Boolean enabled = call.argument("enabled");
                    if (enabled != null && enabled) {
                        getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
                    } else {
                        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
                    }
                    result.success(true);
                } else {
                    result.notImplemented();
                }
            });
    }
}
