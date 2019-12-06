<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class LoginForm
    Inherits System.Windows.Forms.Form

    'Form reemplaza a Dispose para limpiar la lista de componentes.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Requerido por el Diseñador de Windows Forms
    Private components As System.ComponentModel.IContainer

    'NOTA: el Diseñador de Windows Forms necesita el siguiente procedimiento
    'Se puede modificar usando el Diseñador de Windows Forms.  
    'No lo modifique con el editor de código.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.DSNCmb = New System.Windows.Forms.ComboBox
        Me.UserTxt = New System.Windows.Forms.TextBox
        Me.PwdTxt = New System.Windows.Forms.TextBox
        Me.Conectar = New System.Windows.Forms.Button
        Me.Label1 = New System.Windows.Forms.Label
        Me.Label2 = New System.Windows.Forms.Label
        Me.Label3 = New System.Windows.Forms.Label
        Me.SuspendLayout()
        '
        'DSNCmb
        '
        Me.DSNCmb.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.DSNCmb.FormattingEnabled = True
        Me.DSNCmb.Location = New System.Drawing.Point(136, 12)
        Me.DSNCmb.Name = "DSNCmb"
        Me.DSNCmb.Size = New System.Drawing.Size(293, 21)
        Me.DSNCmb.TabIndex = 4
        '
        'UserTxt
        '
        Me.UserTxt.Enabled = False
        Me.UserTxt.Location = New System.Drawing.Point(136, 52)
        Me.UserTxt.Name = "UserTxt"
        Me.UserTxt.Size = New System.Drawing.Size(153, 20)
        Me.UserTxt.TabIndex = 5
        '
        'PwdTxt
        '
        Me.PwdTxt.Location = New System.Drawing.Point(136, 94)
        Me.PwdTxt.Name = "PwdTxt"
        Me.PwdTxt.Size = New System.Drawing.Size(153, 20)
        Me.PwdTxt.TabIndex = 6
        Me.PwdTxt.UseSystemPasswordChar = True
        '
        'Conectar
        '
        Me.Conectar.Location = New System.Drawing.Point(354, 91)
        Me.Conectar.Name = "Conectar"
        Me.Conectar.Size = New System.Drawing.Size(75, 23)
        Me.Conectar.TabIndex = 7
        Me.Conectar.Text = "Conectar"
        Me.Conectar.UseVisualStyleBackColor = True
        '
        'Label1
        '
        Me.Label1.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.Label1.Location = New System.Drawing.Point(12, 12)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(124, 21)
        Me.Label1.TabIndex = 8
        Me.Label1.Text = "Servidor"
        Me.Label1.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'Label2
        '
        Me.Label2.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.Label2.Location = New System.Drawing.Point(12, 51)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(124, 21)
        Me.Label2.TabIndex = 9
        Me.Label2.Text = "Usuario"
        Me.Label2.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'Label3
        '
        Me.Label3.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.Label3.Location = New System.Drawing.Point(12, 94)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(124, 21)
        Me.Label3.TabIndex = 10
        Me.Label3.Text = "Contraseña"
        Me.Label3.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'LoginForm
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(499, 134)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.Conectar)
        Me.Controls.Add(Me.PwdTxt)
        Me.Controls.Add(Me.UserTxt)
        Me.Controls.Add(Me.DSNCmb)
        Me.Name = "LoginForm"
        Me.Text = "LoginForm"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents DSNCmb As System.Windows.Forms.ComboBox
    Friend WithEvents UserTxt As System.Windows.Forms.TextBox
    Friend WithEvents PwdTxt As System.Windows.Forms.TextBox
    Friend WithEvents Conectar As System.Windows.Forms.Button
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
End Class
