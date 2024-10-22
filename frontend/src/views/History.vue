<script>
import LeftBar from "@/components/LeftBar.vue";
import axios from "axios";
import Swal from "sweetalert2";

export default {
    data() {
        return {
            // 模擬資料
            // mockData: {
            //     code: 200,
            //     message: "成功",
            //     data: [
            //         {
            //             orderId: "202409251509A01",
            //             orderMealId: [
            //                 {
            //                     comboName: "2號餐",
            //                     mealName: "火鍋(麻辣), 奶茶(1分糖)",
            //                     price: 199,
            //                 },
            //                 {
            //                     comboName: "1號餐",
            //                     mealName: "勁辣雞腿堡(不要辣), 可樂(去冰)",
            //                     price: 130,
            //                 },
            //             ],
            //             single: [
            //                 {
            //                     mealName: "薯條(去鹽)",
            //                     price: 50,
            //                 },
            //                 {
            //                     mealName: "冰炫風",
            //                     price: 69,
            //                 },
            //             ],
            //             checkoutTime: "2024-10-10 11:22:52",
            //             payType: "信用卡",
            //             totalPrice: 438,
            //             tableNumber: "A02",
            //         },
            //         {
            //             orderId: "202409251510B03",
            //             orderMealId: [
            //                 {
            //                     comboName: "3號餐",
            //                     mealName: "拉麵(醬油湯底), 綠茶",
            //                     price: 250,
            //                 },
            //                 {
            //                     comboName: "4號餐",
            //                     mealName: "牛肉麵(清燉), 豆漿",
            //                     price: 180,
            //                 },
            //             ],
            //             single: [
            //                 {
            //                     mealName: "炸雞塊",
            //                     price: 75,
            //                 },
            //                 {
            //                     mealName: "果汁",
            //                     price: 45,
            //                 },
            //             ],
            //             checkoutTime: "2024-10-10 12:15:30",
            //             payType: "現金",
            //             totalPrice: 550,
            //             tableNumber: "A03",
            //         },
            //         {
            //             orderId: "202409251511C05",
            //             orderMealId: [
            //                 {
            //                     comboName: "5號餐",
            //                     mealName: "海鮮炒飯, 汽水(少冰)",
            //                     price: 220,
            //                 },
            //                 {
            //                     comboName: "6號餐",
            //                     mealName: "雞肉咖哩飯, 冰水",
            //                     price: 160,
            //                 },
            //             ],
            //             single: [
            //                 {
            //                     mealName: "薯條(加鹽)",
            //                     price: 55,
            //                 },
            //                 {
            //                     mealName: "奶昔(微糖)",
            //                     price: 80,
            //                 },
            //             ],
            //             checkoutTime: "2024-10-10 13:45:15",
            //             payType: "行動支付",
            //             totalPrice: 515,
            //             tableNumber: "A05",
            //         },
            //     ],
            // },
            selectedDate: "", // 預設為當日日期（格式 yyyy-MM-dd）
            orderList: [], // 存放訂單列表資料
            drawerVisible: false, // Drawer 顯示控制
            selectedOrder: {}, // 被選中的訂單詳細資料
        };
    },
    components: {
        LeftBar,
    },
    methods: {
        //發送 POST 請求取得指定日期的訂單資料
        fetchOrders() {
            if (this.selectedDate == "") {
                Swal.fire({
                    title: "請輸入日期",
                    icon: "error",
                    confirmButtonText: "確定",
                });
                return;
            }

            const requestUrl = `http://localhost:8080/api/checkout/list/${this.selectedDate}`;

            // 發送 GET 請求
            fetch(requestUrl)
                .then((response) => {
                    if (!response.ok) {
                        throw new Error("Network response was not ok");
                    }
                    return response.json();
                })
                .then((data) => {
                    if (data.code == 200) {
                        // Swal.fire({
                        //     title: data.message,
                        //     icon: 'success',
                        //     confirmButtonText: '確定',
                        // });

                        // 處理 checkoutTime 去掉 "T"
                        this.orderList = data.checkoutList.map((order) => {
                            order.checkoutTime = order.checkoutTime.replace("T", " ");
                            order.orderMealId = [];
                            order.single = [];
                            return order;
                        });
                    } else {
                        Swal.fire({
                            title: data.message,
                            icon: "error",
                            confirmButtonText: "確定",
                        });

                        this.orderList = [];
                    }
                })
                .catch((error) => {
                    // 處理錯誤響應
                    console.error("Error fetching orders:", error);
                    // alert("查詢失敗，請檢查日期格式或伺服器狀態。");
                });

            this.drawerVisible = false;
        },
        // 顯示訂單詳細資料
        showOrderDetail(order) {
            const requestUrl = `http://localhost:8080/api/checkout/detailsOrderId/${order.orderId}`;

            // 發送 GET 請求
            fetch(requestUrl)
                .then((response) => {
                    if (!response.ok) {
                        throw new Error("Network response was not ok");
                    }
                    return response.json();
                })
                .then((data) => {
                    if (data.code == 200) {
                        order.orderMealId = data.data.orderMealId;
                        order.single = data.data.single;
                    }
                })
                .catch((error) => {
                    // 處理錯誤響應
                    console.error("Error fetching orders:", error);
                });

            this.selectedOrder = order;
            this.drawerVisible = true;
        },
    },
    mounted() {
        const today = new Date();
        today.setHours(today.getHours() + 8); // 將時間調整為台灣時間
        const localDate = today.toISOString().split("T")[0];
        document.querySelector(".dateInput").setAttribute("max", localDate);

        this.selectedDate = localDate;

        //預設加載當日訂單資料
        this.fetchOrders();
        // this.orderList = this.mockData.data;
    },
};
</script>

<template>
    <div class="big">
        <div class="leftBar">
            <LeftBar />
        </div>
        <div class="mainArea">
            <!-- 日期選擇區塊 -->
            <div class="datePicker">
                <input type="date" v-model="selectedDate" class="dateInput" />
                <button @click="fetchOrders" class="searchButton">搜尋</button>
            </div>

            <!-- 列表 + drawer-->
            <div class="orderList">
                <div class="orderTableContainer" :style="{ width: drawerVisible ? '60%' : '95%' }">
                    <table class="orderTable">
                        <thead>
                            <tr>
                                <th>訂單編號</th>
                                <th>結帳時間</th>
                                <th>支付方式</th>
                                <th>總金額</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="order in orderList" :key="order.orderId" @click="showOrderDetail(order)">
                                <td>{{ order.orderId }}</td>
                                <td>{{ order.checkoutTime }}</td>
                                <td>{{ order.payType }}</td>
                                <td>${{ order.totalPrice }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="drawer" v-if="drawerVisible">
                    <div class="drawerHeader">
                        <button class="closeButton" @click="drawerVisible = false">></button>
                        <h3>訂單編號 {{ selectedOrder.orderId }}</h3>
                    </div>

                    <div class="drawerBody">
                        <!-- 訂單基本資訊 -->
                        <div class="basicInfo">
                            <div class="tableNumber">{{ selectedOrder.tableNumber }}</div>
                            <div class="payType">{{ selectedOrder.payType }} ${{ selectedOrder.totalPrice }}</div>
                        </div>

                        <h4>餐點明細</h4>

                        <div class="comboItem" v-for="(meal, index) in selectedOrder.orderMealId" :key="index">
                            <div class="comboHeader">
                                <p class="comboName">{{ meal.comboName }}</p>
                                <p class="comboPrice">${{ meal.price }}</p>
                            </div>
                            <div class="comboDetail">
                                <ul>
                                    <li v-for="(item, idx) in meal.mealName.split(', ')" :key="idx">{{ item }}</li>
                                </ul>
                            </div>
                        </div>

                        <div class="singleItem" v-for="(single, index) in selectedOrder.single" :key="index">
                            <p class="singleName">{{ single.mealName }}</p>
                            <p class="singlePrice">${{ single.price }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">
.big {
    width: 100%;
    height: 100dvh;
    display: flex;
    justify-content: center;
    align-items: center;

    .leftBar {
        width: 10%;
        height: 96.4vh;
        position: fixed;
        top: 2%;
        left: 1.4%;
        display: flex;
        align-items: center;
    }

    .mainArea {
        letter-spacing: 0.2dvw;
        width: 100%;
        padding: 2%;
        display: flex;
        flex-direction: column;

        .datePicker {
            // border: 2px solid red;
            display: flex;
            justify-content: flex-start;
            align-items: center;
            width: 100%;
            margin-bottom: 20px;

            .dateInput {
                // border: 2px solid green;
                width: 20%;
                text-align: center;
                letter-spacing: 0.2dvw;
                padding: 8px;
                font-size: 1rem;
                margin-right: 30px;
                border: 1px solid rgba(grey, 0.5);
                border: 1px solid;
                box-shadow: -3px 3px 4px black;
                border-radius: 10px;
            }

            .searchButton {
                // border: 2px solid green;
                padding: 8px 10px;
                font-size: 1rem;
                width: 7%;
                letter-spacing: 0.2dvw;
                text-align: center;
                border: 1px solid rgba(grey, 0.5);
                border: 1px solid;
                box-shadow: -3px 3px 4px black;
                background-color: #ffc90e;
                border-radius: 10px;
                color: black;
                cursor: pointer;
            }
        }

        .orderList {
            display: flex;
            width: 100%;
            height: 88dvh;
            background-color: white;
            border-radius: 10px;
            overflow-y: hidden;
            border: 1px solid rgba(grey, 0.5);
            border: 1px solid;
            box-shadow: -3px 3px 4px black;
            padding: 10px 0;

            .orderTableContainer {
                transition: width 0.3s ease;
                /* 增加寬度變化的過渡效果 */
                overflow-y: scroll;
            }

            .orderTable {
                margin: 15px auto;
                width: 95%;
                border-collapse: collapse;

                th,
                td {
                    border-bottom: 1px solid rgba(grey, 0.2);
                    padding: 10px;
                    text-align: center;
                }

                th {
                    background-color: rgba(black, 0.7);
                    color: white;
                    font-weight: bold;
                }

                tr:hover {
                    border: 2px solid grey;
                    cursor: pointer;
                }
            }

            .drawer {
                width: 40%;
                height: 100%;
                padding: 20px;
                border-left: 1px solid rgba(grey, 0.5);
                box-shadow: -2px 0 5px rgba(0, 0, 0, 0.1);
                background-color: transparent;
                overflow-y: auto;

                .drawerHeader {
                    display: flex;
                    justify-content: start;
                    align-items: center;
                    padding-bottom: 10px;

                    .closeButton {
                        background: #ffc90e;
                        border-radius: 5px;
                        font-size: 1.2rem;
                        border: none;
                        padding: 5px 10px;
                        cursor: pointer;
                    }

                    h3 {
                        font-size: 1.3rem;
                        margin-left: 2%;
                    }
                }

                .drawerBody {
                    .basicInfo {
                        display: flex;
                        justify-content: start;
                        align-items: center;
                        margin-bottom: 15px;
                        margin-top: 10px;

                        .tableNumber {
                            font-size: 18px;
                            background-color: rgba(grey, 0.1);
                            border: 2px solid black;
                            padding: 13px;
                            border-radius: 10px;
                            margin-right: 15px;
                        }

                        .payType {
                            font-size: 1.1rem;
                        }
                    }

                    h4 {
                        font-size: 1.3rem;
                        font-weight: bold;
                        margin-bottom: 15px;
                    }

                    .comboItem {
                        padding: 10px 30px;
                        border: 2px solid rgba(grey, 0.2);
                        border-radius: 10px;
                        margin: 8px;

                        .comboHeader {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;

                            .comboName {
                                font-size: 1.1rem;
                                font-weight: bold;
                            }

                            .comboPrice {
                                font-size: 16px;
                            }
                        }

                        .comboDetail {
                            margin-top: 5px;

                            ul {
                                list-style-type: disc;
                                padding-left: 20px;
                                margin: 0;

                                li {
                                    font-size: 1rem;
                                    margin-bottom: 3px;
                                }
                            }
                        }
                    }

                    .singleItem {
                        padding: 10px 30px;
                        border: 2px solid rgba(grey, 0.2);
                        border-radius: 10px;
                        margin: 8px;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                    }
                }
            }
        }
    }
}
</style>
