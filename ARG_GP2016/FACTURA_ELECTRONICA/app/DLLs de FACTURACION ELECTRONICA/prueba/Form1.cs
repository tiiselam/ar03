using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using AFIP_GenerarQR;
using ACA_WSFE;

namespace prueba
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            //Principal pri = new Principal();
        }
        public string ArmarCadena(
        string ver,
        string fecha_cbte,
        string cuit,
        string punto_vta,
        string tipo_cbte,
        string cbt_desde,
        string imp_total,
        string moneda,
        string tipo_cbio,
        string tipo_doc,
        string nro_doc,
        string tipo_cod_aut,
        string cbte_cae)
        {
        string cadena = "";
        //armar la cadena
        cadena = "{\"ver\":" +  ver + ",\"fecha\":\"" + fecha_cbte + "\",\"cuit\":" + cuit + ",\"ptoVta\":" + punto_vta;
        cadena += ",\"tipoCmp\":" + tipo_cbte + ",\"nroCmp\":" + cbt_desde + ",\"importe\":" + imp_total + ",\"moneda\":\""  + moneda;
            cadena += "\",\"ctz\":" + tipo_cbio + ",\"tipoDocRec\":" + tipo_doc + ",\"nroDocRec\":" + nro_doc + ",\"tipoCodAut\":\"" + tipo_cod_aut + "\",\"codAut\":" + cbte_cae + "}";
        MessageBox.Show(cadena);
        return cadena;
        }    

        private void button1_Click(object sender, EventArgs e)
        {
            //ConexionDB conexion = new ConexionDB();
            //Generarqr qr = new Generarqr("", 1); 

            //defino parametros del DLL y la inicializo a todas
            string cadena = ""; //cadena a codificar en formato json
            int libreria; //libreria a ejecutar para construir el qr. Puese ser 1 0 3
            string sertip = ""; //tipo de servidor. Aqui vale test o sea de prueba.
            

            //creo ver y tipcodaut y otra varialbes y le pongo valores
            string ver = "1";
            string tipcodaut = "E";
            string cuit = "30000000007";           
            string tipo_doc = "80";
            string nro_doc = "20000000001";
            string tipo_cbte = "1";
            string punto_vta = "10";
            string cbt_desde = "94";            
            string fecha_cbte = "2020-10-13";          
            string moneda = "DOL";
            string tipo_cbio = "65";            
            string imp_total = "78";
            string cbte_cae = "70417054367476";

            //llamar a la funcion armar la cadena
            cadena = ArmarCadena(ver, fecha_cbte, cuit, punto_vta, tipo_cbte, cbt_desde, imp_total, moneda, tipo_cbio, tipo_doc, nro_doc, tipcodaut, cbte_cae);
            MessageBox.Show("cadena: " + cadena);
            //gGrabaLog("CADENA   " & cadena)

            //Defino el servidor como de prueba
            sertip = "rutatestqr";
            //Usar la libreriía 1 para calcular el QR. También se puede usar el 3.
            libreria = 1;
            //Defino instancia de la libreria dll y llamo al constructor
            //Dim gqr As New Generarqr(cadena, libreria)
            Generarqr gqr = new Generarqr(cadena, libreria, sertip);

            
            //Principal pri = new Principal();
            //pri.ObtieneCAEPIMSAL(cuit, strId, strigstrToken, strSign, strcantidadreg, presta_serv,
                                //tipo_doc, nro_doc, tipo_cbte, punto_vta, cbt_desde, cbt_hasta,
                                //imp_total, imp_tot_conc, imp_neto, impto_liq, impto_liq_rni,
                                //imp_op_ex, imp_trib, fecha_cbte, fecha_serv_desde, fecha_serv_hasta,
                                //fecha_venc_pago, concepto, moneda, tipo_cbio, tributos, ivastr,
                                //adicionalesstr, cbtesasocstr);
        }        

    }
}
