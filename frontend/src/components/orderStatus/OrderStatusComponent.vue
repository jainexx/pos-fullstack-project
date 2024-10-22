<script>
import axios from 'axios';
import Swal from 'sweetalert2';

export default {
    data() {
        return {
            currentDate: new Date(),
            orderDetail: null,

            preparing: null,
            undelivered: null,
            delivered: null,
        }
    },
    created() {
        axios.post("http://localhost:8080/pos/searchOrderStatus", {
            "startDate": "",
            "endDate": ""
        })
            .then(response => {
                this.preparing = response.data.preparingOrders
                this.undelivered = response.data.undeliveredOrders
                this.delivered = response.data.deliveredOrders
                console.log(this.delivered)
            })
            .catch(error => {
                console.error("Error fetching analysis:", error);
            });
    },
    mounted() {

    },
    computed: {
        currentDateFormate() {
            const year = this.currentDate.getDate()
            const month = String(this.currentDate.getMonth() + 1).padStart(2, '0')
            const day = String(this.currentDate.getFullYear()).padStart(2, '0')
            return `${year}-${month}-${day}`;
        }
    },
    methods: {
        changeStatus(mealId, mealName) {
            Swal.fire({
                title: '確定要繼續嗎？',
                text: "確認是否要將" + `${mealName}` + "更改為已送達",
                icon: 'warning',
                showCancelButton: true,  // 顯示取消按鈕
                confirmButtonText: '是的，繼續',
                cancelButtonText: '取消',
            })
                .then((result) => {
                    if (result.isConfirmed) {
                        Swal.fire(
                            '已繼續',
                            '已成功更新' + `${mealName}` + '餐點狀態為已送達。',
                            'success'
                        );
                        return axios.post("http://localhost:8080/pos/updateOrderStatus", {
                            "id": mealId,
                        })
                            .then(() => {
                                return axios.post("http://localhost:8080/pos/searchOrderStatus", {
                                    "startDate": "",
                                    "endDate": ""
                                })
                            })
                            .then(response => {
                                this.preparing = response.data.preparingOrders
                                this.undelivered = response.data.undeliveredOrders
                                this.delivered = response.data.deliveredOrders
                                console.log(this.delivered)
                            })
                            .catch(error => {
                                console.error("Error fetching analysis:", error);
                            });
                    }
                })
        },
        countUndelivered() {
            let count = 0
            if (this.undelivered != null) {
                for (let i = 0; i < this.undelivered.length; i++) {
                    count += this.undelivered[i].mealList.length
                }
            }
            return count

        },
        formatOptions(options) {
            if (!options || options.length === 0) {
                return '';
            }
            // 移除每個選項的空白並連接成想要的格式
            return `(${options.map(option => option.trim()).join(', ')})`;
            }
    }
}
</script>


<template>
    <div class="container">
        <div class="innerContainer">
            <div class="titleContainer">
                <h1>餐點狀態</h1>
                <div>
                    <p>待送餐點</p>
                    <p>{{ countUndelivered() }}</p>
                </div>
            </div>

            <div class="contentContainer">
                <div class="statusContainer">
                    <h1>準備中</h1>
                    <div class="tableContainer" v-for="(table, tableIndex) in preparing">
                        <div class="tableTitle">
                            <p class="tableNumber">桌號{{ table.tableNumber }}</p>
                            <p class="orderId">訂單編號{{ table.orderId }}</p>
                        </div>
                        <div class="tableContent" v-for="(meal, mealIndex) in table.mealList">
                            <p class="comboName" v-if="meal.comboName">•{{ meal.comboName }}</p>
                            <div class="comboDetailList" v-if="meal.comboName">
                                <p v-for="(comboDetail) in meal.mealDetail">
                                    •{{ comboDetail.mealName }}{{ formatOptions(comboDetail.options) }}
                                </p>
                            </div>
                            <p class="singleName" v-if="!meal.comboName">•{{ meal.mealDetail[0].mealName }}{{ formatOptions(meal.mealDetail[0].options) }}</p>
                        </div>
                    </div>
                </div>
                <div class="statusContainer">
                    <h1>待送餐點</h1>
                    <!-- <h1>{{ undelivered }}</h1> -->
                    <div class="tableContainer" v-for="(table, tableIndex) in undelivered">
                        <div class="tableTitle">
                            <p>桌號{{ table.tableNumber }}</p>
                            <p>訂單編號{{ table.orderId }}</p>
                        </div>
                        <div class="tableContent" v-for="(meal, mealIndex) in table.mealList">
                            <p class="comboName" v-if="meal.comboName">•{{ meal.comboName }}</p>
                            <div class="comboDetailList" v-if="meal.comboName">
                                <p v-for="(comboDetail, index) in meal.mealDetail" :key="comboDetail.id">
                                    <!-- •{{ comboDetail.mealName }} -->
                                    <!-- <h1 style="color: black;">{{ meal}} </h1> -->
                                    <input type="checkbox" :id="`${comboDetail.id}`"
                                        @change="changeStatus(comboDetail.id, comboDetail.mealName)">
                                    <label :for="`${comboDetail.id}`">{{ comboDetail.mealName }}{{ formatOptions(comboDetail.options) }}</label>
                                </p>
                            </div>
                            <p class="singleName" v-if="!meal.comboName" :key="meal.mealDetail[0].id">
                                <!-- •{{ meal.mealDetail[0].mealName }} -->
                                <input type="checkbox" :id="`${meal.mealDetail[0].id}`"
                                    @change="changeStatus(meal.mealDetail[0].id, meal.mealDetail[0].mealName)">
                                <label :for="`${meal.mealDetail[0].id}`">{{ meal.mealDetail[0].mealName }}{{ formatOptions(meal.mealDetail[0].options) }}</label>
                            </p>
                        </div>
                    </div>
                </div>
                <div class="statusContainer">
                    <h1>已送達</h1>
                    <div class="tableContainer" v-for="(table, tableIndex) in delivered">
                        <div class="tableTitle">
                            <p>桌號{{ table.tableNumber }}</p>
                            <p>訂單編號{{ table.orderId }}</p>
                        </div>
                        <div class="tableContent" v-for="(meal, mealIndex) in table.mealList">
                            <p class="comboName" v-if="meal.comboName">•{{ meal.comboName }}</p>
                            <div class="comboDetailList" v-if="meal.comboName">
                                <p v-for="(comboDetail) in meal.mealDetail">
                                    •{{ comboDetail.mealName }}{{ formatOptions(comboDetail.options) }}
                                </p>
                            </div>
                            <p class="singleName" v-if="!meal.comboName">•{{ meal.mealDetail[0].mealName }}{{ formatOptions(meal.mealDetail[0].options) }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">
$mainColor: #FFC90E;
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

.container {
    width: 100%;
    height: 100%;
    padding: 1% 2%;

    .innerContainer {
        width: 100%;
        height: 100%;
        border-radius: 10px;
        background-color: white;
        border: 1px solid rgba(grey, 0.5);
        border: 1px solid;
        box-shadow: -3px 3px 4px black;

        .titleContainer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1% 4%;
            position: relative;

            &:before {
                position: absolute;
                content: "";
                width: 95%;
                height: 1px;
                left: 2.5%;
                bottom: 0;
                background-color: rgba(0, 0, 0, 0.466);
            }

            div {
                width: 15%;
                display: flex;
                align-items: center;
                justify-content: space-between;

                p {
                    width: 50%;
                    font-size: 20px;
                    font-weight: 600;
                    margin: 0 2%;

                    &:nth-child(2) {
                        width: 30%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        border-radius: 12px;
                        background-color: black;
                        color: white;
                    }
                }
            }
        }

        .contentContainer {
            width: 100%;
            height: 90%;
            display: flex;
            align-items: start;
            justify-content: space-between;
            padding: 1% 4%;

            // background-color: antiquewhite;
            .statusContainer {
                width: 30%;
                height: 100%;
                background-color: rgba(0, 0, 0, 0.15);
                border-radius: 12px;
                box-shadow: 0 0 5px rgba(0, 0, 0, 0.2),
                    0 0 10px rgba(0, 0, 0, 0.15),
                    0 0 15px rgba(0, 0, 0, 0.1),
                    0 0 20px rgba(0, 0, 0, 0.05);
                border: 1px solid;
                padding: 1% 1%;
                overflow-y: auto;
                scrollbar-width: none;

                h1 {
                    font-size: 30px;
                }

                &:nth-child(2) {
                    background-color: $mainColor;

                    h1 {
                        color: black;
                    }
                }

                .tableContainer {
                    width: 100%;
                    height: auto;
                    border-radius: 12px;
                    border: 1px solid;
                    background-color: white;
                    padding: 2% 2%;
                    margin: 4% 0;

                    .tableTitle {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        font-size: 20px;
                        font-weight: 600;
                        padding: 4% 6%;

                        p {
                            width: 40%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 20px;
                            border-radius: 12px;
                            color: white;
                            background-color: black;
                        }

                        p:nth-child(2) {
                            font-size: 12px;
                            padding-left: 4%;
                        }
                    }

                    .tableContent {
                        font-size: 18px;
                        font-weight: 600;

                        .comboName {
                            font-size: 20px;
                            padding: 0 8%;
                            margin: 2% 0;
                            position: relative;
                            // &:before{
                            //     position: absolute;
                            //     content: "";
                            //     width: 20%;
                            //     height: 1px;
                            //     left: 5%;
                            //     bottom: -10%;
                            //     background-color: rgba(0, 0, 0, 0.3)
                            // }
                        }

                        .comboDetailList {
                            padding: 0 15%;
                            margin: 2% 0;
                        }

                        .singleName {
                            font-size: 20px;
                            padding: 2% 8%;
                            position: relative;
                            // &:before{
                            //     position: absolute;
                            //     content: "";
                            //     width: 20%;
                            //     height: 1px;
                            //     left: 5%;
                            //     bottom: 10%;
                            //     background-color: rgba(0, 0, 0, 0.4)
                            // }
                        }

                    }
                }
            }
        }

    }

}
</style>
