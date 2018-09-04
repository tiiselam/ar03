<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class InstalarObjetos
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
        Me.Modulos = New System.Windows.Forms.ListBox
        Me.Instalar = New System.Windows.Forms.Button
        Me.Label1 = New System.Windows.Forms.Label
        Me.Companies = New System.Windows.Forms.ListBox
        Me.Label2 = New System.Windows.Forms.Label
        Me.Cancelar = New System.Windows.Forms.Button
        Me.Label3 = New System.Windows.Forms.Label
        Me.Label4 = New System.Windows.Forms.Label
        Me.Label5 = New System.Windows.Forms.Label
        Me.SuspendLayout()
        '
        'Modulos
        '
        Me.Modulos.FormattingEnabled = True
        Me.Modulos.Location = New System.Drawing.Point(416, 26)
        Me.Modulos.Name = "Modulos"
        Me.Modulos.SelectionMode = System.Windows.Forms.SelectionMode.MultiExtended
        Me.Modulos.Size = New System.Drawing.Size(361, 160)
        Me.Modulos.TabIndex = 0
        '
        'Instalar
        '
        Me.Instalar.Location = New System.Drawing.Point(22, 202)
        Me.Instalar.Name = "Instalar"
        Me.Instalar.Size = New System.Drawing.Size(114, 44)
        Me.Instalar.TabIndex = 2
        Me.Instalar.Text = "Instalar"
        Me.Instalar.UseVisualStyleBackColor = True
        '
        'Label1
        '
        Me.Label1.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.Label1.Location = New System.Drawing.Point(416, 9)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(140, 16)
        Me.Label1.TabIndex = 3
        Me.Label1.Text = "Módulos"
        '
        'Companies
        '
        Me.Companies.FormattingEnabled = True
        Me.Companies.Location = New System.Drawing.Point(22, 26)
        Me.Companies.Name = "Companies"
        Me.Companies.SelectionMode = System.Windows.Forms.SelectionMode.MultiExtended
        Me.Companies.Size = New System.Drawing.Size(370, 160)
        Me.Companies.TabIndex = 4
        '
        'Label2
        '
        Me.Label2.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
        Me.Label2.Location = New System.Drawing.Point(22, 9)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(140, 16)
        Me.Label2.TabIndex = 5
        Me.Label2.Text = "Compañías"
        '
        'Cancelar
        '
        Me.Cancelar.Location = New System.Drawing.Point(158, 202)
        Me.Cancelar.Name = "Cancelar"
        Me.Cancelar.Size = New System.Drawing.Size(75, 23)
        Me.Cancelar.TabIndex = 6
        Me.Cancelar.Text = "Cancelar"
        Me.Cancelar.UseVisualStyleBackColor = True
        '
        'Label3
        '
        Me.Label3.Location = New System.Drawing.Point(416, 202)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(361, 23)
        Me.Label3.TabIndex = 7
        Me.Label3.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'Label4
        '
        Me.Label4.Location = New System.Drawing.Point(416, 227)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(358, 23)
        Me.Label4.TabIndex = 8
        Me.Label4.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'Label5
        '
        Me.Label5.Location = New System.Drawing.Point(419, 254)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(355, 23)
        Me.Label5.TabIndex = 9
        Me.Label5.TextAlign = System.Drawing.ContentAlignment.MiddleLeft
        '
        'InstalarObjetos
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(795, 285)
        Me.Controls.Add(Me.Label5)
        Me.Controls.Add(Me.Label4)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.Cancelar)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Companies)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.Instalar)
        Me.Controls.Add(Me.Modulos)
        Me.Name = "InstalarObjetos"
        Me.Text = "Form1"
        Me.ResumeLayout(False)

    End Sub
    Friend WithEvents Modulos As System.Windows.Forms.ListBox
    Friend WithEvents Instalar As System.Windows.Forms.Button
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Companies As System.Windows.Forms.ListBox
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Cancelar As System.Windows.Forms.Button
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents Label5 As System.Windows.Forms.Label

End Class
