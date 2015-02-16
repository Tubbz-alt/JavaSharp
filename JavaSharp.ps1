# JavaSharp, a free Java to C# translator based on ANTLRv4
# Copyright (C) 2014  Philip van Oosten
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# https://github.com/pvoosten


function Find-JavaFiles{
    param([string]$Path)
    Get-ChildItem -Path $Path -Recurse | where {$_.Name.EndsWith('.java')} | select FullName
}

function Parse-JavaSource{
    param([string]$InputObject)
    $JavaFile = $InputObject
    $tempFile = [System.IO.Path]::GetTempFileName()
    java -classpath "D:\workspace\JavaSharp\JavaSharp\target\JavaSharp-0.1.jar;D:\workspace\JavaSharp\lib\antlr-4.3-complete.jar" javasharp.Tool $JavaFile $tempFile
    [xml]$content = Get-Content -Raw $tempFile
    Remove-Item $tempFile -ErrorAction SilentlyContinue
    $content
}

function Process-ChildNodes($processors, $astNode, $cs){
    for($i=0; $i -lt $astNode.ChildNodes.Count; $i++){
        $childNode = $astNode.ChildNodes[$i]
        if($childNode.NodeType -eq 'Element'){
            Process-AstNode $processors $childNode $cs
        }
    }
}

function Process-AstNode($processors, $astNode, $cs) {
    if($astNode.NodeType -ne 'Element'){
        "No element: $($astNode.NodeType)"
    }elseif($processors.ContainsKey($astNode.Name)){
        &$processors[$astNode.Name] $processors $astNode $cs
    } elseif($astNode.ChildNodes -ne $null){
        "$('  '*$indent)$($astNode.Name)"
        $cs += $true
        Process-ChildNodes $processors $astNode $cs
    }else{
        Write-Host $astNode.Name
    }
}

function Transform-ArrayToTree{
    param($cs, $pass="dummy")

    [xml]$tree = "<CompilationUnit pass=""$pass""/>"
    $cursor = $tree.DocumentElement

    foreach($item in $cs){
        if($item.GetType() -eq [bool]){
            $indent = if($item){1}else{
                $cursor = $cursor.ParentNode
                0
            }
        }else{
        "$item  $indent"
            if($item[0] -eq '"'){
                $cursor.InnerText += ' ' + $item
            }elseif($item[0] -eq '<'){
                $tagname = $item.Substring(1, $item.Length-1)
                if($indent -eq 0){
                    $cursor = $cursor.ParentNode
                }
                $cursor.InnerXml += "<$tagname/>"
                $cursor = $cursor.LastChild
                $indent = 0
            }
        }
    }
}

function Flatten-ArrayKeys($dictionary){
    $flattened = @{}
    foreach($kv in $dictionary.GetEnumerator()){
        if($kv.Key -is [string]){
            $flattened[$kv.Key] = $kv.Value
        }else{
            $kv.Key | foreach {
                $flattened[$_] = $kv.Value
            }
        }
    }
    $flattened
}

$firstPassProcessors = @{
    'Symbol'={
        $cs += $astNode.innerText
        if($astNode.type -eq 'SEMI'){
            $cs[-1] += "`r`n"
        }
    };
    @('Comment','LineComment')={
        $cs += $astNode.innerText
    };
    'Annotation'={
        $cs += "[$($astNode.AnnotationName.innerText)]"
    };
    @('FormalParameters','FormalParameterList',
        'ClassOrInterfaceModifier', 'Modifier',
        'MethodBody', 'Block', 'MemberDeclaration','MethodDeclaration',
        'Expression', 'Literal','VariableDeclarator',
        'Primary')={
        PullUp-AstNode $astNode $cs
    };
}
$firstPassProcessors = Flatten-ArrayKeys $firstPassProcessors



function Build-CSharpStructure([xml]$javaXml) {
    $cs = @()
    # first pass: strip the unnecessary bloat from the Java AST
    # transform the XML tree to a push
    Process-AstNode $firstPassProcessors $javaXml.CompilationUnit.TypeDeclaration $cs
    $cs = TransformToXml $cs

    $cs
}

function Generate-UsingStatements{
    param($cs)
    foreach($u in $cs.imports){
        $usings += "using $u;`r`n"
    }
    foreach($u in $cs.multiImports){
        $usings += "using $u;`r`n"
    }
    [string]::Join("`r`n", $usings)
}

function Generate-CSharpSource {
    param($cs)
    @"
$([string]::Join("`r`n", $cs.initialComment))
// Translated from Java to C# with JavaSharp
// $([DateTime]::Now.ToShortDateString()) $([DateTime]::Now.ToShortTimeString())

$(Generate-UsingStatements $cs)
namespace $($cs.namespace) {

}
"@
}

# To convert all java source files to C#:
#
# $javaXml = Find-JavaFiles D:\workspace\JavaSharp | foreach { Parse-JavaSource $_.FullName }
# $cs = $javaXml | foreach { Build-CSharpStructure $_ }
# $cs | foreach { Generate-CSharpSource $_ }

# To debug a single java source file translation
$javaXml = Parse-JavaSource $(Find-JavaFiles D:\workspace\JavaSharp)[2].FullName
$cs = Build-CSharpStructure $javaXml
$cs
$csSource = Generate-CSharpSource $cs
$csSource

# TODO
### De gestripte versie van de AST coderen als een array met INDENT en DEDENT elementen ==> makkelijk te maken met visitor en daarna makkelijk om te vormen tot boomstructuur.
