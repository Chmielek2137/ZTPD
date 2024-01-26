

(:28 for $k in doc('file:///D:/PP/Zaawansowane technologie przetwarzania danych/Laboratorium/L5/XPath-XSLT/swiat.xml')/SWIAT/KRAJE/KRAJ[starts-with(NAZWA, 'A')]:)

(:for $k in doc('file:///D:/PP/Zaawansowane technologie przetwarzania danych/Laboratorium/L5/XPath-XSLT/swiat.xml')/SWIAT/KRAJE/KRAJ[starts-with(NAZWA, substring(STOLICA,1,1))]
return <KRAJ>
  {$k/NAZWA, $k/STOLICA}
</KRAJ>:)

(:30 doc('D:/PP/Zaawansowane technologie przetwarzania danych/Laboratorium/L5/XPath-XSLT/swiat.xml')//KRAJ:)

(:32doc('D:/PP/Zaawansowane technologie przetwarzania danych/Laboratorium/L5/XPath-XSLT/zesp_prac.xml')//NAZWISKO:)

(:33 doc('D:/PP/Zaawansowane technologie przetwarzania danych/Laboratorium/L5/XPath-XSLT/zesp_prac.xml')//ZESPOLY/ROW[NAZWA='SYSTEMY EKSPERCKIE']//NAZWISKO/text() :)

(:34 count(doc('D:/PP/Zaawansowane technologie przetwarzania danych/Laboratorium/L5/XPath-XSLT/zesp_prac.xml')
//ZESPOLY/ROW[ID_ZESP='10']//NAZWISKO):)

(:35 doc('D:/PP/Zaawansowane technologie przetwarzania danych/Laboratorium/L5/XPath-XSLT/zesp_prac.xml')
//PRACOWNICY/ROW[ID_SZEFA='100']/NAZWISKO :)

(:35 :) sum(doc('D:/PP/Zaawansowane technologie przetwarzania danych/Laboratorium/L5/XPath-XSLT/zesp_prac.xml')
//ZESPOLY/ROW[PRACOWNICY/ROW/NAZWISKO='BRZEZINSKI']/PRACOWNICY/ROW/PLACA_POD)