Talos
======

**Talos** is a lightweight app for quickly accessing your 1Password keychain entries.

It's a standalone app - you do not need to have 1Password installed.

Quick Tour
-----------
When first launched, Talos will ask you to locate your 1Password keychain ( the `.agilekeychain` file).

### Locking/Unlocking The Keychain

    * Enter the master password to unlock the keychain.
    * It will automatically lock itself after a while.
    * To manually lock the keychain, use the `CMD+L` shortcut.

### Copying Passwords

    * Search or use the arrow keys to select the item you want.
    * Hit `ENTER` to copy the password.

### Invoking/Dismissing

    * Once launched, Talos will stay resident in memory. You can bring it up by using the `CMD+SHIFT+1` shortcut.
    * Press `esc` to dismiss it.
    * To quit permanently, use `CMD+Q`.

Requirements
-------------

Mac OS X 10.7 or newer.

Building
---------

Talos uses Objective-C literals, so you will need Xcode 4.4 or newer to build it.