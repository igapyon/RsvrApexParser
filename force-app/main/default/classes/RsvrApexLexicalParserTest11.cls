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
private class RsvrApexLexicalParserTest11 {
    // SOQL および SOSL クエリ
    // https://developer.salesforce.com/docs/atlas.ja-jp.apexcode.meta/apexcode/langCon_apex_SOQL.htm

    @isTest(SeeAllData=false)
    static void test01() {
        List<Account> aa = [SELECT Id, Name FROM Account WHERE Name = 'Acme'];
    }

    @isTest(SeeAllData=false)
    static void test02() {
        Contact c = new Contact(Account = [SELECT Name FROM Account 
            WHERE NumberOfEmployees > 10 LIMIT 1]);
        c.FirstName = 'James';
        c.LastName = 'Yoyce';
    }

    @isTest(SeeAllData=false)
    static void test03() {
        Integer i = [SELECT COUNT() FROM Contact WHERE LastName = 'Weissman'];
    }

    @isTest(SeeAllData=false)
    static void test04() {
        Integer j = 5 * [SELECT COUNT() FROM Account];
    }

    @isTest(SeeAllData=false)
    static void test05() {
        // SOSL
        List<List<SObject>> searchList = [FIND 'map*' IN ALL FIELDS RETURNING Account (Id, Name), Contact, Opportunity, Lead];

        Account [] accounts = ((List<Account>)searchList[0]);
        Contact [] contacts = ((List<Contact>)searchList[1]);
        Opportunity [] opportunities = ((List<Opportunity>)searchList[2]);
        Lead [] leads = ((List<Lead>)searchList[3]);
    }
}