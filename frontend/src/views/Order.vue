<script>
import Swal from "sweetalert2";
import LeftBar from "@/components/LeftBar.vue";
import Categores from "@/components/Order/Categores.vue";
import MenuItems from "@/components/Order/MenuItems.vue";
import CustomPopup from "@/components/Order/CustomPopup.vue";

export default {
    data() {
        return {
            // 資料分類
            categoriesList: [],
            menuItemsList: [],
            optionsList: [],
            combosList: [],
            tablesList: [],

            //邏輯變數
            selectedItem: null, // 存放選中的餐點或套餐資訊
            showPopup: false, // 控制彈跳視窗的顯示
            orderItems: [], // 儲存所有選擇的訂單項目
            activeCategoryId: null, // 追蹤當前選中的分類

            singleList: [], // 蒐集單點訂單
            comboList: [], // 蒐集套餐訂單
            newComboList: [], // 存放整理後的套餐訂單資料，前端顯示用
            orderList: [], // 存放所有從子元件傳來的訂單資料
            selectedTableNumber: null, // 被選中的桌號
            customerCount: 1, // 預設人數為1
        };
    },
    components: {
        LeftBar,
        Categores,
        MenuItems,
        CustomPopup,
    },
    computed: {
        // 計算所有訂單項目的合計金額
        totalAmount() {
            const orderList = [...this.singleList, ...this.comboList]; // 合併訂單
            return orderList.reduce((total, item) => total + (item.price || 0), 0); // 如果 price 為 null 則視為 0
        },
    },
    mounted() {
        this.fetchOrderData();
    },
    methods: {
        fetchOrderData() {
            fetch("http://localhost:8080/pos/getOrderMenu", {
                method: "GET",
                headers: {
                    "Content-Type": "application/json",
                },
            })
                .then((response) => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    }
                    return response.json(); // 解析回應為 JSON 格式
                })
                .then((data) => {
                    this.orderMenuData = data;
                    this.categoriesList = this.orderMenuData.categoriesList;
                    this.menuItemsList = this.orderMenuData.menuItemList;
                    this.optionsList = this.orderMenuData.optionList;
                    this.combosList = this.orderMenuData.comboList;
                    this.tablesList = this.orderMenuData.tableNumberList;

                    // 呼叫初始化處理，為 combosList 的主餐加上 available 屬性
                    this.combosList = this.addAvailableToCombos(this.orderMenuData.comboList);

                    // 資料載入完成後，設定預設分類與桌號
                    this.setDefaultCategoryAndTable();
                })
                .catch((error) => {
                    console.error("取得菜單資料失敗:", error);
                });
        },
        setDefaultCategoryAndTable() {
            // 設定預設顯示的第一個分類
            if (this.categoriesList.length > 0) {
                const firstCategoryId = this.categoriesList[0].categoryId;
                this.filterMenuItems(firstCategoryId);
            }
        },
        addAvailableToCombos(combos) {
            return combos.map((combo) => {
                // 查找主餐名稱
                const mainDish = combo.comboDetail[0].dishesList[0];

                // 查找 menuItems 中是否有相同名稱的餐點
                const matchingMeal = this.menuItemsList.find((item) => item.mealName === mainDish.dishName);

                // 若找到則附加 available 屬性，否則預設為 true
                mainDish.available = matchingMeal ? matchingMeal.available : true;

                return combo;
            });
        },
        filterMenuItems(categoryId) {
            this.activeCategoryId = categoryId; // 更新 active 狀態

            const selectCategory = this.categoriesList.find((cat) => cat.categoryId === categoryId);

            if (selectCategory && selectCategory.category.includes("套餐")) {
                this.menuItemsList = []; // 清空單點餐點,傳到子元件的的menuItemsList為空, 只有combosList有值
            } else {
                this.menuItemsList = this.orderMenuData.menuItemList.filter((item) => item.categoryId === categoryId);
            }
        },
        handleItemSelect(item) {
            this.selectedItem = item;
            this.showPopup = true;
        },
        // 接收子元件傳來的訂單List
        handleAddToOrder(order) {
            if (order.length > 1) {
                this.comboList.push(...order);
                // 每次新增套餐後更新 newComboList
                this.generateNewComboList();
            } else {
                this.singleList.push(...order);
            }
        },
        // 將 comboList 整理成 newComboList 格式
        generateNewComboList() {
            const groupedCombos = {};

            // 將 comboList 的資料按 orderMealId 分組
            this.comboList.forEach((item) => {
                const { orderMealId, comboName, comboBasicPrice, selectedComboPrice } = item;

                // 若此 orderMealId 尚未建立，則初始化結構
                if (!groupedCombos[orderMealId]) {
                    groupedCombos[orderMealId] = {
                        orderMealId,
                        comboName,
                        comboBasicPrice,
                        selectedComboPrice,
                        mealList: [],
                    };
                }

                // 如果該項有餐點名稱，則加入 mealList
                if (item.mealName) {
                    groupedCombos[orderMealId].mealList.push({
                        mealName: item.mealName,
                        options: item.options,
                        optionsPriceTotal: item.optionsPriceTotal || 0,
                        priceDifference: item.priceDifference || 0,
                    });
                }
            });

            // 將物件轉為陣列形式，存入 newComboList
            this.newComboList = Object.values(groupedCombos);
        },
        // 編輯訂單
        // editOrder(order, type) {
        //     if (type === "single") {
        //         this.selectedItem = { ...order }; // 複製訂單內容
        //     } else if (type === "combo") {
        //         this.selectedItem = { ...order };
        //     }
        //     this.showPopup = true; // 顯示彈窗進行編輯
        // },
        // 確認刪除單點訂單
        confirmDeleteOrder(index, type) {
            Swal.fire({
                title: "確定要刪除餐點嗎？",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#d33 ",
                cancelButtonColor: "#3085d6",
                confirmButtonText: "是的，刪除！",
                cancelButtonText: "取消",
            }).then((result) => {
                if (result.isConfirmed) {
                    this.deleteOrder(index, type);
                    Swal.fire({
                        title: "已刪除！",
                        text: "餐點已成功刪除。",
                        icon: "success",
                        timer: 1500, // 設定自動關閉時間
                        showConfirmButton: false, // 不顯示確認按鈕
                    });
                }
            });
        },
        // 刪除單點訂單
        deleteOrder(index, type) {
            if (type === "single") {
                this.singleList.splice(index, 1);
            } else if (type === "combo") {
                this.comboList.splice(index, 1);
            }
        },
        // 刪除套餐訂單
        deleteComboOrder(orderMealId) {
            // 刪除 newComboList 中的對應項目
            this.newComboList = this.newComboList.filter((combo) => combo.orderMealId !== orderMealId);

            // 刪除 comboList 中所有符合該 orderMealId 的項目
            this.comboList = this.comboList.filter((item) => item.orderMealId !== orderMealId);
        },
        // 確認刪除套餐訂單
        confirmDeleteComboOrder(orderMealId) {
            Swal.fire({
                title: "確定要刪除餐點嗎？",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#d33",
                cancelButtonColor: "#3085d6",
                confirmButtonText: "是的，刪除！",
                cancelButtonText: "取消",
            }).then((result) => {
                if (result.isConfirmed) {
                    this.deleteComboOrder(orderMealId);
                    Swal.fire({
                        title: "已刪除！",
                        text: "餐點已成功刪除。",
                        icon: "success",
                        timer: 1500, // 設定自動關閉時間
                        showConfirmButton: false, // 不顯示確認按鈕
                    });
                }
            });
        },
        submitOrder() {
            if (!this.selectedTableNumber) {
                Swal.fire({
                    icon: "error",
                    title: "錯誤",
                    text: "請選擇桌號！",
                    showConfirmButton: false, // 隱藏確認按鈕
                    timer: 1500, // 1.5 秒後自動關閉
                });
                return; // 中止送出訂單
            }

            this.orderList = [...this.singleList, ...this.comboList]; // 將資料加入 orderList

            if (this.orderList.length === 0) {
                Swal.fire({
                    icon: "error",
                    title: "錯誤",
                    text: "請至少選擇一個餐點！",
                    showConfirmButton: false, // 隱藏確認按鈕
                    timer: 1500, // 1.5 秒後自動關閉
                });
                return; // 中止送出訂單
            }

            const now = new Date();
            const formattedDate = now.toISOString().slice(0, 10).replace(/-/g, "");
            const formattedTime = now.toTimeString().slice(0, 5).replace(/:/g, "");
            const orderId = `${formattedDate}${formattedTime}${this.selectedTableNumber}`;

            // 將每個訂單物件轉換為符合格式的結構
            const ordersList = this.orderList.map((item) => ({
                orderId: orderId,
                orderMealId: item.orderMealId,
                comboName: item.comboName,
                mealName: item.mealName,
                options: item.options,
                workstationId: item.workstationId,
                price: item.price,
                mealStatus: "準備中", // 固定值
                tableNumber: this.selectedTableNumber, // 被選中的桌號
                orderTime: now.toISOString(), // ISO 時間格式
                checkout: false, // 固定值
            }));

            // 封裝為最終送出的資料結構
            const finalOrder = {
                ordersList: ordersList,
            };

            console.log("送出的訂單資料:", finalOrder); // 預覽格式是否正確

            //送出訂單的 API 請求
            fetch("http://localhost:8080/pos/addOrder", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(finalOrder),
            })
                .then((response) => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    }
                    console.log("訂單已成功送出！");

                    // 訂單成功後彈出 SweetAlert 提示
                    Swal.fire({
                        icon: "success",
                        title: "成功",
                        text: "訂單已送出！",
                        showConfirmButton: false, // 隱藏確認按鈕
                        timer: 1500, // 1.5 秒後自動關閉
                    });

                    this.resetOrder();
                })
                .catch((error) => {
                    console.error("送出訂單失敗:", error);
                });
        },
        resetOrder() {
            this.orderList = [];
            this.singleList = [];
            this.comboList = [];
            this.newComboList = [];
            this.selectedTableNumber = null;
            console.log("訂單已重置");
        },
    },
};
</script>

<template>
    <div class="big">
        <div class="leftBar">
            <LeftBar />
        </div>

        <div class="mainArea">
            <div class="menuArea">
                <h2>菜單</h2>
                <Categores :categories="categoriesList" @selectCategory="filterMenuItems" :activeCategoryId="activeCategoryId" />
                <MenuItems
                    :menuItems="menuItemsList"
                    :combos="combosList"
                    @selectItem="handleItemSelect"
                    :currentCategory="categoriesList.find((cat) => cat.categoryId === activeCategoryId)?.category" />

                <!-- Overlay 遮罩 -->
                <div v-if="showPopup" class="overlay" @click="closePopup"></div>

                <!-- 客製化彈跳視窗 -->
                <CustomPopup v-if="showPopup" :item="selectedItem" :optionsList="optionsList" :categoriesList="categoriesList" @close="showPopup = false" @addToOrder="handleAddToOrder" />
            </div>

            <div class="orderArea">
                <h2>訂單</h2>

                <!-- 桌號(tableNumberList撈資料並綁定選項)及人數選單(1~20人，只供前端使用)-->
                <div class="tableAndCustomerNum">
                    <label for="tableSelect">桌號：</label>
                    <select id="tableSelect" v-model="selectedTableNumber">
                        <option v-for="table in tablesList" :key="table" :value="table">
                            {{ table }}
                        </option>
                    </select>

                    <label for="customerCountSelect">人數：</label>
                    <select id="customerCountSelect" v-model="customerCount">
                        <option v-for="n in 20" :key="n" :value="n">{{ n }} 人</option>
                    </select>
                </div>

                <!-- 餐點明細：顯示從CustomPopup傳來的資料 -->
                <div class="orderSummary">
                    <h3>餐點明細</h3>

                    <!-- 單點訂單 -->
                    <div v-if="singleList.length > 0">
                        <!-- <pre>{{ singleList }}</pre> -->
                        <div v-for="(single, index) in singleList" :key="single.orderMealId" class="singleorderBlock">
                            <div class="singleHeader">
                                <p>{{ single.mealName }}</p>
                                <p>${{ single.mealPrice }}</p>
                            </div>
                            <div class="singleOptions">
                                <p>{{ single.options }}</p>
                                <p>+ ${{ single.optionsPrice }}</p>
                            </div>
                            <div class="singleBottom">
                                <!-- <button @click="editOrder(single, 'single')">編輯</button> -->
                                <button @click="confirmDeleteOrder(index, 'single')"><i class="bi bi-trash3-fill"></i></button>
                                <p>${{ single.price }}</p>
                            </div>
                        </div>
                    </div>

                    <!-- 套餐訂單 -->
                    <div v-if="newComboList.length > 0">
                        <!-- <pre> {{ newComboList }} </pre>
                        <pre> {{ comboList }}</pre> -->
                        <div v-for="(combo, index) in newComboList" :key="combo.orderMealId" class="comboBlock">
                            <div class="comboHeader">
                                <p>{{ combo.comboName }}</p>
                                <p>${{ combo.comboBasicPrice }}</p>
                            </div>

                            <div class="comboDetail">
                                <ul>
                                    <li v-for="(meal, i) in combo.mealList" :key="i">{{ meal.mealName }} ({{ meal.options }})</li>
                                </ul>
                                <ul>
                                    <li v-for="(meal, i) in combo.mealList" :key="i">+ ${{ meal.optionsPriceTotal + meal.priceDifference }}</li>
                                </ul>
                            </div>

                            <div class="comboBottom">
                                <button @click="confirmDeleteComboOrder(combo.orderMealId)"><i class="bi bi-trash3-fill"></i></button>
                                <p>${{ combo.selectedComboPrice }}</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 送出訂單按鈕：將訂單明細包裝成完整req格式接上 api 存入資料庫 -->
                <div class="totalAmountAndBtn">
                    <p>合計 ${{ totalAmount }}</p>
                    <button @click="submitOrder" class="submitBtn">送出訂單</button>
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
        height: 100%;
        display: flex;
        justify-content: space-between;
        padding: 16px; //20px
        letter-spacing: 0.2dvw;

        .menuArea {
            width: 68%;
            border: 1px solid rgba(grey, 0.5);
            border: 1px solid;
            box-shadow: -3px 3px 4px black;
            padding: 2%;
            border-radius: 10px;
            border: 1px solid;
            background-color: white;
        }

        .orderArea {
            width: 32%;
            border: 1px solid rgba(grey, 0.5);
            border: 1px solid;
            box-shadow: -3px 3px 4px black;
            padding: 2%;
            border-radius: 10px;
            border: 1px solid;
            background-color: white;
            margin-left: 0.5%;
        }
    }
}

.overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(0, 0, 0, 0.5); /* 黑色半透明 */
    z-index: 999; /* 保證在最上層 */
}

h2 {
    margin-bottom: 2%;
}

.tableAndCustomerNum {
    display: flex;
    align-items: center;
    gap: 15px;
    padding-bottom: 5%;
    border-bottom: 1px solid rgba(grey, 0.5);

    select {
        padding: 5px;
        border-radius: 5px;
        border: 1px solid #ccc;
    }
}

.orderSummary {
    height: 77%;
    padding: 2% 0;
    border-bottom: 1px solid rgba(grey, 0.5);
    overflow-y: scroll;
    scrollbar-width: none; /* Firefox 隱藏滾動條 */
}

.totalAmountAndBtn {
    padding-top: 2%;
    p {
        width: 100%;
        font-size: 1rem;
        font-weight: 600;
        text-align: end;
        margin-bottom: 3%;
    }
}
button.submitBtn {
    width: 100%;
    padding: 2%;
    color: white;
    font-size: 1rem;
    background-color: rgba(black, 0.8);
    border: none;
    border-radius: 10px;
}

h3 {
    margin: 2% 0;
}

.singleorderBlock {
    border: 1px solid rgba(black, 1);
    padding: 10px;
    border-radius: 5px;
    position: relative;
    margin-bottom: 10px;

    .singleHeader {
        display: flex;
        justify-content: space-between;
        p {
            font-weight: 500;
        }
    }
    .singleOptions {
        display: flex;
        justify-content: space-between;
        padding: 3% 0;
        border-bottom: 1px dashed rgba(black, 1);
    }

    .singleBottom {
        padding-top: 2%;
        display: flex;
        justify-content: space-between;
        p {
            font-weight: 500;
        }
        button {
            background-color: rgba(grey, 0.2);
            padding: 0.8% 1.8%;
            border-radius: 5px;
            border: none;
            font-size: 1.2rem;
            cursor: pointer;

            i {
                color: black;
            }
        }
    }
}

.comboBlock {
    border: 1px solid rgba(black, 1);
    padding: 10px;
    border-radius: 5px;
    position: relative;
    margin-bottom: 10px;

    .comboHeader {
        display: flex;
        justify-content: space-between;
        p {
            font-weight: 500;
        }
    }

    .comboDetail {
        display: flex;
        justify-content: space-between;
        padding: 3% 0;
        border-bottom: 1px dashed rgba(black, 1);

        ul {
            list-style-type: none;
        }

        li {
            margin-bottom: 1% 0;
        }
    }

    .comboBottom {
        padding-top: 2%;
        display: flex;
        justify-content: space-between;
        p {
            font-weight: 500;
        }
        button {
            background-color: rgba(grey, 0.2);
            padding: 0.8% 1.8%;
            border-radius: 5px;
            border: none;
            font-size: 1.2rem;
            cursor: pointer;

            i {
                color: black;
            }
        }
    }
}
</style>
