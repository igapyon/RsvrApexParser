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
 * This class provide buffered input for Syntax Parser.
 * 
 * @since 2022-11-23
 */
public class RsvrApexSyntaxParserInput {
    private List<RsvrApexSyntaxParser.SyntaxToken> tokenList;

    // 現在処理位置情報。
    private Integer currentPos = -1;
    private Integer markPos = -1;

    /**
     * コンストラクタ。
     * 
     * @param apexClassText 解析対象の Apex Class のテキスト。
     */
    public RsvrApexSyntaxParserInput(List<RsvrApexSyntaxParser.SyntaxToken> tokenList) {
        this.tokenList = tokenList;
    }

    public void dumpNextTokens() {
        String dump = 'dumpNextTokens\n'
            + '  1: ' + tokenList.get(currentPos + 1) + '\n'
            + '  2: ' + tokenList.get(currentPos + 2) + '\n'
            + '  3: ' + tokenList.get(currentPos + 3) + '\n';
        System.debug(dump);
    }

    public RsvrApexSyntaxParser.SyntaxToken readToken() {
        currentPos++;
        if (tokenList.size() <= currentPos) {
            // end of token list.
            return null;
        }

        return tokenList.get(currentPos);
    }

    public Integer mark() {
        markPos = currentPos;
        return markPos;
    }

    public void move(Integer pos) {
        currentPos = pos;
    }

    public Integer pos() {
        return currentPos;
    }

    public void reset() {
        currentPos = markPos;
    }

    /**
     * 最初のLexicalTokenを取得。
     * ポジションは一つ進みます。
     */
    public RsvrApexLexicalParser.LexicalToken getFirstLexicalToken() {
        return readToken().getTokenList().get(0);
    }

    /**
     * 最初の(Lexical)KeywordTokenを取得。
     * 成功しようが失敗しようが、ポジションは一つ進みます。
     */
    public RsvrApexLexicalParser.KeywordToken getFirstKeywordToken() {
        RsvrApexLexicalParser.LexicalToken lexToken = readToken().getTokenList().get(0);
        if (lexToken instanceof RsvrApexLexicalParser.KeywordToken) {
            return (RsvrApexLexicalParser.KeywordToken) lexToken;
        }
        return null;
    }

    /**
     * 最初の(Lexical)IdentifierTokenを取得。
     * 成功しようが失敗しようが、ポジションは一つ進みます。
     */
    public RsvrApexLexicalParser.IdentifierToken getFirstIdentifierToken() {
        RsvrApexLexicalParser.LexicalToken lexToken = readToken().getTokenList().get(0);
        if (lexToken instanceof RsvrApexLexicalParser.IdentifierToken) {
            return (RsvrApexLexicalParser.IdentifierToken) lexToken;
        }
        return null;
    }

    /**
     * 最初の(Lexical)SeparatorTokenを取得。
     * 成功しようが失敗しようが、ポジションは一つ進みます。
     */
    public RsvrApexLexicalParser.SeparatorToken getFirstSeparatorToken() {
        RsvrApexLexicalParser.LexicalToken lexToken = readToken().getTokenList().get(0);
        if (lexToken instanceof RsvrApexLexicalParser.SeparatorToken) {
            return (RsvrApexLexicalParser.SeparatorToken) lexToken;
        }
        return null;
    }
}