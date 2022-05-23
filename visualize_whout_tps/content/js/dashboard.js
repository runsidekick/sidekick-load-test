/*
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
var showControllersOnly = false;
var seriesFilter = "";
var filtersOnlySampleSeries = true;

/*
 * Add header in statistics table to group metrics by category
 * format
 *
 */
function summaryTableHeader(header) {
    var newRow = header.insertRow(-1);
    newRow.className = "tablesorter-no-sort";
    var cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 1;
    cell.innerHTML = "Requests";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 3;
    cell.innerHTML = "Executions";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 7;
    cell.innerHTML = "Response Times (ms)";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 1;
    cell.innerHTML = "Throughput";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 2;
    cell.innerHTML = "Network (KB/sec)";
    newRow.appendChild(cell);
}

/*
 * Populates the table identified by id parameter with the specified data and
 * format
 *
 */
function createTable(table, info, formatter, defaultSorts, seriesIndex, headerCreator) {
    var tableRef = table[0];

    // Create header and populate it with data.titles array
    var header = tableRef.createTHead();

    // Call callback is available
    if(headerCreator) {
        headerCreator(header);
    }

    var newRow = header.insertRow(-1);
    for (var index = 0; index < info.titles.length; index++) {
        var cell = document.createElement('th');
        cell.innerHTML = info.titles[index];
        newRow.appendChild(cell);
    }

    var tBody;

    // Create overall body if defined
    if(info.overall){
        tBody = document.createElement('tbody');
        tBody.className = "tablesorter-no-sort";
        tableRef.appendChild(tBody);
        var newRow = tBody.insertRow(-1);
        var data = info.overall.data;
        for(var index=0;index < data.length; index++){
            var cell = newRow.insertCell(-1);
            cell.innerHTML = formatter ? formatter(index, data[index]): data[index];
        }
    }

    // Create regular body
    tBody = document.createElement('tbody');
    tableRef.appendChild(tBody);

    var regexp;
    if(seriesFilter) {
        regexp = new RegExp(seriesFilter, 'i');
    }
    // Populate body with data.items array
    for(var index=0; index < info.items.length; index++){
        var item = info.items[index];
        if((!regexp || filtersOnlySampleSeries && !info.supportsControllersDiscrimination || regexp.test(item.data[seriesIndex]))
                &&
                (!showControllersOnly || !info.supportsControllersDiscrimination || item.isController)){
            if(item.data.length > 0) {
                var newRow = tBody.insertRow(-1);
                for(var col=0; col < item.data.length; col++){
                    var cell = newRow.insertCell(-1);
                    cell.innerHTML = formatter ? formatter(col, item.data[col]) : item.data[col];
                }
            }
        }
    }

    // Add support of columns sort
    table.tablesorter({sortList : defaultSorts});
}

$(document).ready(function() {

    // Customize table sorter default options
    $.extend( $.tablesorter.defaults, {
        theme: 'blue',
        cssInfoBlock: "tablesorter-no-sort",
        widthFixed: true,
        widgets: ['zebra']
    });

    var data = {"OkPercent": 100.0, "KoPercent": 0.0};
    var dataset = [
        {
            "label" : "FAIL",
            "data" : data.KoPercent,
            "color" : "#FF6347"
        },
        {
            "label" : "PASS",
            "data" : data.OkPercent,
            "color" : "#9ACD32"
        }];
    $.plot($("#flot-requests-summary"), dataset, {
        series : {
            pie : {
                show : true,
                radius : 1,
                label : {
                    show : true,
                    radius : 3 / 4,
                    formatter : function(label, series) {
                        return '<div style="font-size:8pt;text-align:center;padding:2px;color:white;">'
                            + label
                            + '<br/>'
                            + Math.round10(series.percent, -2)
                            + '%</div>';
                    },
                    background : {
                        opacity : 0.5,
                        color : '#000'
                    }
                }
            }
        },
        legend : {
            show : true
        }
    });

    // Creates APDEX table
    createTable($("#apdexTable"), {"supportsControllersDiscrimination": true, "overall": {"data": [5.0E-4, 500, 1500, "Total"], "isController": false}, "titles": ["Apdex", "T (Toleration threshold)", "F (Frustration threshold)", "Label"], "items": [{"data": [0.002, 500, 1500, "CSS"], "isController": false}, {"data": [0.0015, 500, 1500, "Owner"], "isController": false}, {"data": [0.0, 500, 1500, "POST Edit Owner"], "isController": false}, {"data": [0.0, 500, 1500, "POST new visit"], "isController": false}, {"data": [0.0, 500, 1500, "Vets"], "isController": false}, {"data": [0.0, 500, 1500, "Home page"], "isController": false}, {"data": [0.001, 500, 1500, "JS"], "isController": false}, {"data": [0.0, 500, 1500, "Find owner"], "isController": false}, {"data": [0.0, 500, 1500, "Find owner with lastname=\"\""], "isController": false}, {"data": [0.0, 500, 1500, "New visit"], "isController": false}, {"data": [0.0, 500, 1500, "Edit Owner"], "isController": false}]}, function(index, item){
        switch(index){
            case 0:
                item = item.toFixed(3);
                break;
            case 1:
            case 2:
                item = formatDuration(item);
                break;
        }
        return item;
    }, [[0, 0]], 3);

    // Create statistics table
    createTable($("#statisticsTable"), {"supportsControllersDiscrimination": true, "overall": {"data": ["Total", 6000, 0, 0.0, 30850.47466666664, 503, 101994, 27426.5, 50646.0, 64416.349999999984, 84500.01999999997, 15.112779114139263, 355.2041386188179, 2.2018659953024446], "isController": false}, "titles": ["Label", "#Samples", "FAIL", "Error %", "Average", "Min", "Max", "Median", "90th pct", "95th pct", "99th pct", "Transactions/s", "Received", "Sent"], "items": [{"data": ["CSS", 500, 0, 0.0, 19195.81599999999, 503, 36555, 19086.5, 26361.9, 28159.3, 32845.200000000004, 8.678446210990383, 1294.4444926580345, 1.2119314532926027], "isController": false}, {"data": ["Owner", 1000, 0, 0.0, 37205.07699999999, 579, 76313, 36248.5, 56525.5, 61010.7, 68812.11, 3.5743774328106404, 17.393325498000134, 0.4331838275505864], "isController": false}, {"data": ["POST Edit Owner", 500, 0, 0.0, 27164.557999999997, 6695, 46133, 27063.0, 35254.5, 37851.7, 43842.990000000005, 3.324335465340478, 20.335583354387456, 0.8349795719585654], "isController": false}, {"data": ["POST new visit", 500, 0, 0.0, 31768.51400000001, 5287, 51631, 31516.0, 41933.700000000004, 43538.65, 51308.99000000003, 3.871107601306886, 20.05182324329137, 0.8558928177405118], "isController": false}, {"data": ["Vets", 500, 0, 0.0, 22235.96800000001, 7791, 43245, 21565.0, 29967.5, 32256.55, 37345.990000000005, 6.242275184459232, 24.158336480480404, 0.7619964824779335], "isController": false}, {"data": ["Home page", 500, 0, 0.0, 21798.252000000008, 9015, 38925, 21645.5, 28497.7, 29813.5, 37025.590000000004, 10.700222564629344, 35.15190303458312, 1.2121345873994178], "isController": false}, {"data": ["JS", 500, 0, 0.0, 18130.379999999972, 1206, 31059, 18571.5, 23851.200000000004, 25443.199999999997, 29058.02, 7.945209832991689, 666.9863992904928, 1.1172951327644562], "isController": false}, {"data": ["Find owner", 500, 0, 0.0, 27078.583999999995, 5474, 62121, 26256.0, 36331.700000000004, 41797.19999999999, 52430.240000000005, 4.7321149714653465, 18.119748831167602, 0.5868931654063467], "isController": false}, {"data": ["Find owner with lastname=\"\"", 500, 0, 0.0, 65851.37399999997, 15782, 101994, 66623.0, 86913.60000000002, 90078.55, 96584.94, 2.765853874408107, 17.327102152664068, 0.35653585099792007], "isController": false}, {"data": ["New visit", 500, 0, 0.0, 29969.352, 5295, 53916, 28863.0, 41240.700000000004, 44428.149999999994, 50326.030000000006, 3.130674347254399, 15.858773323523886, 0.43537163061173373], "isController": false}, {"data": ["Edit Owner", 500, 0, 0.0, 32602.744, 1907, 63628, 32052.0, 43334.8, 46236.1, 54216.02000000001, 2.6127670247899335, 14.616696463097279, 0.32940256142615276], "isController": false}]}, function(index, item){
        switch(index){
            // Errors pct
            case 3:
                item = item.toFixed(2) + '%';
                break;
            // Mean
            case 4:
            // Mean
            case 7:
            // Median
            case 8:
            // Percentile 1
            case 9:
            // Percentile 2
            case 10:
            // Percentile 3
            case 11:
            // Throughput
            case 12:
            // Kbytes/s
            case 13:
            // Sent Kbytes/s
                item = item.toFixed(2);
                break;
        }
        return item;
    }, [[0, 0]], 0, summaryTableHeader);

    // Create error table
    createTable($("#errorsTable"), {"supportsControllersDiscrimination": false, "titles": ["Type of error", "Number of errors", "% in errors", "% in all samples"], "items": []}, function(index, item){
        switch(index){
            case 2:
            case 3:
                item = item.toFixed(2) + '%';
                break;
        }
        return item;
    }, [[1, 1]]);

        // Create top5 errors by sampler
    createTable($("#top5ErrorsBySamplerTable"), {"supportsControllersDiscrimination": false, "overall": {"data": ["Total", 6000, 0, null, null, null, null, null, null, null, null, null, null], "isController": false}, "titles": ["Sample", "#Samples", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors"], "items": [{"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}]}, function(index, item){
        return item;
    }, [[0, 0]], 0);

});
