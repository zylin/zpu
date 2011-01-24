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

    <xsl:variable name="nodeslice_reg">
        <xsl:call-template name="slice_reg" />
    </xsl:variable>

    <xsl:variable name="nodeluts">
        <xsl:call-template name="luts" />
    </xsl:variable>

    <xsl:variable name="nodelutram">
        <xsl:call-template name="lutram" />
    </xsl:variable>

    <xsl:variable name="nodebrams">
        <xsl:call-template name="brams" />
    </xsl:variable>

    <xsl:variable name="nodemul_dsp">
        <xsl:call-template name="mul_dsp" />
    </xsl:variable>

<!--<node name="{$nodename}" size="{$nodeslices}" created="{substring(concat('0000',$nodebrams),1+string-length($nodebrams),4)}-01-01 00:00:00">-->
    <node name="{$nodename}" slices="{$nodeslices}" slice_reg="{$nodeslice_reg}" luts="{$nodeluts}" lutram="{$nodelutram}" brams="{$nodebrams}" mul_dsp="{$nodemul_dsp}">
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


<xsl:template name="slice_reg">
    <xsl:for-each select="item">
            <xsl:if test="@stringID='MAP_SLICE_REG'">
                <xsl:value-of select="@value" />
            </xsl:if>
    </xsl:for-each>
</xsl:template>


<xsl:template name="luts">
    <xsl:for-each select="item">
            <xsl:if test="@label='LUTs'">
                <xsl:value-of select="@value" />
            </xsl:if>
    </xsl:for-each>
</xsl:template>


<xsl:template name="lutram">
    <xsl:for-each select="item">
            <xsl:if test="@label='LUTRAM'">
                <xsl:value-of select="@value" />
            </xsl:if>
    </xsl:for-each>
</xsl:template>


<xsl:template name="brams">
    <xsl:for-each select="item">
            <xsl:if test="@stringID='MAP_BRAM' or @stringID='MAP_BRAM_FIFO'">
                <xsl:value-of select="@value" />
            </xsl:if>
    </xsl:for-each>
</xsl:template>


<xsl:template name="mul_dsp">
    <xsl:for-each select="item">
            <xsl:if test="@stringID='MAP_MULT18X18' or @label='DSP48A1'">
                <xsl:value-of select="@value" />
            </xsl:if>
    </xsl:for-each>
</xsl:template>


</xsl:stylesheet>
