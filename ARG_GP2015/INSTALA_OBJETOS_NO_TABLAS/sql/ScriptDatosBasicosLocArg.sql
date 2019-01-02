SET ANSI_WARNINGS off

if (select COUNT(*) from nfTII_SY40001)=0
BEGIN
	INSERT INTO nfTII_SY40001 (CLFSCLBL,CLFSCMSK,CFCMPNY,CFRM,CFPM)
	VALUES ('C.U.I.T.',1,1,1,1)
END 
if (select count(*) from nfTII_SY40002)=0
begin
	insert into nfTII_SY40002 (nfDOCTYP,DSCRIPTN,nfVALIDT)
	values (80,'C.U.I.T',1),
	(83,'Ident. contribuyente en el exte',0),
	(84,'Documento externo',0),
	(86,'C.U.I.L.',0),
	(87,'C.D.I.',0),
	(96,'DNI',0)
end
if (select count(*) from nfMCP00100)=0
begin
	insert into nfMCP00100(NUMBERID,DSCRIPTN,NEXTNUM)
	values('R-IVA','Retención IVA','00000001'),
	('R-IIBBA','Retención IIBB ARBA','00000001'),
	('R-IIBBC','Retención IIBB CABA','00000001'),
	('R-SUSS','Retención SUSS','00000001'),
	('R-GAN','Retención Ganancias','00000001'),
	('DEPO','Depósito en Cuenta Bancaria','00000001'),
	('RECCOB','Recibos de Cobranza','00000001'),
	('RECVRS','Recibos Varios','00000001'),
	('OP','Pago Proveedores','00000001'),
	('PAGVAR','Pagos Varios','00000001')
end
if (select COUNT(*) from nfMCP00200)=0
begin
	insert into nfMCP00200(GRUPID,DSCRIPTN)
	values('C-RETENC','Cobros - Retenciones'),
	('P-RETENC','Pagos - Retenciones'),
	('TESO','Tesorería')
end
if (select count(*) from nfMCP00600)=0
begin
	insert into nfMCP00600(MCPTYPID,DSCRIPTN,NUMBERID,INGEGR,TYPESTAT,DEPOSIT,ISRFC)
	values('DEPOSITOS','Depósitos','DEPO',1,1,1,0),
	('COBRANZA CLIENTE','Cobranza a Clientes','RECCOB',0,1,0,0),
	('INGRESOS VARIOS','Ingresos Varios','RECVRS',0,1,0,0),
	('PAGO PROVEEDORES','Pago a Proveedores','PAGPRO',1,1,0,0),
	('PAGOS VARIOS','Pagos Varios','PAGVRS',1,1,0,0)
end
if (select count(*) from nfRFC_SY00101)=0
begin
	insert into nfRFC_SY00101(NFRFCDSCPT,NFRFCTXCOND,NFRFCTXCOD,NFRFCSCHM)
	values('Responsable Inscripto',1,'01',0),
	('IVA sujeto exento',3,'04',0),
	('Consumidor final',4,'05',0),
	('Responsable Monotributo',5,'06',0)
end
if (select count(*) from TII_MCP_GL70001)=0
begin
	insert into TII_MCP_GL70001(RPRTNAME,IFFILXST,EXPTTYPE,ASKECHTM,PRNTOFIL,PRTOPRTR,PRTOSCRN,EstadoSeleccionado,HabilitarReimpresion,TextoReimpresion,IMPASIENTO,TextoNoContabilizados,FromEntityType,ToEntityType)
	values('Recibo',0,1000,0,0,0,1,2,1,'ES COPIA',1,'.',0,0)
end
IF (SELECT COUNT(*) FROM TII_MCP_GL70100)=0
BEGIN
	INSERT INTO TII_MCP_GL70100(RPRTNAME,IFFILXST,EXPTTYPE,ASKECHTM,PRNTOFIL,PRTOPRTR,PRTOSCRN,EstadoSeleccionado,RGPRINT,IMPASIENTO,HabilitarReimpresion,TextoNoContabilizados,FromEntityType,ToEntityType,MediosOrRetencion)
	VALUES('OrdenPago',0,2000,0,0,0,1,2,2,1,1,'-',0,0,1)
END
IF (SELECT COUNT(*) FROM nfRET_GL00010)=0
BEGIN
INSERT INTO nfRET_GL00010(nfRET_Tipo_ID,nfRET_Rutina_de_calculo,nfRET_Descripcion,RPTCERT,TII_Incluido_Reproweb,TII_En_Regimen_M)
	VALUES('GCIA',1,'RETENCION GANANCIAS',1,0,0),
	('IIBB',3,'RETENCION DE IIBB',1,0,0),
	('IVA',2,'RETENCION IVA',1,0,0),
	('SUSS',5,'RETENCION DE SUSS',1,0,0),
	('IIBB ARBA',4,'IIBB ARBA',1,0,0),
	('IIBB CABA',3,'IIBB CABA',1,0,0)
END
IF (SELECT COUNT(*) FROM nfRET_GL00050)=0
BEGIN
	INSERT INTO nfRET_GL00050(nfRET_Escala_ID,nfRET_Descripcion)
	VALUES('GCIA','RET GCIA')
END
IF (SELECT COUNT(*) FROM nfRET_GL00040)=0
BEGIN
	INSERT INTO nfRET_GL00040 (nfRET_Escala_ID,nfRET_Impuesto_desde,nfRET_Impuesto_hasta,nfRET_Porcentaje,nfRET_Importe_fijo)
	VALUES('GCIA',0,4999.99,5,0),
	('GCIA',5000.00,9999.99,9,250.00),
	('GCIA',10000.00,14999.99,12,700.00),
	('GCIA',15000.00,19999.99,15,1300.00),
	('GCIA',20000.00,29999.99,19,2050.00),
	('GCIA',30000.00,39999.99,23,3950.00),
	('GCIA',40000.00,59999.99,27,6250.00),
	('GCIA',60000.00,99999999.99,31,11650.00)
END
IF (SELECT COUNT(*) FROM nfRET_GL00070)=0
BEGIN
	INSERT INTO nfRET_GL00070(nfRET_Base_ID,nfRET_Descripcion,nfRET_Fletes,nfRET_Varios,nfRET_Impuestos,nfRET_Descuento,nfRET_Compras,nfRET_CalculateBasedOn)
	VALUES('GCIA','Retención de Ganancias',1,1,0,1,0,1),
	('IIBB','Retencion de Ingresos Brutos',1,1,1,0,0,1),
	('IVA','Retencion de IVA',0,0,0,0,0,0),
	('SUSS','Retencion de SUSS',1,1,1,0,0,1)
END
IF (SELECT COUNT(*) FROM DYNAMICS..AWLI40330)=0
BEGIN
	INSERT INTO DYNAMICS..AWLI40330(RESP_TYPE,RESPBLE)
	VALUES('01','IVA Responsable Inscripto'),
	('02','IVA Responable No Inscripto'),
	('03','IVA No Responsable'),
	('04','IVA Sujeto Excento'),
	('05','Consumidor Final'),
	('06','Responsable Monotributo'),
	('07','Sujeto No Categorizado'),
	('08','Importador del Exterior'),
	('09','Cliente del Exterior'),
	('10','IVA Liberado Ley 19.640'),
	('11','IVA Resp Ins. Ag de Percep')
END
IF (SELECT COUNT(*) FROM DYNAMICS..AWLI40310)=0
BEGIN
	INSERT INTO DYNAMICS..AWLI40310(COD_COMP,COMP,LETRA,FORMAT_DOC)
	VALUES('00','Información Global',5,0),
	('01','Facturas A',1,1),
	('02','Nota de Débito A',1,1),
	('03','Nota de Crédito A',1,1),
	('04','Recibos A',1,1),
	('05','Notas de Venta al Contado',1,1),
	('06','Facturas B',2,1),
	('07','Nota de Débito B',2,1),
	('08','Nota de Crédito B',2,1),
	('09','Recibos B',2,1),
	('10','Notas de Venta al Contado B',2,1),
	('11','Factura C',3,1),
	('12','Nota de Débito C',3,1),
	('13','Nota de Crédito C',3,1),
	('14','Documento Aduanero',5,0),
	('15','Recibos C',3,1),
	('16','Nota de Venta al Contado C',3,1),
	('19','Facturas de Exportación',4,1),
	('20','Nota de Débito por Op Exterior',4,1),
	('21','Nota de Crédito por Op Exterio',4,1),
	('22','Facturas Perm Exp Simplific',4,1),
	('30','Comprobantes Compra Bs Usados',5,0),
	('34','Comprobantes A art 3 inc e',1,1),
	('35','Comprobantes B art 3 inc e',2,1),
	('36','Comprobantes C art 3 inc e',3,1),
	('37','Notas de Débito o Doc equiv',5,0),
	('38','Notas de Crédito o Doc equiv',5,0),
	('39','Otros Comprobantes A RG 1415',1,1),
	('40','Otros Comprobantes B RG 1415',2,1),
	('41','Otros Comprobantes C RG 1514',3,1),
	('51','Factura M',6,1),
	('52','Nota de Débito M',6,1),
	('53','Nota de Crédito M',6,1),
	('54','Recibos M',6,1),
	('55','Notas de Venta al Contado M',6,1),
	('56','Comprobantes M RG 1415',6,	1),
	('57','Otros Comprobantes M RG 1415',   	6,	1),
	('58','Cta de Vtas y Liq Producto M',   	6,	1),
	('59','Liquidación M',6,	1),
	('60','Cta Vta y Liq Producto A',6,1),
	('61','Cta Vta y Liq Producto B',2,	1),
	('62','Cta Vta y Liq Producto C',       	3,	1),
	('63','Liquidación A',                  	1,	1),
	('64','Liquidación B',                  	2,	1),
	('65','Liquidación C',                  	3,	1),
	('66','Despacho de Importación',        	5,	0),
	('80','Comprobante Diario de Cierre Z', 	5,	0),
	('81','Tiquet Factura A',               	1,	1),
	('82','Tiquet Factura B',               	2,	1),
	('83','Tiquet',                         	5,	0),
	('84','Compr/FC de Serv Públicos',      	5,	0),
	('85','NC-Servicios Públicos',          	5,	0),
	('86','ND-Servicios Públicos',          	5,	0),
	('87','Otros Comprob Serv del Exterio', 	5,	0),
	('88','Otros Comprob Doc Exceptuados',  	5,	0),
	('89','Otros Comprob Doc Excep ND',     	5,	0),
	('90','Otros Comprob Doc Excep NC',     	5,	0),
	('91','Comproba/Facturas Serv Público', 	5,	0),
	('92','Ajuste Contab Increm Deb Fisca', 	5,	0),
	('93','Ajuste Contab Dism Deb Fisc',    	5,	0),
	('94','Ajuste Contab Increm Cred Fisc', 	5,	0),
	('95','Ajuste Contab Dism Cred Fiscal', 	5,	0),
	('96','Formulario 1116/B',              	2,	1),
	('97','Formulario 1116/C',              	3,	1),
	('99','Otros Comprobantes',             	5,	0)
END
if (select count(*) from nfRET_SM40010)=0
begin
	insert into nfRET_SM40010 (Tipo,nfRET_ID_Codigo_Operacin,nfRET_Entidad_Fiscal,nfRET_File_Code)
	values(1,1,1,1),
	(2,2,1,2)
end
if (select count(*) from nfRET_SM40020)=0
begin
	insert into nfRET_SM40020(nfRET_File_Code,Descripcion,nfRET_ID_Condicion)
	values('00','Ninguna','00'),
	('01','Inscripto','01'),
	('02','No Inscripto','02'),
	('03','No categorizado','03'),
	('06','Contratación hora día estadía','06'),
	('07','Contratación mensual','07'),
	('08','Incl. en el Reg Fis. de Granos','08'),
	('09','No Incl. en el Reg. Fis. de Gr','09'),
	('10','Inscripto demás sujetos','10'),
	('11','Insc. Ret. IVA Est. de Serv.','11'),
	('12','Servicios Públicos','12'),
	('13','Vta. Muebles y Loc Ali Gral.','13'),
	('14','Vta. Muebles y Loc Ali Red.','14'),
	('15','Retención Sustitutiva','15')
end
if (select count(*) from nfRET_SM40030)=0
begin
insert into nfRET_SM40030(nfRET_ID_Provincia,Descripcion,nfRET_File_Code)
values('00','Capital Federal','00'),
('01','Buenos Aires','01'),
('02','Catamarca','02'),
('03','Córdoba','03'),
('04','Corrientes','04'),
('05','Entre Ríos','05'),
('06','Jujuy','06'),
('07','Mendoza','07'),
('08','La Rioja','08'),
('09','Salta','09'),
('10','San Juan','10'),
('11','San Luis','11'),
('12','Santa Fe','12'),
('13','Santiago del Estero','13'),
('14','Tucumán','14'),
('16','Chaco','16'),
('17','Chubut','17'),
('18','Formosa','18'),
('19','Misiones','19'),
('20','Neuquén','20'),
('21','La Pampa','21'),
('22','Río Negro','22'),
('23','Santa Cruz','23'),
('24','Tierra del Fuego','24'),
('99','No se Informa Provincia','99')
end
if (select count(*) from nfRET_SM40040)=0
begin
	insert into nfRET_SM40040(nfRET_ID_Impuesto,nfRET_File_Code,Descripcion)
	values('217','217','Impuesto a las Ganancias'),
	('218','218','Imp. a las Gan. - Ben del Ext.'),
	('767','767','Impuesto al Valor Agregado'),
	('PIB','PIB','Percepción de Ingresos Brutos')
end 
if (select count(*) from nfRET_SM40050)=0
begin
insert into nfRET_SM40050(nfRET_ID_Codigo_Operacin,nfRET_ID_Regimen,nfRET_File_Code,Descripcion)
	values(1,30,30,'Alquiler Inmuebles'),
	(1,94,94,'Loc de Obra / Prest Serv'),
	(1,167,167,'Beneficiarios del Exterior'),
	(1,116,116,'Honorarios Dir / Prof Liberale'), 
	(1,78,78,'Enaj Bs Cambio y Muebles'),       
	(1,19,19,'Intereses Oper Ent Financieras'), 
	(1,21,21,'Int Oper No Financ'),
	(1,31,31,'Bienes Inmuebles Urbanos'),
	(1,86,86,'Transf derechos llave, marcas'),
	(1,25,25,'Comisiones u otras retribuc'),
	(1,124,124,'Corredor, Desp Aduana, Viajant')
end 
if (select count(*) from nfRET_SM40060)=0
begin
	insert into nfRET_SM40060(nfRET_Codigos_Compras_1,nfRET_Codigos_Compras_2,nfRET_Codigos_Compras_3,nfRET_Codigos_Compras_4,nfRET_Codigos_Compras_5,nfRET_Codigos_Compras_6,nfRET_Codigos_Compras_7,nfRET_Codigos_Ventas_1,nfRET_Codigos_Ventas_2,nfRET_Codigos_Ventas_3,nfRET_Codigos_Ventas_4,nfRET_Codigos_Ventas_5,nfRET_Codigos_Ventas_6,nfRET_Codigos_Ventas_7,nfRET_Codigos_Ventas_8,nfRET_Codigos_Ventas_9,nfRET_Codigos_Ventas_10,SEQNUMBR)
	values('01','04','04','03','03','','','01','01','04','05','05','','03','03','','','')
end
if (select count(*) from nfRET_SM40070)=0
begin
	insert into nfRET_SM40070(nfRET_Entidad_Fiscal,nfRET_Nombre_Archivo,nfRET_Tipo_Archivo,nfRET_Separador_Decimal)
	values(1,'retenciones.txt',1,2),
	(1,'sujetos.txt',2,2)
end
if (select count(*) from nfret_sm40071)=0
begin
	insert into nfret_sm40071(nfRET_Entidad_Fiscal,nfRET_Campo_Archivo,nfRET_Tipo_Dato,nfRET_Posicin,nfRET_Longitud,nfRET_Tipo_Archivo)
	values(1,	1,	1,	1,	2,	1),
	(1,	2,	3,	3,	10,	1),
	(1,	3,	4,	13,	16,	1),
	(1,	4,	2,	29,	16,	1),
	(1,	5,	1,	45,	3,	1),
	(1,	6,	1,	48,	3,	1),
	(1,	7,	1,	51,	1,	1),
	(1,	8,	2,	52,	14,	1),
	(1,	9,	3,	66,	10,	1),
	(1,	10,	1,	76,	2,	1),
	(1,	11,	1,	78,	1,	1),
	(1,	12,	2,	79,	14,	1),
	(1,	13,	2,	93,	6,	1),
	(1,	14,	3,	99,	10,	1),
	(1,	15,	4,	109,	2,	1),
	(1,	16,	1,	111,	20,	1),
	(1,	17,	4,	131,	14,	1),
	(1,	18,	1,	145,	30,	1),
	(1,	19,	4,	175,	1,	1),
	(1,	20,	4,	176,	11,	1),
	(1,	21,	4,	187,	11,	1),
	(1,	1,	4,	1,	11,	2),
	(1,	2,	4,	12,	20,	2),
	(1,	3,	4,	32,	20,	2),
	(1,	4,	4,	52,	20,	2),
	(1,	5,	1,	72,	2,	2),
	(1,	6,	4,	74,	8,	2),
	(1,	7,	1,	82,	2,	2)
end
if (select count(*) from SY04100)=0
begin
	insert into SY04100(BANKID,BANKNAME)
	values('007','BANCO DE GALICIA Y BUENOS AIRES S.A.'),
	('011',	'BANCO DE LA NACION ARGENTINA'),
	('014',	'BANCO DE LA PROVINCIA DE BUENOS AIRES'),
	('015',	'INDUSTRIAL AND COMMERCIAL BANK OF CHINA'),
	('016',	'CITIBANK N.A.'),
	('017',	'BBVA BANCO FRANCES S.A.'),
	('018',	'THE BANK OF TOKYO-MITSUBISHI UFJ, LTD.'),
	('020',	'BANCO DE LA PROVINCIA DE CORDOBA S.A.'),
	('027',	'BANCO SUPERVIELLE S.A.'),
	('029',	'BANCO DE LA CIUDAD DE BUENOS AIRES'),
	('034',	'BANCO PATAGONIA S.A.'),
	('044',	'BANCO HIPOTECARIO S.A.'),
	('045',	'BANCO DE SAN JUAN S.A.'),
	('060',	'BANCO DEL TUCUMAN S.A.'),
	('065',	'BANCO MUNICIPAL DE ROSARIO'),
	('072',	'BANCO SANTANDER RIO S.A.'),
	('083',	'BANCO DEL CHUBUT S.A.'),
	('086',	'BANCO DE SANTA CRUZ S.A.'),
	('093',	'BANCO DE LA PAMPA SOCIEDAD DE ECONOMÍA M'),
	('094',	'BANCO DE CORRIENTES S.A.'),
	('097',	'BANCO PROVINCIA DEL NEUQUÉN SOCIEDAD ANÓ'),
	('147',	'BANCO INTERFINANZAS S.A.'),
	('150',	'HSBC BANK ARGENTINA S.A.'),
	('165',	'JPMORGAN CHASE BANK, NATIONAL ASSOCIATIO'),
	('191',	'BANCO CREDICOOP COOPERATIVO LIMITADO'),
	('198',	'BANCO DE VALORES S.A.'),
	('247',	'BANCO ROELA S.A.'),
	('254',	'BANCO MARIVA S.A.'),
	('259',	'BANCO ITAU ARGENTINA S.A.'),
	('262',	'BANK OF AMERICA, NATIONAL ASSOCIATION'),
	('266',	'BNP PARIBAS'),
	('268',	'BANCO PROVINCIA DE TIERRA DEL FUEGO'),
	('269',	'BANCO DE LA REPUBLICA ORIENTAL DEL URUGU'),
	('277',	'BANCO SAENZ S.A.'),
	('281',	'BANCO MERIDIAN S.A.'),
	('285',	'BANCO MACRO S.A.'),
	('299',	'BANCO COMAFI SOCIEDAD ANONIMA'),
	('300',	'BANCO DE INVERSION Y COMERCIO EXTERIOR S'),
	('301',	'BANCO PIANO S.A.'),
	('303',	'BANCO FINANSUR S.A.'),
	('305',	'BANCO JULIO SOCIEDAD ANONIMA'),
	('309',	'BANCO RIOJA SOCIEDAD ANONIMA UNIPERSONAL'),
	('310',	'BANCO DEL SOL S.A.'),
	('311',	'NUEVO BANCO DEL CHACO S. A.'),
	('312',	'BANCO VOII S.A.'),
	('315',	'BANCO DE FORMOSA S.A.'),
	('319',	'BANCO CMF S.A.'),
	('321',	'BANCO DE SANTIAGO DEL ESTERO S.A.'),
	('322',	'BANCO INDUSTRIAL S.A.'),
	('325',	'DEUTSCHE BANK S.A.'),
	('033',	'NUEVO BANCO DE SANTA FE SOCIEDAD ANONIMA'),
	('331',	'BANCO CETELEM ARGENTINA S.A.'),
	('332',	'BANCO DE SERVICIOS FINANCIEROS S.A.'),
	('336',	'BANCO BRADESCO ARGENTINA S.A.'),
	('338',	'BANCO DE SERVICIOS Y TRANSACCIONES S.A.'),
	('339',	'RCI BANQUE S.A.'),
	('340',	'BACS BANCO DE CREDITO Y SECURITIZACION S'),
	('341',	'BANCO MASVENTAS S.A.'),
	('386',	'NUEVO BANCO DE ENTRE RÍOS S.A.'),
	('389',	'BANCO COLUMBIA S.A.'),
	('426',	'BANCO BICA S.A.'),
	('431',	'BANCO COINAG S.A.'),
	('432',	'BANCO DE COMERCIO S.A.')
end
SET ANSI_WARNINGS on