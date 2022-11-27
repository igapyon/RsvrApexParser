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
private class RsvrApexSyntaxParserTest {
    @isTest(SeeAllData=false)
    static void test01() {
        final RsvrApexLexicalParser lexParser = new RsvrApexLexicalParser();
        final String apexClassBody = RsvrApexLexicalParserUtil.readApexClassBody('RsvrApexLexicalParserTest12');
        final List<RsvrApexLexicalParser.LexicalToken> lexList = lexParser.parse(apexClassBody);

        RsvrApexSyntaxParser parser = new RsvrApexSyntaxParser();
        List<RsvrApexSyntaxParser.SyntaxToken> tokList = parser.unify(lexList);
        RsvrApexSyntaxParser.CompilationUnitToken compUnitTok = (RsvrApexSyntaxParser.CompilationUnitToken) parser.parse(tokList);
        System.debug(compUnitTok.dump(''));
    }

    @isTest(SeeAllData=false)
    static void test02() {
        final String apexClassBody = 'public with sharing class MyClass\n' //
            + '{\n'
            + '    public String def = null;\n'
            + '    public String abc {get; set;}\n'
            + '    public Integer plus(Integer i1, Integer i2) {\n'
            + '        return i1 + i2;\n'
            + '    }\n'
            + '}\n';
        final RsvrApexLexicalParser lexParser = new RsvrApexLexicalParser();
        final List<RsvrApexLexicalParser.LexicalToken> lexList = lexParser.parse(apexClassBody);

        RsvrApexSyntaxParser parser = new RsvrApexSyntaxParser();
        List<RsvrApexSyntaxParser.SyntaxToken> tokList = parser.unify(lexList);
        RsvrApexSyntaxParser.CompilationUnitToken compUnitTok = (RsvrApexSyntaxParser.CompilationUnitToken) parser.parse(tokList);

        System.debug(compUnitTok.dump(''));
    }

}