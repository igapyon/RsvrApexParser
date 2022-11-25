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
 * This class provide buffered input for Lexical Parser.
 * 
 * @since 2022-11-23
 */
public class RsvrApexLexicalParserInput {
    private String originalApexClassText;
    // CPUコスト低減化のためにListではなくMapで保持します。
    private Map<Integer,Integer> apexClassCharMap = new Map<Integer,Integer>();

    // 現在処理位置情報。
    private Integer apexClassCharListSize = -1;
    private Integer currentPos = -1;
    private Integer markPos = -1;

    /**
     * コンストラクタ。
     * 
     * @param apexClassText 解析対象の Apex Class のテキスト。
     */
    public RsvrApexLexicalParserInput(String apexClassText) {
        final RsvrProcTime procTime = new RsvrProcTime('RsvrApexLexicalParserInput');
        procTime.enter('RsvrApexLexicalParserInput');
    
        originalApexClassText = apexClassText;

        // 注意：以下の getChars() によるコードでは、バックスラッシュが消失する回復不能な問題があります。
        // this.apexClassCharList = apexClassText.getChars();

        if (true) {
            // 有利/不利があるのだろうか。
            final List<Integer> result = new List<Integer>();
            final Integer len = apexClassText.length();
            for (Integer i = 0; i < len; i++) {
                apexClassCharMap.put(i, apexClassText.charAt(i));
            }
            // CPUコストを減らすためにサイズを記憶します。
            apexClassCharListSize = len;
        }

        if (false) {
            final String afterString = apexClassText.replace('\\','\\\\');
            System.debug('TRACE: after: ' + afterString);
            final List<Integer> result = afterString.getChars();
            final Integer len = result.size();
            for (Integer i = 0; i < len; i++) {
                apexClassCharMap.put(i, result.get(i));
            }

            // CPUコストを減らすためにサイズを記憶します。
            apexClassCharListSize = len;
        }

        procTime.close();
    }

    public Integer readChar() {
        currentPos++;
        if (apexClassCharListSize <= currentPos) {
            // end of string.
            return -1;
        }

        return apexClassCharMap.get(currentPos);
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

    public String getRemainingtext(Boolean isNext) {
        Integer pos = currentPos;
        if (isNext) {
            pos++;
        }
        if (pos < 0) {
            pos = 0;
        }
        if (apexClassCharListSize <= (pos)) {
            return '';
        }
        return originalApexClassText.substring(pos);
    }
}