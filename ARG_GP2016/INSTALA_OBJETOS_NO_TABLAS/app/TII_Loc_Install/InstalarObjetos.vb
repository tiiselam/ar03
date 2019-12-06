Imports System.IO
Imports System.Windows.Forms
Imports System.Data.SqlClient
Public Enum DataSourceType
    System
    User
End Enum
Public Class InstalarObjetos
    Dim cnCmp As System.Data.SqlClient.SqlConnection = New System.Data.SqlClient.SqlConnection()
    Dim cnSys As System.Data.SqlClient.SqlConnection = New System.Data.SqlClient.SqlConnection()

    Dim cmdCmp As System.Data.SqlClient.SqlCommand = New System.Data.SqlClient.SqlCommand()
    Dim cmdSys As System.Data.SqlClient.SqlCommand = New System.Data.SqlClient.SqlCommand()

    Dim rst As System.Data.SqlClient.SqlDataReader
    Dim resp As Int32
    'General declarations for the example
    Dim GPConnObj As Microsoft.Dexterity.GPConnection
    Dim RetCode As Long
    Dim Key1, Key2 As String

    Dim sSource, sUser, sPassword As String

    Private Sub InstalarObjetos_Deactivate(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Deactivate
 
    End Sub
    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Modulos.Items.Add("9882 - Argentina - Medios de Cobro Pago / Retenci")
        Modulos.Items.Add("9883 - Argentina - TII-AW Listador de Impuestos")
        Modulos.Items.Add("9884 - Argentina - TIIAX-Impresion de Cheques")
        Modulos.Items.Add("4350 - Argentina - Document Legales")
        Modulos.Items.Add("4100 - Argentina - Perceptiones")
        Modulos.Items.Add("5040 - Argentina - Shipping Documents")
        Modulos.Items.Add("9888 - Andina - Ajustes Inflacion Inventarios")
        Modulos.Items.Add("9889 - Andina - Comprobante de Compras")
        Modulos.Items.Add("9887 - Andina - Información Fiscal")
        Modulos.Items.Add("9890 - Andina - Certificados De Retencion")
        Modulos.Items.Add("7705 - Chilena - Localizacion Chilena")
        Modulos.Items.Add("10100 - Chilena - Corr. Monetaria Existencias")

    End Sub
    Public Sub Initialize(ByVal conSys, ByVal DataSource, ByVal Usuario, ByVal Contrasenia)
        cnSys = conSys
        cmdSys.Connection = cnSys
        CargaCompanias()
        sSource = DataSource
        sUser = Usuario
        sPassword = Contrasenia
        Me.Show()
    End Sub
    Private Function CargaCompanias()
        ' Specify the command retrieve all customers
        cmdSys.CommandText = "Select LEFT(RTRIM(INTERID) + '  ', 5) + ' - ' + CMPNYNAM COMPANY From SY01500 ORDER BY CMPNYNAM "

        ' Execute the command
        rst = cmdSys.ExecuteReader()
        While (rst.Read = True)
            Companies.Items.Add(rst.GetValue(rst.GetOrdinal("COMPANY")).ToString())
        End While

        ' Close the connection
        rst.Close()

    End Function
    Public Function CMP_4100(ByVal sDatabase)
        Dim FILE_NAME As String

        Dim mycon As SqlConnection
        Dim Indice As Integer
        Dim sArchivo As String = ""

        mycon = cnCmp

        For Indice = 1 To 2
            Select Case Indice
                Case 1
                    sArchivo = "\4100_COMPANY_1_Procs.cmp"
                Case 2
                    sArchivo = "\4100_COMPANY_2_Stubs.cmp"
            End Select
            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base compañía. Script " & CStr(Indice) & " de 2: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function CMP_4350(ByVal sDatabase)
        Dim FILE_NAME As String

        Dim mycon As SqlConnection
        Dim Indice As Integer
        Dim sArchivo As String = ""

        mycon = cnCmp

        For Indice = 1 To 4
            Select Case Indice
                Case 1
                    sArchivo = "\4350_COMPANY_1_Views.cmp"
                Case 2
                    sArchivo = "\4350_COMPANY_2_Funcs.cmp"
                Case 3
                    sArchivo = "\4350_COMPANY_3_Procs.cmp"
                Case 4
                    sArchivo = "\4350_COMPANY_4_Stubs.cmp"
            End Select

            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base compañía. Script " & CStr(Indice) & " de 4: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function CMP_5040(ByVal sDatabase)
        Dim FILE_NAME As String
        Dim sArchivo As String = ""

        Dim mycon As SqlConnection
        Dim Indice As Integer

        mycon = cnCmp

        For Indice = 1 To 3
            Select Case Indice
                Case 1
                    sArchivo = "\5040_COMPANY_1_Views.cmp"
                Case 2
                    sArchivo = "\5040_COMPANY_2_Procs.cmp"
                Case 3
                    sArchivo = "\5040_COMPANY_3_Stubs.cmp"
            End Select

            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base compañía. Script " & CStr(Indice) & " de 3: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function SYS_5040(ByVal sDynamics)
        Dim FILE_NAME As String
        Dim sArchivo As String = ""

        Dim mycon As SqlConnection
        Dim Indice As Integer

        mycon = cnCmp

        For Indice = 1 To 2
            Select Case Indice
                Case 1
                    sArchivo = "\5040_COMPANY_1_Procs.sys"
                Case 2
                    sArchivo = "\5040_COMPANY_2_Stubs.sys"
            End Select

            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base sistema. Script " & CStr(Indice) & " de 2: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function CMP_7705(ByVal sDatabase)
        Dim FILE_NAME As String
        Dim sArchivo As String = ""

        Dim mycon As SqlConnection
        Dim Indice As Integer

        mycon = cnCmp

        For Indice = 1 To 3
            Select Case Indice
                Case 1
                    sArchivo = "\7705_COMPANY_1_Views.cmp"
                Case 2
                    sArchivo = "\7705_COMPANY_2_Procs.cmp"
                Case 3
                    sArchivo = "\7705_COMPANY_3_Stubs.cmp"
            End Select

            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base compañía. Script " & CStr(Indice) & " de 3: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function CMP_9882(ByVal sDatabase)
        Dim FILE_NAME As String
        Dim sArchivo As String = ""

        Dim mycon As SqlConnection
        Dim Indice As Integer

        mycon = cnCmp

        For Indice = 1 To 3
            Select Case Indice
                Case 1
                    sArchivo = "\9882_COMPANY_1_Views.cmp"
                Case 2
                    sArchivo = "\9882_COMPANY_2_Procs.cmp"
                Case 3
                    sArchivo = "\9882_COMPANY_3_Stubs.cmp"
            End Select

            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base compañía. Script " & CStr(Indice) & " de 3: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function CMP_9883(ByVal sDatabase)
        Dim FILE_NAME As String
        Dim sArchivo As String = ""

        Dim mycon As SqlConnection
        Dim Indice As Integer

        mycon = cnCmp

        For Indice = 1 To 5
            Select Case Indice
                Case 1
                    sArchivo = "\9883_COMPANY_1_Views.cmp"
                Case 2
                    sArchivo = "\9883_COMPANY_2_Funcs.cmp"
                Case 3
                    sArchivo = "\9883_COMPANY_3_Procs.cmp"
                Case 4
                    sArchivo = "\9883_COMPANY_4_Stubs.cmp"
                Case 5
                    sArchivo = "\9883_COMPANY_5_Views.cmp"
            End Select

            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base compañía. Script " & CStr(Indice) & " de 5: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function CMP_9884(ByVal sDatabase)
        Dim FILE_NAME As String
        Dim sArchivo As String = ""

        Dim mycon As SqlConnection
        Dim Indice As Integer

        mycon = cnCmp

        For Indice = 1 To 2
            Select Case Indice
                Case 1
                    sArchivo = "\9884_COMPANY_1_Procs.cmp"
                Case 2
                    sArchivo = "\9884_COMPANY_2_Stubs.cmp"
            End Select

            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base compañía. Script " & CStr(Indice) & " de 2: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function CMP_9887(ByVal sDatabase)
        Dim FILE_NAME As String
        Dim sArchivo As String = ""

        Dim mycon As SqlConnection
        Dim Indice As Integer

        mycon = cnCmp

        For Indice = 1 To 3
            Select Case Indice
                Case 1
                    sArchivo = "\9887_COMPANY_1_Triggers.cmp"
                Case 2
                    sArchivo = "\9887_COMPANY_2_Procs.cmp"
                Case 3
                    sArchivo = "\9887_COMPANY_3_Stubs.cmp"
            End Select

            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base compañía. Script " & CStr(Indice) & " de 3: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function CMP_9888(ByVal sDatabase)
        Dim FILE_NAME As String
        Dim sArchivo As String = ""

        Dim mycon As SqlConnection
        Dim Indice As Integer

        mycon = cnCmp

        For Indice = 1 To 2
            Select Case Indice
                Case 1
                    sArchivo = "\9888_COMPANY_1_Procs.cmp"
                Case 2
                    sArchivo = "\9888_COMPANY_2_Stubs.cmp"
            End Select

            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base compañía. Script " & CStr(Indice) & " de 2: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function CMP_9889(ByVal sDatabase)
        Dim FILE_NAME As String
        Dim sArchivo As String = ""

        Dim mycon As SqlConnection
        Dim Indice As Integer

        mycon = cnCmp

        For Indice = 1 To 2
            Select Case Indice
                Case 1
                    sArchivo = "\9889_COMPANY_1_Procs.cmp"
                Case 2
                    sArchivo = "\9889_COMPANY_2_Stubs.cmp"
            End Select

            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base compañía. Script " & CStr(Indice) & " de 2: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function CMP_9890(ByVal sDatabase)
        Dim FILE_NAME As String
        Dim sArchivo As String = ""

        Dim mycon As SqlConnection
        Dim Indice As Integer

        mycon = cnCmp

        For Indice = 1 To 2
            Select Case Indice
                Case 1
                    sArchivo = "\9890_COMPANY_1_Procs.cmp"
                Case 2
                    sArchivo = "\9890_COMPANY_2_Stubs.cmp"
            End Select

            FILE_NAME = Application.StartupPath() & sArchivo

            Label5.Text = "Base compañía. Script " & CStr(Indice) & " de 2: " & sArchivo
            Label5.Refresh()

            LeerArchivoEjecutarScripts(FILE_NAME, mycon)
        Next

    End Function
    Public Function LeerArchivoEjecutarScripts(ByVal sFile As String, ByVal Conn As SqlConnection)
        Dim TextLine As String = ""

        Dim comUserSelect As SqlCommand
        'Dim rs As ADODB.Connection
        Dim strSQL As String = ""
        Dim pepe As String
        Dim Primero As Integer

        'MessageBox.Show("Achivo " & sFile)

        If System.IO.File.Exists(sFile) = True Then

            Dim objReader As New System.IO.StreamReader(sFile)

            Do While objReader.Peek() <> -1

                TextLine = Trim(objReader.ReadLine()) & vbNewLine
                'MsgBox(TextLine)


                pepe = Trim(Microsoft.VisualBasic.Left(TextLine, 3) & " ")
                If UCase(pepe) <> "GO" And UCase(pepe) <> "GO" & Chr(13) Then
                    'MsgBox(Asc(Mid(TextLine, 3, 1)))
                    strSQL = strSQL & TextLine
                Else
                    'MsgBox(strSQL)
                    'MessageBox.Show(strSQL)
                    comUserSelect = New SqlCommand(strSQL, Conn)
                    comUserSelect.CommandTimeout() = 0
                    Try
                        Primero = comUserSelect.ExecuteNonQuery
                    Catch ex As Exception
                        MsgBox(ex.Message)
                    End Try
                    comUserSelect = Nothing

                    strSQL = ""
                    'MsgBox(Asc(Mid(TextLine, 3, 1)))
                    'MsgBox(UCase(pepe))
                End If

            Loop

            objReader = Nothing

        Else

            'MsgBox("File Does Not Exist")

        End If

    End Function

    Private Sub Instalar_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Instalar.Click
        Dim sDatabase As String
        Dim sDynamics As String = "DYNAMICS"
        Dim CompCount As Integer = 0
        Dim ModuleCount As Integer = 0

        If Modulos.SelectedItems.Count = 0 Then
            MsgBox("No ha seleccionado ningún módulo.")
            Exit Sub
        End If
        If Companies.SelectedItems.Count = 0 Then
            MsgBox("No ha seleccionado ninguna compañía.")
            Exit Sub
        End If

        For Each x As String In Companies.SelectedItems

            Microsoft.Dexterity.GPConnection.Startup()

            ' Create the connection object
            GPConnObj = New Microsoft.Dexterity.GPConnection()

            Key1 = "DAX"
            Key2 = "`l89Q5WV814133USVA.41" & Chr(34) & "277&202t833-02p'"
            ' Initialize
            resp = GPConnObj.Init(Key1, Key2)

            sDatabase = Trim(Microsoft.VisualBasic.Left(x, 5))





            ' Make the connection
            cnCmp.ConnectionString = "DATABASE=" & sDatabase

            'MessageBox.Show(cnCmp.ConnectionString)

            GPConnObj.Connect(cnCmp, sSource, sUser, sPassword)

            If ((GPConnObj.ReturnCode And CType(Microsoft.Dexterity.GPConnection.ReturnCodeFlags.SuccessfulLogin, Integer)) = CType(Microsoft.Dexterity.GPConnection.ReturnCodeFlags.SuccessfulLogin, Integer)) Then

                CompCount = CompCount + 1
                Label3.Text = "Compañía " & CStr(CompCount) & " de " & CStr(Companies.SelectedItems.Count) & " : " & x
                Label3.Refresh()

                ' Specify the system connection
                cmdCmp.Connection = cnCmp

                ' Specify the command retrieve all customers
                cmdCmp.CommandText = "Select DBNAME From SY00100 "

                ' Execute the command
                rst = cmdCmp.ExecuteReader()
                While (rst.Read = True)
                    sDynamics = rst.GetValue(rst.GetOrdinal("DBNAME")).ToString()
                End While

                ' Close the connection
                rst.Close()

                For Each y As String In Modulos.SelectedItems
                    ModuleCount = ModuleCount + 1
                    Label4.Text = "Módulo " & CStr(ModuleCount) & " de " & CStr(Modulos.SelectedItems.Count) & " : " & y
                    Label4.Refresh()

                    Select Case Trim(Microsoft.VisualBasic.Left(y, 5))
                        Case "4100"
                            CMP_4100(sDatabase)
                        Case "4350"
                            CMP_4350(sDatabase)
                        Case "5040"
                            CMP_5040(sDatabase)
                            SYS_5040(sDynamics)
                        Case "7705"
                            CMP_7705(sDatabase)
                        Case "9882"
                            CMP_9882(sDatabase)
                        Case "9883"
                            CMP_9883(sDatabase)
                        Case "9884"
                            CMP_9884(sDatabase)
                        Case "9887"
                            CMP_9887(sDatabase)
                        Case "9888"
                            CMP_9888(sDatabase)
                        Case "9889"
                            CMP_9889(sDatabase)
                        Case "9890"
                            CMP_9890(sDatabase)
                    End Select
                Next
                ModuleCount = 0
            End If
            cnCmp.Close()
            'cmdCmp = Nothing
            Microsoft.Dexterity.GPConnection.Shutdown()
        Next
        cnSys.Close()
        cnSys = Nothing
        cnCmp = Nothing
        cmdSys = Nothing
        GPConnObj = Nothing

        MsgBox("Instalación finalizada")

        Me.Close()

    End Sub
End Class
