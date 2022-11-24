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
@isTest(SeeAllData=false)
private class RsvrApexLexicalParserTest03 {
    private static final Boolean IS_APEXCLASS_OBJECTREAD = false;

    @isTest(SeeAllData=false)
    static void test01() {
        List<ApexClass> apcList = [SELECT Name, Body, NamespacePrefix
            FROM ApexClass
            WHERE Status = 'Active'
            ORDER BY LastModifiedDate DESC
            LIMIT 10];

        for (ApexClass apc : apcList) {
            System.debug('Check: ' + apc.Name);
            if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser(apc.Name, false);
        }
    }
}