package com.example.keepassux;

public final class KeyboardCredentialHolder {
    private static final long TTL_MS = 60_000L;

    private static String label;
    private static String username;
    private static String password;
    private static long expiresAt;

    private KeyboardCredentialHolder() {}

    public static synchronized void set(String label, String username, String password) {
        KeyboardCredentialHolder.label = label;
        KeyboardCredentialHolder.username = username;
        KeyboardCredentialHolder.password = password;
        KeyboardCredentialHolder.expiresAt = System.currentTimeMillis() + TTL_MS;
    }

    public static synchronized void clear() {
        label = null;
        username = null;
        password = null;
        expiresAt = 0L;
    }

    public static synchronized boolean hasCredential() {
        if (expiresAt != 0L && System.currentTimeMillis() > expiresAt) {
            clear();
        }
        return username != null || password != null;
    }

    public static synchronized String getLabel() {
        return hasCredential() ? label : null;
    }

    public static synchronized String getUsername() {
        return hasCredential() ? username : null;
    }

    public static synchronized String getPassword() {
        return hasCredential() ? password : null;
    }
}
