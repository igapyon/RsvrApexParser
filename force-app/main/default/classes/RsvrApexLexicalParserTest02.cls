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
private class RsvrApexLexicalParserTest02 {
    @isTest(SeeAllData=false)
    static void test01() {
        RsvrApexLexicalParserTest.validateLexicalParser('RsvrApexLexicalParser');
    }

    @isTest(SeeAllData=false)
    static void test02() {
        RsvrApexLexicalParserTest.validateLexicalParser('RsvrApexLexicalParserTest');
    }

    @isTest(SeeAllData=false)
    static void test03() {
        RsvrApexLexicalParserTest.validateLexicalParser('RsvrApexLexicalParserInput');
    }

    @isTest(SeeAllData=false)
    static void test04() {
        RsvrApexLexicalParserTest.validateLexicalParser('RsvrApexLexicalParserInputTest');
    }

    @isTest(SeeAllData=false)
    static void test05() {
        RsvrApexLexicalParserTest.validateLexicalParser('RsvrApexLexicalParserUtil');
    }

    @isTest(SeeAllData=false)
    static void test06() {
        RsvrApexLexicalParserTest.validateLexicalParser('RsvrApexLexicalParserUtilTest');
    }

    @isTest(SeeAllData=false)
    static void test07() {
        RsvrApexLexicalParserTest.validateLexicalParser('RsvrApexSyntaxParser');
    }

    @isTest(SeeAllData=false)
    static void test08() {
        RsvrApexLexicalParserTest.validateLexicalParser('RsvrApexSyntaxParserTest');
    }
}