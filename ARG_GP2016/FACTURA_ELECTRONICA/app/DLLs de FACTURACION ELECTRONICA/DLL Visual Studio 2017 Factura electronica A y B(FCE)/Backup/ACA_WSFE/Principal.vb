Imports System
Imports System.Collections.Generic
Imports System.Text
Imports System.Xml
Imports System.Xml.Serialization
Imports System.Xml.XmlException
Imports System.Net
Imports System.Security
Imports System.Security.Cryptography
Imports System.Security.Cryptography.Pkcs
Imports System.Security.Cryptography.X509Certificates
Imports System.IO
Imports System.Runtime.InteropServices
Imports Microsoft.VisualBasic.FileIO.FileSystem
Imports System.Net.Mail
Imports System.Data.SqlClient
Public Class Principal
    ' Valores por defecto, globales en esta clase
    Const DEFAULT_URLWSAAWSDLTEST As String = "https://wsaahomo.afip.gov.ar/ws/services/LoginCms?WSDL"
    Const DEFAULT_URLWSAAWSDLPROD As String = "https://wsaa.afip.gov.ar/ws/services/LoginCms?WSDL"
    Const DEFAULT_SERVICIO As String = "wsfe"
    Const DEFAULT_CERTSIGNER As String = "c:\CertificadoConClavePrivada.p12"
    Const DEFAULT_PROXY As String = Nothing
    Const DEFAULT_PROXY_USER As String = Nothing
    Const DEFAULT_PROXY_PASSWORD As String = ""
    Const DEFAULT_VERBOSE As Boolean = True

    ''' <summary>
    ''' Funcion Principal 
    ''' </summary>
    ''' <returns>0 si terminó bien, valores negativos si hubieron errores</returns>
    ''' <remarks></remarks>
    Public Function ObtieneCAETEST(ByVal cuit As String, _
        ByVal strId As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal strcantidadreg As String, _
        ByVal presta_serv As String, _
        ByVal tipo_doc As String, _
        ByVal nro_doc As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByRef cbt_desde As String, _
        ByRef cbt_hasta As String, _
        ByVal imp_total As String, _
        ByVal imp_tot_conc As String, _
        ByVal imp_neto As String, _
        ByVal impto_liq As String, _
        ByVal impto_liq_rni As String, _
        ByVal imp_op_ex As String, _
        ByVal fecha_cbte As String, _
        ByVal fecha_serv_desde As String, _
        ByVal fecha_serv_hasta As String, _
        ByVal fecha_venc_pago As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, _
        ByRef desc_rechazo As String, _
        ByRef codeerr As String, _
        ByRef msgerr As String, _
        ByRef reproceso As String) As Boolean

        Dim objWSFE As New wsw.Service
        Dim objFEAuthRequest As New wsw.FEAuthRequest
        Dim cantidadreg As Integer = 1
        Dim indicemax As Integer = 0
        Dim d As Integer = 0
        Dim ii As Integer

        Dim objFERequest As New wsw.FERequest
        Dim objFECabeceraRequest As New wsw.FECabeceraRequest
        Dim ArrayOfFEDetalleRequest(indicemax) As wsw.FEDetalleRequest
        Dim objFEResponse As New wsw.FEResponse
        Dim ArrayOfFEDetalleResponse(indicemax) As wsw.FEDetalleResponse
        objFEAuthRequest.cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFECabeceraRequest.id = strId
        objFECabeceraRequest.cantidadreg = Val(strcantidadreg)
        objFECabeceraRequest.presta_serv = presta_serv
        objFERequest.Fecr = objFECabeceraRequest

        'Obtengo los datos del DataGridView DGV_FEDetalleRequest
        For d = 0 To (indicemax)
            Dim objFEDetalleRequest As New wsw.FEDetalleRequest
            With objFEDetalleRequest
                .tipo_doc = Val(tipo_doc)
                .nro_doc = Val(nro_doc)
                .tipo_cbte = Val(tipo_cbte)
                .punto_vta = Val(punto_vta)
                .cbt_desde = Val(cbt_desde)
                .cbt_hasta = Val(cbt_hasta)
                .imp_total = Val(imp_total)
                .imp_tot_conc = Val(imp_tot_conc)
                .imp_neto = Val(imp_neto)
                .impto_liq = Val(impto_liq)
                .impto_liq_rni = Val(impto_liq_rni)
                .imp_op_ex = Val(imp_op_ex)
                .fecha_cbte = fecha_cbte
                If presta_serv > "1" Then
                    .fecha_serv_desde = fecha_serv_desde
                    .fecha_serv_hasta = fecha_serv_hasta
                    .fecha_venc_pago = fecha_venc_pago
                End If
            End With
            ArrayOfFEDetalleRequest(d) = objFEDetalleRequest
        Next d
        objFERequest.Fedr = ArrayOfFEDetalleRequest

        ' Invoco al método FEAutRequest
        Try
            objFEResponse = objWSFE.FEAutRequest(objFEAuthRequest, objFERequest)
            codeerr = objFEResponse.RError.percode.ToString
            msgerr = objFEResponse.RError.perrmsg
            If objFEResponse.FecResp Is Nothing Then
                desc_rechazo = objFEResponse.RError.perrmsg
                ObtieneCAETEST = False
            Else
                ii = objFEResponse.FecResp.cantidadreg
                reproceso = objFEResponse.FecResp.reproceso
                For d = 0 To (ii - 1)
                    'If objFEResponse.FedResp(d) Is not Nothing Then
                    cbte_estado = objFEResponse.FedResp(d).resultado
                    vencimiento_cae = IIf(objFEResponse.FedResp(d).fecha_vto = "NULL", "", objFEResponse.FedResp(d).fecha_vto)
                    cbte_cae = IIf(objFEResponse.FedResp(d).cae = "NULL", "", objFEResponse.FedResp(d).cae)
                    If objFEResponse.FecResp.reproceso = "S" Then
                        cbt_desde = objFEResponse.FedResp(d).cbt_desde.ToString
                        cbt_hasta = objFEResponse.FedResp(d).cbt_hasta.ToString
                    End If
                    motivo_rechazo = IIf(objFEResponse.FedResp(d).motivo = "NULL", "", objFEResponse.FedResp(d).motivo)
                    desc_rechazo = objFEResponse.RError.perrmsg
                    ObtieneCAETEST = True
                    'Else
                    'cbte_estado = objFEResponse.FecResp.resultado
                    'desc_rechazo = "FEResponse.FecResp.motivo: " + objFEResponse.FecResp.motivo + vbCrLf + _
                    '"FEResponse.FecResp.reproceso: " + objFEResponse.FecResp.reproceso + vbCrLf + _
                    '"FEResponse.FecResp.resultado: " + objFEResponse.FecResp.resultado
                    'For d = 0 To (indicemax)
                    '   desc_rechazo = "FEResponse.FedResp(" + d.ToString + ").cae: " + objFEResponse.FedResp(d).cae.ToString + vbCrLf + _
                    '   "FEResponse.FedResp(" + d.ToString + ").resultado: " + objFEResponse.FedResp(d).resultado
                    'Next d
                    'desc_rechazo = "FEResponse.RError.percode: " + objFEResponse.RError.percode.ToString + vbCrLf + _
                    '"FEResponse.RError.perrmsg: " + objFEResponse.RError.perrmsg
                    'End If
                Next d
            End If
        Catch ex As Exception
            desc_rechazo = ex.Message
            ObtieneCAETEST = False
        End Try

        ' Obtengo los XML de request/response y los escribo en el disco
        'Dim writer1 As New XmlSerializer(GetType(wsw.FERequest))
        'Dim file1 As New StreamWriter("C:\wsfe_FERequest.xml")
        'writer1.Serialize(file1, objFERequest)
        'file1.Close()
        'Dim writer2 As New XmlSerializer(GetType(wsw.FEResponse))
        'Dim file2 As New StreamWriter("C:\wsfe_FEResponse.xml")
        'writer2.Serialize(file2, objFEResponse)
        'file2.Close()
    End Function
    Public Function ObtieneCAETEST2(ByVal cuit As String, _
        ByVal strId As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal strcantidadreg As String, _
        ByVal presta_serv As String, _
        ByVal tipo_doc As String, _
        ByRef nro_doc As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByRef cbt_desde As String, _
        ByRef cbt_hasta As String, _
        ByRef imp_total As String, _
        ByVal imp_tot_conc As String, _
        ByVal imp_neto As String, _
        ByVal impto_liq As String, _
        ByVal impto_liq_rni As String, _
        ByVal imp_op_ex As String, _
        ByVal fecha_cbte As String, _
        ByVal fecha_serv_desde As String, _
        ByVal fecha_serv_hasta As String, _
        ByVal fecha_venc_pago As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, _
        ByRef desc_rechazo As String, _
        ByRef codeerr As String, _
        ByRef msgerr As String, _
        ByRef reproceso As String) As Boolean

        Dim objWSFE As New wsw.Service
        Dim objFEAuthRequest As New wsw.FEAuthRequest
        Dim cantidadreg As Integer = 1
        Dim indicemax As Integer = 0
        Dim d As Integer = 0
        Dim ii As Integer

        Dim objFERequest As New wsw.FERequest
        Dim objFECabeceraRequest As New wsw.FECabeceraRequest
        Dim ArrayOfFEDetalleRequest(indicemax) As wsw.FEDetalleRequest
        Dim objFEResponse As New wsw.FEResponse
        Dim ArrayOfFEDetalleResponse(indicemax) As wsw.FEDetalleResponse
        objFEAuthRequest.cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFECabeceraRequest.id = strId
        objFECabeceraRequest.cantidadreg = Val(strcantidadreg)
        objFECabeceraRequest.presta_serv = presta_serv
        objFERequest.Fecr = objFECabeceraRequest

        'Obtengo los datos del DataGridView DGV_FEDetalleRequest
        For d = 0 To (indicemax)
            Dim objFEDetalleRequest As New wsw.FEDetalleRequest
            With objFEDetalleRequest
                .tipo_doc = Val(tipo_doc)
                .nro_doc = Val(nro_doc)
                .tipo_cbte = Val(tipo_cbte)
                .punto_vta = Val(punto_vta)
                .cbt_desde = Val(cbt_desde)
                .cbt_hasta = Val(cbt_hasta)
                .imp_total = Val(imp_total)
                .imp_tot_conc = Val(imp_tot_conc)
                .imp_neto = Val(imp_neto)
                .impto_liq = Val(impto_liq)
                .impto_liq_rni = Val(impto_liq_rni)
                .imp_op_ex = Val(imp_op_ex)
                .fecha_cbte = fecha_cbte
                If presta_serv > "1" Then
                    .fecha_serv_desde = fecha_serv_desde
                    .fecha_serv_hasta = fecha_serv_hasta
                    .fecha_venc_pago = fecha_venc_pago
                End If
            End With
            ArrayOfFEDetalleRequest(d) = objFEDetalleRequest
        Next d
        objFERequest.Fedr = ArrayOfFEDetalleRequest

        ' Invoco al método FEAutRequest
        Try
            objFEResponse = objWSFE.FEAutRequest(objFEAuthRequest, objFERequest)
            codeerr = objFEResponse.RError.percode.ToString
            msgerr = objFEResponse.RError.perrmsg
            If objFEResponse.FecResp Is Nothing Then
                desc_rechazo = objFEResponse.RError.perrmsg
                ObtieneCAETEST2 = False
            Else
                ii = objFEResponse.FecResp.cantidadreg
                reproceso = objFEResponse.FecResp.reproceso
                For d = 0 To (ii - 1)
                    'If objFEResponse.FedResp(d) Is not Nothing Then
                    nro_doc = objFEResponse.FedResp(d).nro_doc.ToString
                    imp_total = Replace(objFEResponse.FedResp(d).imp_total.ToString, ",", ".")
                    cbte_estado = objFEResponse.FedResp(d).resultado
                    vencimiento_cae = IIf(objFEResponse.FedResp(d).fecha_vto = "NULL", "", objFEResponse.FedResp(d).fecha_vto)
                    cbte_cae = IIf(objFEResponse.FedResp(d).cae = "NULL", "", objFEResponse.FedResp(d).cae)
                    If objFEResponse.FecResp.reproceso = "S" Then
                        cbt_desde = objFEResponse.FedResp(d).cbt_desde.ToString
                        cbt_hasta = objFEResponse.FedResp(d).cbt_hasta.ToString
                    End If
                    motivo_rechazo = IIf(objFEResponse.FedResp(d).motivo = "NULL", "", objFEResponse.FedResp(d).motivo)
                    desc_rechazo = objFEResponse.RError.perrmsg
                    ObtieneCAETEST2 = True
                    'Else
                    'cbte_estado = objFEResponse.FecResp.resultado
                    'desc_rechazo = "FEResponse.FecResp.motivo: " + objFEResponse.FecResp.motivo + vbCrLf + _
                    '"FEResponse.FecResp.reproceso: " + objFEResponse.FecResp.reproceso + vbCrLf + _
                    '"FEResponse.FecResp.resultado: " + objFEResponse.FecResp.resultado
                    'For d = 0 To (indicemax)
                    '   desc_rechazo = "FEResponse.FedResp(" + d.ToString + ").cae: " + objFEResponse.FedResp(d).cae.ToString + vbCrLf + _
                    '   "FEResponse.FedResp(" + d.ToString + ").resultado: " + objFEResponse.FedResp(d).resultado
                    'Next d
                    'desc_rechazo = "FEResponse.RError.percode: " + objFEResponse.RError.percode.ToString + vbCrLf + _
                    '"FEResponse.RError.perrmsg: " + objFEResponse.RError.perrmsg
                    'End If
                Next d
            End If
        Catch ex As Exception
            desc_rechazo = ex.Message
            ObtieneCAETEST2 = False
        End Try

        ' Obtengo los XML de request/response y los escribo en el disco
        'Dim writer1 As New XmlSerializer(GetType(wsw.FERequest))
        'Dim file1 As New StreamWriter("C:\wsfe_FERequest.xml")
        'writer1.Serialize(file1, objFERequest)
        'file1.Close()
        'Dim writer2 As New XmlSerializer(GetType(wsw.FEResponse))
        'Dim file2 As New StreamWriter("C:\wsfe_FEResponse.xml")
        'writer2.Serialize(file2, objFEResponse)
        'file2.Close()
    End Function
    Public Function ConsultaCAETESTv1(ByVal cuit As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByVal cbt_desde As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String) As Boolean

        Dim objFEAuthRequest As New wsfev1t.FEAuthRequest
        Dim objFERequest As New wsfev1t.FECompConsultaReq
        Dim objFEResponse As New wsfev1t.FECompConsultaResponse
        Dim objWSFE As New wsfev1t.Service

        objFEAuthRequest.Cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFERequest.CbteTipo = Val(tipo_cbte)
        objFERequest.PtoVta = Val(punto_vta)
        objFERequest.CbteNro = Val(cbt_desde)

        objFEResponse = objWSFE.FECompConsultar(objFEAuthRequest, objFERequest)

        If Not objFEResponse.Errors Is Nothing Then
            ConsultaCAETESTv1 = False
        Else
            cbte_estado = objFEResponse.ResultGet.Resultado
            vencimiento_cae = IIf(objFEResponse.ResultGet.FchVto = "NULL", "", objFEResponse.ResultGet.FchVto)
            cbte_cae = IIf(objFEResponse.ResultGet.CodAutorizacion = "NULL", "", objFEResponse.ResultGet.CodAutorizacion)
            ConsultaCAETESTv1 = True
        End If

    End Function
    Public Function Consulta2CAETESTv1(ByVal cuit As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByVal cbt_desde As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String, _
        ByRef Importe As String, _
        ByRef CUITComprador As String) As Boolean

        Dim objFEAuthRequest As New wsfev1t.FEAuthRequest
        Dim objFERequest As New wsfev1t.FECompConsultaReq
        Dim objFEResponse As New wsfev1t.FECompConsultaResponse
        Dim objWSFE As New wsfev1t.Service

        objFEAuthRequest.Cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFERequest.CbteTipo = Val(tipo_cbte)
        objFERequest.PtoVta = Val(punto_vta)
        objFERequest.CbteNro = Val(cbt_desde)

        objFEResponse = objWSFE.FECompConsultar(objFEAuthRequest, objFERequest)

        If Not objFEResponse.Errors Is Nothing Then
            Consulta2CAETESTv1 = False
        Else
            cbte_estado = objFEResponse.ResultGet.Resultado
            vencimiento_cae = IIf(objFEResponse.ResultGet.FchVto = "NULL", "", objFEResponse.ResultGet.FchVto)
            cbte_cae = IIf(objFEResponse.ResultGet.CodAutorizacion = "NULL", "", objFEResponse.ResultGet.CodAutorizacion)
            Importe = IIf(objFEResponse.ResultGet.ImpTotal = "NULL", "", CStr(objFEResponse.ResultGet.ImpTotal))
            Importe = Replace(Importe, ",", ".")
            CUITComprador = IIf(objFEResponse.ResultGet.DocNro = "NULL", "", CStr(objFEResponse.ResultGet.DocNro))
            Consulta2CAETESTv1 = True
        End If

    End Function
    Public Function ConsultaCAEPRODv1(ByVal cuit As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByVal cbt_desde As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String) As Boolean

        Dim objFEAuthRequest As New wsfev1p.FEAuthRequest
        Dim objFERequest As New wsfev1p.FECompConsultaReq
        Dim objFEResponse As New wsfev1p.FECompConsultaResponse
        Dim objWSFE As New wsfev1p.Service

        objFEAuthRequest.Cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFERequest.CbteTipo = Val(tipo_cbte)
        objFERequest.PtoVta = Val(punto_vta)
        objFERequest.CbteNro = Val(cbt_desde)

        objFEResponse = objWSFE.FECompConsultar(objFEAuthRequest, objFERequest)

        If Not objFEResponse.Errors Is Nothing Then
            ConsultaCAEPRODv1 = False
        Else
            cbte_estado = objFEResponse.ResultGet.Resultado
            'MsgBox(objFEResponse.ResultGet.ImpTotal)
            'MsgBox(objFEResponse.ResultGet.DocNro)
            vencimiento_cae = IIf(objFEResponse.ResultGet.FchVto = "NULL", "", objFEResponse.ResultGet.FchVto)
            cbte_cae = IIf(objFEResponse.ResultGet.CodAutorizacion = "NULL", "", objFEResponse.ResultGet.CodAutorizacion)
            ConsultaCAEPRODv1 = True
        End If

    End Function
    Public Function Consulta2CAEPRODv1(ByVal cuit As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByVal cbt_desde As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String, _
        ByRef Importe As String, _
        ByRef CUITComprador As String) As Boolean

        Dim objFEAuthRequest As New wsfev1p.FEAuthRequest
        Dim objFERequest As New wsfev1p.FECompConsultaReq
        Dim objFEResponse As New wsfev1p.FECompConsultaResponse
        Dim objWSFE As New wsfev1p.Service

        objFEAuthRequest.Cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFERequest.CbteTipo = Val(tipo_cbte)
        objFERequest.PtoVta = Val(punto_vta)
        objFERequest.CbteNro = Val(cbt_desde)

        objFEResponse = objWSFE.FECompConsultar(objFEAuthRequest, objFERequest)

        If Not objFEResponse.Errors Is Nothing Then
            Consulta2CAEPRODv1 = False
        Else
            cbte_estado = objFEResponse.ResultGet.Resultado
            '           MsgBox(objFEResponse.ResultGet.ImpTotal)
            '           MsgBox(objFEResponse.ResultGet.DocNro)
            vencimiento_cae = IIf(objFEResponse.ResultGet.FchVto = "NULL", "", objFEResponse.ResultGet.FchVto)
            cbte_cae = IIf(objFEResponse.ResultGet.CodAutorizacion = "NULL", "", objFEResponse.ResultGet.CodAutorizacion)
            Importe = IIf(objFEResponse.ResultGet.ImpTotal = "NULL", "", CStr(objFEResponse.ResultGet.ImpTotal))
            Importe = Replace(Importe, ",", ".")
            CUITComprador = IIf(objFEResponse.ResultGet.DocNro = "NULL", "", CStr(objFEResponse.ResultGet.DocNro))
            Consulta2CAEPRODv1 = True
        End If

    End Function
    Public Function ObtieneCAEPRODv1PILOTE(ByVal cuit As String, _
        ByVal TableName As String, _
        ByVal TableName2 As String, _
        ByVal sServer As String, _
        ByVal sDatabase As String, _
        ByVal sUser As String, _
        ByVal sPassword As String, _
        ByVal sGPUser As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByRef strError As String) As Boolean

        Dim conexionBD As String
        Dim mycon As SqlConnection
        Dim comUserSelect As SqlCommand
        Dim SQL_STR As String

        Dim objWSFE As New wsfev1p.Service
        Dim objFEAuthRequest As New wsfev1p.FEAuthRequest
        Dim cantidadreg As Integer = 0
        Dim indicemax As Integer = 0
        Dim d As Integer = 0
        Dim indice As Integer = 0
        Dim senial As Integer = 0
        Dim t As Integer = 1
        Dim iv As Integer = 0
        Dim derr As Integer = 0
        Dim ii, tt, ee As Integer
        Dim tribxml, opcionalxml As String
        Dim tipotrib, tipoiva, opcionalesid As Integer
        Dim objFERequest As New wsfev1p.FECAERequest
        Dim objFECabeceraRequest As New wsfev1p.FECAECabRequest
        Dim objFEResponse As New wsfev1p.FECAEResponse
        Dim ArrayOfFEDetalleResponse(0) As wsfev1p.FECAEDetResponse
        'Dim objFEDetalleResponse(indicemax) As wsfev1p.FECAEDetResponse
        Dim TributoId(10) As Integer
        Dim TributoDesc(10) As String
        Dim TributoBaseImp(10), TributoAlic(10), TributoImporte(10) As Double
        Dim OpcionalID(1), OpcionalValor(1) As String
        Dim TempValue As String
        Dim desc_rechazo, reproceso As String
        Dim cbte_estado, vencimiento_cae, cbte_cae, cbte_nro, cbte_pdv, cbte_tipo, cbte_comentario As String

        tipotrib = 0
        tipoiva = 0
        objFEAuthRequest.Cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        '   COL1 =  NO GRAVADO              1
        '   COL2 =  GRAVADO                 2
        '   COL3 =  IVA                     2
        '   COL4 =  CANT TASAS IVA          2
        '   COL5 =  IMPUESTO RNI            3
        '   COL6 =  EXENTO                  4
        '   COL7 =  PERC NACIONALES         5
        '   COL8 =  PERC IIBB               6
        '   COL9 =  PERC MUNICIPALES        7
        '   COL10 = IMP INTERNOS            8

        SQL_STR = "SELECT COUNT(DOCNUMBR) REGISTROS FROM " & Trim(TableName) & " "

        conexionBD = "Data Source=" & sServer & ";" & _
        "Initial Catalog=" & sDatabase & ";" & _
        "User ID=" & sUser & ";" & _
        "Password=" & sPassword

        mycon = New SqlConnection(conexionBD)
        comUserSelect = New SqlCommand(SQL_STR, mycon)
        comUserSelect.CommandTimeout() = 0
        mycon.Open()

        Dim myreader2 As SqlDataReader
        myreader2 = comUserSelect.ExecuteReader
        'MsgBox("reader")
        While (myreader2.Read = True)
            indicemax = myreader2(0)
        End While

        Dim ArrayOfFEDetalleRequest(indicemax - 1) As wsfev1p.FECAEDetRequest

        myreader2.Close()
        comUserSelect = Nothing

        SQL_STR = "SELECT (SELECT SUBSTRING(TAXREGTN, 1, 11) FROM DYNAMICS..SY01500 WHERE INTERID = DB_NAME()) CUIT, " & _
            "TRX.RMDTYPAL, TRX.DOCNUMBR, CONVERT(CHAR(8), SOP.DOCDATE, 112) DOCDATE, TRX.CUSTNMBR, TRX.CUSTNAME, " & _
            "SUBSTRING(SOP.TXRGNNUM, 24, 2) TIPODOC, " & _
            "SUBSTRING(SOP.TXRGNNUM, 1, 11) NRODOC, " & _
            "TRX.FRG_RESP_TYPE, FRG_LETRA1, FRG_PDV, FRG_NRO, FRG_COD,  " & _
            "ISNULL(COL1, 0) COL1, ISNULL(COL2, 0) COL2, ISNULL(COL3, 0) COL3, ISNULL(COL4, 0) COL4, ISNULL(COL5, 0) COL5, ISNULL(COL6, 0) COL6, ISNULL(COL7, 0) COL7,  " & _
            "ISNULL(COL8, 0) COl8, ISNULL(COL9, 0) COL9, ISNULL(COL10, 0) COL10, TRX.DOCAMNT, TRX.VOIDSTTS,   " & _
            "dbo.ACA_TRIBUTOS(SOP.SOPTYPE, SOP.SOPNUMBE) TRIBUTOS, dbo.ACA_IVAXML(SOP.SOPTYPE, SOP.SOPNUMBE) IVAXML, " & _
            "'' XMLOPCIONAL, MC.CURR_CODE MONEDA, CASE WHEN SOP.XCHGRATE = 0 THEN 1 ELSE SOP.XCHGRATE END TCAMBIO " & _
            "FROM " & Trim(TableName2) & " TRX INNER JOIN " & Trim(TableName) & " TRX2  " & _
            "ON TRX.RMDTYPAL = TRX2.RMDTYPAL AND TRX.DOCNUMBR = TRX2.DOCNUMBR  " & _
            "INNER JOIN SOP10100 SOP ON TRX.RMDTYPAL = CASE WHEN SOP.SOPTYPE = 3 then 1 ELSE 8 END AND TRX.DOCNUMBR = SOP.SOPNUMBE " & _
            "INNER JOIN AWLI40380 AW ON SOP.SOPTYPE = AW.SOPTYPE AND SOP.DOCID = AW.DOCID " & _
            "INNER JOIN DYNAMICS..AWLI_MC40200 MC ON SOP.CURNCYID = MC.CURNCYID " & _
            " LEFT OUTER JOIN ( " & _
            "SELECT A.RMDTYPAL, A.DOCNUMBR, SUM(ISNULL(COL1, 0)) COL1,  SUM(ISNULL(COL2, 0)) COL2,  SUM(ISNULL(COL3, 0)) COL3,  SUM(ISNULL(COL4, 0)) COL4,  SUM(ISNULL(COL5, 0)) COL5,   " & _
            " SUM(ISNULL(COL6, 0)) COL6,  SUM(ISNULL(COL7, 0)) COL7,  SUM(ISNULL(COL8, 0)) COL8, SUM(ISNULL(COL9, 0)) COL9, SUM(ISNULL(COL10, 0)) COL10 FROM   " & _
            " FRG_RM20105 A LEFT OUTER JOIN  " & _
            "(SELECT RMDTYPAL, DOCNUMBR, FRG_Impuestos, TX.TAXDTLID,   " & _
            "CASE FRG_Impuestos WHEN 1 THEN TAXDTSLS ELSE 0 END COL1,	" & _
            "CASE FRG_Impuestos WHEN 2 THEN TAXDTSLS ELSE 0 END COL2,	" & _
            "CASE FRG_Impuestos WHEN 2 THEN TAXAMNT ELSE 0 END COL3,	" & _
            "CASE FRG_Impuestos WHEN 2 THEN 1 ELSE 0 END COL4,			" & _
            "CASE FRG_Impuestos WHEN 3 THEN TAXAMNT ELSE 0 END COL5,	" & _
            "CASE FRG_Impuestos WHEN 4 THEN TAXDTSLS ELSE 0 END COL6,   " & _
            "CASE FRG_Impuestos WHEN 5 THEN TAXAMNT ELSE 0 END COL7,    " & _
            "CASE FRG_Impuestos WHEN 6 THEN TAXAMNT ELSE 0 END COL8,    " & _
            "CASE FRG_Impuestos WHEN 7 THEN TAXAMNT ELSE 0 END COL9,    " & _
            "CASE FRG_Impuestos WHEN 8 THEN TAXAMNT ELSE 0 END COL10    " & _
            "FROM ( " & _
            "select CASE WHEN SOPTYPE = 3 then 1 ELSE 8 END RMDTYPAL, SOPNUMBE DOCNUMBR, TAXDTLID, TAXDTSLS, (STAXAMNT+FRTTXAMT+MSCTXAMT) TAXAMNT from SOP10105 WHERE LNITMSEQ = 0 " & _
            ") TX INNER JOIN FRG_TX02001 TX1 ON TX.TAXDTLID = TX1.TAXDTLID) IMP " & _
            " ON A.RMDTYPAL = IMP.RMDTYPAL AND A.DOCNUMBR = IMP.DOCNUMBR " & _
            " WHERE A.USERID = '" & Trim(sGPUser) & "' " & _
            "GROUP BY A.RMDTYPAL, A.DOCNUMBR) TOTIMP ON TRX.RMDTYPAL = TOTIMP.RMDTYPAL AND TRX.DOCNUMBR = TOTIMP.DOCNUMBR " & _
            "ORDER BY TRX.FRG_PDV, TRX.FRG_NRO "

        conexionBD = "Data Source=" & sServer & ";" & _
                "Initial Catalog=" & sDatabase & ";" & _
                "User ID=" & sUser & ";" & _
                "Password=" & sPassword

        'mycon = New SqlConnection(conexionBD)
        comUserSelect = New SqlCommand(SQL_STR, mycon)
        comUserSelect.CommandTimeout() = 0
        'mycon.Open()

        Dim myreader As SqlDataReader
        myreader = comUserSelect.ExecuteReader
        'MsgBox("reader")
        While (myreader.Read = True)
            If senial = 0 Then
                objFECabeceraRequest.CbteTipo = Val(myreader(12))
                objFECabeceraRequest.PtoVta = Val(myreader(10))
                senial = 1
            End If

            Dim reader As StringReader = New StringReader(myreader(25))
            Dim testxml As XmlTextReader = New XmlTextReader(reader)
            Dim readeriva As StringReader = New StringReader(myreader(26))
            Dim testxmliva As XmlTextReader = New XmlTextReader(readeriva)
            Dim readeropcioanl As StringReader = New StringReader(myreader(27))
            Dim testxmlopcional As XmlTextReader = New XmlTextReader(readeropcioanl)


            Dim objFEDetalleRequest As New wsfev1p.FECAEDetRequest
            Dim ArrayOfTributoTax(0) As wsfev1p.Tributo
            Dim ArrayOfAlicIva(0) As wsfev1p.AlicIva
            Dim ArrayOfAdicionales(0) As wsfev1p.Opcional

            With objFEDetalleRequest
                .Concepto = 1       ' Productos
                .MonId = myreader(28)
                .MonCotiz = Val(myreader(29))
                .DocTipo = Val(myreader(6))
                .DocNro = Val(myreader(7))
                .CbteDesde = Val(myreader(11))
                .CbteHasta = Val(myreader(11))
                .ImpTotal = Val(myreader(23))
                .ImpTotConc = Val(myreader(13))
                .ImpNeto = Val(myreader(14))
                .ImpIVA = Val(myreader(15))
                .ImpTrib = Val(myreader(17) + myreader(19) + myreader(20) + myreader(21) + myreader(22))
                '. = Val(impto_liq_rni)
                .ImpOpEx = Val(myreader(18))
                .CbteFch = myreader(3)
                If myreader(25) <> "" Then
                    tribxml = ""
                    t = 0
                    Do While (testxml.Read())
                        Select Case testxml.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                tribxml = tribxml & "<" & testxml.Name & ">"
                                Select Case testxml.Name
                                    Case "Id"
                                        tipotrib = 1
                                    Case "Desc"
                                        tipotrib = 2
                                    Case "BaseImp"
                                        tipotrib = 3
                                    Case "Alic"
                                        tipotrib = 4
                                    Case "Importe"
                                        tipotrib = 5
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                tribxml = tribxml & testxml.Value
                                Select Case tipotrib
                                    Case 1
                                        TempValue = testxml.Value
                                        TributoId(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxml.Value
                                        TributoDesc(t) = TempValue
                                    Case 3
                                        TempValue = testxml.Value
                                        TributoBaseImp(t) = Val(TempValue)
                                    Case 4
                                        TempValue = testxml.Value
                                        TributoAlic(t) = Val(TempValue)
                                    Case 5
                                        TempValue = testxml.Value
                                        TributoImporte(t) = Val(TempValue)
                                End Select
                            Case XmlNodeType.EndElement
                                tribxml = tribxml & "</" & testxml.Name & ">"
                                If testxml.Name = "Tributo" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    For tt = 0 To t - 1
                        Dim TributoTax As New wsfev1p.Tributo
                        With TributoTax
                            .Id = TributoId(tt)
                            .Desc = TributoDesc(tt)
                            .BaseImp = TributoBaseImp(tt)
                            .Alic = TributoAlic(tt)
                            .Importe = TributoImporte(tt)
                        End With
                        If tt > 0 Then
                            ReDim Preserve ArrayOfTributoTax(tt - 1)
                        End If
                        'ArrayOfTributoTax(tt - 1) = TributoTax
                        ArrayOfTributoTax(tt) = TributoTax
                    Next tt
                    objFEDetalleRequest.Tributos = ArrayOfTributoTax
                    For tt = 1 To t - 1
                        TributoId(tt) = 0
                        TributoDesc(tt) = ""
                        TributoBaseImp(tt) = 0
                        TributoAlic(tt) = 0
                        TributoImporte(tt) = 0
                    Next
                    t = 1
                    tribxml = ""
                End If
                If myreader(26) <> "" Then
                    tribxml = ""
                    t = 0
                    Do While (testxmliva.Read())
                        Select Case testxmliva.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                tribxml = tribxml & "<" & testxmliva.Name & ">"
                                Select Case testxmliva.Name
                                    Case "Id"
                                        tipotrib = 1
                                    Case "BaseImp"
                                        tipotrib = 2
                                    Case "Alic"
                                        tipotrib = 3
                                    Case "Importe"
                                        tipotrib = 4
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                tribxml = tribxml & testxmliva.Value
                                Select Case tipotrib
                                    Case 1
                                        TempValue = testxmliva.Value
                                        TributoId(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxmliva.Value
                                        TributoBaseImp(t) = Val(TempValue)
                                    Case 3
                                        TempValue = testxmliva.Value
                                        TributoAlic(t) = Val(TempValue)
                                    Case 4
                                        TempValue = testxmliva.Value
                                        TributoImporte(t) = Val(TempValue)
                                End Select
                            Case XmlNodeType.EndElement
                                tribxml = tribxml & "</" & testxmliva.Name & ">"
                                If testxmliva.Name = "AlicIva" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    For tt = 0 To t - 1
                        Dim AlicIva As New wsfev1p.AlicIva
                        With AlicIva
                            .Id = TributoId(tt)
                            .BaseImp = TributoBaseImp(tt)
                            .Importe = TributoImporte(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfAlicIva(tt - 1)
                        End If
                        ArrayOfAlicIva(tt) = AlicIva
                    Next tt
                    objFEDetalleRequest.Iva = ArrayOfAlicIva
                End If
                opcionalxml = ""
                t = 0
                If myreader(27) <> "" Then
                    Do While (testxmlopcional.Read())
                        Select Case testxmlopcional.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                opcionalxml = opcionalxml & "<" & testxmlopcional.Name & ">"
                                Select Case testxmlopcional.Name
                                    Case "Id"
                                        opcionalesid = 1
                                    Case "Valor"
                                        opcionalesid = 2
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                opcionalxml = opcionalxml & testxmlopcional.Value
                                Select Case opcionalesid
                                    Case 1
                                        TempValue = testxmlopcional.Value
                                        OpcionalID(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxmlopcional.Value
                                        OpcionalValor(t) = TempValue
                                End Select
                            Case XmlNodeType.EndElement
                                opcionalxml = opcionalxml & "</" & testxmlopcional.Name & ">"
                                If testxmlopcional.Name = "Opcional" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    For tt = 0 To t - 1
                        Dim Opcional As New wsfev1p.Opcional
                        With Opcional
                            .Id = OpcionalID(tt)
                            .Valor = OpcionalValor(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfAdicionales(tt - 1)
                        End If
                        ArrayOfAdicionales(tt) = Opcional
                    Next tt
                    objFEDetalleRequest.Opcionales = ArrayOfAdicionales
                End If
                'If presta_serv = "1" Then
                '.FchServDesde = fecha_serv_desde
                '.FchServHasta = fecha_serv_hasta
                '.FchVtoPago = fecha_venc_pago
                'End If
            End With
            ArrayOfFEDetalleRequest(indice) = objFEDetalleRequest
            indice = indice + 1

            reader = Nothing
            testxml = Nothing
            readeriva = Nothing
            testxmliva = Nothing
            readeropcioanl = Nothing
            testxmlopcional = Nothing
        End While
        objFERequest.FeDetReq = ArrayOfFEDetalleRequest

        objFECabeceraRequest.CantReg = indice
        objFERequest.FeCabReq = objFECabeceraRequest

        myreader.Close()
        mycon.Close()
        comUserSelect = Nothing

        ' Invoco al método FEAutRequest
        Try
            objFEResponse = objWSFE.FECAESolicitar(objFEAuthRequest, objFERequest)

            If objFEResponse.Errors IsNot Nothing Then
                For ii = 0 To objFEResponse.Errors.Length - 1
                    If strError = "" Then
                        strError = objFEResponse.Errors(ii).Msg
                    Else
                        strError = strError & vbCrLf & objFEResponse.Errors(ii).Msg
                    End If
                Next
                ObtieneCAEPRODv1PILOTE = False
                Exit Function
            End If
            If objFEResponse IsNot Nothing Then
                ii = objFEResponse.FeCabResp.CantReg
                mycon = New SqlConnection(conexionBD)
                mycon.Open()

                For d = 0 To (ii - 1)
                    cbte_cae = IIf(objFEResponse.FeDetResp(d).CAE = "NULL", "", objFEResponse.FeDetResp(d).CAE)
                    vencimiento_cae = IIf(objFEResponse.FeDetResp(d).CAEFchVto = "NULL", "", objFEResponse.FeDetResp(d).CAEFchVto)
                    cbte_nro = objFEResponse.FeDetResp(d).CbteDesde.ToString
                    cbte_pdv = objFEResponse.FeCabResp.PtoVta.ToString
                    cbte_tipo = objFEResponse.FeCabResp.CbteTipo.ToString
                    cbte_estado = IIf(objFEResponse.FeDetResp(d).Resultado = "NULL", "", objFEResponse.FeDetResp(d).Resultado)
                    If objFEResponse.FeDetResp(d).Observaciones IsNot Nothing Then
                        cbte_comentario = objFEResponse.FeDetResp(d).Observaciones(0).Code
                    Else
                        cbte_comentario = ""
                    End If
                    SQL_STR = "UPDATE FRG_RM20101 SET FRG_CAE = '" & cbte_cae & "', FRG_CAE_DUE = '" & vencimiento_cae & "', " & _
                        "FRG_ESTADO = '" & cbte_estado & "', FRG_MOTIVO = '" & cbte_comentario & "' " & _
                        "WHERE CONVERT(INT, FRG_PDV) = " & cbte_pdv & " AND CONVERT(INT, FRG_COD) = " & cbte_tipo & " " & _
                        "AND CONVERT(INT, FRG_NRO) = " & cbte_nro & " "

                    Dim cmd1 As SqlCommand = New SqlCommand(SQL_STR, mycon)

                    'cmd1.Connection.Open()

                    cmd1.ExecuteNonQuery()

                    cmd1 = Nothing
                Next
                ObtieneCAEPRODv1PILOTE = True
            End If
        Catch ex As Exception
            strError = ex.Message & vbCrLf & "Vuelva a intentarlo."
            ObtieneCAEPRODv1PILOTE = False
        End Try

        ObtieneCAEPRODv1PILOTE = True
    End Function
    Public Function ObtieneCAETESTv1PILOTE(ByVal cuit As String, _
        ByVal TableName As String, _
        ByVal TableName2 As String, _
        ByVal sServer As String, _
        ByVal sDatabase As String, _
        ByVal sUser As String, _
        ByVal sPassword As String, _
        ByVal sGPUser As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByRef strError As String) As Boolean

        Dim conexionBD As String
        Dim mycon As SqlConnection
        Dim comUserSelect As SqlCommand
        Dim SQL_STR As String

        Dim objWSFE As New wsfev1t.Service
        Dim objFEAuthRequest As New wsfev1t.FEAuthRequest
        Dim cantidadreg As Integer = 0
        Dim indicemax As Integer = 0
        Dim d As Integer = 0
        Dim indice As Integer = 0
        Dim senial As Integer = 0
        Dim t As Integer = 1
        Dim iv As Integer = 0
        Dim derr As Integer = 0
        Dim ii, tt, ee As Integer
        Dim tribxml, opcionalxml As String
        Dim tipotrib, tipoiva, opcionalesid As Integer
        Dim objFERequest As New wsfev1t.FECAERequest
        Dim objFECabeceraRequest As New wsfev1t.FECAECabRequest
        Dim objFEResponse As New wsfev1t.FECAEResponse
        Dim ArrayOfFEDetalleResponse(0) As wsfev1t.FECAEDetResponse
        'Dim objFEDetalleResponse(indicemax) As wsfev1t.FECAEDetResponse
        Dim TributoId(10) As Integer
        Dim TributoDesc(10) As String
        Dim TributoBaseImp(10), TributoAlic(10), TributoImporte(10) As Double
        Dim OpcionalID(1), OpcionalValor(1) As String
        Dim TempValue As String
        Dim desc_rechazo, reproceso As String
        Dim cbte_estado, vencimiento_cae, cbte_cae, cbte_nro, cbte_pdv, cbte_tipo, cbte_comentario As String

        tipotrib = 0
        tipoiva = 0
        objFEAuthRequest.Cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        '   COL1 =  NO GRAVADO              1
        '   COL2 =  GRAVADO                 2
        '   COL3 =  IVA                     2
        '   COL4 =  CANT TASAS IVA          2
        '   COL5 =  IMPUESTO RNI            3
        '   COL6 =  EXENTO                  4
        '   COL7 =  PERC NACIONALES         5
        '   COL8 =  PERC IIBB               6
        '   COL9 =  PERC MUNICIPALES        7
        '   COL10 = IMP INTERNOS            8

        SQL_STR = "SELECT COUNT(DOCNUMBR) REGISTROS FROM " & Trim(TableName) & " "

        conexionBD = "Data Source=" & sServer & ";" & _
        "Initial Catalog=" & sDatabase & ";" & _
        "User ID=" & sUser & ";" & _
        "Password=" & sPassword

        mycon = New SqlConnection(conexionBD)
        comUserSelect = New SqlCommand(SQL_STR, mycon)
        comUserSelect.CommandTimeout() = 0
        mycon.Open()

        Dim myreader2 As SqlDataReader
        myreader2 = comUserSelect.ExecuteReader
        'MsgBox("reader")
        While (myreader2.Read = True)
            indicemax = myreader2(0)
        End While

        Dim ArrayOfFEDetalleRequest(indicemax - 1) As wsfev1t.FECAEDetRequest

        myreader2.Close()
        comUserSelect = Nothing

        SQL_STR = "SELECT (SELECT SUBSTRING(TAXREGTN, 1, 11) FROM DYNAMICS..SY01500 WHERE INTERID = DB_NAME()) CUIT, " & _
            "TRX.RMDTYPAL, TRX.DOCNUMBR, CONVERT(CHAR(8), SOP.DOCDATE, 112) DOCDATE, TRX.CUSTNMBR, TRX.CUSTNAME, " & _
            "SUBSTRING(SOP.TXRGNNUM, 24, 2) TIPODOC, " & _
            "SUBSTRING(SOP.TXRGNNUM, 1, 11) NRODOC, " & _
            "TRX.FRG_RESP_TYPE, FRG_LETRA1, FRG_PDV, FRG_NRO, FRG_COD,  " & _
            "ISNULL(COL1, 0) COL1, ISNULL(COL2, 0) COL2, ISNULL(COL3, 0) COL3, ISNULL(COL4, 0) COL4, ISNULL(COL5, 0) COL5, ISNULL(COL6, 0) COL6, ISNULL(COL7, 0) COL7,  " & _
            "ISNULL(COL8, 0) COl8, ISNULL(COL9, 0) COL9, ISNULL(COL10, 0) COL10, TRX.DOCAMNT, TRX.VOIDSTTS,   " & _
            "dbo.ACA_TRIBUTOS(SOP.SOPTYPE, SOP.SOPNUMBE) TRIBUTOS, dbo.ACA_IVAXML(SOP.SOPTYPE, SOP.SOPNUMBE) IVAXML, " & _
            "'' XMLOPCIONAL, MC.CURR_CODE MONEDA, CASE WHEN SOP.XCHGRATE = 0 THEN 1 ELSE SOP.XCHGRATE END TCAMBIO " & _
            "FROM " & Trim(TableName2) & " TRX INNER JOIN " & Trim(TableName) & " TRX2  " & _
            "ON TRX.RMDTYPAL = TRX2.RMDTYPAL AND TRX.DOCNUMBR = TRX2.DOCNUMBR  " & _
            "INNER JOIN SOP10100 SOP ON TRX.RMDTYPAL = CASE WHEN SOP.SOPTYPE = 3 then 1 ELSE 8 END AND TRX.DOCNUMBR = SOP.SOPNUMBE " & _
            "INNER JOIN AWLI40380 AW ON SOP.SOPTYPE = AW.SOPTYPE AND SOP.DOCID = AW.DOCID " & _
            "INNER JOIN DYNAMICS..AWLI_MC40200 MC ON SOP.CURNCYID = MC.CURNCYID " & _
            " LEFT OUTER JOIN ( " & _
            "SELECT A.RMDTYPAL, A.DOCNUMBR, SUM(ISNULL(COL1, 0)) COL1,  SUM(ISNULL(COL2, 0)) COL2,  SUM(ISNULL(COL3, 0)) COL3,  SUM(ISNULL(COL4, 0)) COL4,  SUM(ISNULL(COL5, 0)) COL5,   " & _
            " SUM(ISNULL(COL6, 0)) COL6,  SUM(ISNULL(COL7, 0)) COL7,  SUM(ISNULL(COL8, 0)) COL8, SUM(ISNULL(COL9, 0)) COL9, SUM(ISNULL(COL10, 0)) COL10 FROM   " & _
            " FRG_RM20105 A LEFT OUTER JOIN  " & _
            "(SELECT RMDTYPAL, DOCNUMBR, FRG_Impuestos, TX.TAXDTLID,   " & _
            "CASE FRG_Impuestos WHEN 1 THEN TAXDTSLS ELSE 0 END COL1,	" & _
            "CASE FRG_Impuestos WHEN 2 THEN TAXDTSLS ELSE 0 END COL2,	" & _
            "CASE FRG_Impuestos WHEN 2 THEN TAXAMNT ELSE 0 END COL3,	" & _
            "CASE FRG_Impuestos WHEN 2 THEN 1 ELSE 0 END COL4,			" & _
            "CASE FRG_Impuestos WHEN 3 THEN TAXAMNT ELSE 0 END COL5,	" & _
            "CASE FRG_Impuestos WHEN 4 THEN TAXDTSLS ELSE 0 END COL6,   " & _
            "CASE FRG_Impuestos WHEN 5 THEN TAXAMNT ELSE 0 END COL7,    " & _
            "CASE FRG_Impuestos WHEN 6 THEN TAXAMNT ELSE 0 END COL8,    " & _
            "CASE FRG_Impuestos WHEN 7 THEN TAXAMNT ELSE 0 END COL9,    " & _
            "CASE FRG_Impuestos WHEN 8 THEN TAXAMNT ELSE 0 END COL10    " & _
            "FROM ( " & _
            "select CASE WHEN SOPTYPE = 3 then 1 ELSE 8 END RMDTYPAL, SOPNUMBE DOCNUMBR, TAXDTLID, TAXDTSLS, (STAXAMNT+FRTTXAMT+MSCTXAMT) TAXAMNT from SOP10105 WHERE LNITMSEQ = 0 " & _
            ") TX INNER JOIN FRG_TX02001 TX1 ON TX.TAXDTLID = TX1.TAXDTLID) IMP " & _
            " ON A.RMDTYPAL = IMP.RMDTYPAL AND A.DOCNUMBR = IMP.DOCNUMBR " & _
            " WHERE A.USERID = '" & Trim(sGPUser) & "' " & _
            "GROUP BY A.RMDTYPAL, A.DOCNUMBR) TOTIMP ON TRX.RMDTYPAL = TOTIMP.RMDTYPAL AND TRX.DOCNUMBR = TOTIMP.DOCNUMBR " & _
            "ORDER BY TRX.FRG_PDV, TRX.FRG_NRO "

        conexionBD = "Data Source=" & sServer & ";" & _
                "Initial Catalog=" & sDatabase & ";" & _
                "User ID=" & sUser & ";" & _
                "Password=" & sPassword

        'mycon = New SqlConnection(conexionBD)
        comUserSelect = New SqlCommand(SQL_STR, mycon)
        comUserSelect.CommandTimeout() = 0
        'mycon.Open()

        Dim myreader As SqlDataReader
        myreader = comUserSelect.ExecuteReader
        'MsgBox("reader")
        While (myreader.Read = True)
            If senial = 0 Then
                objFECabeceraRequest.CbteTipo = Val(myreader(12))
                objFECabeceraRequest.PtoVta = Val(myreader(10))
                senial = 1
            End If

            Dim reader As StringReader = New StringReader(myreader(25))
            Dim testxml As XmlTextReader = New XmlTextReader(reader)
            Dim readeriva As StringReader = New StringReader(myreader(26))
            Dim testxmliva As XmlTextReader = New XmlTextReader(readeriva)
            Dim readeropcioanl As StringReader = New StringReader(myreader(27))
            Dim testxmlopcional As XmlTextReader = New XmlTextReader(readeropcioanl)


            Dim objFEDetalleRequest As New wsfev1t.FECAEDetRequest
            Dim ArrayOfTributoTax(0) As wsfev1t.Tributo
            Dim ArrayOfAlicIva(0) As wsfev1t.AlicIva
            Dim ArrayOfAdicionales(0) As wsfev1t.Opcional

            With objFEDetalleRequest
                .Concepto = 1       ' Productos
                .MonId = myreader(28)
                .MonCotiz = Val(myreader(29))
                .DocTipo = Val(myreader(6))
                .DocNro = Val(myreader(7))
                .CbteDesde = Val(myreader(11))
                .CbteHasta = Val(myreader(11))
                .ImpTotal = Val(myreader(23))
                .ImpTotConc = Val(myreader(13))
                .ImpNeto = Val(myreader(14))
                .ImpIVA = Val(myreader(15))
                .ImpTrib = Val(myreader(17) + myreader(19) + myreader(20) + myreader(21) + myreader(22))
                '. = Val(impto_liq_rni)
                .ImpOpEx = Val(myreader(18))
                .CbteFch = myreader(3)
                If myreader(25) <> "" Then
                    tribxml = ""
                    t = 0
                    Do While (testxml.Read())
                        Select Case testxml.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                tribxml = tribxml & "<" & testxml.Name & ">"
                                Select Case testxml.Name
                                    Case "Id"
                                        tipotrib = 1
                                    Case "Desc"
                                        tipotrib = 2
                                    Case "BaseImp"
                                        tipotrib = 3
                                    Case "Alic"
                                        tipotrib = 4
                                    Case "Importe"
                                        tipotrib = 5
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                tribxml = tribxml & testxml.Value
                                Select Case tipotrib
                                    Case 1
                                        TempValue = testxml.Value
                                        TributoId(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxml.Value
                                        TributoDesc(t) = TempValue
                                    Case 3
                                        TempValue = testxml.Value
                                        TributoBaseImp(t) = Val(TempValue)
                                    Case 4
                                        TempValue = testxml.Value
                                        TributoAlic(t) = Val(TempValue)
                                    Case 5
                                        TempValue = testxml.Value
                                        TributoImporte(t) = Val(TempValue)
                                End Select
                            Case XmlNodeType.EndElement
                                tribxml = tribxml & "</" & testxml.Name & ">"
                                If testxml.Name = "Tributo" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    For tt = 0 To t - 1
                        Dim TributoTax As New wsfev1t.Tributo
                        With TributoTax
                            .Id = TributoId(tt)
                            .Desc = TributoDesc(tt)
                            .BaseImp = TributoBaseImp(tt)
                            .Alic = TributoAlic(tt)
                            .Importe = TributoImporte(tt)
                        End With
                        If tt > 0 Then
                            ReDim Preserve ArrayOfTributoTax(tt - 1)
                        End If
                        'ArrayOfTributoTax(tt - 1) = TributoTax
                        ArrayOfTributoTax(tt) = TributoTax
                    Next tt
                    objFEDetalleRequest.Tributos = ArrayOfTributoTax
                    For tt = 1 To t - 1
                        TributoId(tt) = 0
                        TributoDesc(tt) = ""
                        TributoBaseImp(tt) = 0
                        TributoAlic(tt) = 0
                        TributoImporte(tt) = 0
                    Next
                    t = 1
                    tribxml = ""
                End If
                If myreader(26) <> "" Then
                    tribxml = ""
                    t = 0
                    Do While (testxmliva.Read())
                        Select Case testxmliva.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                tribxml = tribxml & "<" & testxmliva.Name & ">"
                                Select Case testxmliva.Name
                                    Case "Id"
                                        tipotrib = 1
                                    Case "BaseImp"
                                        tipotrib = 2
                                    Case "Alic"
                                        tipotrib = 3
                                    Case "Importe"
                                        tipotrib = 4
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                tribxml = tribxml & testxmliva.Value
                                Select Case tipotrib
                                    Case 1
                                        TempValue = testxmliva.Value
                                        TributoId(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxmliva.Value
                                        TributoBaseImp(t) = Val(TempValue)
                                    Case 3
                                        TempValue = testxmliva.Value
                                        TributoAlic(t) = Val(TempValue)
                                    Case 4
                                        TempValue = testxmliva.Value
                                        TributoImporte(t) = Val(TempValue)
                                End Select
                            Case XmlNodeType.EndElement
                                tribxml = tribxml & "</" & testxmliva.Name & ">"
                                If testxmliva.Name = "AlicIva" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    For tt = 0 To t - 1
                        Dim AlicIva As New wsfev1t.AlicIva
                        With AlicIva
                            .Id = TributoId(tt)
                            .BaseImp = TributoBaseImp(tt)
                            .Importe = TributoImporte(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfAlicIva(tt - 1)
                        End If
                        ArrayOfAlicIva(tt) = AlicIva
                    Next tt
                    objFEDetalleRequest.Iva = ArrayOfAlicIva
                End If
                opcionalxml = ""
                t = 0
                If myreader(27) <> "" Then
                    Do While (testxmlopcional.Read())
                        Select Case testxmlopcional.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                opcionalxml = opcionalxml & "<" & testxmlopcional.Name & ">"
                                Select Case testxmlopcional.Name
                                    Case "Id"
                                        opcionalesid = 1
                                    Case "Valor"
                                        opcionalesid = 2
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                opcionalxml = opcionalxml & testxmlopcional.Value
                                Select Case opcionalesid
                                    Case 1
                                        TempValue = testxmlopcional.Value
                                        OpcionalID(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxmlopcional.Value
                                        OpcionalValor(t) = TempValue
                                End Select
                            Case XmlNodeType.EndElement
                                opcionalxml = opcionalxml & "</" & testxmlopcional.Name & ">"
                                If testxmlopcional.Name = "Opcional" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    For tt = 0 To t - 1
                        Dim Opcional As New wsfev1t.Opcional
                        With Opcional
                            .Id = OpcionalID(tt)
                            .Valor = OpcionalValor(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfAdicionales(tt - 1)
                        End If
                        ArrayOfAdicionales(tt) = Opcional
                    Next tt
                    objFEDetalleRequest.Opcionales = ArrayOfAdicionales
                End If
                'If presta_serv = "1" Then
                '.FchServDesde = fecha_serv_desde
                '.FchServHasta = fecha_serv_hasta
                '.FchVtoPago = fecha_venc_pago
                'End If
            End With
            ArrayOfFEDetalleRequest(indice) = objFEDetalleRequest
            indice = indice + 1

            reader = Nothing
            testxml = Nothing
            readeriva = Nothing
            testxmliva = Nothing
            readeropcioanl = Nothing
            testxmlopcional = Nothing
        End While
        objFERequest.FeDetReq = ArrayOfFEDetalleRequest

        objFECabeceraRequest.CantReg = indice
        objFERequest.FeCabReq = objFECabeceraRequest

        myreader.Close()
        mycon.Close()
        comUserSelect = Nothing

        ' Invoco al método FEAutRequest
        Try
            objFEResponse = objWSFE.FECAESolicitar(objFEAuthRequest, objFERequest)

            If objFEResponse.Errors IsNot Nothing Then
                For ii = 0 To objFEResponse.Errors.Length - 1
                    If strError = "" Then
                        strError = objFEResponse.Errors(ii).Msg
                    Else
                        strError = strError & vbCrLf & objFEResponse.Errors(ii).Msg
                    End If
                Next
                ObtieneCAETESTv1PILOTE = False
                Exit Function
            End If
            If objFEResponse IsNot Nothing Then
                ii = objFEResponse.FeCabResp.CantReg
                mycon = New SqlConnection(conexionBD)
                mycon.Open()

                For d = 0 To (ii - 1)
                    cbte_cae = IIf(objFEResponse.FeDetResp(d).CAE = "NULL", "", objFEResponse.FeDetResp(d).CAE)
                    vencimiento_cae = IIf(objFEResponse.FeDetResp(d).CAEFchVto = "NULL", "", objFEResponse.FeDetResp(d).CAEFchVto)
                    cbte_nro = objFEResponse.FeDetResp(d).CbteDesde.ToString
                    cbte_pdv = objFEResponse.FeCabResp.PtoVta.ToString
                    cbte_tipo = objFEResponse.FeCabResp.CbteTipo.ToString
                    cbte_estado = IIf(objFEResponse.FeDetResp(d).Resultado = "NULL", "", objFEResponse.FeDetResp(d).Resultado)
                    If objFEResponse.FeDetResp(d).Observaciones IsNot Nothing Then
                        cbte_comentario = objFEResponse.FeDetResp(d).Observaciones(0).Code
                    Else
                        cbte_comentario = ""
                    End If
                    SQL_STR = "UPDATE FRG_RM20101 SET FRG_CAE = '" & cbte_cae & "', FRG_CAE_DUE = '" & vencimiento_cae & "', " & _
                        "FRG_ESTADO = '" & cbte_estado & "', FRG_MOTIVO = '" & cbte_comentario & "' " & _
                        "WHERE CONVERT(INT, FRG_PDV) = " & cbte_pdv & " AND CONVERT(INT, FRG_COD) = " & cbte_tipo & " " & _
                        "AND CONVERT(INT, FRG_NRO) = " & cbte_nro & " "

                    Dim cmd1 As SqlCommand = New SqlCommand(SQL_STR, mycon)

                    'cmd1.Connection.Open()

                    cmd1.ExecuteNonQuery()

                    cmd1 = Nothing
                Next
                ObtieneCAETESTv1PILOTE = True
            End If
        Catch ex As Exception
            strError = ex.Message & vbCrLf & "Vuelva a intentarlo."
            ObtieneCAETESTv1PILOTE = False
        End Try

        ObtieneCAETESTv1PILOTE = True
    End Function

    Public Function ObtieneCAEPRODv1PI(ByVal cuit As String, _
        ByVal strId As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal strcantidadreg As String, _
        ByVal presta_serv As String, _
        ByVal tipo_doc As String, _
        ByVal nro_doc As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByRef cbt_desde As String, _
        ByRef cbt_hasta As String, _
        ByVal imp_total As String, _
        ByVal imp_tot_conc As String, _
        ByVal imp_neto As String, _
        ByVal impto_liq As String, _
        ByVal impto_liq_rni As String, _
        ByVal imp_op_ex As String, _
        ByVal imp_trib As String, _
        ByVal fecha_cbte As String, _
        ByVal fecha_serv_desde As String, _
        ByVal fecha_serv_hasta As String, _
        ByVal fecha_venc_pago As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, _
        ByRef desc_rechazo As String, _
        ByRef codeerr As String, _
        ByRef msgerr As String, _
        ByRef reproceso As String, _
        ByVal concepto As String, _
        ByVal moneda As String, _
        ByVal tipo_cbio As String, _
        ByVal tributos As String, _
        ByVal ivastr As String, _
        ByVal adicionalesstr As String) As Boolean

        gGrabaLog("C O M I E N Z O")
        gGrabaLog(cuit)
        gGrabaLog(strcantidadreg)
        gGrabaLog(presta_serv)
        gGrabaLog(tipo_doc)
        gGrabaLog(nro_doc)
        gGrabaLog(tipo_cbte)
        gGrabaLog(punto_vta)
        gGrabaLog(cbt_desde)
        gGrabaLog(cbt_hasta)
        gGrabaLog(imp_total)
        gGrabaLog(imp_tot_conc)
        gGrabaLog(imp_neto)
        gGrabaLog(impto_liq)
        gGrabaLog(impto_liq_rni)
        gGrabaLog(imp_op_ex)
        gGrabaLog(imp_trib)
        gGrabaLog(fecha_cbte)
        gGrabaLog(fecha_serv_desde)
        gGrabaLog(fecha_serv_hasta)
        gGrabaLog(fecha_venc_pago)
        gGrabaLog(cbte_estado)
        gGrabaLog(vencimiento_cae)
        gGrabaLog(cbte_cae)
        gGrabaLog(motivo_rechazo)
        gGrabaLog(desc_rechazo)
        gGrabaLog(codeerr)
        gGrabaLog(msgerr)
        gGrabaLog(reproceso)
        gGrabaLog(concepto)
        gGrabaLog(moneda)
        gGrabaLog(tipo_cbio)
        gGrabaLog(tributos)
        gGrabaLog(ivastr)
        gGrabaLog(adicionalesstr)

        Dim objWSFE As New wsfev1p.Service
        Dim objFEAuthRequest As New wsfev1p.FEAuthRequest
        Dim cantidadreg As Integer = 1
        Dim indicemax As Integer = 0
        Dim d As Integer = 0
        Dim t As Integer = 1
        Dim iv As Integer = 0
        Dim derr As Integer = 0
        Dim ii, tt As Integer
        Dim tribxml, opcionalxml As String
        Dim tipotrib, tipoiva, opcionalesid As Integer
        Dim objFERequest As New wsfev1p.FECAERequest
        Dim objFECabeceraRequest As New wsfev1p.FECAECabRequest
        Dim ArrayOfFEDetalleRequest(indicemax) As wsfev1p.FECAEDetRequest
        Dim objFEResponse As New wsfev1p.FECAEResponse
        Dim ArrayOfFEDetalleResponse(indicemax) As wsfev1p.FECAEDetResponse
        Dim ArrayOfTributoTax(0) As wsfev1p.Tributo
        Dim ArrayOfAlicIva(0) As wsfev1p.AlicIva
        Dim ArrayOfAdicionales(0) As wsfev1p.Opcional
        Dim objFEDetalleResponse(indicemax) As wsfev1p.FECAEDetResponse
        Dim TributoId(10) As Integer
        Dim TributoDesc(10) As String
        Dim TributoBaseImp(10), TributoAlic(10), TributoImporte(10) As Double
        Dim OpcionalID(1), OpcionalValor(1) As String
        Dim TempValue As String
        tipotrib = 0
        tipoiva = 0
        objFEAuthRequest.Cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFECabeceraRequest.CantReg = Val(strcantidadreg)
        objFECabeceraRequest.CbteTipo = Val(tipo_cbte)
        objFECabeceraRequest.PtoVta = Val(punto_vta)
        objFERequest.FeCabReq = objFECabeceraRequest
        Dim reader As StringReader = New StringReader(tributos)
        Dim testxml As XmlTextReader = New XmlTextReader(reader)
        Dim readeriva As StringReader = New StringReader(ivastr)
        Dim testxmliva As XmlTextReader = New XmlTextReader(readeriva)
        Dim readeropcioanl As StringReader = New StringReader(adicionalesstr)
        Dim testxmlopcional As XmlTextReader = New XmlTextReader(readeropcioanl)

        tribxml = ""
        'Obtengo los datos del DataGridView DGV_FEDetalleRequest
        For d = 0 To (indicemax)
            Dim objFEDetalleRequest As New wsfev1p.FECAEDetRequest

            With objFEDetalleRequest
                .Concepto = Val(concepto)
                .MonId = moneda
                .MonCotiz = Val(tipo_cbio)
                .DocTipo = Val(tipo_doc)
                .DocNro = Val(nro_doc)
                .CbteDesde = Val(cbt_desde)
                .CbteHasta = Val(cbt_hasta)
                .ImpTotal = Val(imp_total)
                .ImpTotConc = Val(imp_tot_conc)
                .ImpNeto = Val(imp_neto)
                .ImpIVA = Val(impto_liq)
                .ImpTrib = Val(imp_trib)
                '. = Val(impto_liq_rni)
                .ImpOpEx = Val(imp_op_ex)
                .CbteFch = fecha_cbte
                If tributos <> "" Then
                    Do While (testxml.Read())
                        Select Case testxml.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                tribxml = tribxml & "<" & testxml.Name & ">"
                                Select Case testxml.Name
                                    Case "Id"
                                        tipotrib = 1
                                    Case "Desc"
                                        tipotrib = 2
                                    Case "BaseImp"
                                        tipotrib = 3
                                    Case "Alic"
                                        tipotrib = 4
                                    Case "Importe"
                                        tipotrib = 5
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                tribxml = tribxml & testxml.Value
                                Select Case tipotrib
                                    Case 1
                                        TempValue = testxml.Value
                                        TributoId(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxml.Value
                                        TributoDesc(t) = TempValue
                                    Case 3
                                        TempValue = testxml.Value
                                        TributoBaseImp(t) = Val(TempValue)
                                    Case 4
                                        TempValue = testxml.Value
                                        TributoAlic(t) = Val(TempValue)
                                    Case 5
                                        TempValue = testxml.Value
                                        TributoImporte(t) = Val(TempValue)
                                End Select
                            Case XmlNodeType.EndElement
                                tribxml = tribxml & "</" & testxml.Name & ">"
                                If testxml.Name = "Tributo" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    For tt = 1 To t - 1
                        Dim TributoTax As New wsfev1p.Tributo
                        With TributoTax
                            .Id = TributoId(tt)
                            .Desc = TributoDesc(tt)
                            .BaseImp = TributoBaseImp(tt)
                            .Alic = TributoAlic(tt)
                            .Importe = TributoImporte(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfTributoTax(tt - 1)
                        End If
                        ArrayOfTributoTax(tt - 1) = TributoTax
                    Next tt
                    objFEDetalleRequest.Tributos = ArrayOfTributoTax
                    For tt = 1 To t - 1
                        TributoId(tt) = 0
                        TributoDesc(tt) = ""
                        TributoBaseImp(tt) = 0
                        TributoAlic(tt) = 0
                        TributoImporte(tt) = 0
                    Next
                    t = 1
                    tribxml = ""
                End If
                If ivastr <> "" Then
                    Do While (testxmliva.Read())
                        Select Case testxmliva.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                tribxml = tribxml & "<" & testxmliva.Name & ">"
                                Select Case testxmliva.Name
                                    Case "Id"
                                        tipotrib = 1
                                    Case "BaseImp"
                                        tipotrib = 2
                                    Case "Alic"
                                        tipotrib = 3
                                    Case "Importe"
                                        tipotrib = 4
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                tribxml = tribxml & testxmliva.Value
                                Select Case tipotrib
                                    Case 1
                                        TempValue = testxmliva.Value
                                        TributoId(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxmliva.Value
                                        TributoBaseImp(t) = Val(TempValue)
                                    Case 3
                                        TempValue = testxmliva.Value
                                        TributoAlic(t) = Val(TempValue)
                                    Case 4
                                        TempValue = testxmliva.Value
                                        TributoImporte(t) = Val(TempValue)
                                End Select
                            Case XmlNodeType.EndElement
                                tribxml = tribxml & "</" & testxmliva.Name & ">"
                                If testxmliva.Name = "AlicIva" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    gGrabaLog("1- " & desc_rechazo)
                    For tt = 1 To t - 1
                        Dim AlicIva As New wsfev1p.AlicIva
                        With AlicIva
                            .Id = TributoId(tt)
                            .BaseImp = TributoBaseImp(tt)
                            .Importe = TributoImporte(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfAlicIva(tt - 1)
                        End If
                        ArrayOfAlicIva(tt - 1) = AlicIva
                    Next tt
                    gGrabaLog("2- " & desc_rechazo)
                    objFEDetalleRequest.Iva = ArrayOfAlicIva
                End If
                opcionalxml = ""
                t = 1
                If adicionalesstr <> "" Then
                    Do While (testxmlopcional.Read())
                        Select Case testxmlopcional.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                opcionalxml = opcionalxml & "<" & testxmlopcional.Name & ">"
                                Select Case testxmlopcional.Name
                                    Case "Id"
                                        opcionalesid = 1
                                    Case "Valor"
                                        opcionalesid = 2
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                opcionalxml = opcionalxml & testxmlopcional.Value
                                Select Case opcionalesid
                                    Case 1
                                        TempValue = testxmlopcional.Value
                                        OpcionalID(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxmlopcional.Value
                                        OpcionalValor(t) = TempValue
                                End Select
                            Case XmlNodeType.EndElement
                                opcionalxml = opcionalxml & "</" & testxmlopcional.Name & ">"
                                If testxmlopcional.Name = "Opcional" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    gGrabaLog("1- " & desc_rechazo)
                    For tt = 1 To t - 1
                        Dim Opcional As New wsfev1p.Opcional
                        With Opcional
                            .Id = OpcionalID(tt)
                            .Valor = OpcionalValor(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfAdicionales(tt - 1)
                        End If
                        ArrayOfAdicionales(tt - 1) = Opcional
                    Next tt
                    gGrabaLog("2- " & desc_rechazo)
                    objFEDetalleRequest.Opcionales = ArrayOfAdicionales
                End If
                If presta_serv > "1" Then
                    .FchServDesde = fecha_serv_desde
                    .FchServHasta = fecha_serv_hasta
                    .FchVtoPago = fecha_venc_pago
                End If
            End With
            ArrayOfFEDetalleRequest(d) = objFEDetalleRequest
        Next d
        objFERequest.FeDetReq = ArrayOfFEDetalleRequest
        gGrabaLog("21- " & strToken)
        gGrabaLog("21- " & strSign)

        ' Invoco al método FEAutRequest
        Try
            objFEResponse = objWSFE.FECAESolicitar(objFEAuthRequest, objFERequest)
            objFEDetalleResponse = objFEResponse.FeDetResp
            'codeerr = objFEResponse.Errors(0).Code.ToString
            'msgerr = objFEResponse.Errors(0).Msg
            If Not objFEResponse.Errors Is Nothing Then
                desc_rechazo = objFEResponse.Errors(0).Msg
                ObtieneCAEPRODv1PI = False
            Else
                ii = objFEResponse.FeCabResp.CantReg
                reproceso = objFEResponse.FeCabResp.Reproceso
                For d = 0 To (ii - 1)
                    'If objFEResponse.FedResp(d) Is not Nothing Then
                    cbte_estado = objFEResponse.FeDetResp(d).Resultado
                    vencimiento_cae = IIf(objFEResponse.FeDetResp(d).CAEFchVto = "NULL", "", objFEResponse.FeDetResp(d).CAEFchVto)
                    cbte_cae = IIf(objFEResponse.FeDetResp(d).CAE = "NULL", "", objFEResponse.FeDetResp(d).CAE)
                    If objFEResponse.FeCabResp.Reproceso = "S" Then
                        gGrabaLog("3- " & desc_rechazo)
                        cbt_desde = objFEResponse.FeDetResp(d).CbteDesde.ToString
                        cbt_hasta = objFEResponse.FeDetResp(d).CbteHasta.ToString
                    End If
                    'motivo_rechazo = IIf(objFEResponse.FeCabResp(d).motivo = "NULL", "", objFEResponse.FedResp(d).motivo)
                    gGrabaLog("4- " & desc_rechazo)
                    If Not objFEResponse.FeDetResp(d).Observaciones Is Nothing Then
                        gGrabaLog("41 " + objFEResponse.FeDetResp(d).Observaciones.Length.ToString)
                        For derr = 0 To objFEResponse.FeDetResp(d).Observaciones.Length - 1
                            desc_rechazo = desc_rechazo & "; " & objFEResponse.FeDetResp(d).Observaciones(derr).Msg
                            gGrabaLog("5- " & desc_rechazo)
                        Next derr
                    End If
                    gGrabaLog("6- " & desc_rechazo)
                    ObtieneCAEPRODv1PI = True
                    'Else
                    'cbte_estado = objFEResponse.FecResp.resultado
                    'desc_rechazo = "FEResponse.FecResp.motivo: " + objFEResponse.FecResp.motivo + vbCrLf + _
                    '"FEResponse.FecResp.reproceso: " + objFEResponse.FecResp.reproceso + vbCrLf + _
                    '"FEResponse.FecResp.resultado: " + objFEResponse.FecResp.resultado
                    'For d = 0 To (indicemax)
                    '   desc_rechazo = "FEResponse.FedResp(" + d.ToString + ").cae: " + objFEResponse.FedResp(d).cae.ToString + vbCrLf + _
                    '   "FEResponse.FedResp(" + d.ToString + ").resultado: " + objFEResponse.FedResp(d).resultado
                    'Next d
                    'desc_rechazo = "FEResponse.RError.percode: " + objFEResponse.RError.percode.ToString + vbCrLf + _
                    '"FEResponse.RError.perrmsg: " + objFEResponse.RError.perrmsg
                    'End If
                Next d
            End If
            gGrabaLog("F I N A L")
        Catch ex As Exception
            gGrabaLog("7- " & desc_rechazo)
            desc_rechazo = ex.Message
            gGrabaLog("8- " & desc_rechazo)
            ObtieneCAEPRODv1PI = False
        End Try

        ' Obtengo los XML de request/response y los escribo en el disco
        'Dim writer1 As New XmlSerializer(GetType(wsw.FERequest))
        'Dim file1 As New StreamWriter("C:\wsfe_FERequest.xml")
        'writer1.Serialize(file1, objFERequest)
        'file1.Close()
        'Dim writer2 As New XmlSerializer(GetType(wsw.FEResponse))
        'Dim file2 As New StreamWriter("C:\wsfe_FEResponse.xml")
        'writer2.Serialize(file2, objFEResponse)
        'file2.Close()
    End Function
    Public Function ObtieneCAEPRODv1(ByVal cuit As String, _
        ByVal strId As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal strcantidadreg As String, _
        ByVal presta_serv As String, _
        ByVal tipo_doc As String, _
        ByVal nro_doc As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByRef cbt_desde As String, _
        ByRef cbt_hasta As String, _
        ByVal imp_total As String, _
        ByVal imp_tot_conc As String, _
        ByVal imp_neto As String, _
        ByVal impto_liq As String, _
        ByVal impto_liq_rni As String, _
        ByVal imp_op_ex As String, _
        ByVal imp_trib As String, _
        ByVal fecha_cbte As String, _
        ByVal fecha_serv_desde As String, _
        ByVal fecha_serv_hasta As String, _
        ByVal fecha_venc_pago As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, _
        ByRef desc_rechazo As String, _
        ByRef codeerr As String, _
        ByRef msgerr As String, _
        ByRef reproceso As String, _
        ByRef concepto As String, _
        ByVal moneda As String, _
        ByVal tipo_cbio As String, _
        ByVal tributos As String, _
        ByVal ivastr As String) As Boolean

        gGrabaLog("C O M I E N Z O")
        gGrabaLog(cuit)
        gGrabaLog(strcantidadreg)
        gGrabaLog(presta_serv)
        gGrabaLog(tipo_doc)
        gGrabaLog(nro_doc)
        gGrabaLog(tipo_cbte)
        gGrabaLog(punto_vta)
        gGrabaLog(cbt_desde)
        gGrabaLog(cbt_hasta)
        gGrabaLog(imp_total)
        gGrabaLog(imp_tot_conc)
        gGrabaLog(imp_neto)
        gGrabaLog(impto_liq)
        gGrabaLog(impto_liq_rni)
        gGrabaLog(imp_op_ex)
        gGrabaLog(imp_trib)
        gGrabaLog(fecha_cbte)
        gGrabaLog(fecha_serv_desde)
        gGrabaLog(fecha_serv_hasta)
        gGrabaLog(fecha_venc_pago)
        gGrabaLog(cbte_estado)
        gGrabaLog(vencimiento_cae)
        gGrabaLog(cbte_cae)
        gGrabaLog(motivo_rechazo)
        gGrabaLog(desc_rechazo)
        gGrabaLog(codeerr)
        gGrabaLog(msgerr)
        gGrabaLog(reproceso)
        gGrabaLog(concepto)
        gGrabaLog(moneda)
        gGrabaLog(tipo_cbio)
        gGrabaLog(tributos)
        gGrabaLog(ivastr)

        Dim objWSFE As New wsfev1p.Service
        Dim objFEAuthRequest As New wsfev1p.FEAuthRequest
        Dim cantidadreg As Integer = 1
        Dim indicemax As Integer = 0
        Dim d As Integer = 0
        Dim t As Integer = 1
        Dim iv As Integer = 0
        Dim derr As Integer = 0
        Dim ii, tt As Integer
        Dim tribxml As String
        Dim tipotrib, tipoiva As Integer
        Dim objFERequest As New wsfev1p.FECAERequest
        Dim objFECabeceraRequest As New wsfev1p.FECAECabRequest
        Dim ArrayOfFEDetalleRequest(indicemax) As wsfev1p.FECAEDetRequest
        Dim objFEResponse As New wsfev1p.FECAEResponse
        Dim ArrayOfFEDetalleResponse(indicemax) As wsfev1p.FECAEDetResponse
        Dim ArrayOfTributoTax(0) As wsfev1p.Tributo
        Dim ArrayOfAlicIva(0) As wsfev1p.AlicIva
        Dim objFEDetalleResponse(indicemax) As wsfev1p.FECAEDetResponse
        Dim TributoId(10) As Integer
        Dim TributoDesc(10) As String
        Dim TributoBaseImp(10), TributoAlic(10), TributoImporte(10) As Double
        Dim TempValue As String
        tipotrib = 0
        tipoiva = 0
        objFEAuthRequest.Cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFECabeceraRequest.CantReg = Val(strcantidadreg)
        objFECabeceraRequest.CbteTipo = Val(tipo_cbte)
        objFECabeceraRequest.PtoVta = Val(punto_vta)
        objFERequest.FeCabReq = objFECabeceraRequest
        Dim reader As StringReader = New StringReader(tributos)
        Dim testxml As XmlTextReader = New XmlTextReader(reader)
        Dim readeriva As StringReader = New StringReader(ivastr)
        Dim testxmliva As XmlTextReader = New XmlTextReader(readeriva)

        tribxml = ""
        'Obtengo los datos del DataGridView DGV_FEDetalleRequest
        For d = 0 To (indicemax)
            Dim objFEDetalleRequest As New wsfev1p.FECAEDetRequest

            With objFEDetalleRequest
                .Concepto = Val(concepto)
                .MonId = moneda
                .MonCotiz = Val(tipo_cbio)
                .DocTipo = Val(tipo_doc)
                .DocNro = Val(nro_doc)
                .CbteDesde = Val(cbt_desde)
                .CbteHasta = Val(cbt_hasta)
                .ImpTotal = Val(imp_total)
                .ImpTotConc = Val(imp_tot_conc)
                .ImpNeto = Val(imp_neto)
                .ImpIVA = Val(impto_liq)
                .ImpTrib = Val(imp_trib)
                '. = Val(impto_liq_rni)
                .ImpOpEx = Val(imp_op_ex)
                .CbteFch = fecha_cbte
                If tributos <> "" Then
                    Do While (testxml.Read())
                        Select Case testxml.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                tribxml = tribxml & "<" & testxml.Name & ">"
                                Select Case testxml.Name
                                    Case "Id"
                                        tipotrib = 1
                                    Case "Desc"
                                        tipotrib = 2
                                    Case "BaseImp"
                                        tipotrib = 3
                                    Case "Alic"
                                        tipotrib = 4
                                    Case "Importe"
                                        tipotrib = 5
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                tribxml = tribxml & testxml.Value
                                Select Case tipotrib
                                    Case 1
                                        TempValue = testxml.Value
                                        TributoId(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxml.Value
                                        TributoDesc(t) = TempValue
                                    Case 3
                                        TempValue = testxml.Value
                                        TributoBaseImp(t) = Val(TempValue)
                                    Case 4
                                        TempValue = testxml.Value
                                        TributoAlic(t) = Val(TempValue)
                                    Case 5
                                        TempValue = testxml.Value
                                        TributoImporte(t) = Val(TempValue)
                                End Select
                            Case XmlNodeType.EndElement
                                tribxml = tribxml & "</" & testxml.Name & ">"
                                If testxml.Name = "Tributo" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    For tt = 1 To t - 1
                        Dim TributoTax As New wsfev1p.Tributo
                        With TributoTax
                            .Id = TributoId(tt)
                            .Desc = TributoDesc(tt)
                            .BaseImp = TributoBaseImp(tt)
                            .Alic = TributoAlic(tt)
                            .Importe = TributoImporte(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfTributoTax(tt - 1)
                        End If
                        ArrayOfTributoTax(tt - 1) = TributoTax
                    Next tt
                    objFEDetalleRequest.Tributos = ArrayOfTributoTax
                    For tt = 1 To t - 1
                        TributoId(tt) = 0
                        TributoDesc(tt) = ""
                        TributoBaseImp(tt) = 0
                        TributoAlic(tt) = 0
                        TributoImporte(tt) = 0
                    Next
                    t = 1
                    tribxml = ""
                End If
                If ivastr <> "" Then
                    Do While (testxmliva.Read())
                        Select Case testxmliva.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                tribxml = tribxml & "<" & testxmliva.Name & ">"
                                Select Case testxmliva.Name
                                    Case "Id"
                                        tipotrib = 1
                                    Case "BaseImp"
                                        tipotrib = 2
                                    Case "Alic"
                                        tipotrib = 3
                                    Case "Importe"
                                        tipotrib = 4
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                tribxml = tribxml & testxmliva.Value
                                Select Case tipotrib
                                    Case 1
                                        TempValue = testxmliva.Value
                                        TributoId(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxmliva.Value
                                        TributoBaseImp(t) = Val(TempValue)
                                    Case 3
                                        TempValue = testxmliva.Value
                                        TributoAlic(t) = Val(TempValue)
                                    Case 4
                                        TempValue = testxmliva.Value
                                        TributoImporte(t) = Val(TempValue)
                                End Select
                            Case XmlNodeType.EndElement
                                tribxml = tribxml & "</" & testxmliva.Name & ">"
                                If testxmliva.Name = "AlicIva" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    For tt = 1 To t - 1
                        Dim AlicIva As New wsfev1p.AlicIva
                        With AlicIva
                            .Id = TributoId(tt)
                            .BaseImp = TributoBaseImp(tt)
                            .Importe = TributoImporte(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfAlicIva(tt - 1)
                        End If
                        ArrayOfAlicIva(tt - 1) = AlicIva
                    Next tt
                    objFEDetalleRequest.Iva = ArrayOfAlicIva
                End If
                If presta_serv > "1" Then
                    .FchServDesde = fecha_serv_desde
                    .FchServHasta = fecha_serv_hasta
                    .FchVtoPago = fecha_venc_pago
                End If
            End With
            ArrayOfFEDetalleRequest(d) = objFEDetalleRequest
        Next d
        objFERequest.FeDetReq = ArrayOfFEDetalleRequest

        ' Invoco al método FEAutRequest
        Try
            objFEResponse = objWSFE.FECAESolicitar(objFEAuthRequest, objFERequest)
            objFEDetalleResponse = objFEResponse.FeDetResp
            'codeerr = objFEResponse.Errors(0).Code.ToString
            'msgerr = objFEResponse.Errors(0).Msg
            If Not objFEResponse.Errors Is Nothing Then
                desc_rechazo = objFEResponse.Errors(0).Msg
                ObtieneCAEPRODv1 = False
            Else
                ii = objFEResponse.FeCabResp.CantReg
                reproceso = objFEResponse.FeCabResp.Reproceso
                For d = 0 To (ii - 1)
                    'If objFEResponse.FedResp(d) Is not Nothing Then
                    cbte_estado = objFEResponse.FeDetResp(d).Resultado
                    vencimiento_cae = IIf(objFEResponse.FeDetResp(d).CAEFchVto = "NULL", "", objFEResponse.FeDetResp(d).CAEFchVto)
                    cbte_cae = IIf(objFEResponse.FeDetResp(d).CAE = "NULL", "", objFEResponse.FeDetResp(d).CAE)
                    If objFEResponse.FeCabResp.Reproceso = "S" Then
                        cbt_desde = objFEResponse.FeDetResp(d).CbteDesde.ToString
                        cbt_hasta = objFEResponse.FeDetResp(d).CbteHasta.ToString
                    End If
                    'motivo_rechazo = IIf(objFEResponse.FeCabResp(d).motivo = "NULL", "", objFEResponse.FedResp(d).motivo)
                    If Not objFEResponse.FeDetResp(d).Observaciones Is Nothing Then
                        For derr = 0 To objFEResponse.FeDetResp(d).Observaciones.Length - 1
                            desc_rechazo = desc_rechazo & "; " & objFEResponse.FeDetResp(d).Observaciones(derr).Msg
                        Next derr
                    End If
                    ObtieneCAEPRODv1 = True
                    'Else
                    'cbte_estado = objFEResponse.FecResp.resultado
                    'desc_rechazo = "FEResponse.FecResp.motivo: " + objFEResponse.FecResp.motivo + vbCrLf + _
                    '"FEResponse.FecResp.reproceso: " + objFEResponse.FecResp.reproceso + vbCrLf + _
                    '"FEResponse.FecResp.resultado: " + objFEResponse.FecResp.resultado
                    'For d = 0 To (indicemax)
                    '   desc_rechazo = "FEResponse.FedResp(" + d.ToString + ").cae: " + objFEResponse.FedResp(d).cae.ToString + vbCrLf + _
                    '   "FEResponse.FedResp(" + d.ToString + ").resultado: " + objFEResponse.FedResp(d).resultado
                    'Next d
                    'desc_rechazo = "FEResponse.RError.percode: " + objFEResponse.RError.percode.ToString + vbCrLf + _
                    '"FEResponse.RError.perrmsg: " + objFEResponse.RError.perrmsg
                    'End If
                Next d
            End If
        Catch ex As Exception
            desc_rechazo = ex.Message
            ObtieneCAEPRODv1 = False
        End Try

        ' Obtengo los XML de request/response y los escribo en el disco
        'Dim writer1 As New XmlSerializer(GetType(wsw.FERequest))
        'Dim file1 As New StreamWriter("C:\wsfe_FERequest.xml")
        'writer1.Serialize(file1, objFERequest)
        'file1.Close()
        'Dim writer2 As New XmlSerializer(GetType(wsw.FEResponse))
        'Dim file2 As New StreamWriter("C:\wsfe_FEResponse.xml")
        'writer2.Serialize(file2, objFEResponse)
        'file2.Close()
    End Function
    Public Function ObtieneCAETESTv1PI(ByVal cuit As String, _
        ByVal strId As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal strcantidadreg As String, _
        ByVal presta_serv As String, _
        ByVal tipo_doc As String, _
        ByVal nro_doc As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByRef cbt_desde As String, _
        ByRef cbt_hasta As String, _
        ByVal imp_total As String, _
        ByVal imp_tot_conc As String, _
        ByVal imp_neto As String, _
        ByVal impto_liq As String, _
        ByVal impto_liq_rni As String, _
        ByVal imp_op_ex As String, _
        ByVal imp_trib As String, _
        ByVal fecha_cbte As String, _
        ByVal fecha_serv_desde As String, _
        ByVal fecha_serv_hasta As String, _
        ByVal fecha_venc_pago As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, _
        ByRef desc_rechazo As String, _
        ByRef codeerr As String, _
        ByRef msgerr As String, _
        ByRef reproceso As String, _
        ByVal concepto As String, _
        ByVal moneda As String, _
        ByVal tipo_cbio As String, _
        ByVal tributos As String, _
        ByVal ivastr As String, _
        ByVal adicionalesstr As String) As Boolean

        gGrabaLog("C O M I E N Z O")
        gGrabaLog(cuit)
        gGrabaLog(strcantidadreg)
        gGrabaLog(presta_serv)
        gGrabaLog(tipo_doc)
        gGrabaLog(nro_doc)
        gGrabaLog(tipo_cbte)
        gGrabaLog(punto_vta)
        gGrabaLog(cbt_desde)
        gGrabaLog(cbt_hasta)
        gGrabaLog(imp_total)
        gGrabaLog(imp_tot_conc)
        gGrabaLog(imp_neto)
        gGrabaLog(impto_liq)
        gGrabaLog(impto_liq_rni)
        gGrabaLog(imp_op_ex)
        gGrabaLog(imp_trib)
        gGrabaLog(fecha_cbte)
        gGrabaLog(fecha_serv_desde)
        gGrabaLog(fecha_serv_hasta)
        gGrabaLog(fecha_venc_pago)
        gGrabaLog(cbte_estado)
        gGrabaLog(vencimiento_cae)
        gGrabaLog(cbte_cae)
        gGrabaLog(motivo_rechazo)
        gGrabaLog(desc_rechazo)
        gGrabaLog(codeerr)
        gGrabaLog(msgerr)
        gGrabaLog(reproceso)
        gGrabaLog(concepto)
        gGrabaLog(moneda)
        gGrabaLog(tipo_cbio)
        gGrabaLog(tributos)
        gGrabaLog(ivastr)
        gGrabaLog(adicionalesstr)

        Dim objWSFE As New wsfev1t.Service
        Dim objFEAuthRequest As New wsfev1t.FEAuthRequest
        Dim cantidadreg As Integer = 1
        Dim indicemax As Integer = 0
        Dim d As Integer = 0
        Dim t As Integer = 1
        Dim iv As Integer = 0
        Dim derr As Integer = 0
        Dim ii, tt As Integer
        Dim tribxml, opcionalxml As String
        Dim tipotrib, tipoiva, opcionalesid As Integer
        Dim objFERequest As New wsfev1t.FECAERequest
        Dim objFECabeceraRequest As New wsfev1t.FECAECabRequest
        Dim ArrayOfFEDetalleRequest(indicemax) As wsfev1t.FECAEDetRequest
        Dim objFEResponse As New wsfev1t.FECAEResponse
        Dim ArrayOfFEDetalleResponse(indicemax) As wsfev1t.FECAEDetResponse
        Dim ArrayOfTributoTax(0) As wsfev1t.Tributo
        Dim ArrayOfAlicIva(0) As wsfev1t.AlicIva
        Dim ArrayOfAdicionales(0) As wsfev1t.Opcional
        Dim objFEDetalleResponse(indicemax) As wsfev1t.FECAEDetResponse
        Dim TributoId(10) As Integer
        Dim TributoDesc(10) As String
        Dim TributoBaseImp(10), TributoAlic(10), TributoImporte(10) As Double
        Dim OpcionalID(1), OpcionalValor(1) As String
        Dim TempValue As String
        tipotrib = 0
        tipoiva = 0
        objFEAuthRequest.Cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFECabeceraRequest.CantReg = Val(strcantidadreg)
        objFECabeceraRequest.CbteTipo = Val(tipo_cbte)
        objFECabeceraRequest.PtoVta = Val(punto_vta)
        objFERequest.FeCabReq = objFECabeceraRequest
        Dim reader As StringReader = New StringReader(tributos)
        Dim testxml As XmlTextReader = New XmlTextReader(reader)
        Dim readeriva As StringReader = New StringReader(ivastr)
        Dim testxmliva As XmlTextReader = New XmlTextReader(readeriva)
        Dim readeropcioanl As StringReader = New StringReader(adicionalesstr)
        Dim testxmlopcional As XmlTextReader = New XmlTextReader(readeropcioanl)

        tribxml = ""
        'Obtengo los datos del DataGridView DGV_FEDetalleRequest
        For d = 0 To (indicemax)
            Dim objFEDetalleRequest As New wsfev1t.FECAEDetRequest

            With objFEDetalleRequest
                .Concepto = Val(concepto)
                .MonId = moneda
                .MonCotiz = Val(tipo_cbio)
                .DocTipo = Val(tipo_doc)
                .DocNro = Val(nro_doc)
                .CbteDesde = Val(cbt_desde)
                .CbteHasta = Val(cbt_hasta)
                .ImpTotal = Val(imp_total)
                .ImpTotConc = Val(imp_tot_conc)
                .ImpNeto = Val(imp_neto)
                .ImpIVA = Val(impto_liq)
                .ImpTrib = Val(imp_trib)
                '. = Val(impto_liq_rni)
                .ImpOpEx = Val(imp_op_ex)
                .CbteFch = fecha_cbte
                If tributos <> "" Then
                    Do While (testxml.Read())
                        Select Case testxml.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                tribxml = tribxml & "<" & testxml.Name & ">"
                                Select Case testxml.Name
                                    Case "Id"
                                        tipotrib = 1
                                    Case "Desc"
                                        tipotrib = 2
                                    Case "BaseImp"
                                        tipotrib = 3
                                    Case "Alic"
                                        tipotrib = 4
                                    Case "Importe"
                                        tipotrib = 5
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                tribxml = tribxml & testxml.Value
                                Select Case tipotrib
                                    Case 1
                                        TempValue = testxml.Value
                                        TributoId(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxml.Value
                                        TributoDesc(t) = TempValue
                                    Case 3
                                        TempValue = testxml.Value
                                        TributoBaseImp(t) = Val(TempValue)
                                    Case 4
                                        TempValue = testxml.Value
                                        TributoAlic(t) = Val(TempValue)
                                    Case 5
                                        TempValue = testxml.Value
                                        TributoImporte(t) = Val(TempValue)
                                End Select
                            Case XmlNodeType.EndElement
                                tribxml = tribxml & "</" & testxml.Name & ">"
                                If testxml.Name = "Tributo" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    For tt = 1 To t - 1
                        Dim TributoTax As New wsfev1t.Tributo
                        With TributoTax
                            .Id = TributoId(tt)
                            .Desc = TributoDesc(tt)
                            .BaseImp = TributoBaseImp(tt)
                            .Alic = TributoAlic(tt)
                            .Importe = TributoImporte(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfTributoTax(tt - 1)
                        End If
                        ArrayOfTributoTax(tt - 1) = TributoTax
                    Next tt
                    objFEDetalleRequest.Tributos = ArrayOfTributoTax
                    For tt = 1 To t - 1
                        TributoId(tt) = 0
                        TributoDesc(tt) = ""
                        TributoBaseImp(tt) = 0
                        TributoAlic(tt) = 0
                        TributoImporte(tt) = 0
                    Next
                    t = 1
                    tribxml = ""
                End If
                If ivastr <> "" Then
                    Do While (testxmliva.Read())
                        Select Case testxmliva.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                tribxml = tribxml & "<" & testxmliva.Name & ">"
                                Select Case testxmliva.Name
                                    Case "Id"
                                        tipotrib = 1
                                    Case "BaseImp"
                                        tipotrib = 2
                                    Case "Alic"
                                        tipotrib = 3
                                    Case "Importe"
                                        tipotrib = 4
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                tribxml = tribxml & testxmliva.Value
                                Select Case tipotrib
                                    Case 1
                                        TempValue = testxmliva.Value
                                        TributoId(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxmliva.Value
                                        TributoBaseImp(t) = Val(TempValue)
                                    Case 3
                                        TempValue = testxmliva.Value
                                        TributoAlic(t) = Val(TempValue)
                                    Case 4
                                        TempValue = testxmliva.Value
                                        TributoImporte(t) = Val(TempValue)
                                End Select
                            Case XmlNodeType.EndElement
                                tribxml = tribxml & "</" & testxmliva.Name & ">"
                                If testxmliva.Name = "AlicIva" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    gGrabaLog("1- " & desc_rechazo)
                    For tt = 1 To t - 1
                        Dim AlicIva As New wsfev1t.AlicIva
                        With AlicIva
                            .Id = TributoId(tt)
                            .BaseImp = TributoBaseImp(tt)
                            .Importe = TributoImporte(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfAlicIva(tt - 1)
                        End If
                        ArrayOfAlicIva(tt - 1) = AlicIva
                    Next tt
                    gGrabaLog("2- " & desc_rechazo)
                    objFEDetalleRequest.Iva = ArrayOfAlicIva
                End If
                opcionalxml = ""
                t = 1
                If adicionalesstr <> "" Then
                    Do While (testxmlopcional.Read())
                        Select Case testxmlopcional.NodeType
                            Case XmlNodeType.Element 'Mostrar comienzo del elemento.
                                opcionalxml = opcionalxml & "<" & testxmlopcional.Name & ">"
                                Select Case testxmlopcional.Name
                                    Case "Id"
                                        opcionalesid = 1
                                    Case "Valor"
                                        opcionalesid = 2
                                End Select
                            Case XmlNodeType.Text 'Mostrar el texto en cada elemento.
                                opcionalxml = opcionalxml & testxmlopcional.Value
                                Select Case opcionalesid
                                    Case 1
                                        TempValue = testxmlopcional.Value
                                        OpcionalID(t) = Val(TempValue)
                                    Case 2
                                        TempValue = testxmlopcional.Value
                                        OpcionalValor(t) = TempValue
                                End Select
                            Case XmlNodeType.EndElement
                                opcionalxml = opcionalxml & "</" & testxmlopcional.Name & ">"
                                If testxmlopcional.Name = "Opcional" Then
                                    t = t + 1
                                End If
                        End Select
                    Loop
                    'MsgBox(tribxml)
                    gGrabaLog("1- " & desc_rechazo)
                    For tt = 1 To t - 1
                        Dim Opcional As New wsfev1t.Opcional
                        With Opcional
                            .Id = OpcionalID(tt)
                            .Valor = OpcionalValor(tt)
                        End With
                        If tt > 1 Then
                            ReDim Preserve ArrayOfAdicionales(tt - 1)
                        End If
                        ArrayOfAdicionales(tt - 1) = Opcional
                    Next tt
                    gGrabaLog("2- " & desc_rechazo)
                    objFEDetalleRequest.Opcionales = ArrayOfAdicionales
                End If
                If presta_serv > "1" Then
                    .FchServDesde = fecha_serv_desde
                    .FchServHasta = fecha_serv_hasta
                    .FchVtoPago = fecha_venc_pago
                End If
            End With
            ArrayOfFEDetalleRequest(d) = objFEDetalleRequest
        Next d
        objFERequest.FeDetReq = ArrayOfFEDetalleRequest
        gGrabaLog("21- " & strToken)
        gGrabaLog("21- " & strSign)

        ' Invoco al método FEAutRequest
        Try
            objFEResponse = objWSFE.FECAESolicitar(objFEAuthRequest, objFERequest)
            objFEDetalleResponse = objFEResponse.FeDetResp
            'codeerr = objFEResponse.Errors(0).Code.ToString
            'msgerr = objFEResponse.Errors(0).Msg
            If Not objFEResponse.Errors Is Nothing Then
                desc_rechazo = objFEResponse.Errors(0).Msg
                ObtieneCAETESTv1PI = False
            Else
                ii = objFEResponse.FeCabResp.CantReg
                reproceso = objFEResponse.FeCabResp.Reproceso
                For d = 0 To (ii - 1)
                    'If objFEResponse.FedResp(d) Is not Nothing Then
                    cbte_estado = objFEResponse.FeDetResp(d).Resultado
                    vencimiento_cae = IIf(objFEResponse.FeDetResp(d).CAEFchVto = "NULL", "", objFEResponse.FeDetResp(d).CAEFchVto)
                    cbte_cae = IIf(objFEResponse.FeDetResp(d).CAE = "NULL", "", objFEResponse.FeDetResp(d).CAE)
                    If objFEResponse.FeCabResp.Reproceso = "S" Then
                        gGrabaLog("3- " & desc_rechazo)
                        cbt_desde = objFEResponse.FeDetResp(d).CbteDesde.ToString
                        cbt_hasta = objFEResponse.FeDetResp(d).CbteHasta.ToString
                    End If
                    'motivo_rechazo = IIf(objFEResponse.FeCabResp(d).motivo = "NULL", "", objFEResponse.FedResp(d).motivo)
                    gGrabaLog("4- " & desc_rechazo)
                    If Not objFEResponse.FeDetResp(d).Observaciones Is Nothing Then
                        gGrabaLog("41 " + objFEResponse.FeDetResp(d).Observaciones.Length.ToString)
                        For derr = 0 To objFEResponse.FeDetResp(d).Observaciones.Length - 1
                            desc_rechazo = desc_rechazo & "; " & objFEResponse.FeDetResp(d).Observaciones(derr).Msg
                            gGrabaLog("5- " & desc_rechazo)
                        Next derr
                    End If
                    gGrabaLog("6- " & desc_rechazo)
                    ObtieneCAETESTv1PI = True
                    'Else
                    'cbte_estado = objFEResponse.FecResp.resultado
                    'desc_rechazo = "FEResponse.FecResp.motivo: " + objFEResponse.FecResp.motivo + vbCrLf + _
                    '"FEResponse.FecResp.reproceso: " + objFEResponse.FecResp.reproceso + vbCrLf + _
                    '"FEResponse.FecResp.resultado: " + objFEResponse.FecResp.resultado
                    'For d = 0 To (indicemax)
                    '   desc_rechazo = "FEResponse.FedResp(" + d.ToString + ").cae: " + objFEResponse.FedResp(d).cae.ToString + vbCrLf + _
                    '   "FEResponse.FedResp(" + d.ToString + ").resultado: " + objFEResponse.FedResp(d).resultado
                    'Next d
                    'desc_rechazo = "FEResponse.RError.percode: " + objFEResponse.RError.percode.ToString + vbCrLf + _
                    '"FEResponse.RError.perrmsg: " + objFEResponse.RError.perrmsg
                    'End If
                Next d
            End If
            gGrabaLog("F I N A L")
        Catch ex As Exception
            gGrabaLog("7- " & desc_rechazo)
            desc_rechazo = ex.Message
            gGrabaLog("8- " & desc_rechazo)
            ObtieneCAETESTv1PI = False
        End Try

        ' Obtengo los XML de request/response y los escribo en el disco
        'Dim writer1 As New XmlSerializer(GetType(wsw.FERequest))
        'Dim file1 As New StreamWriter("C:\wsfe_FERequest.xml")
        'writer1.Serialize(file1, objFERequest)
        'file1.Close()
        'Dim writer2 As New XmlSerializer(GetType(wsw.FEResponse))
        'Dim file2 As New StreamWriter("C:\wsfe_FEResponse.xml")
        'writer2.Serialize(file2, objFEResponse)
        'file2.Close()
    End Function
    Public Function UltimoNumeroProdv1(ByVal cuit As String, ByVal token As String, ByVal sign As String, _
            ByVal tipo_cbte As String, ByVal punto_vta As String, ByRef codeerr As String, _
            ByRef msgerr As String) As String
        Dim objFEAuthRequest As New wsfev1p.FEAuthRequest
        Dim objFERecuperaLastCbteResponse As New wsfev1p.FERecuperaLastCbteResponse
        Dim objWSFE As New wsfev1p.Service
        objFEAuthRequest.Cuit = cuit
        objFEAuthRequest.Token = token
        objFEAuthRequest.Sign = sign

        codeerr = ""
        msgerr = ""
        UltimoNumeroProdv1 = ""
        ' Invoco al metodo FERecuperaLastCMPRequest
        Try
            objFERecuperaLastCbteResponse = objWSFE.FECompUltimoAutorizado(objFEAuthRequest, CInt(punto_vta), CInt(tipo_cbte))
            'objFERecuperaLastCbteResponseErrors = objFERecuperaLastCbteResponse.Errors.
            'index = UBound(objFERecuperaLastCbteResponse.Errors)
            UltimoNumeroProdv1 = objFERecuperaLastCbteResponse.CbteNro
            If Not objFERecuperaLastCbteResponse.Errors Is Nothing Then
                UltimoNumeroProdv1 = UltimoNumeroProdv1 & vbCrLf & "Error Code: " & objFERecuperaLastCbteResponse.Errors(0).Code
                UltimoNumeroProdv1 = UltimoNumeroProdv1 & vbCrLf & "Error Msg: " & objFERecuperaLastCbteResponse.Errors(0).Msg
            End If
            'MsgBox(UltimoNumeroProdv1)
        Catch ex As Exception
            codeerr = "-300"
            msgerr = ex.Message
        End Try

    End Function
    Public Function UltimoNumeroTESTv1(ByVal cuit As String, ByVal token As String, ByVal sign As String, _
            ByVal tipo_cbte As String, ByVal punto_vta As String, ByRef codeerr As String, _
            ByRef msgerr As String) As String
        Dim objFEAuthRequest As New wsfev1t.FEAuthRequest
        Dim objFERecuperaLastCbteResponse As New wsfev1t.FERecuperaLastCbteResponse
        Dim objWSFE As New wsfev1t.Service
        objFEAuthRequest.Cuit = cuit
        objFEAuthRequest.Token = token
        objFEAuthRequest.Sign = sign

        codeerr = ""
        msgerr = ""
        UltimoNumeroTESTv1 = ""
        ' Invoco al metodo FERecuperaLastCMPRequest
        Try
            objFERecuperaLastCbteResponse = objWSFE.FECompUltimoAutorizado(objFEAuthRequest, CInt(punto_vta), CInt(tipo_cbte))
            'objFERecuperaLastCbteResponseErrors = objFERecuperaLastCbteResponse.Errors.
            'index = UBound(objFERecuperaLastCbteResponse.Errors)
            UltimoNumeroTESTv1 = objFERecuperaLastCbteResponse.CbteNro
            If Not objFERecuperaLastCbteResponse.Errors Is Nothing Then
                UltimoNumeroTESTv1 = UltimoNumeroTESTv1 & vbCrLf & "Error Code: " & objFERecuperaLastCbteResponse.Errors(0).Code
                UltimoNumeroTESTv1 = UltimoNumeroTESTv1 & vbCrLf & "Error Msg: " & objFERecuperaLastCbteResponse.Errors(0).Msg
            End If
            'MsgBox(UltimoNumeroTESTv1)
        Catch ex As Exception
            codeerr = "-300"
            msgerr = ex.Message
        End Try

    End Function
    Public Function ObtieneTicket( _
        ByVal strProdMode1 As String, _
        ByVal strUrlWsaaWsdl1 As String, _
        ByVal strIdServicioNegocio1 As String, _
        ByVal strRutaCertSigner1 As String, _
        ByVal strPasswordSecureString1 As String, _
        ByVal strProxy1 As String, _
        ByVal strProxyUser1 As String, _
        ByVal strProxyPassword1 As String, _
        ByRef UniqueID1 As String, _
        ByVal Service1 As String, _
        ByRef GenerationTime1 As String, _
        ByRef ExpirationTime1 As String, _
        ByRef Sign1 As String, _
        ByRef Token1 As String, _
        ByRef strError As String, _
        Optional ByVal DifGMTBA As Integer = 3) As Integer

        Dim strUrlWsaaWsdl As String = DEFAULT_URLWSAAWSDLTEST
        Dim strIdServicioNegocio As String = DEFAULT_SERVICIO
        Dim strRutaCertSigner As String = DEFAULT_CERTSIGNER
        Dim strPasswordSecureString As New SecureString
        Dim strProxy As String = DEFAULT_PROXY
        Dim strProxyUser As String = DEFAULT_PROXY_USER
        Dim strProxyPassword As String = DEFAULT_PROXY_PASSWORD
        Dim blnVerboseMode As Boolean = DEFAULT_VERBOSE
        Dim blnProdMode As Boolean
        Dim UniqueId As String ' Entero de 32 bits sin signo que identifica el requerimiento
        Dim GenerationTime As DateTime ' Momento en que fue generado el requerimiento
        Dim ExpirationTime As DateTime ' Momento en el que exoira la solicitud
        Dim Service As String ' Identificacion del WSN para el cual se solicita el TA
        Dim Sign As String ' Firma de seguridad recibida en la respuesta
        Dim Token As String ' Token de seguridad recibido en la respuesta
        Dim sError As String

        If Val(strProdMode1) = 0 Then
            blnProdMode = False
        Else
            blnProdMode = True
        End If

        If blnProdMode Then
            If strUrlWsaaWsdl1 = "" Then
                strUrlWsaaWsdl1 = DEFAULT_URLWSAAWSDLPROD
            End If
        End If
        ' Analizo parámetros

        If strUrlWsaaWsdl1 = "" Then
            strError = "Error: no se especificó la URL del WSDL del WSAA"
            Return -1
        ElseIf strIdServicioNegocio1 = "" Then
            strError = "Error: no se especificó el ID del servicio de negocio"
            Return -1
        ElseIf strRutaCertSigner1 = "" Then
            strError = "Error: no se especificó ruta del certificado firmante"
            Return -1
        ElseIf strPasswordSecureString1 = "" Then
            strError = "Error: no se especificó password del certificado firmante"
            Return -1
        End If

        For Each character As Char In strPasswordSecureString1.ToCharArray
            strPasswordSecureString.AppendChar(character)
        Next
        strPasswordSecureString.MakeReadOnly()

        strUrlWsaaWsdl = strUrlWsaaWsdl1
        strIdServicioNegocio = strIdServicioNegocio1
        strRutaCertSigner = strRutaCertSigner1

        ' Parámetros OK, entonces procesar normalmente...

        Dim objTicketRespuesta As LoginTicket
        Dim strTicketRespuesta As String

        Try

            objTicketRespuesta = New LoginTicket

            strTicketRespuesta = objTicketRespuesta.ObtenerLoginTicketResponse(strIdServicioNegocio, strUrlWsaaWsdl, strRutaCertSigner, strPasswordSecureString, strProxy, strProxyUser, strProxyPassword, UniqueId, GenerationTime, ExpirationTime, Sign, Token, sError, DifGMTBA)

            strError = sError
            If strTicketRespuesta = "" Then
                Return -20
            End If
        Catch excepcionAlObtenerTicket As Exception
            'MsgBox("***EXCEPCION AL OBTENER TICKET:" & excepcionAlObtenerTicket.Message)
            strError = "***EXCEPCION AL OBTENER TICKET:" & excepcionAlObtenerTicket.Message
            Return -10

        End Try
        UniqueID1 = CStr(UniqueId)
        GenerationTime1 = Format(GenerationTime, "yyyyMMdd HH:mm:ss:fff")
        ExpirationTime1 = Format(ExpirationTime, "yyyyMMdd HH:mm:ss:fff")
        Sign1 = Sign
        Token1 = Token
        Return 0
    End Function
    Public Function gGrabaLog(ByVal Texto As String)
        Dim strArchivo As String

        strArchivo = "ACA_WSFE.LOG"

        My.Computer.FileSystem.WriteAllText(strArchivo, "Hora : " & CStr(Now()) & " " & Texto & ControlChars.CrLf, True)

    End Function
    Public Function ObtieneCAEPROD(ByVal cuit As String, _
        ByVal strId As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal strcantidadreg As String, _
        ByVal presta_serv As String, _
        ByVal tipo_doc As String, _
        ByVal nro_doc As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByRef cbt_desde As String, _
        ByRef cbt_hasta As String, _
        ByVal imp_total As String, _
        ByVal imp_tot_conc As String, _
        ByVal imp_neto As String, _
        ByVal impto_liq As String, _
        ByVal impto_liq_rni As String, _
        ByVal imp_op_ex As String, _
        ByVal fecha_cbte As String, _
        ByVal fecha_serv_desde As String, _
        ByVal fecha_serv_hasta As String, _
        ByVal fecha_venc_pago As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, _
        ByRef desc_rechazo As String, _
        ByRef codeerr As String, _
        ByRef msgerr As String, _
        ByRef reproceso As String) As Boolean

        Dim objWSFE As New wswprod.Service
        Dim objFEAuthRequest As New wswprod.FEAuthRequest

        Dim cantidadreg As Integer = 1
        Dim indicemax As Integer = 0
        Dim d As Integer = 0
        Dim ii As Integer

        Dim objFERequest As New wswprod.FERequest
        Dim objFECabeceraRequest As New wswprod.FECabeceraRequest
        Dim ArrayOfFEDetalleRequest(indicemax) As wswprod.FEDetalleRequest
        Dim objFEResponse As New wswprod.FEResponse
        Dim ArrayOfFEDetalleResponse(indicemax) As wswprod.FEDetalleResponse
        objFEAuthRequest.cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFECabeceraRequest.id = strId
        objFECabeceraRequest.cantidadreg = Val(strcantidadreg)
        objFECabeceraRequest.presta_serv = presta_serv
        objFERequest.Fecr = objFECabeceraRequest

        'Obtengo los datos del DataGridView DGV_FEDetalleRequest
        For d = 0 To (indicemax)
            Dim objFEDetalleRequest As New wswprod.FEDetalleRequest
            With objFEDetalleRequest
                .tipo_doc = Val(tipo_doc)
                .nro_doc = Val(nro_doc)
                .tipo_cbte = Val(tipo_cbte)
                .punto_vta = Val(punto_vta)
                .cbt_desde = Val(cbt_desde)
                .cbt_hasta = Val(cbt_hasta)
                .imp_total = Val(imp_total)
                .imp_tot_conc = Val(imp_tot_conc)
                .imp_neto = Val(imp_neto)
                .impto_liq = Val(impto_liq)
                .impto_liq_rni = Val(impto_liq_rni)
                .imp_op_ex = Val(imp_op_ex)
                .fecha_cbte = fecha_cbte
                If presta_serv > "1" Then
                    .fecha_serv_desde = fecha_serv_desde
                    .fecha_serv_hasta = fecha_serv_hasta
                    .fecha_venc_pago = fecha_venc_pago
                End If
            End With
            ArrayOfFEDetalleRequest(d) = objFEDetalleRequest
        Next d
        objFERequest.Fedr = ArrayOfFEDetalleRequest

        ' Invoco al método FEAutRequest
        Try
            objFEResponse = objWSFE.FEAutRequest(objFEAuthRequest, objFERequest)
            codeerr = objFEResponse.RError.percode.ToString
            msgerr = objFEResponse.RError.perrmsg
            If objFEResponse.FecResp Is Nothing Then
                desc_rechazo = objFEResponse.RError.perrmsg
                ObtieneCAEPROD = False
            Else
                ii = objFEResponse.FecResp.cantidadreg
                reproceso = objFEResponse.FecResp.reproceso
                For d = 0 To (ii - 1)
                    'If objFEResponse.FedResp(d) Is not Nothing Then
                    cbte_estado = objFEResponse.FedResp(d).resultado
                    vencimiento_cae = IIf(objFEResponse.FedResp(d).fecha_vto = "NULL", "", objFEResponse.FedResp(d).fecha_vto)
                    cbte_cae = IIf(objFEResponse.FedResp(d).cae = "NULL", "", objFEResponse.FedResp(d).cae)
                    If objFEResponse.FecResp.reproceso = "S" Then
                        cbt_desde = objFEResponse.FedResp(d).cbt_desde.ToString
                        cbt_hasta = objFEResponse.FedResp(d).cbt_hasta.ToString
                    End If
                    motivo_rechazo = IIf(objFEResponse.FedResp(d).motivo = "NULL", "", objFEResponse.FedResp(d).motivo)
                    desc_rechazo = objFEResponse.RError.perrmsg
                    ObtieneCAEPROD = True
                    'Else
                    'cbte_estado = objFEResponse.FecResp.resultado
                    'desc_rechazo = "FEResponse.FecResp.motivo: " + objFEResponse.FecResp.motivo + vbCrLf + _
                    '"FEResponse.FecResp.reproceso: " + objFEResponse.FecResp.reproceso + vbCrLf + _
                    '"FEResponse.FecResp.resultado: " + objFEResponse.FecResp.resultado
                    'For d = 0 To (indicemax)
                    '   desc_rechazo = "FEResponse.FedResp(" + d.ToString + ").cae: " + objFEResponse.FedResp(d).cae.ToString + vbCrLf + _
                    '   "FEResponse.FedResp(" + d.ToString + ").resultado: " + objFEResponse.FedResp(d).resultado
                    'Next d
                    'desc_rechazo = "FEResponse.RError.percode: " + objFEResponse.RError.percode.ToString + vbCrLf + _
                    '"FEResponse.RError.perrmsg: " + objFEResponse.RError.perrmsg
                    'End If
                Next d
            End If
        Catch ex As Exception
            desc_rechazo = ex.Message
            ObtieneCAEPROD = False
        End Try

        ' Obtengo los XML de request/response y los escribo en el disco
        'Dim writer1 As New XmlSerializer(GetType(wswprod.FERequest))
        'Dim file1 As New StreamWriter("C:\wsfe_FERequest.xml")
        'writer1.Serialize(file1, objFERequest)
        'file1.Close()
        'Dim writer2 As New XmlSerializer(GetType(wswprod.FEResponse))
        'Dim file2 As New StreamWriter("C:\wsfe_FEResponse.xml")
        'writer2.Serialize(file2, objFEResponse)
        'file2.Close()
    End Function
    Public Function ObtieneCAEPROD2(ByVal cuit As String, _
        ByVal strId As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal strcantidadreg As String, _
        ByVal presta_serv As String, _
        ByVal tipo_doc As String, _
        ByRef nro_doc As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByRef cbt_desde As String, _
        ByRef cbt_hasta As String, _
        ByRef imp_total As String, _
        ByVal imp_tot_conc As String, _
        ByVal imp_neto As String, _
        ByVal impto_liq As String, _
        ByVal impto_liq_rni As String, _
        ByVal imp_op_ex As String, _
        ByVal fecha_cbte As String, _
        ByVal fecha_serv_desde As String, _
        ByVal fecha_serv_hasta As String, _
        ByVal fecha_venc_pago As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, _
        ByRef desc_rechazo As String, _
        ByRef codeerr As String, _
        ByRef msgerr As String, _
        ByRef reproceso As String) As Boolean

        Dim objWSFE As New wswprod.Service
        Dim objFEAuthRequest As New wswprod.FEAuthRequest

        Dim cantidadreg As Integer = 1
        Dim indicemax As Integer = 0
        Dim d As Integer = 0
        Dim ii As Integer

        Dim objFERequest As New wswprod.FERequest
        Dim objFECabeceraRequest As New wswprod.FECabeceraRequest
        Dim ArrayOfFEDetalleRequest(indicemax) As wswprod.FEDetalleRequest
        Dim objFEResponse As New wswprod.FEResponse
        Dim ArrayOfFEDetalleResponse(indicemax) As wswprod.FEDetalleResponse
        objFEAuthRequest.cuit = cuit
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFECabeceraRequest.id = strId
        objFECabeceraRequest.cantidadreg = Val(strcantidadreg)
        objFECabeceraRequest.presta_serv = presta_serv
        objFERequest.Fecr = objFECabeceraRequest

        'Obtengo los datos del DataGridView DGV_FEDetalleRequest
        For d = 0 To (indicemax)
            Dim objFEDetalleRequest As New wswprod.FEDetalleRequest
            With objFEDetalleRequest
                .tipo_doc = Val(tipo_doc)
                .nro_doc = Val(nro_doc)
                .tipo_cbte = Val(tipo_cbte)
                .punto_vta = Val(punto_vta)
                .cbt_desde = Val(cbt_desde)
                .cbt_hasta = Val(cbt_hasta)
                .imp_total = Val(imp_total)
                .imp_tot_conc = Val(imp_tot_conc)
                .imp_neto = Val(imp_neto)
                .impto_liq = Val(impto_liq)
                .impto_liq_rni = Val(impto_liq_rni)
                .imp_op_ex = Val(imp_op_ex)
                .fecha_cbte = fecha_cbte
                If presta_serv > "1" Then
                    .fecha_serv_desde = fecha_serv_desde
                    .fecha_serv_hasta = fecha_serv_hasta
                    .fecha_venc_pago = fecha_venc_pago
                End If
            End With
            ArrayOfFEDetalleRequest(d) = objFEDetalleRequest
        Next d
        objFERequest.Fedr = ArrayOfFEDetalleRequest

        ' Invoco al método FEAutRequest
        Try
            objFEResponse = objWSFE.FEAutRequest(objFEAuthRequest, objFERequest)
            codeerr = objFEResponse.RError.percode.ToString
            msgerr = objFEResponse.RError.perrmsg
            If objFEResponse.FecResp Is Nothing Then
                desc_rechazo = objFEResponse.RError.perrmsg
                ObtieneCAEPROD2 = False
            Else
                ii = objFEResponse.FecResp.cantidadreg
                reproceso = objFEResponse.FecResp.reproceso
                For d = 0 To (ii - 1)
                    'If objFEResponse.FedResp(d) Is not Nothing Then
                    nro_doc = objFEResponse.FedResp(d).nro_doc.ToString
                    imp_total = Replace(objFEResponse.FedResp(d).imp_total.ToString, ",", ".")
                    cbte_estado = objFEResponse.FedResp(d).resultado
                    vencimiento_cae = IIf(objFEResponse.FedResp(d).fecha_vto = "NULL", "", objFEResponse.FedResp(d).fecha_vto)
                    cbte_cae = IIf(objFEResponse.FedResp(d).cae = "NULL", "", objFEResponse.FedResp(d).cae)
                    If objFEResponse.FecResp.reproceso = "S" Then
                        cbt_desde = objFEResponse.FedResp(d).cbt_desde.ToString
                        cbt_hasta = objFEResponse.FedResp(d).cbt_hasta.ToString
                    End If
                    motivo_rechazo = IIf(objFEResponse.FedResp(d).motivo = "NULL", "", objFEResponse.FedResp(d).motivo)
                    desc_rechazo = objFEResponse.RError.perrmsg
                    ObtieneCAEPROD2 = True
                    'Else
                    'cbte_estado = objFEResponse.FecResp.resultado
                    'desc_rechazo = "FEResponse.FecResp.motivo: " + objFEResponse.FecResp.motivo + vbCrLf + _
                    '"FEResponse.FecResp.reproceso: " + objFEResponse.FecResp.reproceso + vbCrLf + _
                    '"FEResponse.FecResp.resultado: " + objFEResponse.FecResp.resultado
                    'For d = 0 To (indicemax)
                    '   desc_rechazo = "FEResponse.FedResp(" + d.ToString + ").cae: " + objFEResponse.FedResp(d).cae.ToString + vbCrLf + _
                    '   "FEResponse.FedResp(" + d.ToString + ").resultado: " + objFEResponse.FedResp(d).resultado
                    'Next d
                    'desc_rechazo = "FEResponse.RError.percode: " + objFEResponse.RError.percode.ToString + vbCrLf + _
                    '"FEResponse.RError.perrmsg: " + objFEResponse.RError.perrmsg
                    'End If
                Next d
            End If
        Catch ex As Exception
            desc_rechazo = ex.Message
            ObtieneCAEPROD2 = False
        End Try

        ' Obtengo los XML de request/response y los escribo en el disco
        'Dim writer1 As New XmlSerializer(GetType(wswprod.FERequest))
        'Dim file1 As New StreamWriter("C:\wsfe_FERequest.xml")
        'writer1.Serialize(file1, objFERequest)
        'file1.Close()
        'Dim writer2 As New XmlSerializer(GetType(wswprod.FEResponse))
        'Dim file2 As New StreamWriter("C:\wsfe_FEResponse.xml")
        'writer2.Serialize(file2, objFEResponse)
        'file2.Close()
    End Function
    Public Function UltimoIDTEST(ByVal cuit As String, ByVal token As String, ByVal sign As String, ByRef codeerr As String, ByRef msgerr As String) As String
        Dim objFEUltNroResponse As New wsw.FEUltNroResponse
        Dim objWSFE As New wsw.Service
        Dim objFEAuthRequest As New wsw.FEAuthRequest
        objFEAuthRequest.cuit = cuit
        objFEAuthRequest.Token = token
        objFEAuthRequest.Sign = sign

        codeerr = ""
        msgerr = ""
        '        UltimoIDTEST = "0"
        ' Invoco al método FEUltNroRequest
        Try
            objFEUltNroResponse = objWSFE.FEUltNroRequest(objFEAuthRequest)
            codeerr = objFEUltNroResponse.RError.percode.ToString
            msgerr = objFEUltNroResponse.RError.perrmsg
            If objFEUltNroResponse.nro Is Nothing Then
                codeerr = objFEUltNroResponse.RError.percode.ToString
                msgerr = objFEUltNroResponse.RError.perrmsg
            Else
                UltimoIDTEST = objFEUltNroResponse.nro.value.ToString
            End If
        Catch ex As Exception
            codeerr = "-200"
            msgerr = ex.Message
        End Try

    End Function
    Public Function UltimoIDPROD(ByVal cuit As String, ByVal token As String, ByVal sign As String, ByRef codeerr As String, ByRef msgerr As String) As String
        Dim objFEUltNroResponse As New wswprod.FEUltNroResponse
        Dim objWSFE As New wswprod.Service
        Dim objFEAuthRequest As New wswprod.FEAuthRequest
        objFEAuthRequest.cuit = cuit
        objFEAuthRequest.Token = token
        objFEAuthRequest.Sign = sign

        codeerr = ""
        msgerr = ""
        UltimoIDPROD = "0"
        ' Invoco al método FEUltNroRequest
        Try
            objFEUltNroResponse = objWSFE.FEUltNroRequest(objFEAuthRequest)
            codeerr = objFEUltNroResponse.RError.percode.ToString
            msgerr = objFEUltNroResponse.RError.perrmsg
            If objFEUltNroResponse.nro Is Nothing Then
                codeerr = objFEUltNroResponse.RError.percode.ToString
                msgerr = objFEUltNroResponse.RError.perrmsg
            Else
                UltimoIDPROD = objFEUltNroResponse.nro.value.ToString
            End If
        Catch ex As Exception
            codeerr = "-200"
            msgerr = ex.Message
        End Try

    End Function
    Public Function UltimoNumeroTEST(ByVal cuit As String, ByVal token As String, ByVal sign As String, _
            ByVal tipo_cbte As String, ByVal punto_vta As String, ByRef codeerr As String, _
            ByRef msgerr As String) As String
        Dim objFELastCMPtype As New wsw.FELastCMPtype
        Dim objFERecuperaLastCMPResponse As New wsw.FERecuperaLastCMPResponse
        Dim objFEAuthRequest As New wsw.FEAuthRequest
        Dim objWSFE As New wsw.Service
        objFEAuthRequest.cuit = cuit
        objFEAuthRequest.Token = token
        objFEAuthRequest.Sign = sign
        objFELastCMPtype.TipoCbte = tipo_cbte
        objFELastCMPtype.PtoVta = punto_vta

        codeerr = ""
        msgerr = ""
        UltimoNumeroTEST = ""
        ' Invoco al método FERecuperaLastCMPRequest
        Try
            objFERecuperaLastCMPResponse = objWSFE.FERecuperaLastCMPRequest(objFEAuthRequest, objFELastCMPtype)
            UltimoNumeroTEST = objFERecuperaLastCMPResponse.cbte_nro.ToString
            codeerr = objFERecuperaLastCMPResponse.RError.percode.ToString
            msgerr = objFERecuperaLastCMPResponse.RError.perrmsg
        Catch ex As Exception
            codeerr = "-300"
            msgerr = ex.Message
        End Try

    End Function
    Public Function UltimoNumeroPROD(ByVal cuit As String, ByVal token As String, ByVal sign As String, _
            ByVal tipo_cbte As String, ByVal punto_vta As String, ByRef codeerr As String, _
            ByRef msgerr As String) As String
        Dim objFELastCMPtype As New wswprod.FELastCMPtype
        Dim objFERecuperaLastCMPResponse As New wswprod.FERecuperaLastCMPResponse
        Dim objFEAuthRequest As New wswprod.FEAuthRequest
        Dim objWSFE As New wswprod.Service
        objFEAuthRequest.cuit = cuit
        objFEAuthRequest.Token = token
        objFEAuthRequest.Sign = sign
        objFELastCMPtype.TipoCbte = tipo_cbte
        objFELastCMPtype.PtoVta = punto_vta

        codeerr = ""
        msgerr = ""
        UltimoNumeroPROD = ""
        ' Invoco al método FERecuperaLastCMPRequest
        Try
            objFERecuperaLastCMPResponse = objWSFE.FERecuperaLastCMPRequest(objFEAuthRequest, objFELastCMPtype)
            UltimoNumeroPROD = objFERecuperaLastCMPResponse.cbte_nro.ToString
            codeerr = objFERecuperaLastCMPResponse.RError.percode.ToString
            msgerr = objFERecuperaLastCMPResponse.RError.perrmsg
        Catch ex As Exception
            codeerr = "-300"
            msgerr = ex.Message
        End Try

    End Function
    Public Function EnviarMail(ByVal CorreoServer As String, ByVal CorreoCuenta As String, ByVal CorreoUser As String, _
        ByVal CorreoPassword As String, ByVal CorreoPort As Integer, ByVal CorreoSSLSecurity As Integer, _
        ByVal CorreoResponderA As String, ByVal CorreoEnviarA As String, ByVal sMensaje As String, ByVal sAsunto As String, _
        ByVal sFactura As String, ByVal sRemito As String, ByVal sRecibo As String, ByVal sFaltantes As String) As Boolean

        Dim fileAttch = New ArrayList

        If FileExists(sFactura) Then
            fileAttch.Add(sFactura)
        End If
        If FileExists(sRemito) Then
            fileAttch.Add(sRemito)
        End If
        If FileExists(sRecibo) Then
            fileAttch.Add(sRecibo)
        End If
        If FileExists(sFaltantes) Then
            fileAttch.Add(sFaltantes)
        End If

        Dim SMTPServer As New SmtpClient(CorreoServer)
        SMTPServer.Credentials = New System.Net.NetworkCredential(CorreoUser, CorreoPassword)
        If CorreoSSLSecurity = 0 Then
            SMTPServer.EnableSsl = False
        Else
            SMTPServer.EnableSsl = True
        End If
        SMTPServer.Port = CorreoPort

        Dim oMsg As MailMessage = New MailMessage()

        oMsg.From = New MailAddress(CorreoCuenta)

        If CorreoEnviarA.Contains(";") Then
            Dim emailList As String()
            emailList = CorreoEnviarA.Split(";")
            For Each email As String In emailList
                oMsg.To.Add(email)
            Next
        Else
            oMsg.To.Add(CorreoEnviarA)
        End If

        oMsg.Subject = sAsunto

        oMsg.ReplyTo = New MailAddress(CorreoResponderA)
        oMsg.Body = sMensaje
        oMsg.IsBodyHtml = True
        Dim i As Integer
        Dim oAttch As System.Net.Mail.Attachment
        For i = 0 To fileAttch.Count - 1
            oAttch = New Net.Mail.Attachment(fileAttch(i))
            oMsg.Attachments.Add(oAttch)
        Next
        SMTPServer.Send(oMsg)

        EnviarMail = True
    End Function
    Private Shared Function FileExists(ByVal FileFullPath As String) As Boolean

        If Trim(FileFullPath) = "" Then Return False

        Dim f As New IO.FileInfo(FileFullPath)

        Return f.Exists

    End Function

End Class
Class LoginTicket

    Public UniqueId As UInt32 ' Entero de 32 bits sin signo que identifica el requerimiento
    Public GenerationTime As DateTime ' Momento en que fue generado el requerimiento
    Public ExpirationTime As DateTime ' Momento en el que exoira la solicitud
    Public Service As String ' Identificacion del WSN para el cual se solicita el TA
    Public Sign As String ' Firma de seguridad recibida en la respuesta
    Public Token As String ' Token de seguridad recibido en la respuesta

    Public XmlLoginTicketRequest As XmlDocument = Nothing
    Public XmlLoginTicketResponse As XmlDocument = Nothing
    Public RutaDelCertificadoFirmante As String
    Public XmlStrLoginTicketRequestTemplate As String = "<loginTicketRequest><header><uniqueId></uniqueId><generationTime></generationTime><expirationTime></expirationTime></header><service></service></loginTicketRequest>"

    Private Shared _globalUniqueID As UInt32 = 0 ' OJO! NO ES THREAD-SAFE

    ''' <summary>
    ''' Construye un Login Ticket obtenido del WSAA
    ''' </summary>
    ''' <param name="argServicio">Servicio al que se desea acceder</param>
    ''' <param name="argUrlWsaa">URL del WSAA</param>
    ''' <param name="argRutaCertX509Firmante">Ruta del certificado X509 (con clave privada) usado para firmar</param>
    ''' <param name="argPassword">Password del certificado X509 (con clave privada) usado para firmar</param>
    ''' <param name="argProxy">IP:port del proxy</param>
    ''' <param name="argProxyUser">Usuario del proxy</param>''' 
    ''' <param name="argProxyPassword">Password del proxy</param>
    ''' <remarks></remarks>
    Public Function ObtenerLoginTicketResponse( _
    ByVal argServicio As String, _
    ByVal argUrlWsaa As String, _
    ByVal argRutaCertX509Firmante As String, _
    ByVal argPassword As SecureString, _
    ByVal argProxy As String, _
    ByVal argProxyUser As String, _
    ByVal argProxyPassword As String, _
    ByRef UniqueID1 As String, _
    ByRef GenerationTime1 As DateTime, _
    ByRef ExpirationTime1 As DateTime, _
    ByRef Sign1 As String, _
    ByRef Token1 As String, _
    ByRef sError As String, _
    ByVal DifGMTBA As Integer _
    ) As String

        Me.RutaDelCertificadoFirmante = argRutaCertX509Firmante

        Dim cmsFirmadoBase64 As String
        Dim loginTicketResponse As String
        Dim xmlNodoUniqueId As XmlNode
        Dim xmlNodoGenerationTime As XmlNode
        Dim xmlNodoExpirationTime As XmlNode
        Dim xmlNodoService As XmlNode
        Dim FechaUTC As DateTime
        Dim GenerationTimex As String
        Dim ExpirationTimex As String

        sError = "OK"

        ' PASO 1: Genero el Login Ticket Request
        Try
            _globalUniqueID += 1

            XmlLoginTicketRequest = New XmlDocument()
            XmlLoginTicketRequest.LoadXml(XmlStrLoginTicketRequestTemplate)

            xmlNodoUniqueId = XmlLoginTicketRequest.SelectSingleNode("//uniqueId")
            xmlNodoGenerationTime = XmlLoginTicketRequest.SelectSingleNode("//generationTime")
            xmlNodoExpirationTime = XmlLoginTicketRequest.SelectSingleNode("//expirationTime")
            xmlNodoService = XmlLoginTicketRequest.SelectSingleNode("//service")

            FechaUTC = DateTime.UtcNow.AddHours(-DifGMTBA)
            xmlNodoGenerationTime.InnerText = FechaUTC.AddMinutes(-10).ToString("s")
            xmlNodoExpirationTime.InnerText = FechaUTC.AddMinutes(+10).ToString("s")
            xmlNodoUniqueId.InnerText = CStr(_globalUniqueID)
            xmlNodoService.InnerText = argServicio
            Me.Service = argServicio

        Catch excepcionAlGenerarLoginTicketRequest As Exception
            sError = "***Error GENERANDO el LoginTicketRequest : " + excepcionAlGenerarLoginTicketRequest.Message
            'Throw New Exception("***Error GENERANDO el LoginTicketRequest : " + excepcionAlGenerarLoginTicketRequest.Message + excepcionAlGenerarLoginTicketRequest.StackTrace)
            Return ""
        End Try

        ' PASO 2: Firmo el Login Ticket Request
        Try
            Dim certFirmante As X509Certificate2 = CertificadosX509Lib.ObtieneCertificadoDesdeArchivo(RutaDelCertificadoFirmante, argPassword)

            ' Convierto el login ticket request a bytes, para firmar
            Dim EncodedMsg As Encoding = Encoding.UTF8
            Dim msgBytes As Byte() = EncodedMsg.GetBytes(XmlLoginTicketRequest.OuterXml)

            ' Firmo el msg y paso a Base64
            Dim encodedSignedCms As Byte() = CertificadosX509Lib.FirmaBytesMensaje(msgBytes, certFirmante)
            cmsFirmadoBase64 = Convert.ToBase64String(encodedSignedCms)

        Catch excepcionAlFirmar As Exception
            sError = "***Error FIRMANDO el LoginTicketRequest : " + excepcionAlFirmar.Message
            'Throw New Exception("***Error FIRMANDO el LoginTicketRequest : " + excepcionAlFirmar.Message)
            Return ""
        End Try

        ' PASO 3: Invoco al WSAA para obtener el Login Ticket Response
        Try
            Dim servicioWsaa As New Wsaa.LoginCMSService()
            servicioWsaa.Url = argUrlWsaa
            If argProxy IsNot Nothing Then
                servicioWsaa.Proxy = New WebProxy(argProxy, True)
                If argProxyUser IsNot Nothing Then
                    Dim Credentials As New NetworkCredential(argProxyUser, argProxyPassword)
                    servicioWsaa.Proxy.Credentials = Credentials
                End If
            End If
            loginTicketResponse = servicioWsaa.loginCms(cmsFirmadoBase64)

        Catch excepcionAlInvocarWsaa As Exception
            'MsgBox("***Error INVOCANDO al servicio WSAA : " + excepcionAlInvocarWsaa.Message)
            sError = "***Error INVOCANDO al servicio WSAA : " + excepcionAlInvocarWsaa.Message
            'Throw New Exception("***Error INVOCANDO al servicio WSAA : " + excepcionAlInvocarWsaa.Message)
            Return ""
        End Try


        ' PASO 4: Analizo el Login Ticket Response recibido del WSAA
        Try
            XmlLoginTicketResponse = New XmlDocument()
            XmlLoginTicketResponse.LoadXml(loginTicketResponse)

            Me.UniqueId = UInt32.Parse(XmlLoginTicketResponse.SelectSingleNode("//uniqueId").InnerText)
            GenerationTimex = XmlLoginTicketResponse.SelectSingleNode("//generationTime").InnerText
            ExpirationTimex = XmlLoginTicketResponse.SelectSingleNode("//expirationTime").InnerText
            GenerationTimex = Mid(GenerationTimex, 1, 23)
            ExpirationTimex = Mid(ExpirationTimex, 1, 23)
            Me.GenerationTime = GenerationTimex
            Me.ExpirationTime = ExpirationTimex
            Me.Sign = XmlLoginTicketResponse.SelectSingleNode("//sign").InnerText
            Me.Token = XmlLoginTicketResponse.SelectSingleNode("//token").InnerText
            UniqueID1 = CStr(Me.UniqueId)
            GenerationTime1 = GenerationTime
            ExpirationTime1 = ExpirationTime
            Sign1 = Me.Sign
            Token1 = Me.Token
        Catch excepcionAlAnalizarLoginTicketResponse As Exception
            sError = "***Error ANALIZANDO el LoginTicketResponse : " + excepcionAlAnalizarLoginTicketResponse.Message
            'Throw New Exception("***Error ANALIZANDO el LoginTicketResponse : " + excepcionAlAnalizarLoginTicketResponse.Message)
            Return ""
        End Try

        Return loginTicketResponse

    End Function


End Class
Class CertificadosX509Lib

    Public Shared VerboseMode As Boolean = False

    ''' <summary>
    ''' Firma mensaje
    ''' </summary>
    ''' <param name="argBytesMsg">Bytes del mensaje</param>
    ''' <param name="argCertFirmante">Certificado usado para firmar</param>
    ''' <returns>Bytes del mensaje firmado</returns>
    ''' <remarks></remarks>
    Public Shared Function FirmaBytesMensaje( _
    ByVal argBytesMsg As Byte(), _
    ByVal argCertFirmante As X509Certificate2 _
    ) As Byte()
        Try
            ' Pongo el mensaje en un objeto ContentInfo (requerido para construir el obj SignedCms)
            Dim infoContenido As New ContentInfo(argBytesMsg)
            Dim cmsFirmado As New SignedCms(infoContenido)

            ' Creo objeto CmsSigner que tiene las caracteristicas del firmante
            Dim cmsFirmante As New CmsSigner(argCertFirmante)
            cmsFirmante.IncludeOption = X509IncludeOption.EndCertOnly

            ' Firmo el mensaje PKCS #7
            cmsFirmado.ComputeSignature(cmsFirmante)

            ' Encodeo el mensaje PKCS #7.
            Return cmsFirmado.Encode()
        Catch excepcionAlFirmar As Exception
            'Throw New Exception("***Error al firmar: " & excepcionAlFirmar.Message)
            Return Nothing
        End Try
    End Function

    ''' <summary>
    ''' Lee certificado de disco
    ''' </summary>
    ''' <param name="argArchivo">Ruta del certificado a leer.</param>
    ''' <returns>Un objeto certificado X509</returns>
    ''' <remarks></remarks>
    Public Shared Function ObtieneCertificadoDesdeArchivo( _
    ByVal argArchivo As String, _
    ByVal argPassword As SecureString _
    ) As X509Certificate2
        Dim objCert As New X509Certificate2
        Try
            If argPassword.IsReadOnly Then
                objCert.Import(My.Computer.FileSystem.ReadAllBytes(argArchivo), argPassword, X509KeyStorageFlags.PersistKeySet)
            Else
                objCert.Import(My.Computer.FileSystem.ReadAllBytes(argArchivo))
            End If
            Return objCert
        Catch excepcionAlImportarCertificado As Exception
            'Throw New Exception(excepcionAlImportarCertificado.Message & " " & excepcionAlImportarCertificado.StackTrace)
            Return Nothing
        End Try
    End Function
End Class
