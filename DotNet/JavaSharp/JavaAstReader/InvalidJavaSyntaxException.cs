﻿/*
 * JavaSharp, a free Java to C# translator based on ANTLRv4
 * Copyright (C) 2014  Philip van Oosten
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * https://github.com/pvoosten
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace JavaAstReader
{
    [Serializable]
    public class InvalidJavaSyntaxException : Exception
    {
        public InvalidJavaSyntaxException() { }
        public InvalidJavaSyntaxException(XElement child) : this(string.Format("Unexpected {0} child element of {1} element", child.Name.LocalName, child.Parent.Name.LocalName)) { }
        public InvalidJavaSyntaxException(string message) : base(message) { }
        public InvalidJavaSyntaxException(string message, Exception inner) : base(message, inner) { }
        protected InvalidJavaSyntaxException(
          System.Runtime.Serialization.SerializationInfo info,
          System.Runtime.Serialization.StreamingContext context)
            : base(info, context) { }
    }
}
