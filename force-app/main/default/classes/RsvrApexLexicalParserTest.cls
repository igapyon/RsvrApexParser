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
    @isTest(SeeAllData=false)
    static void test01() {
        final String apexClassText = '@isTest(SeeAllData=false)\n'
        + 'private class RsvrApexLexicalParserTest11 {\n'
        + '    // SOQL および SOSL クエリ\n'
        + '    @isTest(SeeAllData=false)\n'
        + '    static void test01() {\n'
        + '        List<Account> aa = [SELECT Id, Name FROM Account WHERE Name = \'Acme\'];\n'
        + '    }';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
        System.assertEquals(68, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test02() {
        final String apexClassText = 'public class Sample01 {\n'
        + '    public void sample() {\n'
        + '        Boolean val1 = true;\n'
        + '        Boolean val2 = false;\n'
        + '        Integer val3 = 123;\n'
        + '        Long val4 = 123L;\n'
        + '        String val5 = \'ABC\'123\';\n'
        + '    }';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
        System.assertEquals(63, tokenList.size());
    }

    @isTest(SeeAllData=false)
    static void test03() {
        final String apexClassText = 'List<Account> aa = [SELECT Id, Name FROM Account WHERE Name = \'Acme\' AND CreatedDate < 1999-01-01T23:01:01-01:00];\n';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
    }

    @isTest(SeeAllData=false)
    static void test04() {
        final String apexClassText = 'List<Account> aa = [SELECT Id, Name FROM Account WHERE Name = \'Acme\' AND CreatedDate < 1999-01-01T23:01:01Z];\n';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
    }

    @isTest(SeeAllData=false)
    static void test05() {
        final String apexClassText = '1999-01-01';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
    }

    @isTest(SeeAllData=false)
    static void test06() {
        final String apexClassText = '// ABC123';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
    }

    @isTest(SeeAllData=false)
    static void test07() {
        final String apexClassText = '/** ABC */ /* DEF */';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
    }

    @isTest(SeeAllData=false)
    static void test08() {
        final String apexClassText = 'Boolean look1 = true;';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
    }

    @isTest(SeeAllData=false)
    static void test09() {
        final String apexClassText = 'String look1 = \'ABC\'123\';';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
    }

    @isTest(SeeAllData=false)
    static void test10() {
        final String apexClassText = 'String look1 = \'\u0001\';';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
    }

    @isTest(SeeAllData=false)
    static void test11() {
        final String apexClassText = 'Number look1 = 123.456;';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
    }

    @isTest(SeeAllData=false)
    static void test12() {
        final String apexClassText = '123ABC/*PANIC*/;';

        final RsvrApexLexicalParser parser = new RsvrApexLexicalParser();
        List<RsvrApexLexicalParser.LexicalToken> tokenList = parser.parse(apexClassText);
    }

    @isTest(SeeAllData=false)
    static void test90() {
        System.assertEquals(39, '\''.charAt(0));
        System.assertEquals(92, '\\'.charAt(0));
        System.assertEquals(8, '\b'.charAt(0));
        System.assertEquals(9, '\t'.charAt(0));
        System.assertEquals(10, '\n'.charAt(0));
        System.assertEquals(12, '\f'.charAt(0));
        System.assertEquals(13, '\r'.charAt(0));
        System.assertEquals(34, '"'.charAt(0));
        System.assertEquals(12, '\u000C'.charAt(0));
    }
}
