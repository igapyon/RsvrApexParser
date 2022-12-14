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
 * Measure Process Time.
 * 
 * 処理時間を計測するためのクラス。
 * 
 * `System.LimitException: Apex CPU time limit exceeded` の調査・解消などの作業にて役立ちます。
 * 
 * @version v1.0.20221125a
 * @since 2022-11-23
 */
public class RsvrProcTime {
    private final Map<String,Long> procTimeMap = new Map<String,Long>();
    private final Map<String,Integer> procCountMap = new Map<String,Integer>();

    private String procTimeName = 'Noname';
    private String currentProcName = 'baseline';
    private Long currentProcEnterTime = Datetime.now().getTime();
    private Integer callCounter = 0;

    /**
     * コンストラクタ。
     * 
     * @param procTimeName 計測対象の名称。
     */
    public RsvrProcTime(String procTimeName) {
        this.procTimeName = procTimeName;
        enter('baseline');
    }

    /**
     * 処理のキリの良い箇所に入った時に呼び出す。
     * 
     * @param procName 処理のキリの良い箇所の名称。
     */
    public void enter(String procName) {
        if (procTimeMap.get(procName) == null) {
            procTimeMap.put(procName, 0);
        }
        if (procCountMap.get(procName) == null) {
            procCountMap.put(procName, 0);
        }

        Long enterTime = Datetime.now().getTime();
        calc(enterTime);

        // 与えられた新しい処理名を記憶
        currentProcName = procName;
        currentProcEnterTime = enterTime;

        if (Math.mod(++callCounter,5000) == 0) {
            // 5000回に1回はダンプします。
            dump();
        }
    }

    /**
     * 時間計測を終了します。
     * 計測結果を標準出力にダンプします。
     */
    public void close() {
        // 処理中だった時刻計測を実施
        Long enterTime = Datetime.now().getTime();
        calc(enterTime);

        dump();
    }

    /**
     * 計測結果を標準出力にダンプします。
     * 
     * enter() 呼び出し5000回に1回は自動的に呼び出されます。
     */
    public void dump() {
        String message = '\n\n' + procTimeName + ':\n';
        Long allCount = 0;
        Long allTime = 0;
        for (String key : procCountMap.keySet()) {
            allCount += procCountMap.get(key);
            allTime += procTimeMap.get(key);
            message += ('    ' + key + ': ' + procTimeMap.get(key) + ' ms (' + procCountMap.get(key) + ' count)\n');
        }
        message += ('    -----------------------------------------------\n');
        message += ('    total: ' + allTime + ' ms (' + allCount + ' count)\n');
        message += '\n';
        System.debug(message);
    }

    /**
     * 時間を計算。
     * 
     * @param enterTime 計算に使用する基準ミリ秒。
     */
    private void calc(Long enterTime) {
        // 処理中だった時刻計測を実施
        procTimeMap.put(currentProcName, procTimeMap.get(currentProcName) + (enterTime - currentProcEnterTime));
        procCountMap.put(currentProcName, procCountMap.get(currentProcName) + 1);
    }
}
