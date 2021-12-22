Attribute VB_Name = "PDFOpen"
Public Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" ( _
                    ByVal hwnd As Long, _
                    ByVal lpOperation As String, _
                    ByVal lpFile As String, _
                    ByVal lpParameters As String, _
                    ByVal lpDirectory As String, _
                    ByVal nShowCmd As Long) As Long

Public Const SW_HIDE As Long = 0
Public Const SW_SHOWNORMAL As Long = 1
Public Const SW_SHOWMAXIMIZED As Long = 3
Public Const SW_SHOWMINIMIZED As Long = 2

Public Sub RunMe(ByVal FileName As String)
    ShellExecute 0, "open", FileName, vbNullString, "\", SW_SHOWNORMAL
End Sub



