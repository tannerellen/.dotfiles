### Finding your profile folder:
- Open Firefox and go to about:support
- Next to “Profile Folder” (or “Profile Directory”), click Open Directory

## Add custom user chrome css in Firefox
- Copy userChrome.css to ~/.mozilla/firefox/<profile id>/chrome/

### Enable the legacy stylesheet loading pref: 
- go to about:config, search for toolkit.legacyUserProfileCustomizations.stylesheets, and set it to true.
- Restart Firefox.
