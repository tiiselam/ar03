Imports System
Imports System.Collections.Generic
Imports System.Text
Imports System.Xml
Imports System.Xml.Serialization
Imports System.Xml.XmlException
Imports System.Net
Imports System.Data
Imports System.Security
Imports System.Security.Cryptography
Imports System.Security.Cryptography.Pkcs
Imports System.Security.Cryptography.X509Certificates
Imports System.IO
Imports System.Runtime.InteropServices
Imports Microsoft.VisualBasic.FileIO.FileSystem
Imports System.Net.Mail
Class Objetos
    Dim principal As New Main
    Function Cmps_asoc(ByVal strDetalle As String) As wsfex.Cmp_asoc()
        Dim linea As String() = strDetalle.Split(Chr(13))
        Dim oCmps_asoc(0) As wsfex.Cmp_asoc
        Dim f As Integer
        Dim t As Integer
        '*******************************************************
        t = linea.Length - 1
        If t > 1 Then
            ReDim oCmps_asoc(t - 1)
        End If
        For f = 1 To t
            principal.gGrabaLog(linea(t - 1))
            Dim aDatos As String() = linea(f - 1).Split("|")
            Dim _cmps_asoc As New wsfex.Cmp_asoc
            With _cmps_asoc
                .Cbte_cuit = aDatos.GetValue(0)
                principal.gGrabaLog(_cmps_asoc.Cbte_cuit.ToString)
                .Cbte_nro = aDatos.GetValue(1).ToString
                principal.gGrabaLog(_cmps_asoc.Cbte_nro.ToString)
                .Cbte_punto_vta = aDatos.GetValue(2).ToString
                principal.gGrabaLog(_cmps_asoc.Cbte_punto_vta.ToString)
                .Cbte_tipo = aDatos.GetValue(3).ToString
                principal.gGrabaLog(_cmps_asoc.Cbte_tipo.ToString)
            End With
            oCmps_asoc(f - 1) = _cmps_asoc
            Cmps_asoc = oCmps_asoc
        Next
    End Function
    Function Opcionales(ByVal strDetalle As String) As wsfex.Opcional()
        Dim linea As String() = strDetalle.Split(Chr(13))
        Dim oOpcionales(0) As wsfex.Opcional
        Dim f As Integer
        Dim t As Integer
        '*******************************************************
        t = linea.Length - 1
        If t > 1 Then
            ReDim oOpcionales(t - 1)
        End If
        For f = 1 To t
            principal.gGrabaLog(linea(t - 1))
            Dim aDatos As String() = linea(f - 1).Split("|")
            Dim _opcional As New wsfex.Opcional
            With _opcional
                .Id = aDatos.GetValue(0)
                principal.gGrabaLog(_opcional.Id)
                .Valor = aDatos.GetValue(1)
                principal.gGrabaLog(_opcional.Valor)
            End With
            oOpcionales(f - 1) = _opcional
            Opcionales = oOpcionales
        Next
    End Function
    Function Permisos(ByVal strDetalle As String) As wsfex.Permiso()
        Dim linea As String() = strDetalle.Split(Chr(13))
        Dim oPermisos(0) As wsfex.Permiso
        Dim f As Integer
        Dim t As Integer
        '*******************************************************
        t = linea.Length - 1
        If t > 1 Then
            ReDim oPermisos(t - 1)
        End If
        For f = 1 To t
            principal.gGrabaLog(linea(t - 1))
            Dim aDatos As String() = linea(f - 1).Split("|")
            Dim _Permiso As New wsfex.Permiso
            With _Permiso
                .Id_permiso = aDatos.GetValue(0)
                principal.gGrabaLog(_Permiso.Id_permiso)
                .Dst_merc = aDatos.GetValue(1).ToString
                principal.gGrabaLog(_Permiso.Dst_merc.ToString)
            End With
            oPermisos(f - 1) = _Permiso
            Permisos = oPermisos
        Next
    End Function

    Function Items(ByVal strDetalle As String) As wsfex.Item()
        Dim linea As String() = strDetalle.Split(Chr(13))
        Dim oitems(0) As wsfex.Item
        Dim f As Integer
        Dim t As Integer
        '*******************************************************
        t = linea.Length - 1
        If t > 1 Then
            ReDim oitems(t - 1)
        End If
        For f = 1 To t
            principal.gGrabaLog(linea(t - 1))
            Dim aDatos As String() = linea(f - 1).Split("|")
            Dim _items As New wsfex.Item
            With _items
                .Pro_codigo = aDatos.GetValue(0)
                principal.gGrabaLog(_items.Pro_codigo)
                .Pro_ds = aDatos.GetValue(1)
                principal.gGrabaLog(_items.Pro_ds)
                .Pro_umed = Val(aDatos.GetValue(2))
                principal.gGrabaLog(_items.Pro_umed.ToString)
                'If Val(aDatos.GetValue(3)) <> 0 Then
                .Pro_qty = Val(aDatos.GetValue(3))
                principal.gGrabaLog(_items.Pro_qty.ToString)
                'End If
                'If Val(aDatos.GetValue(4)) <> 0 Then
                .Pro_precio_uni = Val(aDatos.GetValue(4))
                principal.gGrabaLog(_items.Pro_precio_uni.ToString)
                'End If
                'If Val(aDatos.GetValue(5)) <> 0 Then
                .Pro_bonificacion = Val(aDatos.GetValue(5))
                principal.gGrabaLog(_items.Pro_bonificacion.ToString)
                'End If
                .Pro_total_item = Val(aDatos.GetValue(6))
                principal.gGrabaLog(_items.Pro_total_item.ToString)
            End With
            oitems(f - 1) = _items
            Items = oitems
        Next
    End Function
End Class

Class LoginTicket

    Public XmlLoginTicketRequest As XmlDocument = Nothing
    Public XmlLoginTicketResponse As XmlDocument = Nothing
    Public RutaDelCertificadoFirmante As String
    Public XmlStrLoginTicketRequestTemplate As String = "<loginTicketRequest><header><uniqueId></uniqueId><generationTime></generationTime><expirationTime></expirationTime></header><service></service></loginTicketRequest>"
    Private _verboseMode As Boolean = True
    Private Shared _globalUniqueID As UInt32 = 0 ' OJO! NO ES THREAD-SAFE

    ''' <summary>
    ''' Construye un Login Ticket obtenido del WSAA
    ''' </summary>
    ''' <param name="strIdServicioNegocio1">Servicio al que se desea acceder</param>
    ''' <param name="strUrlWsaaWsdl1">URL del WSAA</param>
    ''' <param name="strRutaCertSigner1">Ruta del certificado X509 (con clave privada) usado para firmar</param>
    ''' <param name="argPassword">Password del certificado X509 (con clave privada) usado para firmar</param>
    ''' <param name="argProxy1">IP:port del proxy</param>
    ''' <param name="argProxyUser1">Usuario del proxy</param>''' 
    ''' <param name="argProxyPassword1">Password del proxy</param>
    ''' <remarks></remarks>
    Public Function ObtenerLoginTicketResponse( _
    ByVal strIdServicioNegocio1 As String, _
    ByVal strUrlWsaaWsdl1 As String, _
    ByVal strRutaCertSigner1 As String, _
    ByVal argPassword As SecureString, _
    ByVal argProxy1 As String, _
    ByVal argProxyUser1 As String, _
    ByVal argProxyPassword1 As String, _
    ByRef UniqueId As String, _
    ByRef GenerationTime As Date, _
    ByRef ExpirationTime As Date, _
    ByRef Sign As String, _
    ByRef Token As String, _
    ByRef sErr As String _
    ) As String

        Const ID_FNC As String = "[ObtenerLoginTicketResponse]"

        Me.RutaDelCertificadoFirmante = strRutaCertSigner1
        Me._verboseMode = True
        CertificadosX509Lib.VerboseMode = True

        Dim cmsFirmadoBase64 As String
        Dim loginTicketResponse As String
        Dim xmlNodoUniqueId As XmlNode
        Dim xmlNodoGenerationTime As XmlNode
        Dim xmlNodoExpirationTime As XmlNode
        Dim xmlNodoService As XmlNode

        ' PASO 1: Genero el Login Ticket Request
        Try
            _globalUniqueID += 1

            XmlLoginTicketRequest = New XmlDocument()
            XmlLoginTicketRequest.LoadXml(XmlStrLoginTicketRequestTemplate)

            xmlNodoUniqueId = XmlLoginTicketRequest.SelectSingleNode("//uniqueId")
            xmlNodoGenerationTime = XmlLoginTicketRequest.SelectSingleNode("//generationTime")
            xmlNodoExpirationTime = XmlLoginTicketRequest.SelectSingleNode("//expirationTime")
            xmlNodoService = XmlLoginTicketRequest.SelectSingleNode("//service")
            xmlNodoGenerationTime.InnerText = DateTime.Now.AddMinutes(-10).ToString("s")
            xmlNodoExpirationTime.InnerText = DateTime.Now.AddMinutes(+10).ToString("s")
            xmlNodoUniqueId.InnerText = CStr(_globalUniqueID)
            xmlNodoService.InnerText = strIdServicioNegocio1

        Catch excepcionAlGenerarLoginTicketRequest As Exception
            sErr = excepcionAlGenerarLoginTicketRequest.Message
            Throw New Exception(ID_FNC + "***Error GENERANDO el LoginTicketRequest : " + excepcionAlGenerarLoginTicketRequest.Message + excepcionAlGenerarLoginTicketRequest.StackTrace)
            Return sErr
        End Try

        ' PASO 2: Firmo el Login Ticket Request
        Try

            Dim certFirmante As X509Certificate2 = CertificadosX509Lib.ObtieneCertificadoDesdeArchivo(RutaDelCertificadoFirmante, argPassword)


            ' Convierto el login ticket request a bytes, firmo el msg y convierto a Base64
            Dim EncodedMsg As Encoding = Encoding.UTF8
            Dim msgBytes As Byte() = EncodedMsg.GetBytes(XmlLoginTicketRequest.OuterXml)
            Dim encodedSignedCms As Byte() = CertificadosX509Lib.FirmaBytesMensaje(msgBytes, certFirmante)
            cmsFirmadoBase64 = Convert.ToBase64String(encodedSignedCms)

        Catch excepcionAlFirmar As Exception
            sErr = excepcionAlFirmar.Message
            Throw New Exception(ID_FNC + "***Error FIRMANDO el LoginTicketRequest: " + excepcionAlFirmar.Message)
            Return ""
        End Try

        ' PASO 3: Invoco al WSAA para obtener el Login Ticket Response
        Try

            Dim servicioWsaa As New wsaa.LoginCMSService()
            With servicioWsaa
                .Url = strUrlWsaaWsdl1
            End With

            ' Veo si hay que salir a traves de un proxy
            If argProxy1 <> "" Then
                servicioWsaa.Proxy = New WebProxy(argProxy1, True)
                If argProxyUser1 IsNot Nothing Then
                    Dim Credentials As New NetworkCredential(argProxyUser1, argProxyPassword1)
                    servicioWsaa.Proxy.Credentials = Credentials
                End If
            End If

            loginTicketResponse = servicioWsaa.loginCms(cmsFirmadoBase64)

        Catch excepcionAlInvocarWsaa As Exception
            sErr = excepcionAlInvocarWsaa.Message
            Throw New Exception(ID_FNC + "***Error INVOCANDO al servicio WSAA: " + excepcionAlInvocarWsaa.Message)
            Return ""
        End Try
        ' PASO 4: Analizo el Login Ticket Response recibido del WSAA
        Try
            XmlLoginTicketResponse = New XmlDocument()
            XmlLoginTicketResponse.LoadXml(loginTicketResponse)

            UniqueId = UInt32.Parse(XmlLoginTicketResponse.SelectSingleNode("//uniqueId").InnerText)
            Dim GenerationTimex As String = XmlLoginTicketResponse.SelectSingleNode("//generationTime").InnerText
            Dim ExpirationTimex As String = XmlLoginTicketResponse.SelectSingleNode("//expirationTime").InnerText
            GenerationTimex = Mid(GenerationTimex, 1, 23)
            ExpirationTimex = Mid(ExpirationTimex, 1, 23)
            GenerationTime = GenerationTimex
            ExpirationTime = ExpirationTimex
            Sign = XmlLoginTicketResponse.SelectSingleNode("//sign").InnerText
            Token = XmlLoginTicketResponse.SelectSingleNode("//token").InnerText

        Catch excepcionAlAnalizarLoginTicketResponse As Exception
            sErr = excepcionAlAnalizarLoginTicketResponse.Message
            Throw New Exception(ID_FNC + "***Error ANALIZANDO el LoginTicketResponse: " + excepcionAlAnalizarLoginTicketResponse.Message)
            Return ""
        End Try
        Return loginTicketResponse

    End Function

End Class
Public Class Main
    
    Public Function ObtieneLastID(ByVal strToken As String, _
                                ByVal strSign As String, _
                                ByVal cuit As String, _
                                ByVal strUrl As String) As String

        Dim objWSFEX As New FEEXP.wsfex.Service()

        Dim FEXAuthorize_Auth As New FEEXP.wsfex.ClsFEXAuthRequest
        FEXAuthorize_Auth.Token = strToken
        FEXAuthorize_Auth.Sign = strSign
        FEXAuthorize_Auth.Cuit = Val(cuit)
        Try
            objWSFEX.Url = strUrl
            Dim FEXResponse_LastID As New FEEXP.wsfex.FEXResponse_LastID
            FEXResponse_LastID = objWSFEX.FEXGetLast_ID(FEXAuthorize_Auth)

            If FEXResponse_LastID.FEXResultGet Is Nothing Then
                ObtieneLastID = ""
            Else
                If FEXResponse_LastID.FEXErr.ErrCode = 0 Then
                    ObtieneLastID = FEXResponse_LastID.FEXResultGet.Id.ToString
                Else
                    MsgBox("Error al obtener siguiente Id de Comprobante en la AFIP.")
                    ObtieneLastID = "-1"
                End If
            End If
        Catch ex As Exception
            ObtieneLastID = ""
            Throw New Exception("***Error ObtieneLastID: " + ex.Message)
        End Try

    End Function
    Public Function ObtieneLastICbte(ByVal strToken As String, _
                            ByVal strSign As String, _
                            ByVal cuit As String, _
                            ByVal strUrl As String, _
                            ByVal Punto_vta As String, _
                            ByVal Cbte_Tipo As String) As String

        Dim objWSFEX As New FEEXP.wsfex.Service()

        Dim FEXAuthorize_Auth As New FEEXP.wsfex.ClsFEX_LastCMP
        FEXAuthorize_Auth.Token = strToken
        FEXAuthorize_Auth.Sign = strSign
        FEXAuthorize_Auth.Cuit = Val(cuit)
        FEXAuthorize_Auth.Pto_venta = Val(Punto_vta)
        FEXAuthorize_Auth.Cbte_Tipo = Val(Cbte_Tipo)
        Try
            objWSFEX.Url = strUrl
            Dim FEXResponseLast_CMP As New FEEXP.wsfex.FEXResponseLast_CMP
            FEXResponseLast_CMP = objWSFEX.FEXGetLast_CMP(FEXAuthorize_Auth)
            If FEXResponseLast_CMP.FEXResult_LastCMP Is Nothing Then
                ObtieneLastICbte = ""
            Else
                ObtieneLastICbte = FEXResponseLast_CMP.FEXResult_LastCMP.Cbte_nro.ToString
            End If
        Catch ex As Exception
            ObtieneLastICbte = ""
            Throw New Exception("***Error ObtieneLastID: " + ex.Message)
        End Try

    End Function
    Public Function ObtieneMoneda(ByVal strToken As String, _
                                ByVal strSign As String, _
                                ByVal cuit As String) As String

        Dim objWSFE As New wsfex.Service()
        Dim FEXAuthorize_Auth As New wsfex.ClsFEXAuthRequest
        FEXAuthorize_Auth.Token = strToken
        FEXAuthorize_Auth.Sign = strSign
        FEXAuthorize_Auth.Cuit = Val(cuit)
        Dim objFEXResponse_Mon As wsfex.FEXResponse_Mon
        ObtieneMoneda = ""
        Try
            objFEXResponse_Mon = objWSFE.FEXGetPARAM_MON(FEXAuthorize_Auth)

            If objFEXResponse_Mon.FEXResultGet Is Nothing Then
                ObtieneMoneda = "||" + objFEXResponse_Mon.FEXErr.ErrMsg + "|" + _
                objFEXResponse_Mon.FEXEvents.EventMsg + "|" + Chr(3)
            Else
                For Each item As wsfex.ClsFEXResponse_Mon In objFEXResponse_Mon.FEXResultGet
                    ObtieneMoneda = ObtieneMoneda + Str(item.Mon_Id) + "|" + item.Mon_Ds + "|||" + Chr(13)
                Next
                ObtieneMoneda = ObtieneMoneda + "||" + objFEXResponse_Mon.FEXErr.ErrMsg + "|" + objFEXResponse_Mon.FEXEvents.EventMsg + "|" + Chr(3)
            End If
        Catch ex As Exception
            ObtieneMoneda = ObtieneMoneda + "||" + ex.Message + "|" + ex.StackTrace + "|" + Chr(3)
            Throw New Exception("***Error Generando CAE: " + ex.Message)
        End Try

    End Function
    Public Function ObtienePais(ByVal strToken As String, _
                                ByVal strSign As String, _
                                ByVal cuit As String, _
                                ByVal url As String) As String

        Dim objWSFEX As New wsfex.Service()
        objWSFEX.Url = url
        Dim FEXAuthorize_Auth As New wsfex.ClsFEXAuthRequest
        FEXAuthorize_Auth.Token = strToken
        FEXAuthorize_Auth.Sign = strSign
        FEXAuthorize_Auth.Cuit = Val(cuit)

        ObtienePais = ""
        Try
            Dim FEXResponse_DST_pais As New FEEXP.wsfex.FEXResponse_DST_pais
            FEXResponse_DST_pais = objWSFEX.FEXGetPARAM_DST_pais(FEXAuthorize_Auth)

            If FEXResponse_DST_pais.FEXResultGet.Length - 1 = 0 Then
                ObtienePais = "||" + _
                FEXResponse_DST_pais.FEXErr.ErrMsg + "|" + _
                FEXResponse_DST_pais.FEXEvents.EventMsg + "|" + Chr(3)
            Else
                For Each item As wsfex.ClsFEXResponse_DST_pais In FEXResponse_DST_pais.FEXResultGet
                    ObtienePais = ObtienePais + Str(item.DST_Codigo) + "|" + item.DST_Ds + "|||" + Chr(13)
                Next
                ObtienePais = ObtienePais + "||" + FEXResponse_DST_pais.FEXErr.ErrMsg + "|" + FEXResponse_DST_pais.FEXEvents.EventMsg + "|" + Chr(3)
            End If
        Catch ex As Exception
            ObtienePais = ""
            Throw New Exception("***Error ObtienePais: " + ex.Message)
        End Try

    End Function
    Public Function ObtieneUM(ByVal strToken As String, _
                            ByVal strSign As String, _
                            ByVal cuit As String, _
                            ByVal url As String) As String

        Dim objWSFE As New wsfex.Service()
        objWSFE.Url = url
        Dim FEXAuthorize_Auth As New wsfex.ClsFEXAuthRequest
        FEXAuthorize_Auth.Token = strToken
        FEXAuthorize_Auth.Sign = strSign
        FEXAuthorize_Auth.Cuit = Val(cuit)

        ObtieneUM = ""
        Try
            Dim objFEXResponse_Umed As New wsfex.FEXResponse_Umed
            objFEXResponse_Umed = objWSFE.FEXGetPARAM_UMed(FEXAuthorize_Auth)

            If objFEXResponse_Umed.FEXResultGet Is Nothing Then
                ObtieneUM = "||" + objFEXResponse_Umed.FEXErr.ErrMsg + "|" + _
                objFEXResponse_Umed.FEXEvents.EventMsg + "|" + Chr(3)
            Else
                For Each item As wsfex.ClsFEXResponse_UMed In objFEXResponse_Umed.FEXResultGet
                    ObtieneUM = ObtieneUM + Str(item.Umed_Id) + "|" + item.Umed_Ds + "|||" + Chr(13)
                Next
                ObtieneUM = ObtieneUM + "||" + objFEXResponse_Umed.FEXErr.ErrMsg + "|" + objFEXResponse_Umed.FEXEvents.EventMsg + "|" + Chr(3)
            End If
        Catch ex As Exception
            ObtieneUM = ObtieneUM + "||" + ex.Message + "|" + ex.StackTrace + "|" + Chr(3)
        End Try

    End Function
    Public Function ObtieneFEXCAE(ByVal strUrl As String, _
                                    ByVal strToken As String, _
                                       ByVal strSign As String, _
                                       ByVal cuit As String, _
                                       ByVal Id As String, _
                                       ByVal cbte_nro As String, _
                                       ByVal fecha_cbte As String, _
                                       ByVal cbte_tipo As String, _
                                       ByVal punto_vta As String, _
                                       ByVal tipo_expo As String, _
                                       ByVal permiso_existente As String, _
                                       ByVal detPermisos As String, _
                                       ByVal dst_cmp As String, _
                                       ByVal cliente As String, _
                                       ByVal cuit_pais_cliente As String, _
                                       ByVal domicilio_cliente As String, _
                                       ByVal id_impositivo As String, _
                                       ByVal moneda_id As String, _
                                       ByVal moneda_ctz As String, _
                                       ByVal obs_comerciales As String, _
                                       ByVal imp_total As String, _
                                       ByVal obs As String, _
                                       ByVal detCmps_asoc As String, _
                                       ByVal forma_pago As String, _
                                       ByVal incoterms As String, _
                                       ByVal incoterms_ds As String, _
                                       ByVal idioma_cbte As String, _
                                       ByVal detItems As String, _
                                       ByVal detOpcionales As String) As String
        Dim detCmp As New Objetos
        Dim _WSFEX As New wsfex.Service()
        _WSFEX.Url = strUrl
        '******************************
        Dim Auth As New wsfex.ClsFEXAuthRequest
        Auth.Token = strToken
        Auth.Sign = strSign
        Auth.Cuit = Val(cuit)
        '******************************
        gGrabaLog("C O M I E N Z O")
        gGrabaLog("Cuit:" + Auth.Cuit.ToString)
        gGrabaLog("Sign:" + Auth.Sign)
        gGrabaLog("Token:" + Auth.Token)

        Dim Cmp As New wsfex.ClsFEXRequest
        Cmp.Id = Val(Me.ObtieneLastID(strToken, strSign, cuit, strUrl)) + 1 'Val(cbte_nro)
        gGrabaLog(Cmp.Id.ToString)
        If Cmp.Id = 0 Then
            ObtieneFEXCAE = ""

            Exit Function
        End If
        Cmp.Fecha_cbte = fecha_cbte
        gGrabaLog(Cmp.Fecha_cbte)

        Cmp.Cbte_Tipo = Val(cbte_tipo)
        gGrabaLog(Cmp.Cbte_Tipo.ToString)

        Cmp.Punto_vta = Val(punto_vta)
        gGrabaLog(Cmp.Punto_vta.ToString)
        Cmp.Cbte_nro = Val(Me.ObtieneLastICbte(strToken, strSign, cuit, strUrl, punto_vta, cbte_tipo)) + 1 'Val(cbte_nro)
        gGrabaLog(Cmp.Cbte_nro.ToString)

        Cmp.Tipo_expo = Val(tipo_expo)
        gGrabaLog(Cmp.Tipo_expo.ToString)

        Cmp.Permiso_existente = permiso_existente
        gGrabaLog(Cmp.Permiso_existente)

        Cmp.Dst_cmp = Val(dst_cmp)
        gGrabaLog(Cmp.Dst_cmp.ToString)

        Cmp.Cliente = cliente
        gGrabaLog(Cmp.Cliente)

        Cmp.Cuit_pais_cliente = Val(cuit_pais_cliente)
        gGrabaLog(Cmp.Cuit_pais_cliente.ToString)

        Cmp.Domicilio_cliente = domicilio_cliente
        gGrabaLog(Cmp.Domicilio_cliente)

        If id_impositivo <> "" Then
            Cmp.Id_impositivo = id_impositivo
            gGrabaLog(Cmp.Id_impositivo)
        End If
        Cmp.Moneda_Id = moneda_id.Substring(0, 3)
        gGrabaLog(Cmp.Moneda_Id)

        Cmp.Moneda_ctz = Val(moneda_ctz)
        gGrabaLog(Cmp.Moneda_ctz.ToString)

        If obs_comerciales <> "" Then
            Cmp.Obs_comerciales = obs_comerciales
            gGrabaLog(Cmp.Obs_comerciales)
        End If
        Cmp.Imp_total = Val(imp_total)
        gGrabaLog(Cmp.Imp_total.ToString)

        If obs <> "" Then
            Cmp.Obs = obs
            gGrabaLog(Cmp.Obs)
        End If
        Cmp.Forma_pago = forma_pago
        gGrabaLog(Cmp.Forma_pago)

        Cmp.Incoterms = incoterms
        gGrabaLog(Cmp.Incoterms)

        Cmp.Incoterms_Ds = incoterms_ds
        gGrabaLog(Cmp.Incoterms_Ds)

        Cmp.Idioma_cbte = Val(idioma_cbte)
        gGrabaLog(Cmp.Idioma_cbte.ToString)

        If detOpcionales <> "" Then
            gGrabaLog(detOpcionales)
            ReDim Cmp.Opcionales(0)
            Cmp.Opcionales = detCmp.Opcionales(detOpcionales)
            For i As Integer = 0 To Cmp.Opcionales.Length - 1
                gGrabaLog(Cmp.Opcionales(i).Id)
                gGrabaLog(Cmp.Opcionales(i).Valor)
            Next
        End If

        If detCmps_asoc <> "" Then
            gGrabaLog(detCmps_asoc)
            ReDim Cmp.Cmps_asoc(0)
            Cmp.Cmps_asoc = detCmp.Cmps_asoc(detCmps_asoc)
            For i As Integer = 0 To Cmp.Cmps_asoc.Length - 1
                gGrabaLog(Cmp.Cmps_asoc(i).Cbte_cuit.ToString)
                gGrabaLog(Cmp.Cmps_asoc(i).Cbte_nro.ToString)
                gGrabaLog(Cmp.Cmps_asoc(i).Cbte_punto_vta.ToString)
                gGrabaLog(Cmp.Cmps_asoc(i).Cbte_tipo.ToString)
            Next
        End If

        If detPermisos <> "" Then
            gGrabaLog(detPermisos)
            ReDim Cmp.Permisos(0)
            Cmp.Permisos = detCmp.Permisos(detPermisos)
            For i As Integer = 0 To Cmp.Permisos.Length - 1
                gGrabaLog(Cmp.Permisos(i).Id_permiso)
                gGrabaLog(Cmp.Permisos(i).Dst_merc.ToString)
            Next
        End If

        If detItems <> "" Then
            ReDim Cmp.Items(0)
            Cmp.Items = detCmp.Items(detItems)
            For i As Integer = 0 To Cmp.Items.Length - 1
                gGrabaLog("***************Linea " + i.ToString)
                gGrabaLog(Cmp.Items(i).Pro_codigo)
                gGrabaLog(Cmp.Items(i).Pro_ds)
                gGrabaLog(Cmp.Items(i).Pro_umed.ToString)
                gGrabaLog(Cmp.Items(i).Pro_qty.ToString)
                gGrabaLog(Cmp.Items(i).Pro_precio_uni.ToString)
                gGrabaLog(Cmp.Items(i).Pro_bonificacion.ToString)
                gGrabaLog(Cmp.Items(i).Pro_total_item.ToString)
            Next
        End If
        gGrabaLog("***************Obtener CAE")
        Try
            Dim objFEXResponseAuthorize As New wsfex.FEXResponseAuthorize
            objFEXResponseAuthorize = _WSFEX.FEXAuthorize(Auth, Cmp)
            If objFEXResponseAuthorize.FEXResultAuth Is Nothing Then
                ObtieneFEXCAE = "|||||||" + _
                objFEXResponseAuthorize.FEXErr.ErrCode.ToString + "|E:" + _
                objFEXResponseAuthorize.FEXErr.ErrMsg + "|"
                gGrabaLog(ObtieneFEXCAE)
            Else
                ObtieneFEXCAE = objFEXResponseAuthorize.FEXResultAuth.Id.ToString + "|" + _
                objFEXResponseAuthorize.FEXResultAuth.Cbte_nro.ToString + "|" + _
                objFEXResponseAuthorize.FEXResultAuth.Cae + "|" + _
                objFEXResponseAuthorize.FEXResultAuth.Fch_venc_Cae + "|" + _
                objFEXResponseAuthorize.FEXResultAuth.Resultado + "|" + _
                objFEXResponseAuthorize.FEXResultAuth.Reproceso + "|" + _
                objFEXResponseAuthorize.FEXResultAuth.Motivos_Obs + "|||"
                gGrabaLog(ObtieneFEXCAE)
            End If

        Catch ex As Exception
            ObtieneFEXCAE = ""
            gGrabaLog("***Error Generando CAE: " + ex.Message)
            Throw New Exception("***Error Generando CAE: " + ex.Message)
        End Try
    End Function
    Function ConsultaCAE(ByVal cuit As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal tipo_cbte As String, _
        ByVal punto_vta As String, _
        ByVal cbt_desde As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String) As Boolean

        Dim objFEAuthRequest As New wsfex.ClsFEXAuthRequest
        Dim objFERequest As New wsfex.ClsFEXGetCMP
        Dim objFEResponse As New wsfex.FEXGetCMPResponse
        Dim objWSFE As New wsfex.Service

        objFEAuthRequest.Cuit = Val(cuit)
        objFEAuthRequest.Token = strToken
        objFEAuthRequest.Sign = strSign

        objFERequest.Cbte_tipo = Val(tipo_cbte)
        objFERequest.Punto_vta = Val(punto_vta)
        objFERequest.Cbte_nro = Val(cbt_desde)

        objFEResponse = objWSFE.FEXGetCMP(objFEAuthRequest, objFERequest)

        If Not objFEResponse.FEXErr Is Nothing Then
            ConsultaCAE = False
        Else
            cbte_estado = objFEResponse.FEXResultGet.Resultado
            vencimiento_cae = IIf(objFEResponse.FEXResultGet.Fch_venc_Cae = "NULL", "", objFEResponse.FEXResultGet.Fch_venc_Cae)
            cbte_cae = IIf(objFEResponse.FEXResultGet.Cae = "NULL", "", objFEResponse.FEXResultGet.Cae)
            ConsultaCAE = True
        End If

    End Function
    Public Function gGrabaLog(ByVal Texto As String)
        Dim strArchivo As String

        strArchivo = "FEEXP.LOG"

        My.Computer.FileSystem.WriteAllText(strArchivo, "Hora : " & CStr(Now()) & " " & Texto & ControlChars.CrLf, True)

    End Function

    Function ObtieneLastCmp(ByVal cuit As String, ByVal token As String, ByVal sign As String, _
            ByVal tipo_cbte As String, ByVal punto_vta As String) As String
        '***************************
        Dim objAuth As New wsfex.ClsFEX_LastCMP
        objAuth.Cuit = Val(cuit)
        objAuth.Token = token
        objAuth.Sign = sign
        objAuth.Cbte_Tipo = tipo_cbte
        objAuth.Pto_venta = punto_vta
        Dim objFELastCbteResponse As New wsfex.FEXResponseLast_CMP
        Dim objWSFE As New wsfex.Service
        '****************************
        Try
            objFELastCbteResponse = objWSFE.FEXGetLast_CMP(objAuth)
            If objFELastCbteResponse.FEXResult_LastCMP Is Nothing Then
                ObtieneLastCmp = "||" + objFELastCbteResponse.FEXErr.ErrCode.ToString.ToString + "|" + objFELastCbteResponse.FEXErr.ErrMsg + "|"
            Else
                ObtieneLastCmp = objFELastCbteResponse.FEXResult_LastCMP.Cbte_nro + "|" + objFELastCbteResponse.FEXResult_LastCMP.Cbte_fecha.ToString + "|||"
            End If
        Catch ex As Exception
            ObtieneLastCmp = "||" + ex.Message + "|" + ex.StackTrace + "|"
        End Try

    End Function
    Function ObtieneMonCot(ByVal url As String, ByVal cuit As String, ByVal token As String, ByVal sign As String, _
            ByVal Mon_id As String) As String
        Dim objAuth As New wsfex.ClsFEXAuthRequest
        '***************************
        objAuth.Cuit = Val(cuit)
        objAuth.Token = token
        objAuth.Sign = sign
        Dim objFEXResponse_Ctz As New wsfex.FEXResponse_Ctz
        Dim objWSFE As New wsfex.Service
        '****************************
        objWSFE.Url = url
        gGrabaLog("C O M I E N Z O")
        gGrabaLog("Cuit:" + objAuth.Cuit.ToString)
        gGrabaLog("Sign:" + objAuth.Sign)
        gGrabaLog("Token:" + objAuth.Token)
        gGrabaLog("Mon id:" + Mon_id)
        Try
            objFEXResponse_Ctz = objWSFE.FEXGetPARAM_Ctz(objAuth, Mon_id)
            gGrabaLog("Ctz Mon:" + objFEXResponse_Ctz.FEXResultGet.Mon_ctz.ToString)
            If objFEXResponse_Ctz.FEXResultGet Is Nothing Then
                MsgBox("ObtieneMonCot: " + objFEXResponse_Ctz.FEXErr.ErrCode.ToString.ToString + " " + objFEXResponse_Ctz.FEXErr.ErrMsg)
            Else
                ObtieneMonCot = objFEXResponse_Ctz.FEXResultGet.Mon_ctz.ToString + "|"
            End If
        Catch ex As Exception
            ObtieneMonCot = "||" + ex.Message + "|" + ex.StackTrace + "|" + Chr(13)
        End Try

    End Function

    Public Function ObtieneTicket(ByVal strIdServicioNegocio1 As String, _
        ByVal strUrlWsaaWsdl1 As String, _
        ByVal strRutaCertSigner1 As String, _
        ByVal strPasswordSecureString1 As String, _
        ByVal strProxy1 As String, _
        ByVal strProxyUser1 As String, _
        ByVal strProxyPassword1 As String) As String

        Dim UniqueId As String = Nothing ' Entero de 32 bits sin signo que identifica el requerimiento
        Dim GenerationTime As DateTime = Nothing ' Momento en que fue generado el requerimiento
        Dim ExpirationTime As DateTime = Nothing ' Momento en el que exoira la solicitud
        Dim Sign As String = Nothing ' Firma de seguridad recibida en la respuesta
        Dim Token As String = Nothing ' Token de seguridad recibido en la respuesta
        Dim sError As String = Nothing
        Dim strPasswordSecureString As New SecureString
        Dim resultado As String
        For Each character As Char In strPasswordSecureString1.ToCharArray
            strPasswordSecureString.AppendChar(character)
        Next
        strPasswordSecureString.MakeReadOnly()

        Dim objTicketRespuesta As LoginTicket
        Dim strTicketRespuesta As String

        Try
            objTicketRespuesta = New LoginTicket
            strTicketRespuesta = objTicketRespuesta.ObtenerLoginTicketResponse(strIdServicioNegocio1, _
                                     strUrlWsaaWsdl1, _
                                     strRutaCertSigner1, _
                                     strPasswordSecureString, _
                                     strProxy1, _
                                     strProxyUser1, _
                                     strProxyPassword1, _
                                     UniqueId, _
                                     GenerationTime, _
                                     ExpirationTime, _
                                     Sign, _
                                     Token, _
                                     sError)


        Catch excepcionAlObtenerTicket As Exception
            resultado = " | | | | |" + excepcionAlObtenerTicket.Message + " |"
            Return resultado

        End Try
        resultado = UniqueId + " |" + Format(GenerationTime, "yyyyMMdd HH:mm:ss:fff") + " |" + Format(ExpirationTime, "yyyyMMdd HH:mm:ss:fff") + " |" + Sign + " |" + Token + " |" + sError + " |"
        Return resultado
    End Function

    Public Function FileExists(ByVal FileFullPath As String) As Boolean

        If Trim(FileFullPath) = "" Then Return False

        Dim f As New IO.FileInfo(FileFullPath)

        Return f.Exists

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


    Public Shared Function ObtieneCertificadoDesdeArchivo(ByVal argArchivo As String, _
    ByVal argPassword As SecureString) As X509Certificate2
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


