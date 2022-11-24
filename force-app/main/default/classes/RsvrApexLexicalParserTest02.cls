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
        RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParser', false);
    }

    @isTest(SeeAllData=false)
    static void test02() {
        RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserTest', false);
    }

    @isTest(SeeAllData=false)
    static void test03() {
        RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserInput', false);
    }

    @isTest(SeeAllData=false)
    static void test04() {
        RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserInputTest', false);
    }

    @isTest(SeeAllData=false)
    static void test05() {
        RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserUtil', false);
    }

    @isTest(SeeAllData=false)
    static void test06() {
        RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserUtilTest', false);
    }

    @isTest(SeeAllData=false)
    static void test07() {
        RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexSyntaxParser', false);
    }

    @isTest(SeeAllData=false)
    static void test08() {
        RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexSyntaxParserTest', false);
    }

    @isTest(SeeAllData=false)
    static void test11() {
        RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserTest11', false);
    }

}