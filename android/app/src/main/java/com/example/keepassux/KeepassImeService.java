package com.example.keepassux;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import android.inputmethodservice.InputMethodService;
import android.widget.Button;
import android.widget.TextView;

public class KeepassImeService extends InputMethodService {
    private View root;
    private TextView entryLabel;
    private Button usernameButton;
    private Button passwordButton;

    @Override
    public View onCreateInputView() {
        root = getLayoutInflater().inflate(R.layout.keyboard_view, null);
        entryLabel = root.findViewById(R.id.kb_entry_label);
        usernameButton = root.findViewById(R.id.kb_username);
        passwordButton = root.findViewById(R.id.kb_password);

        usernameButton.setOnClickListener(v -> commit(KeyboardCredentialHolder.getUsername()));
        passwordButton.setOnClickListener(v -> commit(KeyboardCredentialHolder.getPassword()));
        root.findViewById(R.id.kb_open_app).setOnClickListener(v -> openApp());
        root.findViewById(R.id.kb_switch).setOnClickListener(v -> switchKeyboard());
        return root;
    }

    @Override
    public void onStartInputView(EditorInfo info, boolean restarting) {
        super.onStartInputView(info, restarting);
        refresh();
    }

    private void refresh() {
        if (entryLabel == null) return;
        boolean has = KeyboardCredentialHolder.hasCredential();
        if (has) {
            String label = KeyboardCredentialHolder.getLabel();
            entryLabel.setText(label == null || label.isEmpty()
                    ? getString(R.string.kb_entry_ready) : label);
        } else {
            entryLabel.setText(getString(R.string.kb_no_entry));
        }
        usernameButton.setEnabled(KeyboardCredentialHolder.getUsername() != null);
        passwordButton.setEnabled(KeyboardCredentialHolder.getPassword() != null);
    }

    private void commit(String text) {
        if (text == null) return;
        InputConnection ic = getCurrentInputConnection();
        if (ic != null) {
            ic.commitText(text, 1);
        }
    }

    private void openApp() {
        Intent intent = getPackageManager().getLaunchIntentForPackage(getPackageName());
        if (intent != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        }
    }

    private void switchKeyboard() {
        boolean switched = false;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            switched = switchToPreviousInputMethod();
        }
        if (!switched) {
            InputMethodManager imm =
                    (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            if (imm != null) {
                imm.showInputMethodPicker();
            }
        }
    }
}
