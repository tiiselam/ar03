VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "nfRETCertRetIIBBII02"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Dim cn As New ADODB.Connection
Dim rst As New ADODB.Recordset
Dim cmd As New ADODB.Command
Dim sPorcentajeTuc As String

Private Sub Report_BeforeAF(ByVal Level As Integer, SuppressBand As Boolean)
'-If Level = 3 Then
'-    PorcentajeIIBBLASTF3 = sPorcentajeTuc
'-Else
'    PorcentajeIIBBLASTF3 = "2%"
'-End If
 PorcentajeIIBB = sPorcentajeTuc
End Sub

Private Sub Report_BeforePH(SuppressBand As Boolean)
Set cn = UserInfoGet.CreateADOConnection
cn.DefaultDatabase = UserInfoGet.IntercompanyID
cmd.ActiveConnection = cn

'------ Armo la consulta para obtener el transportista del método de envío ------
cmd.CommandText = " select CONVERT(VARCHAR, CONVERT(DECIMAL(5, 2), PRCNTAGE)) + '%' PORCENTAJE from nfRET_PM00201 WHERE VENDORID = '" & VendorID & "' AND " & _
 " TII_MCP_From_Date <= '" & Format(DocumentDate, "yyyymmdd") & "' AND TII_MCP_TO_DATE >= '" & Format(DocumentDate, "yyyymmdd") & "' " & _
 " AND nfRET_Tipo_ID =(SELECT nfRET_Tipo_ID FROM nfRET_GL00030 WHERE nfRET_Retencion_ID = 'RT-PIBB TU') "
                 
'select CONVERT(VARCHAR, CONVERT(DECIMAL(5, 2), PRCNTAGE)/100)) + '%' PORCENTAJE from nfRET_PM00201 WHERE VENDORID = '" & VendorID & "' AND " & _
' TII_MCP_From_Date <= '" & Format(nfRETFecRetencion, "yyyymmdd") & "' AND TII_MCP_TO_DATE >= '" & Format(nfRETFecRetencion, "yyyymmdd") & "' " & _
'AND nfRET_Tipo_ID =(SELECT nfRET_Tipo_ID FROM nfRET_GL00030 WHERE nfRET_Retencion_ID = 'RT-PIBB BA') "
                 
Set rst = cmd.Execute
     
If Not rst.EOF Then
    sPorcentajeTuc = rst.Fields("PORCENTAJE").Value
Else
    sPorcentajeTuc = nfRETPorcentajeLASTF3
End If

rst.Close
Set cmd = Nothing
Set cn = Nothing

End Sub

