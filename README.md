This is an improved version of the [QuickSwitch script v0.5](https://github.com/gepruts/QuickSwitch) from Gepruts. [DaWolfi, NotNull and Tuska](https://www.voidtools.com/forum/viewtopic.php?t=9881) first improved it to [v0.5dw9a](https://www.voidtools.com/forum/download/file.php?id=2235).

[New versions](https://github.com/JoyHak/QuickSwitch/releases) displays all open tabs and contains new powerful options. 

## About

Imagine you want to open/save a file. A dialog box appears, allowing you to manually select the directory on your system. QuickSwitch lets you automatically switch to the path you need if it's open in any of the supported file managers (File Explorer, Directory Opus, Total Commander, XYPlorer). 
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/white.png)

**Menu** displays a list of opened paths (tabs from file managers). Select any path to change path in file dialog:
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/menu.gif)

Enable **Auto Switch** option to automatically change path in file dialog. If the file manager was active before opening the dialog, QuickSwitch opens it's directory immediately:

![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/autoswitch.gif)

You can add specific file dialog to the **Black List** to disable QuickSwitch in web browser or another app. Use `Ctr+Q` to access the Menu if needed.

These options work separately for each window, which makes it possible to customize the application for each dialog.

And of course you can customize the display of paths in the Menu:
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/settings.png)
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/settings.gif)

[The latest versions](https://github.com/JoyHak/QuickSwitch/releases) include the following features:

- Added application auto-startup at Windows log-on.
- The menu will display the paths from all open tabs starting from the current one. 
- The path can be displayed in a shortened form.
- Improved settings interface and additional customization options and features.
- Significantly improved performance.
- Added minimalistic display of errors about incorrectly entered settings.

As an addition I recommend the [BigSur](https://www.deviantart.com/niivu/art/Big-Sur-2-Windows-10-Themes-861727886) or [CakeOS](https://www.deviantart.com/niivu/art/cakeOS-2-0-for-Windows-11-953541433) themes from Niivu and [XYplorer](https://www.xyplorer.com/index.php) file manager:
![](https://github.com/JoyHak/QuickSwitch/blob/main/Images/xyplorer.png)


## Feedback

**I really need your feedback!** If something is not working for you, please [let me know](https://github.com/JoyHak/QuickSwitch/issues/new?template=bug-report.yaml). If you think that app can be improved, [write to me](https://github.com/JoyHak/QuickSwitch/issues/new?template=feature-request.yaml).

To ensure that the correct current paths always appear in the menu:
- Disable localized folder names *(e.g. C:\Users, C:\Användare, ...).*                       
- Periodically open the file manager you need *(a big number of windows makes it difficult to find the last open manager).*
- Do not keep virtual folders open *(e.g. coll://, Desktop, Rapid Access, ...).*

QuickSwitch interacts with other applications, but the system may [restrict its access](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/user-account-control-allow-uiaccess-applications-to-prompt-for-elevation-without-using-the-secure-desktop). To avoid this, run QuickSwitch as an administrator or [disable UAC](https://superuser.com/a/1773044).

<details><summary>Details</summary>

QuickSwitch is written in AutoHotkey, which uses WinAPI. It sends messages to other file managers and receives information about the current file dialog and its contents. For these actions to work correctly, it is required that **the target process is not running as an administrator** or QuickSwitch is running with UI access (if it is not a compiled `.ahk` file) or as an administrator. The reason for this is [UIPI](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/security-policy-settings/user-account-control-allow-uiaccess-applications-to-prompt-for-elevation-without-using-the-secure-desktop):

> User Interface Privilege Isolation (UIPI) implements restrictions in the Windows subsystem that prevent lower-privilege applications from sending messages or installing hooks in higher-privilege processes. Higher-privilege applications are permitted to send messages to lower-privilege processes. UIPI doesn't interfere with or change the behavior of messages between applications at the same privilege (or integrity) level.

</details>

## Installation

1. [Download](https://github.com/JoyHak/QuickSwitch/releases) the latest version.

> [Subscribe to releases](https://docs.github.com/en/account-and-profile/managing-subscriptions-and-notifications-on-github/setting-up-notifications/about-notifications#notifications-and-subscriptions) so you don't miss critical updates!

2. Run `.exe` for your CPU architecture and check it's existence in the tray.

3. Open different directories in a supported file manager.

> E.g., open `C:\` in `Explorer`.

4. Open any application and try to open\save a file using it.

> E.g., open `Notepad` then `File - Open...`. Or try downloading any file.

5. Press `Ctrl+Q` and look at the paths in the **menu** that opens. All directories opened in supported file managers will be displayed here.

6. Explore the available options in the menu, open the settings and experiment with them. Choose a convenient style and logic of the menu!

## Scripting

This script is written in the [Autohotkey language](https://en.m.wikipedia.org/wiki/AutoHotkey).

1. [Download](https://www.autohotkey.com/download/) Autohotkey v1.1 and install it. 

> [!WARNING]
> Autohotkey v1 is an **outdated version.** I'm using it temporarily. If you want to start learning the language, install `v2`. **Do not learn autohotkey v1 yourself** and use it exclusively to run old scripts. QuickSwitch needs to be updated from `v1` to `v2` !

2. When the installation is complete, you are presented with another menu. Choose `Run AutoHotkey`.
Once the AutoHotkey help file opens, you can read or close it now. 

3. [Download](https://github.com/JoyHak/QuickSwitch/releases) the latest version of QuickSwitch.
5.  Unpack `.zip` and run `QuickSwitch.ahk`. Check it's existence in the tray.

## Compiling	

`QuickSwitch.ahk` can be automatically compiled using `ahk2exe` which is here by default: `C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe` 
It can be downloaded from here: https://github.com/AutoHotkey/Ahk2Exe
Or installed from here: `C:\Program Files\AutoHotkey\UX\install-ahk2exe.ahk`

`7-zip` is also needed to automatically create an archive with the required files: 

```powershell
"C:\Program Files\7-Zip\7zG.exe" a "%A_ScriptDir%\Releases\QuickSwitch 1.0".zip -tzip -sae -- "%A_ScriptDir%\QuickSwitch.ahk" "%A_ScriptDir%\Lib" "%A_ScriptDir%\QuickSwitch.ico"
```

For compilation, you need to select the AHK `.exe` v1.1.+ with Unicode support *(e.g. Autohotkey U64.exe)*. It can be found here:
```powershell
C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe
C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU32.exe
# version may vary
```

[Directives](https://www.autohotkey.com/docs/v1/misc/Ahk2ExeDirectives.htm#Bin) are used for compilation, but it can be set manually at each compilation using the `ahk2exe GUI`. But this is inconvenient because you will need to manually perform different actions each time you run it and you lose [the benefits of directives](https://www.autohotkey.com/docs/v1/misc/Ahk2ExeDirectives.htm#SetProp):

> Script compiler directives allow the user to specify details of how a script is to be compiled via [Ahk2Exe](https://www.autohotkey.com/docs/v1/Scripts.htm#ahk2exe). Some of the features are:
>
> - Ability to change the version information (such as the name, description, version...).
> - Ability to add resources to the compiled script.
> - Ability to tweak several miscellaneous aspects of compilation.
> - Ability to remove code sections from the compiled script and vice versa.

## Need help with
- Auto-check for update (lib and setting)
- AutoSwitch on clipboard change
- Drag and drop any file field
- Pin favourite paths
- `QTTabBar` (get all tabs)
- `Autohotkey v2` port
- New file managers support
