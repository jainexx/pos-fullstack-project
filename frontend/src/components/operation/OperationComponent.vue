<script>
import * as echarts from 'echarts';
import axios from 'axios';
import OperationSpecificComponent from './OperationSpecificComponent.vue';
export default{
    data(){
        return{
            currentHead:'日',
            currentTopSelect: '日常統計',
            firstOperationDate:null,
            allDateList:[],
            allRevenueList:[],

            dateForDay: null,
            dateForMonth: new Date(),
            dateForSeason: new Date(),
            dateForYear: new Date(),
            startDate: null,
            endDate: null,
            analysis:null,

            preDateForDay: null,
            preDateForMonth: new Date(new Date().setMonth(new Date().getMonth() - 1)),
            preDateForSeason: new Date(new Date().setMonth(new Date().getMonth() - 2)),
            preDateForYear: new Date(new Date().setYear(new Date().getFullYear() - 1)),
            preStartDate: null,
            preEndDate: null,
            preAnalysis:null,

            analysis12Month:[],
            preAnalysis12Month:[],
            lastYearAnalysis12Month:[],

            analysis4Season:[],
            preAnalysis4Season:[],
            lastYearAnalysis4Season:[],

            analysisMealVoList:[],

            joinOrderList:[],

            optionLineDishes:{
                tooltip: {
                        trigger: 'axis',  // 當軸上的數據被觸發時顯示 tooltip
                    },
                legend: {
                    data:['餐點銷售量'],
                    left: 'center',
                    textStyle: {
                        fontSize: 18,  // 設置圖例的字體大小
                        color: '#000'                      
                    }
                },      
                grid: {
                    top: '15%',
                    left: '3%',
                    right: '3%',
                    bottom: '6%',
                    containLabel: true
                },
                xAxis: {
                    type: 'category',
                    data:[],
                    boundaryGap: true, // 不留白，从原点开始
                    boundaryGap: ['1%', '1%'] // 左右邊界分別設置為 20%
                },
                yAxis: {
                    type: 'value'
                },
                series: [
                    {
                        name:'餐點銷售量',
                        type: 'bar',
                        label: {
                                show: false,  // 顯示數據標籤
                                position: 'top'  // 數值顯示在數據點上方
                            },
                        //显示出来折线图的面积
                        areaStyle: {
                            normal: {
                                // 颜色渐变函数 前四个参数分别表示四个位置依次为左、下、右、上
                                color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                                    offset: 0,
                                    color: 'rgba(80,141,255,0.39)'
                                }, {
                                    offset: 0.25,
                                    color: 'rgba(56,155,255,0.25)'
                                }, {
                                    offset: 1,
                                    color: 'rgba(38,197,254,0.00)'
                                }])
                            }
                        },
                        data: [],
                    }
                ]
            },
            optionLine:{
                tooltip: {
                        trigger: 'axis',  // 當軸上的數據被觸發時顯示 tooltip
                    },
                legend: {
                    data:['銷售額'],
                    left: 'center',
                    textStyle: {
                        fontSize: 18,  // 設置圖例的字體大小
                        color: '#000'                      
                    }
                },      
                grid: {
                    top: '15%',
                    left: '3%',
                    right: '3%',
                    bottom: '6%',
                    containLabel: true
                },
                xAxis: {
                    type: 'category',
                    data:["123"],
                    boundaryGap: true, // 不留白，从原点开始
                    boundaryGap: ['1%', '1%'] // 左右邊界分別設置為 20%
                },
                yAxis: {
                    type: 'value'
                },
                series: [
                    {
                        name:'銷售額',
                        type: 'line',
                        label: {
                                show: false,  // 顯示數據標籤
                                position: 'top'  // 數值顯示在數據點上方
                            },
                        //显示出来折线图的面积
                        areaStyle: {
                            normal: {
                                // 颜色渐变函数 前四个参数分别表示四个位置依次为左、下、右、上
                                color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
                                    offset: 0,
                                    color: 'rgba(80,141,255,0.39)'
                                }, {
                                    offset: 0.25,
                                    color: 'rgba(56,155,255,0.25)'
                                }, {
                                    offset: 1,
                                    color: 'rgba(38,197,254,0.00)'
                                }])
                            }
                        },
                        data: [20],
                    }
                ]
            },
            option:{
                // title: {
                //     text: '上月本月比教圖',
                //     subtext: 'Fake Data'
                // },
                tooltip: {
                    trigger: 'axis'
                },
                legend: {
                    data: ['去年', '今年'],
                    left: 'center' // 圖例顯示在左側
                },
                toolbox: {
                    show: true,
                    feature: {
                    dataView: { show: true, readOnly: false },
                    magicType: { show: true, type: ['line', 'bar'] },
                    // restore: { show: true },
                    saveAsImage: { show: true }
                    }
                },
                calculable: true,
                xAxis: [
                    {
                    type: 'category',
                    // prettier-ignore
                    data: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
                    }
                ],
                yAxis: [
                    {
                    type: 'value'
                    }
                ],
                series: [
                    {
                    name: '去年',
                    type: 'bar',
                    data: [],
                    markPoint: {
                        data: [
                        { type: 'max', name: 'Max' },
                        { type: 'min', name: 'Min' }
                        ]
                    },
                    markLine: {
                        data: [{ type: 'average', name: 'Avg' }]
                    }
                    },
                    {
                    name: '今年',
                    type: 'bar',
                    data: [],
                    markPoint: {
                        data: [
                        { type: 'max', name: 'Max' },
                        { type: 'min', name: 'Min' }
                        ]
                    },
                    markLine: {
                        data: [{ type: 'average', name: 'Avg' }]
                    }
                    }
                ]
            }
        }
    },
    components:{
        OperationSpecificComponent
    },
    created(){
        
    },
    mounted() {

        axios.post("http://localhost:8080/pos/analysis", {   
            "startDate": "",
            "endDate": ""
        })
        .then(response=>{
            this.allDateList = response.data.analysis.revenueGrowth.map(item => new Date(item.day));
            this.firstOperationDate = response.data.analysis.revenueGrowth[0].day
            this.dateForDay = this.allDateList[this.allDateList.length - 1]
            this.preDateForDay = this.allDateList[this.allDateList.length - 2]
        })
        .then(()=>{
            return Promise.all([
                        axios.post("http://localhost:8080/pos/analysis", {   
                        "startDate": this.dateForDay,
                        "endDate": this.dateForDay
                    }),
                        axios.post("http://localhost:8080/pos/analysis", {   
                        "startDate": this.preDateForDay,
                        "endDate": this.preDateForDay
                    }),
            ])
        })
        .then(([response2, response3]) => {
            this.analysis = response2.data.analysis;
            this.analysis.popularDishes = this.analysis.popularDishes.sort((a, b) => b.orders - a.orders);
            this.preAnalysis = response3.data.analysis;

            this.optionLine.xAxis.data = this.allDateList[this.allDateList.length-1]
            this.optionLine.series[0].data = this.analysis.revenueGrowth.map(item=>item.revenue)

            this.optionLineDishes.xAxis.data = this.analysis.popularDishes.map(item=>item.name)
            this.optionLineDishes.series[0].data = this.analysis.popularDishes.map(item=>item.orders)
        })   
        .catch(error => {
            console.error("Error fetching analysis:", error);
        });
        this.$nextTick(() => {
            this.drawChart();  // 初始化图表
            this.drawDishesChart()
        });
    },
    computed:{
        currentDay() {
            const year = this.dateForDay.getFullYear();
            const month = String(this.dateForDay.getMonth() + 1).padStart(2, '0'); // 月份從 0 開始，需加 1
            const day = String(this.dateForDay.getDate()).padStart(2, '0'); // 格式化日期，確保兩位數
            this.startDate = `${year}-${month}-${day}`;
            this.endDate = `${year}-${month}-${day}`;
            this.postStartDateAndEndDate(this.startDate, this.endDate)
            this.preCurrentDay

            return `${year}年${month}月${day}日`;
        },
        preCurrentDay() {
            const preYear = this.preDateForDay.getFullYear();
            const preMonth = String(this.preDateForDay.getMonth() + 1).padStart(2, '0'); // 月份從 0 開始，需加 1
            const preDay = String(this.preDateForDay.getDate()).padStart(2, '0'); // 格式化日期，確保兩位數
            this.preStartDate = `${preYear}-${preMonth}-${preDay}`;
            this.preEndDate = `${preYear}-${preMonth}-${preDay}`;
            this.postPreStartDateAndPreEndDate(this.preStartDate, this.preEndDate)

            return `${preYear}年${preMonth}月${preDay}日`;
        },


        previousDay() {
            const index = this.allDateList.indexOf(this.dateForDay)
            this.dateForDay = this.allDateList[index-1]
            this.preDateForDay = this.allDateList[index-2]

            // const newDate = new Date(this.dateForDay); // 先複製當前日期
            // newDate.setDate(newDate.getDate() - 1); // 修改新日期的值
            // this.dateForDay = newDate; // 賦值給 date，這樣 Vue 才能監測變化

            // const newDate2 = new Date(this.preDateForDay); // 先複製當前日期
            // newDate2.setDate(newDate2.getDate() - 1); // 修改新日期的值
            // this.preDateForDay = newDate2; // 賦值給 date，這樣 Vue 才能監測變化

        },
        nextDay() {
            const index = this.allDateList.indexOf(this.dateForDay)
            this.dateForDay = this.allDateList[index+1]
            this.preDateForDay = this.allDateList[index]

            // const newDate = new Date(this.dateForDay); // 先複製當前日期
            // newDate.setDate(newDate.getDate() + 1); // 修改新日期的值
            // this.dateForDay = newDate; // 賦值給 date，這樣 Vue 才能監測變化

            // const newDate2 = new Date(this.preDateForDay); // 先複製當前日期
            // newDate2.setDate(newDate2.getDate() + 1); // 修改新日期的值
            // this.preDateForDay = newDate2; // 賦值給 date，這樣 Vue 才能監測變化
        },

        ///////////////////////////////////////////////////////////
        currentMonth() {
            const year = this.dateForMonth.getFullYear();
            const month = String(this.dateForMonth.getMonth()+1).padStart(2, '0'); // 月份從 0 開始，需加 1

            // 計算第一天 and 計算最後一天
            let firstDay = new Date(year, month - 1, 1); 
            let lastDay = new Date(year, month, 0); 
            firstDay = String(firstDay.getDate()).padStart(2, '0')
            lastDay = String(lastDay.getDate()).padStart(2, '0')
            this.startDate = `${year}-${month}-${firstDay}`;
            this.endDate = `${year}-${month}-${lastDay}`;
            this.postStartDateAndEndDate(this.startDate, this.endDate)
            this.preCurrentMonth

            //這是為了計算第二張圖用的
            // this.option.legend.data[1] = String(year)
            // this.option.series[1].name = String(year)
            // this.option.legend.data[0] = String(year-1)
            // this.option.series[0].name = String(year-1)


            // 接下來送出一年的12個月份
            //[preDates,currentDates]
            let result = this.getFirstAndLastDaysOfYear(year);
            this.postEveryMonthOfYear(result)


            return `${year}年${month}月`;
        },
        preCurrentMonth() {
            const preYear = this.preDateForMonth.getFullYear();
            const preMonth = String(this.preDateForMonth.getMonth()+1).padStart(2, '0'); // 月份從 0 開始，需加 1

            // 計算第一天 and 計算最後一天
            let preFirstDay = new Date(preYear, preMonth - 1, 1); 
            let preLastDay = new Date(preYear, preMonth, 0); 
            preFirstDay = String(preFirstDay.getDate()).padStart(2, '0')
            preLastDay = String(preLastDay.getDate()).padStart(2, '0')
            this.preStartDate = `${preYear}-${preMonth}-${preFirstDay}`;
            this.preEndDate = `${preYear}-${preMonth}-${preLastDay}`;
            this.postPreStartDateAndPreEndDate(this.preStartDate, this.preEndDate)

            return `${preYear}年${preMonth}月`;
        },
        previousMonth(){
            const newDate = new Date(this.dateForMonth);
            newDate.setMonth(newDate.getMonth() - 1);
            this.dateForMonth = newDate;
      
            const newDate2 = new Date(this.preDateForMonth); // 先複製當前日期
            newDate2.setMonth(newDate2.getMonth() - 1); // 修改新日期的值
            this.preDateForMonth = newDate2; // 賦值給 date，這樣 Vue 才能監測變化
  },
        nextMonth(){
            const newDate = new Date(this.dateForMonth);
            newDate.setMonth(newDate.getMonth() + 1);
            this.dateForMonth = newDate;        

            const newDate2 = new Date(this.preDateForMonth); // 先複製當前日期
            newDate2.setMonth(newDate2.getMonth() + 1); // 修改新日期的值
            this.preDateForMonth = newDate2; // 賦值給 date，這樣 Vue 才能監測變化
        },

        ///////////////////////////////////////////////////////////

        currentSeason() {
            let year = this.dateForSeason.getFullYear();
            let month = String(this.dateForSeason.getMonth()+1).padStart(2, '0'); // 月份從 0 開始，需加 1
            
            let monthStart
            let monthEnd
            if (month>=1 && month<=3){
                monthStart = 1
                monthEnd = 3
            }
            if (month>=4 && month<=6){
                monthStart = 4
                monthEnd = 6
            }
            if (month>=7 && month<=9){
                monthStart = 7
                monthEnd = 9
            }
            if (month>=10 && month<=12){
                monthStart = 10
                monthEnd = 12
            }
            //1~3 4~6 7~9 10~12
            // 計算第一天 and 計算最後一天
            let firstDay = new Date(year, monthStart, 1);
            let lastDay = new Date(year, monthEnd, 0)
            firstDay = String(firstDay.getDate()).padStart(2, '0')
            lastDay = String(lastDay.getDate()).padStart(2, '0')
            monthStart = String(monthStart).padStart(2, '0') 
            monthEnd = String(monthEnd).padStart(2, '0') 
            this.startDate = `${year}-${monthStart}-${firstDay}`;
            this.endDate = `${year}-${monthEnd}-${lastDay}`;
            this.postStartDateAndEndDate(this.startDate, this.endDate)
            this.preCurrentSeason

            //這是為了計算第二張圖用的
            // this.option.legend.data[1] = String(year)
            // this.option.series[1].name = String(year)
            // this.option.legend.data[0] = String(year-1)
            // this.option.series[0].name = String(year-1)

            // 接下來送出一年的12個月份
            //[preDates,currentDates]
            let result = this.getFirstAndLastDaysOfSeason(year);
            this.postEveryMonthOfSeason(result)




            return `${year}年${monthStart}月~${monthEnd}月`;
        },
        preCurrentSeason() {
            let year = this.preDateForSeason.getFullYear();
            let month = String(this.preDateForSeason.getMonth()+1).padStart(2, '0'); // 月份從 0 開始，需加 1
            
            let monthStart
            let monthEnd
            if (month>=1 && month<=3){
                monthStart = 1
                monthEnd = 3
            }
            if (month>=4 && month<=6){
                monthStart = 4
                monthEnd = 6
            }
            if (month>=7 && month<=9){
                monthStart = 7
                monthEnd = 9
            }
            if (month>=10 && month<=12){
                monthStart = 10
                monthEnd = 12
            }

            //1~3 4~6 7~9 10~12
            // 計算第一天 and 計算最後一天
            let firstDay = new Date(year, monthStart, 1);
            let lastDay = new Date(year, monthEnd, 0)
            firstDay = String(firstDay.getDate()).padStart(2, '0')
            lastDay = String(lastDay.getDate()).padStart(2, '0')
            monthStart = String(monthStart).padStart(2, '0') 
            monthEnd = String(monthEnd).padStart(2, '0') 
            this.preStartDate = `${year}-${monthStart}-${firstDay}`;
            this.preEndDate = `${year}-${monthEnd}-${lastDay}`;
            this.postPreStartDateAndPreEndDate(this.preStartDate, this.preEndDate)

            return `${year}年${monthStart}月~${monthEnd}月`;
        },
        previousSeason(){
            const newDate = new Date(this.dateForSeason);
            newDate.setMonth(newDate.getMonth() - 3);
            this.dateForSeason = newDate;

            const newDate2 = new Date(this.preDateForSeason);
            newDate2.setMonth(newDate2.getMonth() - 3);
            this.preDateForSeason = newDate2;
        },
        nextSeason(){
            const newDate = new Date(this.dateForSeason);
            newDate.setMonth(newDate.getMonth() + 3);
            this.dateForSeason = newDate;   

            const newDate2 = new Date(this.preDateForSeason);
            newDate2.setMonth(newDate2.getMonth() + 3);
            this.preDateForSeason = newDate2;        
        },

        ///////////////////////////////////////////////////////////
        currentYear() {
            let year = this.dateForYear.getFullYear();
            let firstDay = new Date(year, 1, 1);
            let lastDay = new Date(year, 12, 0)
            firstDay = String(firstDay.getDate()).padStart(2, '0')
            lastDay = String(lastDay.getDate()).padStart(2, '0')
            this.startDate = `${year}-01-${firstDay}`;
            this.endDate = `${year}-12-${lastDay}`;
            this.postStartDateAndEndDate(this.startDate, this.endDate);

            // this.option.legend.data[1] = String(year)
            // this.option.series[1].name = String(year)
            // this.option.legend.data[0] = String(year-1)
            // this.option.series[0].name = String(year-1)
            // 接下來送出一年的12個月份
            //[preDates,currentDates]
            // let result = this.getFirstAndLastDaysOfYear(year);
            // this.postEveryMonthOfYear(result)


            //這是為了計算第二張圖用的
            this.option.legend.data[1] = String(year)
            this.option.series[1].name = String(year)
            this.option.legend.data[0] = String(year-1)
            this.option.series[0].name = String(year-1)

            // 接下來送出一年的12個月份
            //[preDates,currentDates]
            let result = this.getFirstAndLastDaysOfSeason(year);
            this.postEveryMonthOfSeason(result)

            return `${year}年`;
        },
        preCurrentYear() {
            let year = this.preDateForYear.getFullYear();
            let firstDay = new Date(year, 1, 1);
            let lastDay = new Date(year, 12, 0)
            firstDay = String(firstDay.getDate()).padStart(2, '0')
            lastDay = String(lastDay.getDate()).padStart(2, '0')
            this.preStartDate = `${year}-01-${firstDay}`;
            this.preEndDate = `${year}-12-${lastDay}`;
            this.postPreStartDateAndPreEndDate(this.preStartDate, this.preEndDate)

            return `${year}年`;
        },
        previousYear(){
            const newDate = new Date(this.dateForYear);
            newDate.setFullYear(newDate.getFullYear() - 1);
            this.dateForYear = newDate;

            const newDate2 = new Date(this.preDateForYear);
            newDate2.setFullYear(newDate2.getFullYear() - 1);
            this.preDateForYear = newDate2;
        },
        nextYear(){
            const newDate = new Date(this.dateForYear);
            newDate.setFullYear(newDate.getFullYear() + 1);
            this.dateForYear = newDate;

            const newDate2 = new Date(this.preDateForYear);
            newDate2.setFullYear(newDate2.getFullYear() + 1);
            this.preDateForYear = newDate2;        
        },

    },
    methods:{
        postEveryMonthOfYearDishes(mealName){
            if (this.currentHead != '年'){

            //這是年在用的
            //為了bar的統計圖 x軸應該是月份
            //當前年當月
            this.analysisMealVoList = []
            this.analysis12Month = []
            this.lastYearAnalysis12Month = []
            let result = this.getFirstAndLastDaysOfYear(this.dateForYear.getFullYear())
            let currentDate = result[1]
            let promisesCurrrDate = [];
            for (let month=0; month<12; month++){
                console.log(currentDate[month][0])
                console.log(currentDate[month][1])
                let promise = axios.post("http://localhost:8080/pos/analysis", {   
                            "startDate":currentDate[month][0],
                            "endDate":currentDate[month][1],
                            "mealName": mealName
                })
                promisesCurrrDate.push(promise)
            }
            Promise.all(promisesCurrrDate)
                .then(responses=>{
                    responses.forEach(response => {
                        this.analysis12Month.push(response.data.analysis);
                    });
                    let mealTotalOrdersList = this.analysis12Month.map(item => item.analysisMealVo.mealTotalOrders);
                    console.log(this.analysis12Month)    
                    this.option.series[1].data = mealTotalOrdersList
                    this.drawChart()
                })
                .catch(error => {
                    console.error("Error in one or more requests:", error);
                });    

            //這是年在用的x軸應該是月份
            //為了bar的統計圖
            //去年同月    
            let lastYearDate = result[2]
            let promisesLastYearDate = [];
            for (let month=0; month<12; month++){
                let promise = axios.post("http://localhost:8080/pos/analysis", {   
                            "startDate":lastYearDate[month][0],
                            "endDate":lastYearDate[month][1],
                            "mealName": mealName
                })
                promisesLastYearDate.push(promise)
            }
            Promise.all(promisesLastYearDate)
                .then(responses=>{
                    responses.forEach(response => {
                        this.lastYearAnalysis12Month.push(response.data.analysis);
                    });
                    let mealTotalOrdersList = this.lastYearAnalysis12Month.map(item => item.analysisMealVo.mealTotalOrders);
                    console.log('last' + mealTotalOrdersList)    
                    this.option.series[0].data = mealTotalOrdersList
                    this.drawChart()
                })
                .catch(error => {
                    console.error("Error in one or more requests:", error);
                });    


            //點擊商品時計算折線圖顯示販賣的商品數量 
            //optionLine就是echat1負責，用來顯示x軸是日期y軸是餐點銷售數量
            //給月使用
            let promisesAnalysisMealVoList = [];
            this.optionLine.legend.data[0] = '商品銷售量'
            this.optionLine.series[0].name = '商品銷售量'
            this.optionLine.series[0].type = 'bar'
            console.log(this.optionLine)
            for (let i=0; i<this.optionLine.series[0].data.length; i++){
                let promise = axios.post("http://localhost:8080/pos/analysis", {   
                            "startDate":this.optionLine.xAxis.data[i],
                            "endDate":this.optionLine.xAxis.data[i],
                            "mealName": mealName
                })
                promisesAnalysisMealVoList.push(promise)
            }

            Promise.all(promisesAnalysisMealVoList)
                .then(responses=>{
                    responses.forEach(response => {
                        this.analysisMealVoList.push(response.data.analysis);
                    });
                })
                .then(()=>{
                    let list = this.analysisMealVoList.map(item=>item.analysisMealVo.mealTotalOrders)
                    this.optionLine.series[0].data = list
                    this.drawChart()
                })
                .catch(error => {
                    console.error("Error in one or more requests:", error);
                }); 

            }

            
            //這是給年用的 x軸是每一季
            if (this.currentHead == '年'){
                console.log('進入年的領域')
                this.analysisMealVoList = []
                this.analysis4Season = []
                this.lastYearAnalysis4Season = []
                //先獲取時間段
                let seasonTimeresult = this.getFirstAndLastDaysOfSeason(this.dateForYear.getFullYear())
                console.log(seasonTimeresult)
                
                let currentYearSeason = seasonTimeresult[1] //今年
                let lastYearSeason = seasonTimeresult[2] //去年
                let promisesCurrrYearSeason = [];
                let promisesLastYearSeason = [];
                
                // 當前年份请求 季度x軸
                for (let season = 0; season < 4; season++) {
                    let promiseCurrent = axios.post("http://localhost:8080/pos/analysis", {
                        "startDate": currentYearSeason[season][0],
                        "endDate": currentYearSeason[season][1],
                        "mealName":mealName
                    });
                    promisesCurrrYearSeason.push(promiseCurrent);
                }
                // 去年年份请求 季度x軸
                for (let season = 0; season < 4; season++) {
                    let promiseLastYear = axios.post("http://localhost:8080/pos/analysis", {
                        "startDate": lastYearSeason[season][0],
                        "endDate": lastYearSeason[season][1],
                        "mealName":mealName
                    });
                    promisesLastYearSeason.push(promiseLastYear);
                }
                // 同時處理兩個Promise.all
                Promise.all([...promisesCurrrYearSeason, ...promisesLastYearSeason])
                    .then(responses=>{
                        // 處理當前年份數據 (前4個response對應當前年分)
                        responses.slice(0, 4).forEach(response=>{
                            this.analysis4Season.push(response.data.analysis);
                        })

                        let mealTotalOrders = this.analysis4Season.map(item=>item.analysisMealVo.mealTotalOrders)
                        console.log('mealTotalOrders' + mealTotalOrders)
                        this.option.series[1].data = mealTotalOrders;
                        this.option.xAxis[0].data = ["第一季", "第二季", "第三季", "第四季"];
                        
                        //處理去年同月數據 (後4個response對應去年年分)
                        responses.slice(4).forEach(response=>{
                            this.lastYearAnalysis4Season.push(response.data.analysis);
                        })
                        let lastMealTotalOrders = this.lastYearAnalysis4Season.map(item=>item.analysisMealVo.mealTotalOrders)
                        console.log('lastMealTotalOrders' + lastMealTotalOrders)
                        this.option.series[0].data = lastMealTotalOrders;
                        this.option.xAxis[0].data = ["第一季", "第二季", "第三季", "第四季"];

                        //繪製圖表
                        this.drawChart();
                    })
                    .catch(error => {
                        console.error("Error in one or more requests:", error);
                    });

            }
                

        },
        getFirstAndLastDaysOfSeason(year){
            this.option.legend.data[0] = String(year-1)
            this.option.series[0].name = String(year-1)
            this.option.legend.data[1] = String(year)
            this.option.series[1].name = String(year)



            const currentDates = [];
            for (let season = 0; season < 4; season++) {
                // 第一個月的第一天
                const firstDay = new Date(year, season*3, 1);
                // 該月的最後一天
                const lastDay = new Date(year, season*3 + 3, 0);
                // 格式化日期為 yyyy-mm-dd 格式
                const firstDayFormatted = firstDay.toISOString().split('T')[0];
                const lastDayFormatted = lastDay.toISOString().split('T')[0];
                // 將兩個日期加入結果
                currentDates.push([firstDayFormatted, lastDayFormatted]);
            }

            const preDates = [];
            // for (let month = 0; month < 12; month++) {
            //     // 第一個月的第一天
            //     const firstDay = new Date(year, month-1, 1);
            //     // 該月的最後一天
            //     const lastDay = new Date(year, month, 0);
            //     // 格式化日期為 yyyy-mm-dd 格式
            //     const firstDayFormatted = firstDay.toISOString().split('T')[0];
            //     const lastDayFormatted = lastDay.toISOString().split('T')[0];
            //     // 將兩個日期加入結果
            //     preDates.push([firstDayFormatted, lastDayFormatted]);
            // }

            const lastYearDates = [];
            for (let season = 0; season < 4; season++) {
                // 第一個月的第一天
                const firstDay = new Date(year-1, season*3, 1);
                // 該月的最後一天
                const lastDay = new Date(year-1, season*3 + 3, 0);
                // 格式化日期為 yyyy-mm-dd 格式
                const firstDayFormatted = firstDay.toISOString().split('T')[0];
                const lastDayFormatted = lastDay.toISOString().split('T')[0];
                // 將兩個日期加入結果
                lastYearDates.push([firstDayFormatted, lastDayFormatted]);
            }
            
            return [preDates, currentDates, lastYearDates]
        },
        postEveryMonthOfSeason(result){
            this.analysis4Season = [];
            this.preAnalysis4Season = [];
            this.lastYearAnalysis4Season = [];

            // 當前年當月
            let currentDate = result[1];
            let lastYearDate = result[2];

            let promisesCurrrDate = [];
            let promisesLastYearDate = [];

            // 当前年份请求
            for (let month = 0; month < 4; month++) {
                let promiseCurrent = axios.post("http://localhost:8080/pos/analysis", {
                    "startDate": currentDate[month][0],
                    "endDate": currentDate[month][1]
                });
                promisesCurrrDate.push(promiseCurrent);
            }

            // 去年同月请求
            for (let month = 0; month < 4; month++) {
                let promiseLastYear = axios.post("http://localhost:8080/pos/analysis", {
                    "startDate": lastYearDate[month][0],
                    "endDate": lastYearDate[month][1]
                });
                promisesLastYearDate.push(promiseLastYear);
            }

            // 同时处理两个Promise.all
            Promise.all([...promisesCurrrDate, ...promisesLastYearDate])
                .then(responses => {
                    // 处理当前年份数据 (前4个response对应当前年份)
                    responses.slice(0, 4).forEach(response => {
                        this.analysis4Season.push(response.data.analysis);
                    });
                    let totalRevenueList = this.analysis4Season.map(item => item.totalRevenue);
                    console.log('今年' + totalRevenueList);
                    this.option.series[1].data = totalRevenueList;
                    this.option.xAxis[0].data = ["第一季", "第二季", "第三季", "第四季"];

                    // 处理去年同月数据 (后4个response对应去年数据)
                    responses.slice(4).forEach(response => {
                        this.lastYearAnalysis4Season.push(response.data.analysis);
                    });
                    let lastYearRevenueList = this.lastYearAnalysis4Season.map(item => item.totalRevenue);
                    console.log('去年' + lastYearRevenueList);
                    this.option.series[0].data = lastYearRevenueList;

                    // 绘制图表
                    this.drawChart();
                })
                .catch(error => {
                    console.error("Error in one or more requests:", error);
                });

        },
        getFirstAndLastDaysOfYear(year){
            const currentDates = [];
            for (let month = 0; month < 12; month++) {
                // 第一個月的第一天
                const firstDay = new Date(year, month, 1);
                // 該月的最後一天
                const lastDay = new Date(year, month + 1, 0);
                // 格式化日期為 yyyy-mm-dd 格式
                const firstDayFormatted = firstDay.toISOString().split('T')[0];
                const lastDayFormatted = lastDay.toISOString().split('T')[0];
                // 將兩個日期加入結果
                currentDates.push([firstDayFormatted, lastDayFormatted]);
            }

            const preDates = [];
            for (let month = 0; month < 12; month++) {
                // 第一個月的第一天
                const firstDay = new Date(year, month-1, 1);
                // 該月的最後一天
                const lastDay = new Date(year, month, 0);
                // 格式化日期為 yyyy-mm-dd 格式
                const firstDayFormatted = firstDay.toISOString().split('T')[0];
                const lastDayFormatted = lastDay.toISOString().split('T')[0];
                // 將兩個日期加入結果
                preDates.push([firstDayFormatted, lastDayFormatted]);
            }

            const lastYearDates = [];
            for (let month = 0; month < 12; month++) {
                // 第一個月的第一天
                const firstDay = new Date(year-1, month, 1);
                // 該月的最後一天
                const lastDay = new Date(year-1, month+1, 0);
                // 格式化日期為 yyyy-mm-dd 格式
                const firstDayFormatted = firstDay.toISOString().split('T')[0];
                const lastDayFormatted = lastDay.toISOString().split('T')[0];
                // 將兩個日期加入結果
                lastYearDates.push([firstDayFormatted, lastDayFormatted]);
            }
            
            return [preDates, currentDates, lastYearDates]
        },
        postEveryMonthOfYear(result){
            // 當前年當月
            let currentDate = result[1]
            let promisesCurrrDate = [];
            for (let month=0; month<12; month++){
                let promise = axios.post("http://localhost:8080/pos/analysis", {   
                            "startDate":currentDate[month][0],
                            "endDate":currentDate[month][1]
                })
                promisesCurrrDate.push(promise)
            }
            Promise.all(promisesCurrrDate)
                .then(responses=>{
                    responses.forEach(response => {
                        this.analysis12Month.push(response.data.analysis);
                    });
                    let totalRevenueList = this.analysis12Month.map(item => item.totalRevenue);
                    this.option.series[1].data = totalRevenueList
                    this.option.xAxis[0].data = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
                    this.drawChart()
                })
                .catch(error => {
                    console.error("Error in one or more requests:", error);
                });    
                

            //去年同月    
            let lastYearDate = result[2]
            let promisesLastYearDate = [];
            for (let month=0; month<12; month++){
                let promise = axios.post("http://localhost:8080/pos/analysis", {   
                            "startDate":lastYearDate[month][0],
                            "endDate":lastYearDate[month][1]
                })
                promisesLastYearDate.push(promise)
            }
            Promise.all(promisesLastYearDate)
                .then(responses=>{
                    responses.forEach(response => {
                        this.lastYearAnalysis12Month.push(response.data.analysis);
                    });
                    let totalRevenueList = this.lastYearAnalysis12Month.map(item => item.totalRevenue);
                    this.option.series[0].data = totalRevenueList
                    this.option.xAxis[0].data = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
                    this.drawChart()
                })
                .catch(error => {
                    console.error("Error in one or more requests:", error);
                });
                
                
            // this.option.legend.data[1] = String(year)
            // this.option.series[1].name = String(year)
            // this.option.legend.data[0] = String(year-1)
            // this.option.series[0].name = String(year-1)

        },
        todayDate(){
            let today = new Date();
            const year = today.getFullYear();
            const month = String(today.getMonth() + 1).padStart(2, '0'); 
            const day = String(today.getDate()).padStart(2, '0'); 

            return `${year}年${month}月${day}日`;
        },
        isFirstOperationDateBeforeMonth(firstOperationDate, dateForMonth) {
            const firstDate = new Date(firstOperationDate);
            const comparisonDate = new Date(dateForMonth);

            // 比較年份
            if (firstDate.getFullYear() < comparisonDate.getFullYear()) {
                return true;
            } else if (firstDate.getFullYear() === comparisonDate.getFullYear()) {
                // 如果年份相同，則比較月份
                return firstDate.getMonth() < comparisonDate.getMonth();
            }
            return false;
        },
        getSeason(date) {
            const month = date.getMonth() + 1; // 月份從 0 開始，所以要加 1
            if (month >= 1 && month <= 3) return 1; // 第一季
            if (month >= 4 && month <= 6) return 2; // 第二季
            if (month >= 7 && month <= 9) return 3; // 第三季
            if (month >= 10 && month <= 12) return 4; // 第四季
        },

        isFirstOperationDateBeforeSeason(firstOperationDate, dateForSeason) {
            const firstDate = new Date(firstOperationDate);
            const comparisonDate = new Date(dateForSeason);

            // 獲取季節
            const firstSeason = this.getSeason(firstDate);
            const comparisonSeason = this.getSeason(comparisonDate);

            // 比較年份和季節
            if (firstDate.getFullYear() < comparisonDate.getFullYear()) {
                return true;
            } else if (firstDate.getFullYear() === comparisonDate.getFullYear()) {
                return firstSeason < comparisonSeason; // 只比較季節
            }
            return false;
        },
        drawDishesChart(){
            const myChart0 = echarts.init(document.getElementById("echart0"));
            if (myChart0) {
                myChart0.setOption(this.optionLineDishes);  
            } else {
                console.error("Invalid DOM: chart container not found");
            }
        },
        drawChart() {

            const myChart1 = echarts.init(document.getElementById("echart1"));
            if (myChart1) {
                myChart1.setOption(this.optionLine);  
            } else {
                console.error("Invalid DOM: chart container not found");
            }
            const myChart2 = echarts.init(document.getElementById("echart2"));
            if (myChart2) {
                myChart2.setOption(this.option);  
            } else {
                console.error("Invalid DOM: chart container not found");
            }
        },

        selectPeriod(type){
            this.currentHead = type
        },
        calRevenueGrowth(){
            let revenueUpRate = (this.analysis.totalRevenue - this.preAnalysis.totalRevenue) / (this.preAnalysis.totalRevenue) * 100
            revenueUpRate = Math.round(revenueUpRate)
            return revenueUpRate
        },
        calOrdersGrowth(){
            let ordersUpRate = (this.analysis.totalOrders - this.preAnalysis.totalOrders) / (this.preAnalysis.totalOrders) * 100
            ordersUpRate = Math.round(ordersUpRate)
            return ordersUpRate
        },

        postStartDateAndEndDate(startDate, endDate){
            axios.post("http://localhost:8080/pos/analysis", {   
                            "startDate":startDate,
                            "endDate":endDate
            })
            .then(response=>{
                this.analysis = response.data.analysis
                this.analysis.popularDishes.sort((a,b)=>{return b.orders-a.orders})
            
                this.optionLine.legend.data[0] = '銷售額'
                this.optionLine.series[0].name = '銷售額'
                this.optionLine.series[0].type = 'line'
                this.optionLine.xAxis.data = this.analysis.revenueGrowth.map(item=>item.day)
                this.optionLine.series[0].data = this.analysis.revenueGrowth.map(item=>item.revenue)
                this.optionLineDishes.xAxis.data = this.analysis.popularDishes.map(item=>item.name)
                this.optionLineDishes.series[0].data = this.analysis.popularDishes.map(item=>item.orders)
                console.log(this.optionLineDishes.series[0].data)
            })
            .then(()=>{
                this.drawDishesChart();  // 初始化图表
            })
            .catch(()=>{
                console.error("Error fetching analysis:", error);
            })
        },

        
        postPreStartDateAndPreEndDate(startDate, endDate){
            axios.post("http://localhost:8080/pos/analysis", {   
                            "startDate":startDate,
                            "endDate":endDate
            })
            .then(response=>{
                this.preAnalysis = response.data.analysis
                this.preAnalysis.popularDishes.sort((a,b)=>{return b.orders-a.orders})
            })
        },

        getTodayDate() {
            const today = new Date();
            const year = today.getFullYear();
            const month = String(today.getMonth() + 1).padStart(2, '0'); // 月份從 0 開始，需加 1
            const day = String(today.getDate()).padStart(2, '0'); // 確保日期是兩位數
            this.startDate = `${year}-${month}-${day}`;
            this.endDate = `${year}-${month}-${day}`;

            const preToday = new Date(new Date().setDate(new Date().getDate() - 1));
            const preYear = preToday.getFullYear();
            const preMonth = String(preToday.getMonth() + 1).padStart(2, '0'); // 月份從 0 開始，需加 1
            const preDay = String(preToday.getDate()).padStart(2, '0'); // 確保日期是兩位數
            this.preStartDate = `${preYear}-${preMonth}-${preDay}`;
            this.preEndDate = `${preYear}-${preMonth}-${preDay}`;
        },

        getPeriodDate(startDate, endDate){
            if (!startDate || !endDate) {
                console.error("startDate 或 endDate 不能為 null");
                return [];
            }
            let list = [];
            let start = new Date(startDate);
            let end = new Date(endDate);

            while (start <= end) {
                let year = start.getFullYear(); // 月份從 0 開始，需要加 1
                let month = start.getMonth() + 1; // 月份從 0 開始，需要加 1
                let day = start.getDate();
                list.push(`${year}年${month}月${day}日`);
                start.setDate(start.getDate() + 1); // 增加一天
            }
            return list;
        }
    },
}
</script>


<template>

<div class="container" v-if="analysis">
    <!-- <div class="innerContainer0">
        <p class="topStyle" :class="{topStyleClick: currentTopSelect == '日常統計'}" @click="currentTopSelect = '日常統計'">日常統計</p>
        <p class="topStyle" :class="{topStyleClick: currentTopSelect == '活動統計'}"  @click="currentTopSelect = '活動統計'">活動統計</p>
    </div> -->
    <!-- <h1>{{ allDateList }}</h1> -->
    <!-- <h1 >{{ dateForDay }}</h1> -->
    <!-- <h1 >{{ preDateForDay }}</h1> -->
    <!-- <h1 v-if="analysis">{{ analysis}}</h1> -->
    <!-- <h1 v-if="preAnalysis">{{ preAnalysis}}</h1> -->
    <!-- <h1>{{ this.dateForDay.toISOString().split('T')[0] }}</h1>  -->
    <!-- <h1>{{ this.allDateList[this.allDateList.length - 1].toISOString().split('T')[0] }}</h1>  -->
    <!-- <h1>{{ this.startDate }}</h1>  -->
    <!-- <h1>{{ this.endDate  }}</h1>  -->
    <!-- <h1>{{ this.analysisMealVoList }}</h1> -->
    <!-- <h1>{{ this.optionLine.series[0].data }}</h1> -->
    <!-- <h1>{{ this.optionLine.xAxis.data }}</h1> -->
    <div class="innerContainer" v-if="currentTopSelect == '日常統計'">
        <div class="dashboardLeft">
            <div class="navHead">
                <h1 class="headStyle" :class="{headStyleClick: currentHead == '日'}" @click="selectPeriod('日')">日</h1>
                <h1 class="headStyle" :class="{headStyleClick: currentHead == '月'}" @click="selectPeriod('月')">月</h1>
                <!-- <h1 class="headStyle" :class="{headStyleClick: currentHead == '季'}" @click="selectPeriod('季')">季</h1> -->
                <h1 class="headStyle" :class="{headStyleClick: currentHead == '年'}" @click="selectPeriod('年')">年</h1>
                <!-- <h1 class="headStyle" :class="{headStyleClick: currentHead == '自訂'}" @click="selectPeriod('自訂')">自訂</h1> -->
            </div>

            <div class="echartContainer" v-if="currentHead=='日'">
                <div class="leftRightContainer">
                    <i class='bx bx-chevron-left' @click="previousDay" 
                    v-if="new Date(firstOperationDate).toISOString().split('T')[0] < 
                    dateForDay.toISOString().split('T')[0]"></i>
                    <p>{{ currentDay }}</p>
                    <i class='bx bx-chevron-right' @click="nextDay" 
                    v-if="this.dateForDay.toISOString().split('T')[0] != 
                    this.allDateList[this.allDateList.length - 1].toISOString().split('T')[0]"></i>
                </div>
            </div>
            <div class="echartContainer" v-if="currentHead=='月'">
                <div class="leftRightContainer">
                    <i class='bx bx-chevron-left' @click="previousMonth" v-if="isFirstOperationDateBeforeMonth(firstOperationDate, dateForMonth)"></i>
                    <p>{{ currentMonth }}</p>
                    <i class='bx bx-chevron-right' @click="nextMonth" v-if="dateForMonth.toISOString().split('T')[0] < new Date().toISOString().split('T')[0]"></i>
                </div>
            </div>
            <div class="echartContainer" v-if="currentHead=='季'">
                <div class="leftRightContainer">
                    <i class='bx bx-chevron-left' @click="previousSeason" v-if="isFirstOperationDateBeforeSeason(firstOperationDate, dateForSeason)"></i>
                    <p>{{ currentSeason }}</p> 
                    <i class='bx bx-chevron-right' @click="nextSeason" v-if="dateForSeason.toISOString().split('T')[0] < new Date().toISOString().split('T')[0]"></i>
                </div>
            </div>
            <div class="echartContainer" v-if="currentHead=='年'">
                <div class="leftRightContainer">
                    <i class='bx bx-chevron-left' @click="previousYear" v-if="new Date(firstOperationDate).getFullYear() < dateForYear.getFullYear()"></i>
                    <p>{{ currentYear }}</p>
                    <i class='bx bx-chevron-right' @click="nextYear" v-if="dateForYear.toISOString().split('T')[0] < new Date().toISOString().split('T')[0]"></i>
                </div>
            </div>
            <!-- <div class="echartContainer" v-if="currentHead=='自訂'">
                <p>請選擇日期範圍</p>
                <div class="leftRightContainer">
                    <p>開始</p>
                    <input type="date" v-model="startDate">
                    <p>結束</p>
                    <input type="date" v-model="startDate">
                </div>
            </div> -->
            </div>
        <div class="dashboardRight">
            <!-- <i class='bx bxs-grid'></i> -->
            <!-- <button>下載檔案</button> -->
        </div>
    </div>
    <div class="innerContainer2" v-if="currentTopSelect == '日常統計'">
            <div class="innerContainer2-Left">
                <div class="compareContainer">

                    <div class="compareItem">
                        <p class="title">總銷售額</p>
                        <div class="content">
                            <p class="contentNumber" v-if="analysis && analysis.totalRevenue !== null">${{ analysis.totalRevenue }}</p>
                            <!-- <p class="contentNumber">{{ preAnalysis.totalRevenue }}</p> -->
                        </div>
                        <div class="foot">
                            <!-- <div class="contentRateUp" v-if="analysis && analysis.totalRevenue !== null && preAnalysis && preAnalysis.totalRevenue !== null && calRevenueGrowth()>=0">
                                <i class='bx bx-up-arrow-alt'></i>
                                <p>{{calRevenueGrowth()}}%</p>
                            </div>
                            <div class="contentRateDown" v-if="analysis && analysis.totalRevenue !== null && preAnalysis && preAnalysis.totalRevenue !== null && calRevenueGrowth()<0">
                                <i class='bx bx-down-arrow-alt'></i>
                                <p>{{calRevenueGrowth()}}%</p>
                            </div>
                            <p class="compareWhat" v-if="currentHead=='日'">vs 上個營業日</p>
                            <p class="compareWhat" v-if="currentHead=='月'">vs 前一月</p>
                            <p class="compareWhat" v-if="currentHead=='季'">vs 前一季</p>
                            <p class="compareWhat" v-if="currentHead=='年'">vs 前一年</p> -->
                        </div>    
                    </div>
                    <div class="compareItem">
                        <p class="title">總銷售額上升/下降</p>
                        <div class="content">
                            <div class="contentRateUp" v-if="analysis && analysis.totalRevenue !== null && preAnalysis && preAnalysis.totalRevenue !== null && calRevenueGrowth()>=0">
                                <i class='bx bx-up-arrow-alt'></i>
                                <p>{{calRevenueGrowth()}}%</p>
                            </div>
                            <div class="contentRateDown" v-if="analysis && analysis.totalRevenue !== null && preAnalysis && preAnalysis.totalRevenue !== null && calRevenueGrowth()<0">
                                <i class='bx bx-down-arrow-alt'></i>
                                <p>{{calRevenueGrowth()}}%</p>
                            </div>
                        </div>
                        <div class="foot">
                            <!-- <div class="contentRateUp" v-if="analysis && analysis.totalRevenue !== null && preAnalysis && preAnalysis.totalRevenue !== null && calRevenueGrowth()>=0">
                                <i class='bx bx-up-arrow-alt'></i>
                                <p>{{calOrdersGrowth()}}%</p>
                            </div>
                            <div class="contentRateDown" v-if="analysis && analysis.totalRevenue !== null && preAnalysis && preAnalysis.totalRevenue !== null && calRevenueGrowth()<0">
                                <i class='bx bx-down-arrow-alt'></i>
                                <p>{{calOrdersGrowth()}}%</p>
                            </div> -->
                            <p class="compareWhat" v-if="currentHead=='日'">vs 上個營業日</p>
                            <p class="compareWhat" v-if="currentHead=='月'">vs 前一月</p>
                            <p class="compareWhat" v-if="currentHead=='季'">vs 前一季</p>
                            <p class="compareWhat" v-if="currentHead=='年'">vs 前一年</p>
                        </div>    
                    </div>
                    <!-- <div class="compareItem">
                        <p class="title">總銷售量</p>
                        <div class="content">
                            <p class="contentNumber" v-if="analysis && analysis.totalOrders !== null">{{ analysis.totalOrders }}</p>
                        </div>
                        <div class="foot">
                            <div class="contentRateUp" v-if="analysis && analysis.totalOrders !== null && preAnalysis && preAnalysis.totalOrders !== null && calOrdersGrowth()>=0">
                                <i class='bx bx-up-arrow-alt'></i>
                                <p>{{calOrdersGrowth()}}%</p>
                            </div>
                            <div class="contentRateDown" v-if="analysis && analysis.totalOrders !== null && preAnalysis && preAnalysis.totalOrders !== null && calOrdersGrowth()<0">
                                <i class='bx bx-down-arrow-alt'></i>
                                <p>{{calOrdersGrowth()}}%</p>
                            </div>
                            <p class="compareWhat" v-if="currentHead=='日'">vs 上個營業日</p>
                            <p class="compareWhat" v-if="currentHead=='月'">vs 前一月</p>
                            <p class="compareWhat" v-if="currentHead=='季'">vs 前一季</p>
                            <p class="compareWhat" v-if="currentHead=='年'">vs 前一年</p>
                        </div>    
                    </div> -->
                </div>
                <div class="chartArea" >
                    <div class="chartContainer0" v-show="currentHead=='日'">
                        <h1>日餐點銷售數量</h1>
                        <div id="echart0">
                        </div>
                    </div>
                    <div class="chartContainer1" v-show="currentHead=='月'">
                        <h1>月每日營業額</h1>
                        <div id="echart1" >
                        </div>
                    </div>
                    <div class="chartContainer2" v-if="currentHead=='年'">
                        <h1>季比較圖</h1>
                        <div id="echart2" >
                        </div>
                    </div>
                </div>    
            </div>
            <div class="innerContainer2-Right">
                <div class="title">
                    <h1>人氣餐點排行</h1>

                    <!-- <p>View All</p> -->
                </div >
                <div class="column">
                    <p>Rank</p>
                    <p>Name</p>
                </div>
                <div class="poppularDishes">
                    <div class="dishItem" v-if="analysis && analysis.popularDishes!==null" v-for="(dish,index) in analysis.popularDishes"
                    @click="postEveryMonthOfYearDishes(dish.name)">
                        <p class="rank">{{ String(index+1).padStart(2,"0")}}</p>
                        <!-- <img class="img" src="https://tokyo-kitchen.icook.network/uploads/recipe/cover/420886/dd9e8293a9b1a758.jpg" alt=""> -->
                        <div class="content">
                            <h1 class="name">{{dish.name}}</h1>
                            <div class="quantity">
                                <p>Orders:</p>
                                <p>{{ dish.orders }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
    </div>
    <div class="innerContainerSpecific" v-if="currentTopSelect == '活動統計'">
        <OperationSpecificComponent/>
    </div>
</div>

</template>


<style scoped lang ="scss">
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@100..900&display=swap');
$up-background: #ffcdd2;
$up-font: #c62828;
$down-background: #c8e6c9;
$down-font: #388e3c;


*{
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: "Noto Sans TC", sans-serif;
}

.container{
    width: 100%;
    height: 100dvh;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    justify-content: flex-start;
    padding: 2% 0 4% 0;
    // .innerContainer0{
    //     width: 100%;
    //     height: 10%;
    //     display: flex;
    //     align-items: center;
    //     justify-content: center;
    //     background-color: white;
    //     border-radius: 12px;
    //     border: 2px solid rgba(0, 0, 0, 0.25);
    //     margin: 0 0 1% 0;

    //     .topStyle{
    //         width: 8%;
    //         height: 100%;
    //         display: flex;
    //         align-items: center;
    //         justify-content: center;
    //         font-size: 20px;
    //         font-weight: 600;
    //         color: rgba(0, 0, 0, 0.7);
    //         cursor: pointer;
            
    //     }
    //     .topStyleClick{
    //         color: black;
    //         position: relative;
    //         &::before{
    //             position: absolute;
    //             content: "";
    //             width: 100%;
    //             height: 2px;
    //             left: 0;
    //             bottom: 0;
    //             color: black;
    //             background-color: black;
    //         }
    //     }
    // }
    .innerContainer{
        width: 100%;
        height: 10%;
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin: 0 0 0 0;

        .dashboardLeft{
            width: 90%;
            height: 45px;
            display: flex;
            align-items: center;
            justify-content: flex-start;
            .navHead{
                width: 30%;
                height: 100%;
                display: flex;
                justify-content: space-evenly;
                align-items: center;
                background-color: rgba(255, 255, 255, 0.7);
                border-radius: 10px;
                border: 1px solid rgba(grey, 0.5);
                border: 1px solid;
                box-shadow: -3px 3px 4px black;
                padding: 0 0;
                margin: 0 5% 0 0;
                position: relative;

                .headStyle{
                    width: 25%;
                    font-size: 20px;
                    text-align: center;
                    display: flex;
                    justify-content: center;  /* 水平居中 */
                    align-items: center;      /* 垂直居中 */
                    cursor: pointer;

                    &:hover{
                        color: white;
                        background-color: rgba(0, 0, 255, 0.301);
                        border-radius: 12px;
                    }
                }

                .headStyleClick {
                    color: white;
                    background-color: rgba(0, 0, 255, 0.301);
                    border-radius: 12px;
                }

            }
            .echartContainer {
                width: 35%;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                background-color: rgba(255, 255, 255, 0.7);
                border-radius: 12px;
                border: 1px solid rgba(grey, 0.5);
                border: 1px solid;
                box-shadow: -3px 3px 4px black;

                .leftRightContainer{
                    width: 100%;
                    display: flex;
                    align-items: center;
                    justify-content: center;

                    i{  
                        width: 50px;
                        display: flex;
                        text-align: center;
                        justify-content: center;
                        background-color: rgba(0, 0, 0, 0.121);
                        font-size: 30px;
                        cursor: pointer;
                        border-radius: 12px;
                        padding: 2px 0 0 0;
                    }
                    p{
                        font-size: 25px;
                        margin: 0 10px;
                    }
                    input{
                        width: 150px;
                        height: 40px;
                        border-radius: 12px;
                    }
                }
            }
        }

        .dashboardRight{
            width: 50%;
            display: flex;
            align-items: center;
            justify-content: flex-end;

            i{
                font-size: 25px;
                margin: 0 10px 0 0;
                cursor: pointer;

            }

            button{
                width: 120px;
                height: 40px;
                font-size: 18px;
                color: white;
                border: none;
                border-radius: 12px;
                background-color: #2DB976;
                cursor: pointer;
            }
        }
    }
    .innerContainer2{
        width: 100%;
        height: 90%;
        display: flex;
        align-items: flex-start;
        justify-content: flex-start;
        margin: 0% 0 0 0;
        .innerContainer2-Left{
            width: 75%;
            height: 100%;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            justify-content: flex-start;
            border-radius: 12px;
            margin: 0 1% 0 0;

            .compareContainer{
                width: 100%;
                height: 25%;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 12px;
                background-color: white;
                border: 1px solid rgba(grey, 0.5);
                border: 1px solid;
                box-shadow: -3px 3px 4px black;
                margin: 0 0 2% 0;

                .compareItem{
                    width: 50%;
                    height: 100%;
                    padding: 20px 20px;
                    display: flex;
                    flex-direction: column;
                    align-items: flex-start;
                    justify-content: center;
                    margin: 0 0 0 4%;
                    position: relative;
                    &:nth-child(-n+2):before{
                        position: absolute;
                        content: "";
                        width: 2px;                   /* 線的寬度，1px 即為細線 */
                        height: 70%;                 /* 讓線佔滿元素的高度 */
                        top: 20%;                       /* 讓線從頂部開始 */
                        left: -2%;                     /* 將線放在元素的右邊 */
                        background-color: rgba(0, 0, 0, 0.232); /* 線的顏色 */
                    }
                    .title{
                        font-size: 18px;
                        color: #212528;
                        font-weight: 600;
                    }
                    .content{
                        width: 100%;
                        height: 100%;
                        display: flex;
                        align-items: center;
                        justify-content: flex-start;
                        .contentNumber{
                            font-size: 50px;
                            margin: 0 15px 0 0;
                        }
                        .contentRateUp{
                            width: max-content;
                            height: 100%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            text-align: center;
                            border-radius: 12px;
                            background-color: $up-background;
                            padding: 0 1%;
                            margin: 5px 10px 0 0;
                            p{
                                color: $up-font;
                                font-size: 25px;
                            }
                            i{
                                color: $up-font;
                                font-size: 30px
                            }
                        }
                        .contentRateDown{
                            width: max-content;
                            height: 100%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            text-align: center;
                            border-radius: 12px;
                            padding: 0 1%;
                            margin: 5px 10px 0 0;
                            background-color: $down-background;
                            p{
                                color: $down-font;
                                font-size: 25px;
                            }
                            i{
                                color: $down-font;
                                font-size: 30px
                            }
                        }
                    }
                    .foot{
                        width: 100%;
                        height: 100%;
                        display: flex;
                        align-items: center;
                        justify-content: flex-start;
                        .contentRateUp{
                            width: 80px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            text-align: center;
                            border-radius: 12px;
                            background-color: $up-background;
                            margin: 0 10px 0 0;
                            p{
                                color: $up-font;
                            }
                            i{
                                color: $up-font;
                            }
                        }
                        .contentRateDown{
                            width: 80px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            text-align: center;
                            border-radius: 12px;
                            margin: 0 10px 0 0;
                            background-color: $down-background;
                            p{
                                color: $down-font;
                            }
                            i{
                                color: $down-font;
                            }
                        }
                        .compareWhat{
                            color: #5D6165;
                            margin: 10px 0 0 0;
                        }
                    }
                }
            }

            .chartArea{
                width: 100%;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: center;

                .chartContainer0{
                    width: 100%;
                    height: 100%;
                    display: flex;
                    flex-direction: column;
                    align-items: flex-start;
                    justify-content: flex-start;
                    border-radius: 12px;
                    background-color: white;
                    border: 1px solid rgba(grey, 0.5);
                    border: 1px solid;
                    box-shadow: -3px 3px 4px black;
                    padding: 2% 2%;
                    margin: 0 0 0 0;
                    h1{
                        font-size: 25px;
                        margin: 0 0 20px 0;
                    }
                    #echart0{
                        width: 100%;
                        height: 100%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        border: 1px solid rgba(0, 0, 0, 0.25);
                    }
                }
                .chartContainer1{
                    width: 100%;
                    height: 100%;
                    display: flex;
                    flex-direction: column;
                    align-items: flex-start;
                    justify-content: flex-start;
                    border-radius: 12px;
                    background-color: white;
                    border: 2px solid rgba(0, 0, 0, 0.25);
                    padding: 2% 2%;
                    margin: 0 0 0 0;
                    h1{
                        font-size: 25px;
                        margin: 0 0 20px 0;
                    }
                    #echart1{
                        width: 100%;
                        height: 100%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        border: 1px solid rgba(0, 0, 0, 0.25);
                    }
                }
                .chartContainer2{
                    width: 100%;
                    height: 100%;
                    display: flex;
                    flex-direction: column;
                    align-items: flex-start;
                    justify-content: flex-start;
                    border-radius: 12px;
                    background-color: white;
                    border: 2px solid rgba(0, 0, 0, 0.25);
                    padding: 2% 2%;
                    // margin: 0 2% 0 0;
                    h1{
                        font-size: 25px;
                        margin: 0 0 20px 0;
                    }
                    #echart2{
                        width: 100%;
                        height: 100%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        border: 1px solid rgba(0, 0, 0, 0.25);
                    }
                }
            }
        }
        .innerContainer2-Right{
            width: 25%;
            height: 100%;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            justify-content: flex-start;
            background-color: white;
            border-radius: 10px;
            border: 1px solid rgba(grey, 0.5);
            border: 1px solid;
            box-shadow: -3px 3px 4px black;
            padding: 20px 20px;
            overflow-y: scroll;
            scrollbar-width: none;
            .title{
                width: 100%;
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin: 0 0 10px 0;
                h1{
                    font-size: 25px;
                }
                // p{  
                //     font-weight: 500;
                //     color: #066a68cf;
                // }
            }
            .column{
                display: flex;
                align-items: center;
                justify-content: flex-start;
                color: #000000a5;
                margin: 0 0 10px 0;
                p{
                    margin: 0 10px 0 0;
                }
            }
            .poppularDishes{
                width: 100%;
                height: 100%;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: flex-start;
                // background-color: aquamarine;
                .dishItem{
                    width: 100%;
                    height: 70px;
                    display: flex;
                    align-items: center;
                    justify-content: flex-start;
                    cursor: pointer;
                    border-radius: 12px;
                    margin: 10px 0;
                    padding: 10px 10px;
                    background-color: rgba(0, 0, 255, 0.06);
                    &:hover{
                        background-color: rgba(0, 0, 255, 0.1);
                    }
                    &:active{
                        background-color: rgba(0, 0, 255, 0.2);
                    }
                    .rank{
                        margin: 0 20px 0 0;
                    }
                    .img{
                        width: 60px;
                        height: 60px;
                        border-radius: 50px;
                        margin: 0 20px 0 0;
                    }
                    .content{
                        display: flex;
                        flex-direction: column;
                        align-items: flex-start;
                        justify-content: flex-start;
                        h1{
                            font-size: 20px; 
                        }
                        .quantity{
                            display: flex;
                            align-items: center;
                            justify-content: flex-start;
                            p:nth-child(1){
                                color: #000000aa;
                                margin: 0 10px 0 0;
                            }
                            p:nth-child(2){
                                font-weight: 500;
                                color: rgba(255, 0, 0, 0.723);
                            }
                            
                        }
                    }
                }

            }
        }

    }
    .innerContainerSpecific{
        width: 100%;
        height: 100%;
    }

}
</style>
