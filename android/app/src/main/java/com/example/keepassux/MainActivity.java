package com.example.keepassux;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodInfo;
import android.view.inputmethod.InputMethodManager;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterFragmentActivity {
    private static final String CHANNEL = "com.example.keepassux/saf";
    private static final String KEYBOARD_CHANNEL = "com.example.keepassux/keyboard";
    private static final int REQUEST_OPEN_DOCUMENT = 4311;
    private static final int REQUEST_CREATE_DOCUMENT = 4312;

    private MethodChannel.Result pendingDocumentResult;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("openDocument")) {
                    if (pendingDocumentResult != null) {
                        result.error("busy", "Another document request is in progress", null);
                        return;
                    }
                    pendingDocumentResult = result;
                    Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                    intent.addCategory(Intent.CATEGORY_OPENABLE);
                    intent.setType("*/*");
                    startActivityForResult(intent, REQUEST_OPEN_DOCUMENT);
                } else if (call.method.equals("createDocument")) {
                    if (pendingDocumentResult != null) {
                        result.error("busy", "Another document request is in progress", null);
                        return;
                    }
                    pendingDocumentResult = result;
                    Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
                    intent.addCategory(Intent.CATEGORY_OPENABLE);
                    intent.setType("application/octet-stream");
                    intent.putExtra(Intent.EXTRA_TITLE, (String) call.argument("fileName"));
                    startActivityForResult(intent, REQUEST_CREATE_DOCUMENT);
                } else if (call.method.equals("takePersistableUriPermission")) {
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

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), KEYBOARD_CHANNEL)
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

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_OPEN_DOCUMENT || requestCode == REQUEST_CREATE_DOCUMENT) {
            MethodChannel.Result result = pendingDocumentResult;
            pendingDocumentResult = null;
            if (result == null) return;
            Uri uri = (resultCode == RESULT_OK && data != null) ? data.getData() : null;
            if (uri == null) {
                result.success(null);
                return;
            }
            try {
                getContentResolver().takePersistableUriPermission(uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            } catch (Exception ignored) {
            }
            result.success(uri.toString());
            return;
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    /** Whether this app's IME is enabled in Android's input-method settings. */
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
}
