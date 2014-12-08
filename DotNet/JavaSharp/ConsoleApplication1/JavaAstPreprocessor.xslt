﻿<?xml version="1.0" encoding="utf-8"?>
<!--
JavaSharp, a free Java to C# translator based on ANTLRv4
Copyright (C) 2014  Philip van Oosten

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

https://github.com/pvoosten
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
>
  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="CompilationUnit">
    <CSharp>
      <xsl:apply-templates select="./TypeDeclaration/preceding-sibling::*" />
      <xsl:text>
namespace </xsl:text>
      <xsl:choose>
        <xsl:when test="./PackageDeclaration">
          <xsl:apply-templates select="PackageDeclaration/QualifiedName/*" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Default</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>
{
    </xsl:text>
      <xsl:apply-templates select="./TypeDeclaration" />
      <xsl:text>
}
</xsl:text>
      <xsl:apply-templates select="./TypeDeclaration[last()]/following-sibling::*" />
    </CSharp>
  </xsl:template>

  <!-- toss the throws clause from method declarations -->
  <xsl:template match="MethodDeclaration">
    <xsl:apply-templates select="./*[not(self::Symbol[@type='THROWS'])][not(self::QualifiedNameList)]" />
  </xsl:template>

  <xsl:template match="*/ClassBodyDeclaration/Modifier/ClassOrInterfaceModifier/Symbol[type='FINAL']">
    <xsl:text>sealed</xsl:text>
  </xsl:template>

  <xsl:template match="Symbol[@type='VOID']">
    <xsl:apply-templates />
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- toss package declaration -->
  <xsl:template match="PackageDeclaration"/>

  <!-- copy line comments, including newline -->
  <xsl:template match="LineComment">
    <xsl:value-of select="text()"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <!-- copy comments -->
  <xsl:template match="Comment">
    <xsl:value-of select="text()" />
  </xsl:template>

  <!-- translate import statements to using statements -->
  <xsl:template match="ImportDeclaration">
    <xsl:text>
using </xsl:text>
    <xsl:apply-templates select="./QualifiedName/*" />
    <xsl:text>;
</xsl:text>
  </xsl:template>

  <xsl:template match="QualifiedName|BlockStatement|LocalVariableDeclarationStatement|ClassOrInterfaceType|VariableDeclarators|VariableDeclarator|VariableDeclaratorId|Literal">
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="Statement|StatementExpression|Expression|Primary|ExpressionList|MethodBody|ClassBody|ClassBodyDeclaration|TypeDeclaration|MemberDeclaration|LocalVariableDeclaration|Type|VariableInitializer">
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="FormalParameters|FormalParameter|FormalParameterList|Creator|CreatedName|ClassCreatorRest|Arguments|Block|ClassDeclaration|Modifier|CatchClause|CatchType">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="Symbol">
    <xsl:text>{</xsl:text>
    <xsl:value-of select="@type"/>
    <xsl:text>|</xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="Symbol[@type='HIDDEN']">
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="Symbol[@type='DOT']|Symbol[@type='SEMI']|Symbol[@type='RPAREN']|Symbol[@type='LPAREN']|Symbol[@type='RBRACE']|Symbol[@type='LBRACE']|Symbol[@type='COMMA']|Symbol[@type='ASSIGN']">
    <xsl:value-of select="text()"/>
  </xsl:template>
  <xsl:template match="Symbol[@type='PRIVATE']|Symbol[@type='TRY']|Symbol[@type='PUBLIC']|Symbol[@type='CLASS']|Symbol[@type='LBRACK']|Symbol[@type='RBRACK']|Symbol[@type='NEW']|Symbol[@type='StringLiteral']|Symbol[@type='STATIC']|Symbol[@type='Identifier']|Symbol[@type='CATCH']|Symbol[@type='NullLiteral']">
    <xsl:value-of select="text()"/>
  </xsl:template>
  <xsl:template match="Symbol[@type='LT']|Symbol[@type='GT']|Symbol[@type='INT']|Symbol[@type='THIS']|Symbol[@type='SUB']|Symbol[@type='IntegerLiteral']|Symbol[@type='RETURN']|Symbol[@type='THROW']|Symbol[@type='IF']|Symbol[@type='AND']|Symbol[@type='NOTEQUAL']|Symbol[@type='ADD']|Symbol[@type='INC']|Symbol[@type='EQUAL']|Symbol[@type='ELSE']|Symbol[@type='LE']|Symbol[@type='QUESTION']|Symbol[@type='COLON']">
    <xsl:value-of select="text()"/>
  </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
