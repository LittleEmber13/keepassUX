# KeepassUX

A mobile application built with Flutter for managing passwords using the KDBX format (compatible with KeePass), with a strong focus on delivering a clean, elegant, and visually appealing user interface. The goal of the project is to offer a secure and intuitiv way to store and access passwords while prioritizing a polished UX.

> ⚠️ Project status:
> The app is functional for basic password management but is still in active development. Several features are incomplete or missing, and there are known bugs. Not ready for production use.

## What Works

- Open and view KDBX databases
- Create new KDBX databases
- Add, edit, and delete entries
- Add, edit, and delete groups
- Drag-and-drop to move entries and groups between folders
- Recycle bin with soft delete, permanent delete, and restore
- Change master password
- Search entries and groups
- Password generator
- Password strength meter
- Biometric authentication to unlock the database
- Screenshot prevention
- Dark/light theme
- Internationalization (English / Spanish)

## Technologies Used

- **Flutter** — UI framework
- **kdbx.dart** — KDBX file reading and writing (https://github.com/authpass/kdbx.dart)
- **flutter_bloc** — State management
- **local_auth** — Biometric authentication
- **flutter_secure_storage** — Encrypted credential storage
- **easy_localization** — Internationalization
- **zxcvbnm** — Password strength estimation
- **file_picker / uri_content / content_resolver** — File system access via SAF

## Target Platforms

- Android

## Planned Features

- **Autofill**
- **IOS Support**