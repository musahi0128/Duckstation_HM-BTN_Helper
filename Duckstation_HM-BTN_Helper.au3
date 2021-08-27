#RequireAdmin
#include <ScreenCapture.au3>

Global $Emulator = "C:\Users\User1\Apps\DuckStation\duckstation-qt-x64-ReleaseLTCG.exe"
Global $WindowName = "Harvest Moon - Back to Nature (USA)"
Global $SavestateDir = "C:\Users\User1\Apps\DuckStation\savestates"
Global $SavestateFile = "SLUS-01115_1"
Global $7z = "C:\Program Files\7-Zip\7z.exe"

; ---------------------------------------------------------------------------------- ;

Func DoBackupSavestate()
	HotKeySet("{f1}")
	Send("{f1}")
	Local $BackupFilename = $SavestateFile & "-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC
	Local $TrayToolTipText = @YEAR & "-" &  @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
	_ScreenCapture_CaptureWnd($SavestateDir & "\backup\" & $BackupFilename & ".png", WinActive($WindowName))
	FileCopy($SavestateDir & "\" & $SavestateFile & ".sav", $SavestateDir & "\backup\" & $BackupFilename & ".sav")
	TraySetToolTip("Last backup: " & $TrayToolTipText)
	HotKeySet("{f1}", DoBackupSavestate)
EndFunc

Func _GetPixelState($a = 1)
	; Window Size: 909x830, Position: 0,0
	If $a = 1 Then
		Return _
		PixelGetColor(940, 232, $WindowName) + PixelGetColor(240, 346, $WindowName) + _
		PixelGetColor(940, 460, $WindowName) + PixelGetColor(240, 575, $WindowName) + _
		PixelGetColor(940, 688, $WindowName) + PixelGetColor(240, 802, $WindowName) + _
		PixelGetColor(940, 917, $WindowName)
	ElseIf $a = 2 Then
		Return PixelChecksum(538, 740, 542, 744, "", "", 1);
	ElseIf $a = 3 Then
		Return PixelChecksum(92, 439, 107, 454, "", "", 1);
	EndIf
EndFunc

; ---------------------------------------------------------------------------------- ;

HotKeySet("{f1}", DoBackupSavestate)
$PID = Run($Emulator)
While ProcessExists($PID) = $PID
	While WinActive($WindowName) = True
		If _GetPixelState(1) = 0 Then
			Send("{tab}")
			Do
				Sleep(100)
			Until _GetPixelState(1) <> 0
			Send("{tab}")
		EndIf
		If _GetPixelState(2) = 3559730004 Then
			Sleep(100)
			If _GetPixelState(3) <> 2197810037 Then
				Send("{tab}")
				Do
					Sleep(100)
				Until _GetPixelState(2) <> 3559730004
				Send("{tab}")
			EndIf
		EndIf
	WEnd
WEnd
HotKeySet("{f1}")
ToolTip("Compressing backup files. Please wait...", @DesktopWidth/2, @DesktopHeight/2, $WindowName, 1, 2)
ShellExecuteWait($7z, "a -t7z -sdel " & $SavestateFile & "-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & ".7z *.sav *.png", $SavestateDir & "\backup\", "", @SW_HIDE)
ToolTip("")
Exit
