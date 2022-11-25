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
private class RsvrApexLexicalParserTest02 {
    private static final Boolean IS_APEXCLASS_OBJECTREAD = false;

    @isTest(SeeAllData=false)
    static void test01() {
        if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParser', false);
    }

    @isTest(SeeAllData=false)
    static void test02() {
        if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserTest', false);
    }

    @isTest(SeeAllData=false)
    static void test03() {
        if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserInput', false);
    }

    @isTest(SeeAllData=false)
    static void test04() {
        if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserInputTest', false);
    }

    @isTest(SeeAllData=false)
    static void test05() {
        if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserUtil', false);
    }

    @isTest(SeeAllData=false)
    static void test06() {
        if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserUtilTest', false);
    }

    @isTest(SeeAllData=false)
    static void test07() {
        if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexSyntaxParser', false);
    }

    @isTest(SeeAllData=false)
    static void test08() {
        if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexSyntaxParserTest', false);
    }

    @isTest(SeeAllData=false)
    static void test11() {
        if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserTest11', false);
    }

    @isTest(SeeAllData=false)
    static void test12() {
        if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserTest12', false);
    }

    @isTest(SeeAllData=false)
    static void test13() {
        if (IS_APEXCLASS_OBJECTREAD) RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParserTest13', false);
    }
}