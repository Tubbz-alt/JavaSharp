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
    $tempFile = [System.IO.Path]::GetTempFileName()
    java -classpath "D:\workspace\JavaSharp\JavaSharp\target\JavaSharp-0.1.jar;D:\workspace\JavaSharp\lib\antlr-4.3-complete.jar" javasharp.Tool $JavaFile $tempFile
    [xml]$content = Get-Content -Raw $tempFile
    Remove-Item $tempFile -ErrorAction SilentlyContinue
    $content
}

function Build-CSharpStructure([xml]$javaXml) {
    $cs = @{}
    $cs.namespace = $javaXml.CompilationUnit.PackageDeclaration.QualifiedName.InnerText

    $cs.multiImports = @()
    $cs.imports = @()
    $imports = $javaXml.CompilationUnit.ImportDeclaration
    foreach($import in $imports){
        if($import.Symbol[-2].type -eq 'MUL'){
            $cs.multiImports += $import.QualifiedName.InnerText
        }else{
            $cs.imports += $import.QualifiedName.InnerText
        }
    }

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
// Generated with JavaSharp
// $([DateTime]::Now.ToLongDateString()) $([DateTime]::Now.ToShortTimeString())

$(Generate-UsingStatements $cs)
namespace $($cs.namespace) {

}
"@
}

$javaSource = $(Find-JavaFiles D:\workspace\JavaSharp)[0].FullName
$javaXml = Parse-JavaSource $javaSource
$cs = Build-CSharpStructure $javaXml
Generate-CSharpSource $cs

