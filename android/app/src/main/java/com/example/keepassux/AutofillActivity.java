package com.example.keepassux;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.provider.Settings;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodInfo;
import android.view.inputmethod.InputMethodManager;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class AutofillActivity extends FlutterFragmentActivity {
    private static final String CHANNEL = "com.example.keepassux/autofill";
    private static final String KEYBOARD_CHANNEL = "com.example.keepassux/keyboard";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("launchMainActivity")) {
                    Intent intent = new Intent(this, MainActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK
                            | Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    startActivity(intent);
                    result.success(true);
                } else if (call.method.equals("fillDataset")) {
                    String label = call.argument("label");
                    String username = call.argument("username");
                    String password = call.argument("password");
                    String status = AutofillFiller.INSTANCE.fill(
                            this,
                            label != null ? label : "",
                            username != null ? username : "",
                            password != null ? password : "");
                    result.success(status);
                    if (AutofillFiller.RESULT_DATASET.equals(status)) {
                        finish();
                    }
                } else {
                    result.notImplemented();
                }
            });

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(), KEYBOARD_CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "setKeyboardEntry":
                        KeyboardCredentialHolder.set(
                                call.argument("label"),
                                call.argument("username"),
                                call.argument("password"));
                        result.success(true);
                        break;
                    case "clearKeyboardEntry":
                        KeyboardCredentialHolder.clear();
                        result.success(true);
                        break;
                    case "isKeyboardEnabled":
                        result.success(isKeyboardEnabled());
                        break;
                    case "openKeyboardSettings":
                        Intent settings = new Intent(Settings.ACTION_INPUT_METHOD_SETTINGS);
                        settings.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        startActivity(settings);
                        result.success(true);
                        break;
                    case "showKeyboardPicker":
                        InputMethodManager picker =
                                (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                        if (picker != null) {
                            picker.showInputMethodPicker();
                        }
                        result.success(true);
                        break;
                    default:
                        result.notImplemented();
                }
            });
    }

    private boolean isKeyboardEnabled() {
        InputMethodManager imm =
                (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm == null) return false;
        for (InputMethodInfo info : imm.getEnabledInputMethodList()) {
            if (info.getPackageName().equals(getPackageName())) {
                return true;
            }
        }
        return false;
    }

    @Override
    public String getDartEntrypointFunctionName() {
        return "autofillEntryPoint";
    }
}
