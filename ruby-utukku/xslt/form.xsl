<?xml version="1.0" ?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://dh.tamu.edu/ns/fabulator/1.0#"
  exclude-result-prefixes="f"
  version="1.0"
>
  <xsl:output
    method="html"
    indent="yes"
  />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="//f:form">
    <xsl:choose>
      <xsl:when test="''">
        <xsl:call-template name="form-content" />
      </xsl:when>
      <xsl:otherwise>
        <form>
          <xsl:attribute name="type">application/x-multipart</xsl:attribute>
          <xsl:attribute name="method">POST</xsl:attribute>
          <xsl:attribute name="class">fabulator-form</xsl:attribute>
          <xsl:call-template name="form-content" />
        </form>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="form-content">
    <xsl:param name="form_level">1</xsl:param>
    <table class="form-content" border="0" cellspacing="0" cellpadding="0">
      <xsl:apply-templates select="f:text|f:asset|f:password|f:selection|f:form|f:group">
        <xsl:with-param name="form_level"><xsl:value-of select="$form_level" /></xsl:with-param>
      </xsl:apply-templates>
      <xsl:if test="f:submission|f:reset">
        <tr><td colspan="2" align="center">
          <xsl:apply-templates select="f:submission|f:reset" />
        </td></tr>
      </xsl:if>
    </table>
    <xsl:apply-templates select="f:value" />
  </xsl:template>

  <xsl:template match="f:form/f:form | f:option/f:form">
    <xsl:param name="form_level" />
    <xsl:choose>
      <xsl:when test="f:caption">
        <tr><td colspan="2" class="form-subform">
        <fieldset>
          <legend><xsl:apply-templates select="f:caption" /></legend>
          <xsl:call-template name="form-content">
            <xsl:with-param name="form_level"><xsl:value-of select="$form_level + 1"/></xsl:with-param>
          </xsl:call-template>
        </fieldset>
        </td></tr>
      </xsl:when>
      <xsl:otherwise>
        <tr><td colspan="2">
        <xsl:call-template name="form-content">
          <xsl:with-param name="form_level"><xsl:value-of select="$form_level + 1" /></xsl:with-param>
        </xsl:call-template>
        </td></tr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="f:text">
    <tr><xsl:call-template name="form-caption" />
    <td class="form-element" valign="top">
      <xsl:choose>
        <xsl:when test="@f:rows > 1 or @rows > 1">
          <textarea>
            <xsl:attribute name="name"><xsl:apply-templates select="." mode="id" /></xsl:attribute>
            <xsl:attribute name="rows"><xsl:choose>
              <xsl:when test="@f:rows"><xsl:value-of select="@f:rows"/></xsl:when>
              <xsl:when test="@rows"><xsl:value-of select="@rows"/></xsl:when>
            </xsl:choose></xsl:attribute>
            <xsl:attribute name="cols">
              <xsl:choose>
                <xsl:when test="@f:cols > 132 or @cols > 132">132</xsl:when>
                <xsl:when test="@f:cols"><xsl:value-of select="@f:cols" /></xsl:when>
                <xsl:when test="@cols"><xsl:value-of select="@cols" /></xsl:when>
                <xsl:otherwise>60</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="f:default" />
            <xsl:text> </xsl:text>
          </textarea>
        </xsl:when>
        <xsl:otherwise>
          <input>
            <xsl:attribute name="type">text</xsl:attribute>
            <xsl:attribute name="name"><xsl:apply-templates select="." mode="id" /></xsl:attribute>
            <xsl:attribute name="size">
              <xsl:choose>
                <xsl:when test="@f:cols > 40 or @cols > 40">40</xsl:when>
                <xsl:when test="@f:cols"><xsl:value-of select="@f:cols" /></xsl:when>
                <xsl:when test="@cols"><xsl:value-of select="@cols" /></xsl:when>
                <xsl:otherwise>12</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="value"><xsl:apply-templates select="f:default" /></xsl:attribute>
          </input>
        </xsl:otherwise>
      </xsl:choose>
    </td></tr>
  </xsl:template>

  <xsl:template match="f:password">
    <tr><xsl:call-template name="form-caption" />
    <td class="form-element" valign="top">
      <input>
        <xsl:attribute name="type">password</xsl:attribute>
        <xsl:attribute name="name"><xsl:apply-templates select="." mode="id" /></xsl:attribute>
      </input>
    </td></tr>
  </xsl:template>

  <xsl:template match="f:asset">
    <tr><xsl:call-template name="form-caption" />
    <td class="form-element" valign="top">
      <span class="form-fluid-asset"></span>
      <input>
        <xsl:attribute name="class">form-asset</xsl:attribute>
        <xsl:attribute name="type">file</xsl:attribute>
        <xsl:attribute name="name"><xsl:apply-templates select="." mode="id" /></xsl:attribute>
        <xsl:if test="@f:accept">
          <xsl:attribute name="accept"><xsl:value-of select="@f:accept" /></xsl:attribute>
        </xsl:if>
      </input>
    </td></tr>
  </xsl:template>

  <xsl:template match="f:selection">
    <!-- for now, just handle simple selections -->
    <xsl:param name="form_level"/>
    <tr><xsl:call-template name="form-caption" />
    <td class="form-element" valign="top">
      <xsl:call-template name="field-selection">
        <xsl:with-param name="form_level"><xsl:value-of select="$form_level"/></xsl:with-param>
      </xsl:call-template>
    </td></tr>
  </xsl:template>

  <xsl:template match="f:group">
   <xsl:param name="form_level" />
   <tr><xsl:call-template name="form-caption" />
     <td class="form-element" valign="top">
     <xsl:call-template name="form-content">
       <xsl:with-param name="form_level"><xsl:value-of select="$form_level" /></xsl:with-param>
     </xsl:call-template>
    </td></tr>
  </xsl:template>

  <xsl:template match="f:submission">
    <xsl:choose>
      <xsl:when test="f:caption or f:default">
        <button>
          <xsl:attribute name="type">submit</xsl:attribute>
          <xsl:attribute name="name"><xsl:apply-templates select="." mode="id" /></xsl:attribute>
          <xsl:attribute name="value">
            <xsl:choose>
              <xsl:when test="f:default">
                <xsl:value-of select="f:default" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="f:caption" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="f:caption" />
        </button>
      </xsl:when>
      <xsl:otherwise>
        <input>
          <xsl:attribute name="type">submit</xsl:attribute>
          <xsl:attribute name="name"><xsl:apply-templates select="." mode="id" /></xsl:attribute>
          <xsl:attribute name="value">
            <xsl:choose>
              <xsl:when test="f:default">
                <xsl:value-of select="f:default" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="f:caption" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </input>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="f:reset">
    <xsl:choose>
      <xsl:when test="f:caption">
        <button>
          <xsl:attribute name="type">reset</xsl:attribute>
          <xsl:attribute name="name"><xsl:apply-templates select="." mode="id" /></xsl:attribute>
          <xsl:apply-templates select="f:caption" />
        </button>
      </xsl:when>
      <xsl:otherwise>
        <input>
          <xsl:attribute name="type">reset</xsl:attribute>
          <xsl:attribute name="name"><xsl:apply-templates select="." mode="id" /></xsl:attribute>
          <xsl:attribute name="value"><xsl:value-of select="f:caption" /></xsl:attribute>
        </input>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="f:value">
    <input>
      <xsl:attribute name="type">hidden</xsl:attribute>
      <xsl:attribute name="name"><xsl:apply-templates select="." mode="id" /></xsl:attribute>
      <xsl:attribute name="value"><xsl:apply-templates select="default" /></xsl:attribute>
    </input>
  </xsl:template>

  <xsl:template match="f:caption">
    <span class="caption"><xsl:apply-templates /></span>
  </xsl:template>

  <xsl:template match="f:default">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template name="field-selection">
    <!-- xsl:param name="form_id"/ -->
    <xsl:param name="form_level"/>
    <xsl:param name="style">
      <xsl:if test="f:option//f:form">
        <xsl:choose>  
          <xsl:when test="@count = 'multiple'">checkbox</xsl:when>
          <xsl:otherwise>radio</xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="not($style) or $style = ''">
        <select>
          <!-- xsl:attribute name="name"><xsl:if test="$form_id != ''"><xsl:value-of select="$form_id"/>.</xsl:if><xsl:value-of select="@id"/></xsl:attribute -->
          <xsl:attribute name="name"><xsl:apply-templates select="." mode="id"/></xsl:attribute>
          <xsl:if test="@count = 'multiple'">
            <xsl:attribute name="multiple"><xsl:text>1</xsl:text></xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="f:option">
          </xsl:apply-templates>
        </select>
      </xsl:when>
      <xsl:otherwise>
        <!-- select -->
          <!-- xsl:attribute name="name"><xsl:if test="$form_id != ''"><xsl:value-of select="$form_id"/>.</xsl:if><xsl:value-of select="@id"/></xsl:attribute -->
          <!-- xsl:attribute name="name"><xsl:apply-templates select="." mode="id"/></xsl:attribute -->
          <!-- xsl:if test="@count = 'multiple'">
            <xsl:attribute name="multiple"/>
          </xsl:if -->
          <span class="form-selection-options">
          <xsl:apply-templates select="f:option">
            <xsl:with-param name="style" select="$style"/>
            <xsl:with-param name="form_level" select="$form_level"/>
            <!-- xsl:with-param name="form_id">
              <xsl:if test="$form_id != ''"><xsl:value-of select="$form_id"/><xsl:text>.</xsl:text></xsl:if>
              <xsl:value-of select="@id"/>
            </xsl:with-param -->
          </xsl:apply-templates>
          </span>
        <!-- /select -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

    <xsl:template match="f:form/f:selection/f:option|f:form//f:group/f:selection/f:option">
    <xsl:param name="style"/>
    <!-- xsl:param name="form_id"/ -->
    <xsl:param name="form_level"/>
    <xsl:choose>
      <xsl:when test="$style = 'radio'">
        <span class="form-selection-option">
        <input>
          <xsl:attribute name="type"><xsl:value-of select="$style"/></xsl:attribute>
          <!-- xsl:attribute name="name"><xsl:value-of select="$form_id"/></xsl:attribute -->
          <xsl:attribute name="name"><xsl:apply-templates select="parent::selection[1]" mode="id"/></xsl:attribute>
          <xsl:attribute name="show">
            <xsl:choose>
              <xsl:when test=".//f:form">
                <xsl:text>rel:</xsl:text>
                <xsl:apply-templates select="." mode="id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>none</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="myid">
            <xsl:choose>
              <xsl:when test="@id">
                <xsl:value-of select="@id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="value"><xsl:value-of select="$myid"/></xsl:attribute>
          <xsl:for-each select="../f:default">
            <xsl:if test=". = $myid">
              <xsl:attribute name="checked"/>
            </xsl:if>
          </xsl:for-each>
        </input>
        <xsl:choose>
          <xsl:when test="f:caption">
            <xsl:choose>
              <xsl:when test="f:caption"><xsl:apply-templates select="f:caption"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="f:help"/>
            <xsl:if test="./f:form">
                <xsl:apply-templates select="f:form" mode="body">
                  <!-- xsl:with-param name="form_id"><xsl:value-of select="$form_id"/>.<xsl:value-of select="@id"/></xsl:with-param -->
                  <xsl:attribute name="name"><xsl:apply-templates select="." mode="id"/></xsl:attribute>
                  <xsl:with-param name="form_level"><xsl:value-of select="$form_level+1"/></xsl:with-param>
                </xsl:apply-templates>
            </xsl:if>
          </xsl:when>
          <xsl:when test="f:form">
            <xsl:if test="f:form/f:caption">
              <xsl:apply-templates select="f:form/f:caption"/>
              <xsl:apply-templates select="f:form/f:help"/>
            </xsl:if>
            <xsl:apply-templates select="f:form" mode="body">
              <!-- xsl:with-param name="form_id"><xsl:value-of select="$form_id"/>.<xsl:value-of select="@id"/></xsl:with-param -->
              <xsl:attribute name="name"><xsl:apply-templates select="." mode="id"/></xsl:attribute>
              <xsl:with-param name="form_level"><xsl:value-of select="$form_level+1"/></xsl:with-param>
            </xsl:apply-templates>
          </xsl:when>
        </xsl:choose>
        </span>
      </xsl:when>
      <xsl:when test="$style = 'checkbox'">
        <span class="form-selection-option">
        <input>
          <xsl:attribute name="type"><xsl:value-of select="$style"/></xsl:attribute>
          <!-- xsl:attribute name="name"><xsl:value-of select="$form_id"/></xsl:attribute -->
          <xsl:attribute name="name"><xsl:apply-templates select="parent::selection[1]" mode="id"/></xsl:attribute>
          <xsl:attribute name="show">
            <xsl:choose>
              <xsl:when test=".//f:form">
                <xsl:text>rel:</xsl:text>
                <xsl:apply-templates select="." mode="id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>none</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="myid">
            <xsl:choose>
              <xsl:when test="@id">
                <xsl:value-of select="@id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="value"><xsl:value-of select="$myid"/></xsl:attribute>
          <xsl:for-each select="../f:default">
            <xsl:if test=". = $myid">
              <xsl:attribute name="checked"/>
            </xsl:if>
          </xsl:for-each>
        </input>
        <xsl:choose>
          <xsl:when test="f:caption">
                <xsl:choose>
                  <xsl:when test="f:caption"><xsl:apply-templates select="f:caption"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="f:help"/>
                <xsl:if test="./form">
                  <xsl:apply-templates select="f:form" mode="body">
                    <!-- xsl:with-param name="form_id"><xsl:value-of select="$form_id"/>.<xsl:value-of select="@id"/></xsl:with-param -->
                    <xsl:attribute name="name"><xsl:apply-templates select="." mode="id"/></xsl:attribute>
                    <xsl:with-param name="form_level"><xsl:value-of select="$form_level+1"/></xsl:with-param>
                  </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="f:form">
              <xsl:if test="f:form/f:caption">
                <xsl:apply-templates select="f:form/f:caption"/>
                <xsl:apply-templates select="f:form/f:help"/>
              </xsl:if>
              <xsl:apply-templates select="f:form" mode="body">
                <!-- xsl:with-param name="form_id"><xsl:value-of select="$form_id"/>.<xsl:value-of select="@id"/></xsl:with-param -->
                <xsl:attribute name="name"><xsl:apply-templates select="." mode="id"/></xsl:attribute>
                <xsl:with-param name="form_level"><xsl:value-of select="$form_level+1"/></xsl:with-param>
              </xsl:apply-templates>
            </xsl:when>
          </xsl:choose>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <option>
          <xsl:variable name="myid">
            <xsl:choose>
              <xsl:when test="@id">
                <xsl:value-of select="@id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="value"><xsl:value-of select="$myid"/></xsl:attribute>
          <xsl:for-each select="../f:default">
            <xsl:if test=". = $myid">
              <xsl:attribute name="selected"/>
            </xsl:if>
          </xsl:for-each>
          <xsl:choose>
            <xsl:when test="f:caption">
              <xsl:value-of select="f:caption"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$myid"/>
            </xsl:otherwise>
          </xsl:choose>
        </option>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="form-caption">
    <td class="form-caption" valign="top">
      <xsl:apply-templates select="f:caption" />
    </td>
  </xsl:template>



  <xsl:template match="*" mode="id">
    <xsl:for-each select="ancestor::*[@id != '']">
      <xsl:value-of select="@id" />
      <xsl:if test="position() != last()">
        <xsl:text>.</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="@id">
      <xsl:if test="ancestor::*[@id != '']">
        <xsl:text>.</xsl:text>
      </xsl:if>
      <xsl:value-of select="@id" />
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
