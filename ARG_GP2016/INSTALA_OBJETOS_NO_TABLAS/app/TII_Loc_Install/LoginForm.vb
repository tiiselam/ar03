Imports System.Data
Public Class LoginForm
    'General declarations for the example
    Dim GPConnObj As Microsoft.Dexterity.GPConnection
    Dim RetCode As Long
    Dim Key1, Key2 As String

    Private Sub LoginForm_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Dim dsnList As New System.Collections.SortedList()
        Dim x As Integer
        dsnList = GetUserDataSourceNames()
        For x = 0 To dsnList.Count - 1
            DSNCmb.Items.Add(dsnList.GetKey(x).ToString)
        Next
        UserTxt.Text = "sa"
    End Sub
    Public Function GetUserDataSourceNames() As System.Collections.SortedList
        Dim dsnList As New System.Collections.SortedList()
        ' get user dsn's
        Dim reg As Microsoft.Win32.RegistryKey = (Microsoft.Win32.Registry.LocalMachine).OpenSubKey("Software")

        If reg IsNot Nothing Then
            If IntPtr.Size = 8 Then
                reg = reg.OpenSubKey("Wow6432Node")
            End If
            reg = reg.OpenSubKey("ODBC")
            If reg IsNot Nothing Then
                reg = reg.OpenSubKey("ODBC.INI")
                If reg IsNot Nothing Then
                    reg = reg.OpenSubKey("ODBC Data Sources")
                    If reg IsNot Nothing Then
                        ' Get all DSN entries defined in DSN_LOC_IN_REGISTRY.
                        For Each sName As String In reg.GetValueNames()
                            dsnList.Add(sName, DataSourceType.System)
                        Next
                    End If
                    Try
                        reg.Close()
                        ' ignore this exception if we couldn't close
                    Catch
                    End Try
                End If
            End If
        End If
        Return dsnList
    End Function

    Private Sub Button1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Conectar.Click
        Dim cnCmp As System.Data.SqlClient.SqlConnection = New System.Data.SqlClient.SqlConnection()
        Dim cnSys As System.Data.SqlClient.SqlConnection = New System.Data.SqlClient.SqlConnection()

        Dim cmdCmp As System.Data.SqlClient.SqlCommand = New System.Data.SqlClient.SqlCommand()
        Dim cmdSys As System.Data.SqlClient.SqlCommand = New System.Data.SqlClient.SqlCommand()

        Dim rst As System.Data.SqlClient.SqlDataReader
        Dim resp As Int32

        Microsoft.Dexterity.GPConnection.Startup()

        ' Create the connection object
        GPConnObj = New Microsoft.Dexterity.GPConnection()

        Key1 = "DAX"
        Key2 = "`l89Q5WV814133USVA.41" & Chr(34) & "277&202t833-02p'"
        ' Initialize
        resp = GPConnObj.Init(Key1, Key2)



        ' Make the connection
        cnSys.ConnectionString = "DATABASE=DYNAMICS"
        GPConnObj.Connect(cnSys, DSNCmb.Text, UserTxt.Text, PwdTxt.Text)

        ' Check the return code
        If ((GPConnObj.ReturnCode And CType(Microsoft.Dexterity.GPConnection.ReturnCodeFlags.SuccessfulLogin, Integer)) = CType(Microsoft.Dexterity.GPConnection.ReturnCodeFlags.SuccessfulLogin, Integer)) Then

            ' Specify the system connection

            cmdSys.Connection = cnSys

            Call InstalarObjetos.Initialize(cnSys, DSNCmb.Text, UserTxt.Text, PwdTxt.Text)
            Me.Close()
        Else
            MessageBox.Show("Login failed")
        End If

        ' Dispose of the connection object
        GPConnObj = Nothing
        'Shut down the object
        Microsoft.Dexterity.GPConnection.Shutdown()

    End Sub
End Class