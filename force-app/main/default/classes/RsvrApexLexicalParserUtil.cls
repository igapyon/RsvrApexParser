/*
 * Copyright 2022 Reservoir Consulting - Toshiki Iga
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
public class RsvrApexLexicalParserUtil {
    public static String int2string(Integer val) {
        List<Integer> nextOne = new List<Integer>();
        nextOne.add(val);
        return String.fromCharArray(nextOne);
    }





    public static String readApexClassBody(String apexClassName) {
        ApexClass apc = [SELECT Name, Body, NamespacePrefix
            FROM ApexClass
            WHERE Status = 'Active'
            AND Name = :apexClassName
            LIMIT 1];

        if (apc == null) {
            return null;
        }
        return apc.Body;
    }
}