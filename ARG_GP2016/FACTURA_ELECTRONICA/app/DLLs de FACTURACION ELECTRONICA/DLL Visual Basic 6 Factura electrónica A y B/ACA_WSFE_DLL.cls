VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Principal"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True

Public Function EnviarMail(ByVal CorreoServer As String, ByVal CorreoCuenta As String, ByVal CorreoUser As String, _
    ByVal CorreoPassword As String, ByVal CorreoPort As Integer, ByVal CorreoSSLSecurity As Integer, _
    ByVal CorreoResponderA As String, ByVal CorreoEnviarA As String, ByVal sMensaje As String, ByVal sAsunto As String, _
    ByVal sFactura As String, ByVal sRemito As String, ByVal sRecibo As String, ByVal sFaltantes As String) As Boolean

    Dim objGeneral As Object
    
    Set objGeneral = CreateObject("ACA_WSFE.Principal")

    EnviarMail = objGeneral.EnviarMail(CorreoServer, CorreoCuenta, CorreoUser, CorreoPassword, CorreoPort, CorreoSSLSecurity, _
        CorreoResponderA, CorreoEnviarA, sMensaje, sAsunto, sFactura, sRemito, sRecibo, sFaltantes)
        
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
        ByRef Service1 As String, _
        ByRef GenerationTime1 As String, _
        ByRef ExpirationTime1 As String, _
        ByRef Sign1 As String, _
        ByRef Token1 As String, _
        ByRef strError As String, _
        Optional ByVal DifGMTBA As Integer = 3) As Integer
        
        Dim Resultado As Integer
        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFE.Principal")

        If strProdMode1 = "0" Then
            If Trim(strUrlWsaaWsdl1) = "" Then
                strUrlWsaaWsdl1 = "https://wsaahomo.afip.gov.ar/ws/services/LoginCms?WSDL"
            End If
        Else
            If (strUrlWsaaWsdl1) = "" Then
                strUrlWsaaWsdl1 = "https://wsaa.afip.gov.ar/ws/services/LoginCms?WSDL"
            End If
        End If
        If Trim(strIdServicioNegocio1) = "" Then
            strIdServicioNegocio1 = "wsfe"
        End If
        If Trim(strRutaCertSigner1) = "" Then
            strRutaCertSigner1 = "C:\OpenSSL-Win32\bin\aparicio.p12"
        End If
        If Trim(strPasswordSecureString1) = "" Then
            strPasswordSecureString1 = "acaparicio"
        End If
        'strProxy1 = ""
        'strProxyUser1 = ""
        'strProxyPassword1 = ""
        If RTrim(Service1) = "" Then
            Service1 = "wsfe"
        End If

        Resultado = objGeneral.ObtieneTicket(strProdMode1, _
                    strUrlWsaaWsdl1, _
        strIdServicioNegocio1, _
        strRutaCertSigner1, _
        strPasswordSecureString1, _
        strProxy1, _
        strProxyUser1, _
        strProxyPassword1, _
        UniqueID1, _
        Service1, _
        GenerationTime1, _
        ExpirationTime1, _
        Sign1, _
        Token1, _
        strError, _
        DifGMTBA)

        ObtieneTicket = Resultado
        
        Set objGeneral = Nothing
        
End Function
    Public Function ObtieneTicketfex( _
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

        Dim Resultado As Integer
        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFEX.Principal")
        
        If strProdMode1 = "0" Then
            If Trim(strUrlWsaaWsdl1) = "" Then
                strUrlWsaaWsdl1 = "https://wsaahomo.afip.gov.ar/ws/services/LoginCms?WSDL"
            End If
        Else
            If (strUrlWsaaWsdl1) = "" Then
                strUrlWsaaWsdl1 = "https://wsaa.afip.gov.ar/ws/services/LoginCms?WSDL"
            End If
        End If
        If Trim(strIdServicioNegocio1) = "" Then
            strIdServicioNegocio1 = "wsfex"
        End If
        If Trim(strRutaCertSigner1) = "" Then
            strRutaCertSigner1 = "C:\OpenSSL-Win32\bin\aparicio.p12"
        End If
        If Trim(strPasswordSecureString1) = "" Then
            strPasswordSecureString1 = "acaparicio"
        End If
        'strProxy1 = ""
        'strProxyUser1 = ""
        'strProxyPassword1 = ""
        If RTrim(Service1) = "" Then
            Service1 = "wsfex"
        End If
        
        Resultado = objGeneral.ObtieneTicketfex(strProdMode1, _
                    strUrlWsaaWsdl1, _
        strIdServicioNegocio1, _
        strRutaCertSigner1, _
        strPasswordSecureString1, _
        strProxy1, _
        strProxyUser1, _
        strProxyPassword1, _
        UniqueID1, _
        Service1, _
        GenerationTime1, _
        ExpirationTime1, _
        Sign1, _
        Token1, _
        strError, _
        DifGMTBA)

        ObtieneTicketfex = Resultado
        
        Set objGeneral = Nothing

End Function
Public Function ObtieneCAE(ByVal strProdMode As String, _
        ByVal cuit As String, ByVal strId As String, ByVal strToken As String, _
        ByVal strSign As String, ByVal strcantidadreg As String, _
        ByVal presta_serv As String, ByVal tipo_doc As String, _
        ByVal nro_doc As String, ByVal tipo_cbte As String, _
        ByVal punto_vta As String, ByRef cbt_desde As String, _
        ByRef cbt_hasta As String, ByVal imp_total As String, _
        ByVal imp_tot_conc As String, ByVal imp_neto As String, _
        ByVal impto_liq As String, ByVal impto_liq_rni As String, _
        ByVal imp_op_ex As String, ByVal fecha_cbte As String, _
        ByVal fecha_serv_desde As String, ByVal fecha_serv_hasta As String, _
        ByVal fecha_venc_pago As String, ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, ByRef desc_rechazo As String, _
        ByRef codeerr As String, ByRef msgerr As String, ByRef reproceso As String) As Boolean
        
        Dim Resultado As Integer
        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFE.Principal")
        
        If strProdMode = "0" Then
            Resultado = objGeneral.ObtieneCAETEST(cuit, strId, _
            strToken, strSign, strcantidadreg, presta_serv, _
            tipo_doc, nro_doc, tipo_cbte, punto_vta, cbt_desde, cbt_hasta, _
            imp_total, imp_tot_conc, imp_neto, impto_liq, impto_liq_rni, _
            imp_op_ex, fecha_cbte, fecha_serv_desde, fecha_serv_hasta, fecha_venc_pago, _
            cbte_estado, vencimiento_cae, cbte_cae, motivo_rechazo, desc_rechazo, codeerr, msgerr, reproceso)
        Else
            Resultado = objGeneral.ObtieneCAEPROD(cuit, strId, _
            strToken, strSign, strcantidadreg, presta_serv, _
            tipo_doc, nro_doc, tipo_cbte, punto_vta, cbt_desde, cbt_hasta, _
            imp_total, imp_tot_conc, imp_neto, impto_liq, impto_liq_rni, _
            imp_op_ex, fecha_cbte, fecha_serv_desde, fecha_serv_hasta, fecha_venc_pago, _
            cbte_estado, vencimiento_cae, cbte_cae, motivo_rechazo, desc_rechazo, codeerr, msgerr, reproceso)
        End If


        ObtieneCAE = Resultado

        Set objGeneral = Nothing

End Function
Public Function ObtieneCAE2(ByVal strProdMode As String, _
        ByVal cuit As String, ByVal strId As String, ByVal strToken As String, _
        ByVal strSign As String, ByVal strcantidadreg As String, _
        ByVal presta_serv As String, ByVal tipo_doc As String, _
        ByRef nro_doc As String, ByVal tipo_cbte As String, _
        ByVal punto_vta As String, ByRef cbt_desde As String, _
        ByRef cbt_hasta As String, ByRef imp_total As String, _
        ByVal imp_tot_conc As String, ByVal imp_neto As String, _
        ByVal impto_liq As String, ByVal impto_liq_rni As String, _
        ByVal imp_op_ex As String, ByVal fecha_cbte As String, _
        ByVal fecha_serv_desde As String, ByVal fecha_serv_hasta As String, _
        ByVal fecha_venc_pago As String, ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, ByRef desc_rechazo As String, _
        ByRef codeerr As String, ByRef msgerr As String, ByRef reproceso As String) As Boolean
        
        Dim Resultado As Integer
        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFE.Principal")
        
        If strProdMode = "0" Then
            Resultado = objGeneral.ObtieneCAETEST2(cuit, strId, _
            strToken, strSign, strcantidadreg, presta_serv, _
            tipo_doc, nro_doc, tipo_cbte, punto_vta, cbt_desde, cbt_hasta, _
            imp_total, imp_tot_conc, imp_neto, impto_liq, impto_liq_rni, _
            imp_op_ex, fecha_cbte, fecha_serv_desde, fecha_serv_hasta, fecha_venc_pago, _
            cbte_estado, vencimiento_cae, cbte_cae, motivo_rechazo, desc_rechazo, codeerr, msgerr, reproceso)
        Else
            Resultado = objGeneral.ObtieneCAEPROD2(cuit, strId, _
            strToken, strSign, strcantidadreg, presta_serv, _
            tipo_doc, nro_doc, tipo_cbte, punto_vta, cbt_desde, cbt_hasta, _
            imp_total, imp_tot_conc, imp_neto, impto_liq, impto_liq_rni, _
            imp_op_ex, fecha_cbte, fecha_serv_desde, fecha_serv_hasta, fecha_venc_pago, _
            cbte_estado, vencimiento_cae, cbte_cae, motivo_rechazo, desc_rechazo, codeerr, msgerr, reproceso)
        End If


        ObtieneCAE2 = Resultado

        Set objGeneral = Nothing

End Function


Public Function ObtieneCAEv1(ByVal strProdMode As String, _
        ByVal cuit As String, ByVal strId As String, ByVal strToken As String, _
        ByVal strSign As String, ByVal strcantidadreg As String, _
        ByVal presta_serv As String, ByVal tipo_doc As String, _
        ByVal nro_doc As String, ByVal tipo_cbte As String, _
        ByVal punto_vta As String, ByRef cbt_desde As String, _
        ByRef cbt_hasta As String, ByVal imp_total As String, _
        ByVal imp_tot_conc As String, ByVal imp_neto As String, _
        ByVal impto_liq As String, ByVal impto_liq_rni As String, _
        ByVal imp_op_ex As String, ByVal imp_trib As String, ByVal fecha_cbte As String, _
        ByVal fecha_serv_desde As String, ByVal fecha_serv_hasta As String, _
        ByVal fecha_venc_pago As String, ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, ByRef desc_rechazo As String, _
        ByRef codeerr As String, ByRef msgerr As String, ByRef reproceso As String, _
        ByVal concepto As String, ByVal moneda As String, ByVal tipo_cbio As String, _
        ByVal tributos As String, ByVal ivastr As String) As Boolean
        
        Dim Resultado As Integer
        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFE.Principal")
        
        If strProdMode = "0" Then
            Resultado = objGeneral.ObtieneCAETESTv1(cuit, strId, _
            strToken, strSign, strcantidadreg, presta_serv, _
            tipo_doc, nro_doc, tipo_cbte, punto_vta, cbt_desde, cbt_hasta, _
            imp_total, imp_tot_conc, imp_neto, impto_liq, impto_liq_rni, _
            imp_op_ex, imp_trib, fecha_cbte, fecha_serv_desde, fecha_serv_hasta, fecha_venc_pago, _
            cbte_estado, vencimiento_cae, cbte_cae, motivo_rechazo, desc_rechazo, codeerr, msgerr, reproceso, _
            concepto, moneda, tipo_cbio, tributos, ivastr)
        Else
            Resultado = objGeneral.ObtieneCAEPRODv1(cuit, strId, _
            strToken, strSign, strcantidadreg, presta_serv, _
            tipo_doc, nro_doc, tipo_cbte, punto_vta, cbt_desde, cbt_hasta, _
            imp_total, imp_tot_conc, imp_neto, impto_liq, impto_liq_rni, _
            imp_op_ex, imp_trib, fecha_cbte, fecha_serv_desde, fecha_serv_hasta, fecha_venc_pago, _
            cbte_estado, vencimiento_cae, cbte_cae, motivo_rechazo, desc_rechazo, codeerr, msgerr, reproceso, _
            concepto, moneda, tipo_cbio, tributos, ivastr)
        End If


        ObtieneCAEv1 = Resultado

        Set objGeneral = Nothing

End Function
Public Function ObtieneCAEfex(ByVal strProdMode As String, _
        ByVal cuit As String, _
        ByRef strId As String, _
        ByVal UniqueId As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal iSopType As Integer, _
        ByVal sSopNumber As String, _
        ByVal sServer As String, _
        ByVal sBase As String, _
        ByVal sUser As String, _
        ByVal sPassword As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, _
        ByRef desc_rechazo As String, _
        ByRef codeerr As String, _
        ByRef msgerr As String, _
        ByRef reproceso As String) As Boolean
        
        Dim Resultado As Integer
        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFEX.Principal")
        
        If strProdMode = "0" Then
            Resultado = objGeneral.ObtieneCAETESTfex(cuit, strId, UniqueId, _
            strToken, strSign, iSopType, _
            sSopNumber, sServer, sBase, _
            sUser, sPassword, cbte_estado, _
            vencimiento_cae, cbte_cae, motivo_rechazo, _
            desc_rechazo, codeerr, msgerr, _
            reproceso)
        Else
            Resultado = objGeneral.ObtieneCAEPRODfex(cuit, strId, UniqueId, _
            strToken, strSign, iSopType, _
            sSopNumber, sServer, sBase, _
            sUser, sPassword, cbte_estado, _
            vencimiento_cae, cbte_cae, motivo_rechazo, _
            desc_rechazo, codeerr, msgerr, _
            reproceso)
        End If

        ObtieneCAEfex = Resultado

        Set objGeneral = Nothing

End Function
Public Function ObtieneCAEfexAVENT(ByVal strProdMode As String, _
        ByVal cuit As String, _
        ByRef strId As String, _
        ByVal UniqueId As String, _
        ByVal strToken As String, _
        ByVal strSign As String, _
        ByVal iSopType As Integer, _
        ByVal sSopNumber As String, _
        ByVal sServer As String, _
        ByVal sBase As String, _
        ByVal sUser As String, _
        ByVal sPassword As String, _
        ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, _
        ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, _
        ByRef desc_rechazo As String, _
        ByRef codeerr As String, _
        ByRef msgerr As String, _
        ByRef reproceso As String, _
        ByRef sCbte As String) As Boolean
        
        Dim Resultado As Integer
        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFEX.Principal")
        
        If strProdMode = "0" Then
            Resultado = objGeneral.ObtieneCAETESTfexAVENT(cuit, strId, UniqueId, _
            strToken, strSign, iSopType, _
            sSopNumber, sServer, sBase, _
            sUser, sPassword, cbte_estado, _
            vencimiento_cae, cbte_cae, motivo_rechazo, _
            desc_rechazo, codeerr, msgerr, _
            reproceso, sCbte)
        Else
            Resultado = objGeneral.ObtieneCAEPRODfexAVENT(cuit, strId, UniqueId, _
            strToken, strSign, iSopType, _
            sSopNumber, sServer, sBase, _
            sUser, sPassword, cbte_estado, _
            vencimiento_cae, cbte_cae, motivo_rechazo, _
            desc_rechazo, codeerr, msgerr, _
            reproceso, sCbte)
        End If

        ObtieneCAEfexAVENT = Resultado

        Set objGeneral = Nothing

End Function

Public Function ObtieneCAEv1PI(ByVal strProdMode As String, _
        ByVal cuit As String, ByVal strId As String, ByVal strToken As String, _
        ByVal strSign As String, ByVal strcantidadreg As String, _
        ByVal presta_serv As String, ByVal tipo_doc As String, _
        ByVal nro_doc As String, ByVal tipo_cbte As String, _
        ByVal punto_vta As String, ByRef cbt_desde As String, _
        ByRef cbt_hasta As String, ByVal imp_total As String, _
        ByVal imp_tot_conc As String, ByVal imp_neto As String, _
        ByVal impto_liq As String, ByVal impto_liq_rni As String, _
        ByVal imp_op_ex As String, ByVal imp_trib As String, ByVal fecha_cbte As String, _
        ByVal fecha_serv_desde As String, ByVal fecha_serv_hasta As String, _
        ByVal fecha_venc_pago As String, ByRef cbte_estado As String, _
        ByRef vencimiento_cae As String, ByRef cbte_cae As String, _
        ByRef motivo_rechazo As String, ByRef desc_rechazo As String, _
        ByRef codeerr As String, ByRef msgerr As String, ByRef reproceso As String, _
        ByVal concepto As String, ByVal moneda As String, ByVal tipo_cbio As String, _
        ByVal tributos As String, ByVal ivastr As String, ByVal adicionalesstr As String) As Boolean
        
        Dim Resultado As Integer
        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFE.Principal")
        
        If strProdMode = "0" Then
            Resultado = objGeneral.ObtieneCAETESTv1PI(cuit, strId, _
            strToken, strSign, strcantidadreg, presta_serv, _
            tipo_doc, nro_doc, tipo_cbte, punto_vta, cbt_desde, cbt_hasta, _
            imp_total, imp_tot_conc, imp_neto, impto_liq, impto_liq_rni, _
            imp_op_ex, imp_trib, fecha_cbte, fecha_serv_desde, fecha_serv_hasta, fecha_venc_pago, _
            cbte_estado, vencimiento_cae, cbte_cae, motivo_rechazo, desc_rechazo, codeerr, msgerr, reproceso, _
            concepto, moneda, tipo_cbio, tributos, ivastr, adicionalesstr)
        Else
            Resultado = objGeneral.ObtieneCAEPRODv1PI(cuit, strId, _
            strToken, strSign, strcantidadreg, presta_serv, _
            tipo_doc, nro_doc, tipo_cbte, punto_vta, cbt_desde, cbt_hasta, _
            imp_total, imp_tot_conc, imp_neto, impto_liq, impto_liq_rni, _
            imp_op_ex, imp_trib, fecha_cbte, fecha_serv_desde, fecha_serv_hasta, fecha_venc_pago, _
            cbte_estado, vencimiento_cae, cbte_cae, motivo_rechazo, desc_rechazo, codeerr, msgerr, reproceso, _
            concepto, moneda, tipo_cbio, tributos, ivastr, adicionalesstr)
        End If


        ObtieneCAEv1PI = Resultado

        Set objGeneral = Nothing

End Function
Public Function ObtieneCAEPv1PILOTE(strProdMode As String, _
    ByVal cuit As String, _
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

        Dim Resultado As Integer
        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFE.Principal")
        
        If strProdMode = "0" Then
            Resultado = objGeneral.ObtieneCAETESTv1PILOTE(cuit, TableName, TableName2, sServer, sDatabase, sUser, _
            sPassword, sGPUser, strToken, strSign, strError)
        Else
            Resultado = objGeneral.ObtieneCAEPRODv1PILOTE(cuit, TableName, TableName2, sServer, sDatabase, sUser, _
            sPassword, sGPUser, strToken, strSign, strError)
        End If
End Function
Public Function ConsultaCAEv1(ByVal strProdMode As String, ByVal cuit As String, ByVal strToken As String, ByVal strSign As String, _
                ByVal tipo_cbte As String, ByVal punto_vta As String, ByVal cbt_desde As String, _
                ByRef cbte_estado As String, ByRef vencimiento_cae As String, ByRef cbte_cae As String) As Boolean

        Dim Resultado As Boolean
        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFE.Principal")
        
        If strProdMode = "0" Then
            Resultado = objGeneral.ConsultaCAETESTv1(cuit, strToken, strSign, _
            tipo_cbte, punto_vta, cbt_desde, _
            cbte_estado, vencimiento_cae, cbte_cae)
        Else
            Resultado = objGeneral.ConsultaCAEPRODv1(cuit, strToken, strSign, _
            tipo_cbte, punto_vta, cbt_desde, _
            cbte_estado, vencimiento_cae, cbte_cae)
        End If


        ConsultaCAEv1 = Resultado

        Set objGeneral = Nothing

End Function
Public Function Consulta2CAEv1(ByVal strProdMode As String, ByVal cuit As String, ByVal strToken As String, ByVal strSign As String, _
                ByVal tipo_cbte As String, ByVal punto_vta As String, ByVal cbt_desde As String, _
                ByRef cbte_estado As String, ByRef vencimiento_cae As String, ByRef cbte_cae As String, _
                ByRef importe As String, ByRef CUITComprador As String) As Boolean

        Dim Resultado As Boolean
        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFE.Principal")
        
        If strProdMode = "0" Then
            Resultado = objGeneral.Consulta2CAETESTv1(cuit, strToken, strSign, _
            tipo_cbte, punto_vta, cbt_desde, _
            cbte_estado, vencimiento_cae, cbte_cae, importe, CUITComprador)
        Else
            Resultado = objGeneral.Consulta2CAEPRODv1(cuit, strToken, strSign, _
            tipo_cbte, punto_vta, cbt_desde, _
            cbte_estado, vencimiento_cae, cbte_cae, importe, CUITComprador)
        End If


        Consulta2CAEv1 = Resultado

        Set objGeneral = Nothing

End Function
Public Function UltimoID(ByVal strProdMode As String, _
                                ByVal cuit As String, _
                                ByVal token As String, _
                                ByVal sign As String, _
                                ByRef codeerr As String, _
                                ByRef msgerr As String) As String

        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFE.Principal")

        If strProdMode = "0" Then
            UltimoID = objGeneral.UltimoIDTEST(cuit, token, sign, codeerr, msgerr)
        Else
            UltimoID = objGeneral.UltimoIDPROD(cuit, token, sign, codeerr, msgerr)
        End If

        Set objGeneral = Nothing
        
End Function
Public Function UltimoNumero(ByVal strProdMode As String, _
                                ByVal cuit As String, _
                                ByVal token As String, _
                                ByVal sign As String, _
                                ByVal tipo_cbte As String, _
                                ByVal punto_vta As String, _
                                ByRef codeerr As String, _
                                ByRef msgerr As String) As String

        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFE.Principal")

        If strProdMode = "0" Then
            UltimoNumero = objGeneral.UltimoNumeroTESTv1(cuit, token, sign, tipo_cbte, punto_vta, codeerr, msgerr)
        Else
            UltimoNumero = objGeneral.UltimoNumeroProdv1(cuit, token, sign, tipo_cbte, punto_vta, codeerr, msgerr)
        End If

        Set objGeneral = Nothing

End Function
Public Function UltimoNumerofex(ByVal strProdMode As String, _
                                ByVal cuit As String, _
                                ByVal token As String, _
                                ByVal sign As String, _
                                ByVal tipo_cbte As String, _
                                ByVal punto_vta As String, _
                                ByRef codeerr As String, _
                                ByRef msgerr As String) As String

        Dim objGeneral As Object
        
        Set objGeneral = CreateObject("ACA_WSFEX.Principal")

        If strProdMode = "0" Then
            UltimoNumerofex = objGeneral.UltimoNumeroTESTfex(cuit, token, sign, tipo_cbte, punto_vta, codeerr, msgerr)
        Else
            UltimoNumerofex = objGeneral.UltimoNumeroProdfex(cuit, token, sign, tipo_cbte, punto_vta, codeerr, msgerr)
        End If

        Set objGeneral = Nothing

End Function
Public Function GenerarPDF(ByVal sPathRPT As String, ByVal Servidor As String, ByVal BaseDatos As String, _
                            ByVal Usuario As String, ByVal Contraseña As String, ByVal NroDesde As String, _
                            ByVal NroHasta As String, ByVal sPathPDF As String, _
                            Optional ByVal AbrePDF As Integer = 1, _
                            Optional ByVal SubReporte As String = "") As String

Dim CRAXReport As New CRAXDRT.Application
Dim Report As New CRAXDRT.Report
Dim iParamCount, iParamCount2 As Integer
Dim myParameters, myParameters2 As Object
Dim myParameter, myParameter2 As Object
Dim Subreport As CRAXDRT.Report
Dim crxDatabaseTable As CRAXDRT.DatabaseTable
Dim iTableCount As Integer
Dim myTables As Object
Dim x As Integer
Dim Sections As CRAXDRT.Sections
Dim Section As CRAXDRT.Section
Dim RepObjs As CRAXDRT.ReportObjects
Dim SubReportObj As CRAXDRT.SubreportObject
Dim n As Integer
Dim i As Integer

'Set reporte = Nothing
Set Report = CRAXReport.OpenReport(sPathRPT, 1)

'Declare a DatabaseTable Object
'   count our tables and set the collection
iTableCount = Report.Database.Tables.Count
Set myTables = Report.Database.Tables

'   spin through the tables and log into the database for each
For x = 1 To iTableCount
    Set myTable = myTables.Item(x)
    myTable.SetLogOnInfo Servidor, BaseDatos, Usuario, Contraseña
    
    '   and set the location to current company
    myTable.Location = BaseDatos + ".dbo." + myTable.Location   'such as TWO.dbo.RM00101
Next x

iParamCount = Report.ParameterFields.Count
Set myParameters = Report.ParameterFields

Set myParameter = myParameters.Item(1)
Call myParameter.ClearCurrentValueAndRange
myParameter.SetCurrentValue (NroDesde)

Set myParameter = myParameters.Item(2)
Call myParameter.ClearCurrentValueAndRange
myParameter.SetCurrentValue (NroHasta)

If SubReporte = "Ingresos_Brutos" Then
    Set Sections = Report.Sections
    For n = 1 To Sections.Count
        Set Section = Sections.Item(n)
        Set RepObjs = Section.ReportObjects
        For i = 1 To RepObjs.Count
            If RepObjs.Item(i).Kind = crSubreportObject Then
                Set SubReportObj = RepObjs.Item(i)
                Set Subreport = SubReportObj.OpenSubreport
                Subreport.ParameterFields(1).AddCurrentValue NroHasta
            End If
        Next i
    Next n
        
End If

'Dim crxExportOptions As CRAXDRT.ExportOptions

'Set crxExportOptions = Report.ExportOptions

'crxExportOptions.DestinationType = crEDTDiskFile
'crxExportOptions.DiskFileName = sPathPDF
'crxExportOptions.FormatType = crEFTPortableDocFormat
'crxExportOptions.PDFFirstPageNumber = 1
'crxExportOptions.PDFLastPageNumber = 1
'crxExportOptions.PDFExportAllPages = True

'    With Report
'        .EnableParameterPrompting = False
'        .MorePrintEngineErrorMessages = True
'    End With

    With Report.ExportOptions
        .DestinationType = crEDTDiskFile
        .DiskFileName = sPathPDF
        .FormatType = crEFTPortableDocFormat
        .PDFFirstPageNumber = 1
        .PDFLastPageNumber = 1
        .PDFExportAllPages = True
    End With


Report.Export False

'Shell "C:\Archivos de programa\Adobe\Reader 9.0\Reader\AcroRd32.exe" " & sPathPDF, vbNormalFocus
'Shell sPathPDF, vbNormalFocus

If AbrePDF = 1 Then
    RunMe (sPathPDF)
End If


GenerarPDF = "OK"



End Function

