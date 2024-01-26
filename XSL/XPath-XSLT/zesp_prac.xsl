<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!--6B-->
    <xsl:template match="/ZESPOLY/ROW">
        <li>
            <!--9-->
            <a href="#{ID_ZESP}">
                <xsl:value-of select="NAZWA"/>
            </a>
        </li>
    </xsl:template>
    <!--7-->
    <xsl:template match="/ZESPOLY/ROW" mode="info">
        <!--9-->
        <b id="{ID_ZESP}">
            NAZWA: <xsl:value-of select="NAZWA"/><br/>
            ADRES: <xsl:value-of select="ADRES"/><br/>
        </b>
        <br/>
        <!--14-->
        <xsl:if test="count(PRACOWNICY/ROW) > 0">
            <!--8-->
            <table border="2">
                <thead>
                    <th>Nazwisko</th>
                    <th>Etat</th>
                    <th>Zatrudniony</th>
                    <th>Placa pod.</th>
                    <th>Id szefa</th>
                </thead>
                <tbody>
                    <xsl:apply-templates select="PRACOWNICY/ROW" mode="emp">
                        <!--10-->
                        <xsl:sort select="NAZWISKO"/>
                    </xsl:apply-templates>
                </tbody>
            </table>
        </xsl:if>
        <!--13-->
        Liczba pracowników: <xsl:value-of select="count(PRACOWNICY/ROW)"/>
        <br />
    </xsl:template>

    <!--8-->
    <xsl:template match="PRACOWNICY/ROW" mode="emp">
        <tr>
            <td><xsl:value-of select="NAZWISKO"/></td>
            <td><xsl:value-of select="ETAT"/></td>
            <td><xsl:value-of select="ZATRUDNIONY"/></td>
            <td><xsl:value-of select="PLACA_POD"/></td>
            <!--<td><xsl:value-of select="ID_SZEFA"/></td>-->
            <!--12-->
            <td>
                <xsl:choose>
                    <xsl:when test="ID_SZEFA">
                        <!--11-->
                        <xsl:value-of select="//PRACOWNICY/ROW[ID_PRAC = current()/ID_SZEFA]/NAZWISKO"/>
                    </xsl:when>
                    <xsl:otherwise>BRAK</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>

    </xsl:template>

    <xsl:template match="/">
        <html>
            <body>
                <!--4: <xsl:apply-templates/> -->
                <h1>ZESPOŁY:</h1>
                <!--6A
                <ol>
                    <xsl:for-each select="ZESPOLY/ROW">
                        <li>
                            <xsl:value-of select="NAZWA"/>
                        </li>
                    </xsl:for-each>
                </ol> -->
                <!--6B-->
                <ol>
                    <xsl:apply-templates select="/ZESPOLY/ROW"/>
                </ol>
                <!--7-->
                <xsl:apply-templates select="/ZESPOLY/ROW" mode="info" />
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>