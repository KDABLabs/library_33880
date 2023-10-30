# Entre-deux-mers Libraries

A media manager application for libraries of Entre-deux-mers.  
The application allows:

- Add one or more accounts
- Switch accounts
- See existing reservations list and details
- See existing loans and details with possibility to extends the loans
- Shortcut to search (open in an external browser)
- Drawer with switching accounts and account informations
- Settings view with accounts edition and re-ordering, light/dark theme

## License

Open Source / GPL3

## Icons

* KDE Breeze - LGPL
* https://pxhere.com/en/photo/1039926 - Libre

## Authors

* Filipe Azevedo

## Building

You need Dart and Flutter installed, either manually or from the VSCode plugins.  
For Android, you would need the NDK / SDK as well as the AVD Manager plugin.  
When typing command line commands, ensure to have dart, flutter and the Android SDK / NDK accessible.

### Desktop

You need VSCode with Dart and Flutter plugins installed to build for the desktop.  
Press F5 from within VSCode or type this command from the source directory:

For Linux: `$ flutter build linux`  
For windows: `$ flutter build windows`  
For macOS: `$ flutter build macos`  

### Android

For android you woud need the AVD Manager plugin as well.  
Type this command from the source directory:

`$ flutter build apk --split-per-abi`

## Information

This application started as an education project aiming at discovering Dart & Flutter, it may be imcomplete or break at any time.
