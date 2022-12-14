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

/**
 * Reservoir Apex Language Parser.
 * 
 * This class provide Apex test.
 * 
 * @since 2022-11-23
 */
@isTest(SeeAllData=false)
private class RsvrApexLexicalParserTest13 {
    /**
     * DATETIME についての定数が正しく動作することを確認。
     */

    // DATETIME 比較
    @isTest(SeeAllData=false)
    static void test01() {
        List<Account> aa = [SELECT Id, Name FROM Account WHERE Name = 'Acme' AND CreatedDate < 1999-01-23T12:34:56+01:00];
    }

    @isTest(SeeAllData=false)
    static void test02() {
        List<Account> aa = [SELECT Id, Name FROM Account WHERE Name = 'Acme' AND CreatedDate < 1999-01-01T23:01:01-01:00];
    }

    @isTest(SeeAllData=false)
    static void test03() {
        List<Account> aa = [SELECT Id, Name FROM Account WHERE Name = 'Acme' AND CreatedDate < 1999-01-01T23:01:01Z];
    }

    @isTest(SeeAllData=false)
    static void test04() {
        List<Contact> aa = [SELECT Id, Name FROM Contact WHERE Birthdate < 1999-12-23];
    }
}