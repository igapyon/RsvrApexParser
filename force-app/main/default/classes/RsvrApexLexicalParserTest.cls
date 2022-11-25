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
}
