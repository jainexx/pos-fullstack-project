<script>
import axios from 'axios';

export default{
    data(){
        return{
            analysis:null,
            preAnalysis:null,

            mealName:null,
            getMealName:null,
            currentStartDate:null,
            currentEndDate:null,
            lastStartDate:null,
            lastEndDate:null,

            totalRevenue:0,
            totalOrders:0,
            productTotalRevenue:0,
            productTotalMealOrders:0,

            totalRevenueRate:0,
            totalOrdersRate:0,
            productTotalRevenueRate:0,
            productTotalOrdersRate:0


        }
    },
    mounted() {
        Promise.all([
                axios.post("http://localhost:8080/pos/analysis", {   
                    "startDate": "2024-09-01",
                    "endDate": "2024-09-30",
                    "mealName":"1號餐"
                }),
                axios.post("http://localhost:8080/pos/analysis", {   
                    "startDate": "2024-09-30",
                    "endDate": "2024-10-04",
                    "mealName":"1號餐"
                })
            ])   
            .then(([response1, response2])=>{
                if (response1 && response1.data) {
                    this.analysis = response1.data.analysis;
                } else {
                    console.error("Response 1 is not valid:", response1);
                }
                if (response2 && response2.data) {
                    this.preAnalysis = response2.data.analysis;
                } else {
                    console.error("Response 2 is not valid:", response2);
                }

                this.totalRevenue = this.analysis.totalRevenue
                this.totalOrders = this.analysis.totalOrders
                this.productTotalRevenue = this.analysis.analysisMealVo.mealTotalRevenue
                this.productTotalMealOrders = this.analysis.analysisMealVo.mealTotalOrders
                this.getMealName = this.analysis.analysisMealVo.mealName

                this.calTotalRevenueRate()
                this.calTotalOrdersRate()
                this.calProductRevenueRate()
                this.calProductOrdersRate()
            })
            .catch(error => {
                console.error("Error fetching analysis:", error);
            });
    },
    methods:{
        search(product, currentStartDate, currentEndDate,lastStartDate,lastEndDate){
            Promise.all([
                axios.post("http://localhost:8080/pos/analysis", {   
                    "startDate": this.currentStartDate,
                    "endDate": this.currentEndDate,
                    "mealName":this.mealName
                }),
                axios.post("http://localhost:8080/pos/analysis", {   
                    "startDate": this.lastStartDate,
                    "endDate": this.lastEndDate,
                    "mealName":this.mealName
                })
            ])   
            .then(([response1, response2])=>{
                if (response1 && response1.data) {
                    this.analysis = response1.data.analysis;
                } else {
                    console.error("Response 1 is not valid:", response1);
                }
                if (response2 && response2.data) {
                    this.preAnalysis = response2.data.analysis;
                } else {
                    console.error("Response 2 is not valid:", response2);
                }

                this.totalRevenue = this.analysis.totalRevenue
                this.totalOrders = this.analysis.totalOrders
                this.productTotalRevenue = this.analysis.analysisMealVo.mealTotalRevenue
                this.productTotalMealOrders = this.analysis.analysisMealVo.mealTotalOrders
                this.getMealName = this.analysis.analysisMealVo.mealName

                this.calTotalRevenueRate()
                this.calTotalOrdersRate()
                this.calProductRevenueRate()
                this.calProductOrdersRate()
            })
            .then()
            .catch(error => {
                console.error("Error fetching analysis:", error);
            });

        },

        drawChart() {
            const myChart = echarts.init(document.getElementById("echart"));
            if (myChart) {
                myChart.setOption(this.optionLine);  
            } else {
                console.error("Invalid DOM: chart container not found");
            }
        },
        calTotalRevenueRate(){
            let revenueUpRate = (this.analysis.totalRevenue-this.preAnalysis.totalRevenue)/(this.preAnalysis.totalRevenue) * 100
            revenueUpRate = Math.round(revenueUpRate)
            this.totalRevenueRate = revenueUpRate 
        },
        calTotalOrdersRate(){
            let ordersUpRate = (this.analysis.totalOrders - this.preAnalysis.totalOrders)/ (this.preAnalysis.totalOrders) * 100
            ordersUpRate = Math.round(ordersUpRate)
            this.totalOrdersRate = ordersUpRate 
        },
        calProductRevenueRate(){
            let revenueUpRate = (this.analysis.analysisMealVo.mealTotalRevenue-this.preAnalysis.analysisMealVo.mealTotalRevenue)/
            (this.preAnalysis.analysisMealVo.mealTotalRevenue) * 100
            revenueUpRate = Math.round(revenueUpRate)
            this.productTotalRevenueRate = revenueUpRate 
            
        },
        calProductOrdersRate(){
            // 確保前一次的數據存在且不為 0，避免除以 0
            if (this.preAnalysis && this.preAnalysis.analysisMealVo && this.preAnalysis.analysisMealVo.mealTotalOrders > 0) {
                let ordersUpRate = (this.analysis.analysisMealVo.mealTotalOrders - this.preAnalysis.analysisMealVo.mealTotalOrders) /
                                    this.preAnalysis.analysisMealVo.mealTotalOrders * 100;
                ordersUpRate = Math.round(ordersUpRate);
                this.productTotalOrdersRate = ordersUpRate; 
            } else {
                this.productTotalOrdersRate = 0; // 如果前一次數據無效，設為 0
            }
        },
        validateDates() {
            // 確保上次活動的結束日期不大於本次活動的結束日期
            if (this.lastEndDate && this.currentEndDate && this.lastEndDate > this.currentEndDate) {
                alert("上次活動結束日期不能大於本次活動結束日期");
                this.lastEndDate = this.currentEndDate; // 若上次結束日期大於本次結束日期，則重設
            }

            // 確保本次活動的結束日期不小於開始日期
            if (this.currentEndDate < this.currentStartDate) {
                alert("本次活動結束日期必須大於或等於開始日期");
                this.currentEndDate = this.currentStartDate; // 重設結束日期
            }

            // 確保上次活動的結束日期不小於開始日期
            if (this.lastEndDate < this.lastStartDate) {
                alert("上次活動結束日期必須大於或等於開始日期");
                this.lastEndDate = this.lastStartDate; // 重設結束日期
            }

        }
    }
}
</script>


<template>
    <div class="innerContainerSpecific" v-if="analysis && preAnalysis">
        <div class="innerContainerLeft">
            <div class="innerContainerLeft1">
                <div class="compareItem">
                    <p class="title">總銷售額</p>
                    <div class="content">
                        <p class="contentNumber">${{totalRevenue }}</p>
                    </div>
                    <div class="foot">
                        <div class="contentRateUp" v-if="totalRevenueRate>0">
                            <i class='bx bx-up-arrow-alt' ></i>
                            <p>{{ totalRevenueRate}}%</p>
                        </div>
                        <div class="contentRateDown" v-if="totalRevenueRate<0">
                            <i class='bx bx-down-arrow-alt' ></i>
                            <p>{{ totalRevenueRate}}%</p>
                        </div>
                        <p class="compareWhat">vs 上次區間</p>
                    </div>    
                </div>
                <div class="compareItem">
                    <p class="title">總銷售量</p>
                    <div class="content">
                        <p class="contentNumber">{{ totalOrders }}份</p>
                    </div>
                    <div class="foot">
                        <div class="contentRateUp" v-if="totalOrdersRate>0" >
                            <i class='bx bx-up-arrow-alt' ></i>
                            <p>{{ totalOrdersRate}}%</p>
                        </div>
                        <div class="contentRateDown" v-if="totalOrdersRate<0">
                            <i class='bx bx-down-arrow-alt'></i>
                            <p>{{ totalOrdersRate}}%</p>
                        </div>
                        <p class="compareWhat">vs 上次區間</p>
                    </div>    
                </div>
            </div>
            <div class="innerContainerLeft2">
                <div class="compareItem">
                    <p class="title">{{getMealName}}銷售額</p>
                    <div class="content">
                        <p class="contentNumber">${{productTotalRevenue}}</p>
                    </div>
                    <div class="foot">
                        <div class="contentRateUp" v-if="productTotalRevenueRate>0">
                            <i class='bx bx-up-arrow-alt' ></i>
                            <p>{{ productTotalRevenueRate}}%</p>
                        </div>
                        <div class="contentRateDown" v-if="productTotalRevenueRate<0">
                            <i class='bx bx-down-arrow-alt'></i>
                            <p>{{ productTotalRevenueRate}}%</p>
                        </div>
                        <p class="compareWhat">vs 上次區間</p>
                    </div>    
                </div>
                <div class="compareItem">
                    <p class="title">{{getMealName}}銷售量</p>
                    <div class="content">
                        <p class="contentNumber">{{productTotalMealOrders}}份</p>
                    </div>
                    <div class="foot">
                        <div class="contentRateUp" v-if="productTotalOrdersRate>0">
                            <i class='bx bx-up-arrow-alt'></i>
                            <p>{{ productTotalOrdersRate}}%</p>
                        </div>
                        <div class="contentRateDown" v-if="productTotalOrdersRate<0">
                            <i class='bx bx-down-arrow-alt'></i>
                            <p>{{ productTotalOrdersRate}}%</p>
                        </div>
                        <p class="compareWhat">vs 上次區間</p>
                    </div>    
                </div>
            </div>
            <div class="innerContainerLeft3">
                <h1>營運分析圖</h1>
                <div id="echart" >
                </div>
            </div>
        </div>
        <div class="innerContainerRight">
            <div class="searchContainer">
                <h1>查詢</h1>
                <div class="searchMenu">
                    <p>商品名稱:</p>
                    <div class="searchArea">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" placeholder="商品名稱" v-model="mealName">
                     </div>
                </div>
                <div class="searchDateContainer">
                    <p>本次活動日期:</p>
                    <div class="searchDate">
                        <input 
                            type="date" 
                            v-model="currentStartDate" 
                            :max="new Date().toISOString().split('T')[0]" 
                            @change="validateDates">
                        <p>到</p>
                        <input 
                            type="date" 
                            v-model="currentEndDate" 
                            :min="currentStartDate" 
                            :max="new Date().toISOString().split('T')[0]" 
                            @change="validateDates">
                    </div>
                </div>
                <div class="searchDateContainer">
                    <p>上次活動日期:</p>
                    <div class="searchDate">
                        <input 
                            type="date" 
                            v-model="lastStartDate" 
                            :max="new Date().toISOString().split('T')[0]"
                            @change="validateDates">
                        <p>到</p>
                        <input 
                            type="date" 
                            v-model="lastEndDate" 
                            :min="lastStartDate" 
                            :max="currentEndDate"
                            @change="validateDates">
                    </div>
                </div>
                <button @click="search">搜尋</button>
                
            </div>
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

.innerContainerSpecific{
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;


    .innerContainerLeft{
        width: 70%;
        height: 100%;
        margin: 0 2% 0 0;
        .innerContainerLeft1{
            width: 100%;
            height: 20%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: white;
            border-radius: 12px;
            border: 2px solid rgba(0, 0, 0, 0.25);
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
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        .contentNumber{
                            font-size: 50px;
                            margin: 0 15px 0 0;
                        }
                    }
                    .foot{
                        width: 100%;
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
                        }
                    }
                }
        }
        .innerContainerLeft2{
            width: 100%;
            height: 20%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: white;
            border-radius: 12px;
            border: 2px solid rgba(0, 0, 0, 0.25);
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
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        .contentNumber{
                            font-size: 50px;
                            margin: 0 15px 0 0;
                        }
                    }
                    .foot{
                        width: 100%;
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
                        }
                    }
                }
        }
        .innerContainerLeft3{
            width: 100%;
            height: 55%;
            background-color: white;
            border-radius: 12px;
            border: 2px solid rgba(0, 0, 0, 0.25);
            margin: 0 0 2% 0;
        }
    }

    .innerContainerRight{
        width: 30%;
        height: 100%;
        background-color: white;
        border-radius: 12px;
        border: 2px solid rgba(0, 0, 0, 0.25);
        padding: 1% 2%;
        .searchContainer{
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            justify-content: flex-start;
            h1{
                width: 100%;
                height: 10%;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .searchMenu{
                width: 100%;
                height: 13%;
                display: flex;
                flex-direction: column;
                align-items: flex-start;
                justify-content: center;
                margin: 0 0 5% 0;
                p{
                    font-size: 20px;
                    font-weight: 600;
                    margin: 0 0 2% 0;
                }
                .searchArea{
                    width: 60%;
                    height: 100%;
                    display: flex;
                    align-items: center;
                    justify-content: flex-start;
                    background-color: rgba(0, 0, 0, 0.1);
                    border-radius: 20px;
                    padding: 0 4%;
                    &:focus-within {
                        border: 1px solid rgba(0, 0, 0, 0.5) // 你想要的顏色
                    }
                    i{
                        margin: 0 10px 0 0;
                    }
                    input{
                        width: 100%;
                        font-size: 20px;
                        border: none;
                        color: rgba(0, 0, 0, 0.6);
                        background-color: transparent;
                        outline: none;
                        // padding: 2% 4%;

                    }
                }
            }
            .searchDateContainer{
                width: 100%;
                height: 10%;
                display: flex;
                flex-direction: column;
                align-items: flex-start;
                justify-content: center;
                margin: 0 0 10% 0;
                p{
                    font-size: 20px;
                    font-weight: 600;
                    margin: 0 0 2% 0;
                }
                .searchDate{
                    width: 80%;
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    input{

                    }
                    p{
                        font-size: 20px;
                        font-weight: 300;
                    }
                }
            }
            button{
                width: 20%;
                height: 6%;
                border-radius: 12px;
                border: none;
                background-color: rgba(0, 0, 0, 0.812);
                color: white;
                cursor: pointer;
                &:active{
                    background-color: rgba(0, 0, 0, 0.615);
                }
            }
        }
    }
}



</style>