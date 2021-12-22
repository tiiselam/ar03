Public Class Form1

    Private Sub Button2_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button2.Click
        Dim Sign1 As String
        Dim Token1 As String
        Dim blnProdMode1 As String
        Dim cuit As String
        Dim codeerr As String
        Dim msgerr As String
        Dim UltimoID As String

        Dim objGeneral As New ACA_WSFE.Principal

        'objGeneral = CreateObject("ACA_WSFEDLL.Principal")

        Token1 = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9InllcyI/Pgo8c3NvIHZlcnNpb249IjIuMCI+CiAgICA8aWQgdW5pcXVlX2lkPSIzNzgzMjUzOTE5IiBzcmM9IkNOPXdzYWFob21vLCBPPUFGSVAsIEM9QVIsIFNFUklBTE5VTUJFUj1DVUlUIDMzNjkzNDUwMjM5IiBnZW5fdGltZT0iMTI5OTU4OTg2OSIgZXhwX3RpbWU9IjEyOTk2MzMxMjkiIGRzdD0iQ049d3NmZSwgTz1BRklQLCBDPUFSIi8+CiAgICA8b3BlcmF0aW9uIHZhbHVlPSJncmFudGVkIiB0eXBlPSJsb2dpbiI+CiAgICAgICAgPGxvZ2luIHVpZD0iQz1hciwgTz1hZHJpYW4gYXBhcmljaW8sIFNFUklBTE5VTUJFUj1DVUlUIDIwMTM3NTQ1MzIzLCBDTj1hZHJpYW4iIHNlcnZpY2U9IndzZmUiIHJlZ21ldGhvZD0iMjIiIGVudGl0eT0iMzM2OTM0NTAyMzkiIGF1dGhtZXRob2Q9ImNtcyI+CiAgICAgICAgICAgIDxyZWxhdGlvbnM+CiAgICAgICAgICAgICAgICA8cmVsYXRpb24gcmVsdHlwZT0iNCIga2V5PSIyMDEzNzU0NTMyMyIvPgogICAgICAgICAgICA8L3JlbGF0aW9ucz4KICAgICAgICA8L2xvZ2luPgogICAgPC9vcGVyYXRpb24+Cjwvc3NvPgoK"
        Sign1 = "EZw9r3Xc/Mfb6y4mCAT1OvwP0PedxhGvl8n2ZBhEc/teR7e8nbNURFZ4C0Rr0Oiz4PegLuErGfldNI0ZfSkf0DYKxFPqd4pery96SJ32iXsER4L5WaE8emJqF4T/O3jJl4h4aQkoe0f0v08UW+Khtq/MFF2wYmsu2TZZEWGpOb4="

        blnProdMode1 = "0"
        cuit = "20137545323"
        codeerr = ""
        msgerr = ""
        UltimoID = ""
        UltimoID = objGeneral.UltimoIDTEST(cuit, Token1, Sign1, codeerr, msgerr)
    End Sub

    Private Sub Button3_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button3.Click
        Dim Sign1 As String
        Dim Token1 As String
        Dim blnProdMode1 As String
        Dim cuit As String
        Dim tipo_cbte As String
        Dim punto_vta As String
        Dim codeerr As String
        Dim msgerr As String
        Dim UltimoNumero As String

        Dim objGeneral As New ACA_WSFE.Principal

        'objGeneral = CreateObject("ACA_WSFEDLL.Principal")

        Sign1 = "EsVZLWQDhLHnea97KWpNBvriwv/uv4iD6me0xx/BN3tIFe/wS7WMpj8pxIXBL3RaoYprxAYvH2LsdPMeED0CLJSGSWDdAnKQn23owpIwUJxORbHzpZzJCRbRcclpCVONhYKZFSUKLqkIggyq9erkz3U0ABCOJpFLncXQJWK1UDw="
        Token1 = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9InllcyI/Pgo8c3NvIHZlcnNpb249IjIuMCI+CiAgICA8aWQgdW5pcXVlX2lkPSI3Nzg5MTQ3ODUiIHNyYz0iQ049d3NhYWhvbW8sIE89QUZJUCwgQz1BUiwgU0VSSUFMTlVNQkVSPUNVSVQgMzM2OTM0NTAyMzkiIGdlbl90aW1lPSIxNDk5OTk3MTg3IiBleHBfdGltZT0iMTUwMDA0MDQ0NyIgZHN0PSJDTj13c2ZlLCBPPUFGSVAsIEM9QVIiLz4KICAgIDxvcGVyYXRpb24gdmFsdWU9ImdyYW50ZWQiIHR5cGU9ImxvZ2luIj4KICAgICAgICA8bG9naW4gdWlkPSJTRVJJQUxOVU1CRVI9Q1VJVCAyMDEzNzU0NTMyMywgQ049YWNhcGFyaWNpbyIgc2VydmljZT0id3NmZSIgcmVnbWV0aG9kPSIyMiIgZW50aXR5PSIzMzY5MzQ1MDIzOSIgYXV0aG1ldGhvZD0iY21zIj4KICAgICAgICAgICAgPHJlbGF0aW9ucz4KICAgICAgICAgICAgICAgIDxyZWxhdGlvbiByZWx0eXBlPSI0IiBrZXk9IjIwMTM3NTQ1MzIzIi8+CiAgICAgICAgICAgIDwvcmVsYXRpb25zPgogICAgICAgIDwvbG9naW4+CiAgICA8L29wZXJhdGlvbj4KPC9zc28+Cgo="
        tipo_cbte = 1
        punto_vta = 37
        blnProdMode1 = "0"
        cuit = "20137545323"

        codeerr = ""
        msgerr = ""
        UltimoNumero = ""
        UltimoNumero = objGeneral.UltimoNumeroTESTv1(cuit, Token1, Sign1, tipo_cbte, punto_vta, codeerr, msgerr)
        MsgBox(UltimoNumero)
    End Sub

    Private Sub Button4_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button4.Click
        Dim EnviarCorreo As Object
        Dim enviado As Boolean

        EnviarCorreo = CreateObject("ACA_WSFE.Principal")

        enviado = EnviarCorreo.EnviarMail("relay.uolsinectis.com.ar", "wintersnews@winters.com.ar", "wintersnews@uolsinectis.com.ar", _
                    "YaPaso35", 25, 0, "wintersnews@winters.com.ar", "acaparicio@hotmail.com", _
                    "Este es el cuerpo del mensaje B", "Este es el asunto B", "", "", "", "")

    End Sub

    Private Sub Button5_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button5.Click
        Dim cuit As String
        Dim TableName As String
        Dim TableName2 As String
        Dim sServer As String
        Dim sDatabase As String
        Dim strError As String
        Dim sUser As String
        Dim sPassword As String
        Dim sGPUser As String
        Dim strToken As String
        Dim strSign As String
        Dim ObtieneCAE As Boolean
        Dim blnProdMode1 As String

        Dim objGeneral As New ACA_WSFE.Principal

        cuit = "20137545323"
        TableName = "##1765939"
        TableName2 = "##1465939"
        sServer = "NTBK-XX\GP510"
        sDatabase = "TWO"
        sUser = "UserArgFE"
        sPassword = "FEArgUser"
        sGPUser = "sa"
        strToken = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9InllcyI/Pgo8c3NvIHZlcnNpb249IjIuMCI+CiAgICA8aWQgdW5pcXVlX2lkPSIyMDM0NzA5MzY2IiBzcmM9IkNOPXdzYWFob21vLCBPPUFGSVAsIEM9QVIsIFNFUklBTE5VTUJFUj1DVUlUIDMzNjkzNDUwMjM5IiBnZW5fdGltZT0iMTQ0MTE1NTkzMyIgZXhwX3RpbWU9IjE0NDExOTkxOTMiIGRzdD0iQ049d3NmZSwgTz1BRklQLCBDPUFSIi8+CiAgICA8b3BlcmF0aW9uIHZhbHVlPSJncmFudGVkIiB0eXBlPSJsb2dpbiI+CiAgICAgICAgPGxvZ2luIHVpZD0iQz1hciwgTz1hZHJpYW4gYXBhcmljaW8sIFNFUklBTE5VTUJFUj1DVUlUIDIwMTM3NTQ1MzIzLCBDTj1hY2FwYXJpY2lvIiBzZXJ2aWNlPSJ3c2ZlIiByZWdtZXRob2Q9IjIyIiBlbnRpdHk9IjMzNjkzNDUwMjM5IiBhdXRobWV0aG9kPSJjbXMiPgogICAgICAgICAgICA8cmVsYXRpb25zPgogICAgICAgICAgICAgICAgPHJlbGF0aW9uIHJlbHR5cGU9IjQiIGtleT0iMjAxMzc1NDUzMjMiLz4KICAgICAgICAgICAgPC9yZWxhdGlvbnM+CiAgICAgICAgPC9sb2dpbj4KICAgIDwvb3BlcmF0aW9uPgo8L3Nzbz4KCg=="
        strSign = "pQmFBN8dx+vzU+eNr9VlIbIWSoc0O9cFYixT18bpqn2felhVV8ge/Uo5v21eipaU8btjN9g8DNAYxbeo4MO1llYj5YP0lxtph/od/FfABDGTCZXg9mlqTDrYv1YW/Mfuuy6yrB6iNxHQ+By7yk5FEePIQyxy8IEjL9mPFbr8zeE="

        ObtieneCAE = objGeneral.ObtieneCAETESTv1PILOTE(cuit, TableName, TableName2, sServer, sDatabase, sUser, sPassword, _
            sGPUser, strToken, strSign, strError)
    End Sub

    Private Sub Button6_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button6.Click
        Dim cuit As String
        Dim strToken As String
        Dim strSign As String
        Dim tipo_cbte As String
        Dim punto_vta As String
        Dim cbt_desde As String
        Dim cbte_estado As String
        Dim vencimiento_cae As String
        Dim cbte_cae As String
        Dim importe As String
        Dim CUITComprador As String
        Dim Resultado As Boolean
        Dim objGeneral As Object

        objGeneral = CreateObject("ACA_WSFE.Principal")

        cuit = "20137545323"
        strToken = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9InllcyI/Pgo8c3NvIHZlcnNpb249IjIuMCI+CiAgICA8aWQgdW5pcXVlX2lkPSIxMzA5MzU5ODA2IiBzcmM9IkNOPXdzYWFob21vLCBPPUFGSVAsIEM9QVIsIFNFUklBTE5VTUJFUj1DVUlUIDMzNjkzNDUwMjM5IiBnZW5fdGltZT0iMTQ0MzY3NDU2MyIgZXhwX3RpbWU9IjE0NDM3MTc4MjMiIGRzdD0iQ049d3NmZSwgTz1BRklQLCBDPUFSIi8+CiAgICA8b3BlcmF0aW9uIHZhbHVlPSJncmFudGVkIiB0eXBlPSJsb2dpbiI+CiAgICAgICAgPGxvZ2luIHVpZD0iQz1hciwgTz1hZHJpYW4gYXBhcmljaW8sIFNFUklBTE5VTUJFUj1DVUlUIDIwMTM3NTQ1MzIzLCBDTj1hY2FwYXJpY2lvIiBzZXJ2aWNlPSJ3c2ZlIiByZWdtZXRob2Q9IjIyIiBlbnRpdHk9IjMzNjkzNDUwMjM5IiBhdXRobWV0aG9kPSJjbXMiPgogICAgICAgICAgICA8cmVsYXRpb25zPgogICAgICAgICAgICAgICAgPHJlbGF0aW9uIHJlbHR5cGU9IjQiIGtleT0iMjAxMzc1NDUzMjMiLz4KICAgICAgICAgICAgPC9yZWxhdGlvbnM+CiAgICAgICAgPC9sb2dpbj4KICAgIDwvb3BlcmF0aW9uPgo8L3Nzbz4KCg=="
        strSign = "hsziO0BT4p0S6BK0235oOs4Lp6Is8naZJEeq3mRLiqArqLZY8w7yNlxXp2/5g7bNIHC8uCdzWSTVJppnXmdORWTOF2rbDdL/0nC0T6Q8AXWC6wdH5Liyp9OOtESDZbzd9JdDTCSHaPh42EuQR5MlN/PDfkal6/08ZcIywqZUFWs="
        tipo_cbte = "1"
        punto_vta = "71"
        cbt_desde = "39"
        cbte_estado = ""
        vencimiento_cae = ""
        cbte_cae = ""
        importe = "141.00"
        CUITComprador = "20137545331"

        Resultado = objGeneral.ConsultaCAETESTv1(cuit, strToken, strSign,
        tipo_cbte, punto_vta, cbt_desde,
        cbte_estado, vencimiento_cae, cbte_cae)



    End Sub

    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click

    End Sub
End Class
