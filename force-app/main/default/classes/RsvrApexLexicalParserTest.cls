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
public class RsvrApexLexicalParserTest {
    /**
     * 基本的なパースの挙動を確認。
     */
    @isTest(SeeAllData=false)
    static void test01() {
        final String apexClassText = 'Boolean val1 = true;';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('Identifier', current.type);
        System.assertEquals('Boolean', current.target);

        current = tokenList.get(index++);
        System.assertEquals('Whitespace', current.type);
        System.assertEquals(' ', current.target);

        current = tokenList.get(index++);
        System.assertEquals('Identifier', current.type);
        System.assertEquals('val1', current.target);

        current = tokenList.get(index++);
        System.assertEquals('Whitespace', current.type);
        System.assertEquals(' ', current.target);

        current = tokenList.get(index++);
        System.assertEquals('Operator', current.type);
        System.assertEquals('=', current.target);

        current = tokenList.get(index++);
        System.assertEquals('Whitespace', current.type);
        System.assertEquals(' ', current.target);

        current = tokenList.get(index++);
        System.assertEquals('BooleanLiteral', current.type);
        System.assertEquals('true', current.target);

        current = tokenList.get(index++);
        System.assertEquals('Separator', current.type);
        System.assertEquals(';', current.target);

        System.assertEquals(8, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test02() {
        final String apexClassText = 'String val1=\'ABC\\\'123\';';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('Identifier', current.type);
        System.assertEquals('String', current.target);

        current = tokenList.get(index++);
        System.assertEquals('Whitespace', current.type);
        System.assertEquals(' ', current.target);

        current = tokenList.get(index++);
        System.assertEquals('Identifier', current.type);
        System.assertEquals('val1', current.target);

        current = tokenList.get(index++);
        System.assertEquals('Operator', current.type);
        System.assertEquals('=', current.target);

        current = tokenList.get(index++);
        System.assertEquals('StringLiteral', current.type);
        System.assertEquals('ABC\'123', current.target);

        current = tokenList.get(index++);
        System.assertEquals('Separator', current.type);
        System.assertEquals(';', current.target);

        System.assertEquals(6, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test03() {
        final String apexClassText = '\'ABC\n123\'';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('StringLiteral', current.type);
        System.assertEquals('ABC\n123', current.target);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test04() {
        final String apexClassText = '1987-01-23';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('DateLiteral', current.type);
        System.assertEquals('1987-01-23', current.target);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test05() {
        final String apexClassText = '1999-01-01T23:01:01-01:00';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('DateTimeLiteral', current.type);
        System.assertEquals('1999-01-01T23:01:01-01:00', current.target);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test06() {
        final String apexClassText = '1999-01-01T23:01:01Z';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('DateTimeLiteral', current.type);
        System.assertEquals('1999-01-01T23:01:01Z', current.target);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test07() {
        final String apexClassText = '123.456';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('NumberLiteral', current.type);
        System.assertEquals('123.456', current.target);
        System.assertEquals('123.456', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test08() {
        final String apexClassText = '123L';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('LongLiteral', current.type);
        System.assertEquals('123', current.target);
        System.assertEquals('123L', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test09() {
        final String apexClassText = '123';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('IntegerLiteral', current.type);
        System.assertEquals('123', current.target);
        System.assertEquals('123', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test09b() {
        final String apexClassText = '123D';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('NumberLiteral', current.type);
        System.assertEquals('123', current.target);
        System.assertEquals('123D', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test10() {
        final String apexClassText = '// COMMENT';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('LineComment', current.type);
        System.assertEquals(' COMMENT', current.target);
        System.assertEquals('// COMMENT', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test11() {
        final String apexClassText = '/* COMMENT*COM */';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('Comment', current.type);
        System.assertEquals(' COMMENT*COM ', current.target);
        System.assertEquals('/* COMMENT*COM */', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test12() {
        final String apexClassText = '/** COMMENT*COM */';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('DocComment', current.type);
        System.assertEquals(' COMMENT*COM ', current.target);
        System.assertEquals('/** COMMENT*COM */', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test13() {
        final String apexClassText = 'null';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('NullLiteral', current.type);
        System.assertEquals('null', current.target);
        System.assertEquals('null', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test14() {
        final String apexClassText = 'true';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('BooleanLiteral', current.type);
        System.assertEquals('true', current.target);
        System.assertEquals('true', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test15() {
        final String apexClassText = 'false';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('BooleanLiteral', current.type);
        System.assertEquals('false', current.target);
        System.assertEquals('false', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test16() {
        final String apexClassText = 'public';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('Keyword', current.type);
        System.assertEquals('public', current.target);
        System.assertEquals('public', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test17() {
        final String apexClassText = '00PANIC';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('PANIC', current.type);
        System.assertEquals(null, current.target);
        System.assertEquals(null, current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test18() {
        final String apexClassText = '\'\\u0034\'';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('StringLiteral', current.type);
        System.assertEquals('A', current.target);
        System.assertEquals('\'\\u0034\'', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test19() {
        final String apexClassText = '\'\\b\'';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('StringLiteral', current.type);
        System.assertEquals('\b', current.target);
        System.assertEquals('\'\\b\'', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test20() {
        final String apexClassText = '\'\\t\'';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('StringLiteral', current.type);
        System.assertEquals('\t', current.target);
        System.assertEquals('\'\\t\'', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test21() {
        final String apexClassText = '\'\\n\'';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('StringLiteral', current.type);
        System.assertEquals('\n', current.target);
        System.assertEquals('\'\\n\'', current.original);

        System.assertEquals(1, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test22() {
        final String apexClassText = '\'\\r\'';
        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);

        Integer index = 0;
        RsvrApexLexicalParser.LexicalToken current = tokenList.get(index++);
        System.assertEquals('StringLiteral', current.type);
        System.assertEquals('\r', current.target);
        System.assertEquals('\'\\r\'', current.original);

        System.assertEquals(1, tokenList.size());
    }

    //////////////////////////////
    // memo
    // RsvrApexLexicalParserUtil.validateLexicalParser('RsvrApexLexicalParser', false);
}
