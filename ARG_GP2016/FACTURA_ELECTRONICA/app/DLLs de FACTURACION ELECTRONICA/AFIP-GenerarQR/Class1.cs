using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using MessagingToolkit.QRCode;
//using ThoughtWorks.QRCode.Codec;
using Gma.QrCodeNet.Encoding;
using Gma.QrCodeNet.Encoding.Windows.Render;
using Comun;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using System.Xml;
using System.Text.RegularExpressions;
using System.Reflection;

namespace AFIP_GenerarQR
{
    public class Generarqr
    {
        //definir un variable nombre de archivo
        public string nomarchivo = "";
        //string cadcon = "";
        string path = "";
        //string rutapar = "";

        public Generarqr(string cadena, int libreria, string sertip)
        //public Generarqr(string cadena, int libreria)
        {
            try
            {
                //string sertip = "rutaprodqr";
                //rutapar = "Ruta de archivo xml:  C:\\ParametrosCfdi.xml;  Parametros: <servidor>...<servidor>, <segurida integrada>1</seguridad integrada>, <usuariosql>sa</usuariosql>";
                //rutapar += "< passwordsql >-</ passwordsql >";               
                //MessageBox.Show(rutapar); //parámetros y ruta de conexión   

                //Definos un objeto de parametros xml y cargo el archvio xml                
                XmlDocument listaParametros = new XmlDocument();
                listaParametros.Load(new XmlTextReader("ParametrosQR.xml"));                
                //Empiezo a leer el archivo de parámetros xml
                XmlNodeList listaElementos = listaParametros.DocumentElement.ChildNodes;
                foreach (XmlNode n in listaElementos)
               {
                    //MessageBox.Show("Inner "+ n.InnerXml + " Name " + n.Name);
                    if (n.Name.Equals(sertip))
                    {
                        //Guardo el path donde se va a a guardar la imágen png del QR
                        path = n.InnerXml;
                        //MessageBox.Show(path);
                    } 
                    
                }

                //crear un arreglo de la cadena
                nomarchivo = cadena;
                string[] arrcad = nomarchivo.Split(',');
                //tomar la subcadena del número de comprobante
                //nomarchivo = arrcad[5];
                nomarchivo = arrcad[12];
                //reemplazar caracteres no usados para nombre de archivo
                //nomarchivo = (nomarchivo.Replace(":", "- ").Replace('"', ' ').Replace("\\", " ")).Trim();

                //1 solución para tomar solo los caracteres numéricos de la subcadena. No funciono sale tambien el nombre de la etiqueta en letras
                //Regex rgx = new Regex("^[0-9]");
                //nomarchivo = rgx.Replace(nomarchivo, "");
                //MessageBox.Show(nomarchivo);
                //2 Solución para tomar los caracteres numéricos de la subcadena
                nomarchivo = nomarchivo.Replace("\"codAut\":", "").Replace("}","");
                //MessageBox.Show(nomarchivo);                
          
                //Genero el código QR segun la librería MessagingToolkit.QRCode
                if (libreria == 1)
                {
                    //Crear una instancia QREncoder
                    MessagingToolkit.QRCode.Codec.QRCodeEncoder encoder = new MessagingToolkit.QRCode.Codec.QRCodeEncoder();
                    //escala del código QR
                    encoder.QRCodeScale = 3;
                    //conversor de cadena en byte
                    byte[] Byte = System.Text.Encoding.UTF8.GetBytes(cadena);
                    //conversor de byte a base 64
                    string cadenaBase64 = Convert.ToBase64String(Byte);
                    string cadenaFinal = "https:/www.afip.gob.ar/fe/qr/?p=" + cadenaBase64;
                    //MessageBox.Show(cadenaFinal);
                    //convertir una cadenabase64 en un codigo QR
                    Bitmap bmp = encoder.Encode(cadenaFinal);
                    //guardar la imágen QR resultante en una ruta específica            
                    //bmp.Save(@path + "\\" + nomarchivo + ".png", ImageFormat.Png);
                    bmp.Save(@path + nomarchivo + ".png", ImageFormat.Png);
                    //MessageBox.Show(@path + nomarchivo + ".png");
                    //bmp.Save(nomarchivo + ".png", ImageFormat.Png);
                    //MessageBox.Show("Se genero el código QR: " + nomarchivo + ".png");
                }
                //genero el código QR según la librería ThoughtWorks.QRCode
                else if (libreria == 2)
                {
                    
                    //Crear una instancia QREncoder
                    //QRCodeEncoder qrCodeEncoder = new QRCodeEncoder();
                    //conversor de cadena en byte
                    //byte[] Byte = System.Text.Encoding.UTF8.GetBytes(cadena);
                    //conversor de byte a base 64
                    //string cadenaBase64 = Convert.ToBase64String(Byte);
                    //definir la escala del código QE
                    //qrCodeEncoder.QRCodeScale = 3;
                    //genrar el código QR
                    //Image img = qrCodeEncoder.Encode(cadenaBase64);
                    //crear una instancia de tipo Bitmap
                    //Bitmap bmp = new Bitmap(img);
                    //Guardar la ímágen QR resultante en una ruta específica  
                    //bmp.Save(@path + "\\" + nomarchivo + ".png", ImageFormat.Png);
                }
                else
                {
                    //Genero el QR segun la librería Gma.QRCodeNet.Encoding
                    QrEncoder qrencoder = new QrEncoder(ErrorCorrectionLevel.H);
                    QrCode qrCode = new QrCode();
                    qrencoder.TryEncode(cadena, out qrCode);
                    //crea el grafico
                    GraphicsRenderer renderer = new GraphicsRenderer(new FixedCodeSize(400, QuietZoneModules.Zero), Brushes.Black, Brushes.White);
                    MemoryStream ms = new MemoryStream();
                    renderer.WriteToStream(qrCode.Matrix, ImageFormat.Png, ms);
                    var imagentemporal = new Bitmap(ms);
                    var bmp = new Bitmap(imagentemporal, new Size(new Point(200, 200)));
                    bmp.Save(@path + "\\" + nomarchivo + ".png", ImageFormat.Png);
                    //bmp.Save(nomarchivo + ".png", ImageFormat.Png);
                    //MessageBox.Show("Se genero el código QR: " + nomarchivo + ".png");
                }
                //Cerrar conexión
                //conexion.Close();
            }
            catch(Exception ex)
            {
                MessageBox.Show("Error de conexión: " + ex.Message);
            }
        }
    }    
}
