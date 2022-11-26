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
private class RsvrApexLexicalParserUtilTest {
    @isTest(SeeAllData=false)
    static void test01() {
        System.assertEquals('<', RsvrApexLexicalParserUtil.int2string(60));
    }

    @isTest(SeeAllData=false)
    static void test02() {
        System.assertEquals(false, RsvrApexLexicalParserUtil.isJavaLetter(96));
        System.assertEquals(true, RsvrApexLexicalParserUtil.isJavaLetter(97));
    }

    @isTest(SeeAllData=false)
    static void test03() {
        System.assertEquals(false, RsvrApexLexicalParserUtil.isJavaLetterOrDigit(96));
        System.assertEquals(true, RsvrApexLexicalParserUtil.isJavaLetterOrDigit(97));
    }

    @isTest(SeeAllData=false)
    static void test04() {
        System.assertEquals(false, RsvrApexLexicalParserUtil.isKeyword('pubpub'));
        System.assertEquals(true, RsvrApexLexicalParserUtil.isKeyword('public'));
    }

    @isTest(SeeAllData=false)
    static void test05() {
        System.assertEquals(false, RsvrApexLexicalParserUtil.isOperator('0'));
        System.assertEquals(true, RsvrApexLexicalParserUtil.isOperator('<'));
    }

    @isTest(SeeAllData=false)
    static void test06() {
        System.assertEquals(false, RsvrApexLexicalParserUtil.isOperatorLetter(0));
        System.assertEquals(true, RsvrApexLexicalParserUtil.isOperatorLetter(RsvrUnicodeConstants.LETTER_Equal));
    }

    @isTest(SeeAllData=false)
    static void test07() {
        System.assertEquals(false, RsvrApexLexicalParserUtil.isDigit(0));
        System.assertEquals(true, RsvrApexLexicalParserUtil.isDigit(RsvrUnicodeConstants.LETTER_Digit_Zero));
    }

    @isTest(SeeAllData=false)
    static void test08() {
        System.assertEquals(false, RsvrApexLexicalParserUtil.isHexCharacter(0));
        System.assertEquals(true, RsvrApexLexicalParserUtil.isHexCharacter('A'.charAt(0)));
    }

    @isTest(SeeAllData=false)
    static void test09() {
        System.assertEquals(null, RsvrApexLexicalParserUtil.readApexClassBody('abcdef'));
    }
}