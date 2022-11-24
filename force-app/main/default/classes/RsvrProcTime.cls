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
 * Trace Process time.
 */
 public class RsvrProcTime {
    private final Map<String,Long> procTimeMap = new Map<String,Long>();
    private final Map<String,Integer> procCountMap = new Map<String,Integer>();

    private String procTimeName = 'Noname';
    private String currentProcName = 'Noname';
    private Long currentProcEnterTime = Datetime.now().getTime();
    private Integer callCounter = 0;

    public RsvrProcTime(String procTimeName) {
        this.procTimeName = procTimeName;
        enter('Noname');
    }

    public void enter(String procName) {
        if (procTimeMap.get(procName) == null) {
            procTimeMap.put(procName, 0);
        }
        if (procCountMap.get(procName) == null) {
            procCountMap.put(procName, 0);
        }

        Long enterTime = Datetime.now().getTime();
        cal(enterTime);

        // 与えられた新しい処理名を記憶
        currentProcName = procName;
        currentProcEnterTime = enterTime;

        if (Math.mod(++callCounter,10000) == 0) {
            dump();
        }
    }

    private void cal(Long enterTime) {
        // 処理中だった時刻計測を実施
        procTimeMap.put(currentProcName, procTimeMap.get(currentProcName) + (enterTime - currentProcEnterTime));
        procCountMap.put(currentProcName, procCountMap.get(currentProcName) + 1);
    }

    public void close() {
        // 処理中だった時刻計測を実施
        Long enterTime = Datetime.now().getTime();
        cal(enterTime);

        dump();
    }

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
}
