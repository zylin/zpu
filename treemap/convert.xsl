<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output encoding="UTF-8"/>
<xsl:strip-space elements="*" />
<xsl:preserve-space elements="node" />

<xsl:template match="tree">

    <xsl:if test="@stringID='MAP_MODULE_HIERARCHY'">
        <xsl:apply-templates />
    </xsl:if>

</xsl:template>


<xsl:template match="node">
    
    <xsl:variable name="nodename">
        <xsl:value-of select="@value" />
    </xsl:variable>
    
    <xsl:variable name="nodeslices">
        <xsl:call-template name="slices" />
    </xsl:variable>

    <xsl:variable name="nodebrams">
        <xsl:call-template name="brams" />
    </xsl:variable>

    <node name="{$nodename}" size="{$nodeslices}" created="{substring(concat('0000',$nodebrams),1+string-length($nodebrams),4)}-01-01 00:00:00">
        <xsl:apply-templates /> 
    </node>

</xsl:template>

<xsl:template name="slices">
    <xsl:for-each select="item">
            <xsl:if test="@stringID='MAP_SLICES'">
                <xsl:value-of select="@value" />
<!--                <xsl:value-of select="@ACCUMULATED" />-->
            </xsl:if>
    </xsl:for-each>
</xsl:template>

<xsl:template name="brams">
    <xsl:for-each select="item">
            <xsl:if test="@stringID='MAP_BRAM'">
                <xsl:value-of select="@value" />
<!--                <xsl:value-of select="@ACCUMULATED" />-->
            </xsl:if>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
