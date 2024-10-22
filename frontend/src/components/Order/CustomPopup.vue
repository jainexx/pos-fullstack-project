<script>
import { v4 as uuidv4 } from "uuid";

export default {
    props: {
        item: Object,
        optionsList: Array,
        categoriesList: Array,
    },
    data() {
        return {
            // 被選擇的單點餐點及選項
            singleDishes: {},
            singleOptions: {},

            // 被選擇的套餐餐點及選項
            comboDishes: {
                comboName: this.item.comboName,
                discountAmount: this.item.discountAmount,
                comboBasicPrice: this.item.comboPrice,
                selectedDishes: [], // 菜品和其客製化選項
            },

            totalPrice: 0,

            //  傳到主元件的陣列
            comboList: [], //套餐訂單
            singleList: [], // 單點訂單
        };
    },
    computed: {
        isCombo() {
            return !!this.item.comboDetail;
        },
        //套餐中的單品
        groupedComboDishes() {
            return this.item.comboDetail.map((detail) => {
                const defaultDish = detail.dishesList[0]; // 預設餐點
                return {
                    categoryName: this.getCategoryName(detail.categoryId),
                    categoryId: detail.categoryId,
                    dishes: detail.dishesList.map((dish) => ({
                        name: dish.dishName,
                        price: dish.price,
                        categoryId: detail.categoryId,
                        // 計算與預設餐點的價差
                        priceDifference: dish.price - defaultDish.price,
                    })),
                };
            });
        },
        itemPrice() {
            return this.isCombo ? this.item.comboPrice : this.item.price;
        },
        //單點客製化選項
        filteredOptions() {
            const categoryId = this.singleDishes.categoryId || this.item.categoryId;
            // 根據 categoryId 過濾選項，即使該餐點不可用
            return this.optionsList.filter((option) => option.categoryId === categoryId);
        },
    },
    mounted() {
        if (this.isCombo) {
            // 預設選擇每個分類的第一個菜品
            this.comboDishes.selectedDishes = this.groupedComboDishes.map((group) => ({
                ...group.dishes[0], // 選擇第一個菜品
                workstationId: this.getWorkstationId(group.categoryId), // 取得對應的 workstationId
                selectedOptions: {}, // 初始化選項
            }));
            this.totalPrice = this.comboDishes.comboBasicPrice;
        } else {
            this.singleDishes = this.item;
            this.singleOptions = {};
            this.totalPrice = this.singleDishes.price;
        }
    },
    methods: {
        // 單點
        selectSingleDish(dish) {
            this.singleDishes = dish;
            this.calculateTotal();
        },
        toggleSingleOption(optionTitle, optionContent, extraPrice, optionType) {
            let options = this.singleOptions[optionTitle] || [];

            if (optionType === "radio") {
                options = [{ content: optionContent, price: extraPrice }];
            } else {
                const index = options.findIndex((opt) => opt.content === optionContent);
                if (index !== -1) {
                    options.splice(index, 1);
                } else {
                    options.push({ content: optionContent, price: extraPrice });
                }
            }
            this.singleOptions[optionTitle] = options;
            this.calculateTotal();
        },
        // 組裝單點訂單資料
        assembleSingleOrder() {
            const orderMealId = uuidv4(); // 生成唯一的 orderMealId

            const options = Object.values(this.singleOptions)
                .flat()
                .map((opt) => opt.content)
                .join(", "); // 組合所有選項的 content

            const optionsPrice = Object.values(this.singleOptions)
                .flat()
                .map((opt) => opt.price)
                .join(", "); // 組合所有選項的 price

            const totalPrice =
                this.singleDishes.price +
                Object.values(this.singleOptions)
                    .flat()
                    .reduce((sum, opt) => sum + opt.price, 0); // 計算總價

            const singleOrder = {
                orderMealId,
                comboName: null, // 單點沒有套餐名稱
                mealName: this.singleDishes.mealName,
                mealPrice: this.singleDishes.price,
                options: options || null, // 如果沒有選項則為 null
                optionsPrice: optionsPrice,
                workstationId: this.singleDishes.workstationId || 0,
                price: totalPrice,
            };

            this.singleList.push(singleOrder); // 加入到 singleList 中

            // 傳送資料至主元件
            this.$emit("addToOrder", this.singleList);

            // 關閉視窗
            this.closePopup();
        },

        // 套餐
        selectComboDish(categoryName, dish) {
            const workstationId = this.getWorkstationId(dish.categoryId);
            const existingDishIndex = this.comboDishes.selectedDishes.findIndex((d) => d.categoryId === dish.categoryId);

            if (existingDishIndex !== -1) {
                this.comboDishes.selectedDishes[existingDishIndex] = {
                    ...dish,
                    workstationId,
                    selectedOptions: {},
                };
            } else {
                this.comboDishes.selectedDishes.push({
                    ...dish,
                    workstationId,
                    selectedOptions: {},
                });
            }
            this.calculateTotal();
        },
        toggleComboOption(categoryName, optionTitle, optionContent, extraPrice, optionType) {
            // 根據 categoryName 找到對應的菜品
            const dish = this.comboDishes.selectedDishes.find((d) => d.categoryId === this.getCategoryIdByName(categoryName));

            if (!dish) return; // 若找不到菜品則直接返回

            let options = dish.selectedOptions[optionTitle] || [];

            if (optionType === "radio") {
                // 單選：清空陣列並加入新選項
                options = [{ content: optionContent, price: extraPrice }];
            } else {
                // 多選：檢查是否已選擇，如果已選則移除，否則加入
                const index = options.findIndex((opt) => opt.content === optionContent);
                if (index !== -1) {
                    options.splice(index, 1);
                } else {
                    options.push({ content: optionContent, price: extraPrice });
                }
            }

            dish.selectedOptions[optionTitle] = options;
            this.calculateTotal();
        },
        // selectComboDish(categoryId, dish, index) {
        //     // 確保每個菜品都有自己的索引位置
        //     this.comboDishes.selectedDishes[index] = {
        //         ...dish,
        //         selectedOptions: {},
        //     };
        //     this.calculateTotal();
        // },
        // toggleComboOption(index, optionTitle, optionContent, extraPrice, optionType) {
        //     // 根據菜品的索引處理選項邏輯
        //     const dish = this.comboDishes.selectedDishes[index];
        //     if (!dish) return;

        //     let options = dish.selectedOptions[optionTitle] || [];
        //     if (optionType === "radio") {
        //         options = [{ content: optionContent, price: extraPrice }];
        //     } else {
        //         const optIndex = options.findIndex((opt) => opt.content === optionContent);
        //         if (optIndex !== -1) {
        //             options.splice(optIndex, 1);
        //         } else {
        //             options.push({ content: optionContent, price: extraPrice });
        //         }
        //     }
        //     dish.selectedOptions[optionTitle] = options;
        //     this.calculateTotal();
        // },
        getOptionsForDish(dish) {
            return this.optionsList.filter((option) => option.categoryId === dish.categoryId);
        },
        getCategoryName(categoryId) {
            const category = this.categoriesList.find((cat) => cat.categoryId === categoryId);
            return category ? category.category : "未分類";
        },
        getCategoryIdByName(categoryName) {
            const category = this.categoriesList.find((cat) => cat.category === categoryName);
            return category ? category.categoryId : null;
        },
        getWorkstationId(categoryId) {
            const detail = this.item.comboDetail.find((d) => d.categoryId === categoryId);
            return detail ? detail.workstationId : null;
        },
        // 組裝套餐訂單資料
        assembleComboOrder() {
            const orderMealId = uuidv4(); // 生成唯一的 orderMealId

            // 1.1 套餐總覽
            const comboOverview = {
                orderMealId,
                comboName: this.comboDishes.comboName,
                mealName: null,
                options: null,
                workstationId: 0,
                price: this.comboDishes.discountAmount,
                comboBasicPrice: this.comboDishes.comboBasicPrice,
                selectedComboPrice: this.totalPrice,
            };

            // 1.2 套餐單品項
            const comboItems = this.comboDishes.selectedDishes.map((dish) => {
                const options = Object.values(dish.selectedOptions)
                    .flat()
                    .map((opt) => opt.content)
                    .join(", "); // 將選項以逗號分隔

                const optionsPriceTotal = Object.values(dish.selectedOptions)
                    .flat()
                    .reduce((sum, opt) => sum + opt.price, 0); // 加總所有選項的 price

                const totalPrice =
                    dish.price +
                    Object.values(dish.selectedOptions)
                        .flat()
                        .reduce((sum, opt) => sum + opt.price, 0); // 計算選項的總金額

                return {
                    orderMealId,
                    comboName: this.comboDishes.comboName,
                    mealName: dish.name,
                    options: options || null,
                    optionsPriceTotal: optionsPriceTotal,
                    workstationId: dish.workstationId || 0,
                    price: totalPrice,
                    priceDifference: dish.priceDifference,
                };
            });

            // 將總覽和單品項加入 comboList
            this.comboList.push(comboOverview, ...comboItems);

            // 傳送資料至主元件
            this.$emit("addToOrder", this.comboList);

            // 關閉視窗
            this.closePopup();
        },

        // 共用
        calculateTotal() {
            let total = 0;

            // 單點的總金額
            if (this.singleDishes.mealName) {
                total += this.singleDishes.price;
                // 遍歷單點所有選項，累加選項價格
                Object.values(this.singleOptions).forEach((options) => {
                    total += options.reduce((sum, opt) => sum + opt.price, 0);
                });
            }

            // 套餐的總金額計算
            if (this.isCombo) {
                // 遍歷套餐中的每個選中的菜品及其選項
                this.comboDishes.selectedDishes.forEach((dish) => {
                    total += dish.price || 0; // 加上菜品的價格，若為 null 則視為 0

                    // 遍歷該菜品的所有客製化選項，累加價格
                    Object.values(dish.selectedOptions).forEach((options) => {
                        total += options.reduce((sum, opt) => sum + (opt.price || 0), 0); // 若選項價格為 null，則視為 0
                    });
                });

                // 套餐折扣計算
                if (this.comboDishes.discountAmount) {
                    total += this.comboDishes.discountAmount;
                }
            }

            this.totalPrice = total;
        },
        // 共用
        closePopup() {
            this.$emit("close");
        },
    },
};
</script>

<template>
    <!-- 單點 -->
    <div class="popup" v-if="!isCombo">
        <div class="popupHeader">
            <h3>餐點內容</h3>
            <button @click="closePopup"><i class="fa-regular fa-circle-xmark"></i></button>
        </div>

        <div class="mealNamePrice">
            <!-- <img v-if="item.picture" :src="item.picture" class="popupMenuImage" /> -->
            <h4>{{ singleDishes.mealName }}</h4>
            <p>${{ singleDishes.price }}</p>
        </div>

        <div v-for="option in filteredOptions" :key="option.optionTitle" class="option">
            <h4>{{ option.optionTitle }}</h4>
            <div v-for="item in option.optionItems" :key="item.optionContent" class="optionItem">
                <label class="optionLabel">
                    <input :type="option.optionType" :name="option.optionTitle" @change="toggleSingleOption(option.optionTitle, item.optionContent, item.extraPrice, option.optionType)" />
                    <span class="optionContent">{{ item.optionContent }}</span>
                </label>
                <span class="optionPrice">+ ${{ item.extraPrice }}</span>
            </div>
        </div>

        <div class="totalPriceBlock">合計 &nbsp;&nbsp;&nbsp; $ {{ totalPrice }}</div>

        <button @click="assembleSingleOrder" class="submit">加入訂單</button>
    </div>

    <!-- 套餐 -->
    <div class="popup2" v-if="isCombo">
        <div class="popupHeader">
            <h3>餐點內容</h3>
            <button @click="closePopup"><i class="fa-regular fa-circle-xmark"></i></button>
        </div>

        <div class="comboNamePrice">
            <h3>{{ item.comboName }}</h3>
            <p>${{ item.comboPrice }}</p>
            <!-- 顯示每個分類的第一個菜品名稱 -->
            <!-- <p v-if="isCombo">
                <span v-for="(group, index) in groupedComboDishes" :key="index"> | {{ group.dishes[0].name }} </span>
            </p> -->
        </div>

        <!-- 套餐選擇區 -->
        <div class="comboDetail">
            <div v-for="(group, index) in groupedComboDishes" :key="index" class="comboGroup">
                <h4>{{ group.categoryName }}</h4>

                <!-- 菜品選擇區 -->
                <div class="dishRadioGroup">
                    <div v-for="dish in group.dishes" :key="dish.name">
                        <label class="dishLabel">
                            <span class="dishInputName">
                                <input
                                    type="radio"
                                    :name="group.categoryName"
                                    :value="dish"
                                    :checked="comboDishes.selectedDishes.some((d) => d.name === dish.name)"
                                    @change="selectComboDish(group.categoryName, dish)" />
                                {{ dish.name }}
                            </span>
                            <span class="dishPrice">${{ dish.priceDifference }}</span>
                        </label>
                    </div>
                </div>

                <!-- 該分類下的客製化區塊 -->
                <div v-if="comboDishes.selectedDishes.some((d) => d.categoryId === group.categoryId)" class="customOptions">
                    <div v-for="option in getOptionsForDish(comboDishes.selectedDishes.find((d) => d.categoryId === group.categoryId))" :key="option.optionTitle" class="customOption">
                        <h5>{{ option.optionTitle }}</h5>
                        <div v-for="item in option.optionItems" :key="item.optionContent">
                            <label class="optionLabel">
                                <span class="optionInputName">
                                    <input
                                        :type="option.optionType"
                                        :name="`${group.categoryName}-${option.optionTitle}`"
                                        @change="toggleComboOption(group.categoryName, option.optionTitle, item.optionContent, item.extraPrice, option.optionType)" />
                                    {{ item.optionContent }}
                                </span>
                                <span class="optionPrice">+${{ item.extraPrice }}</span>
                            </label>
                        </div>
                    </div>
                </div>

                <!-- <div v-for="dish in group.dishes" :key="dish.name" class="dishRadioGroup">
                    <label class="dishLabel">
                        <input
                            type="radio"
                            :name="`dish-${group.categoryId}-${index}`"
                            :value="dish"
                            @change="selectComboDish(group.categoryId, dish, index)"
                            :checked="comboDishes.selectedDishes[index].name === dish.name" />
                        {{ dish.name }}
                    </label>
                </div> -->

                <!-- 客製化選項區
                <div v-if="comboDishes.selectedDishes[index]">
                    <div v-for="option in getOptionsForDish(comboDishes.selectedDishes[index])" :key="option.optionTitle">
                        <label v-for="item in option.optionItems" :key="item.optionContent">
                            <input :type="option.optionType" @change="toggleComboOption(index, option.optionTitle, item.optionContent, item.extraPrice, option.optionType)" />
                            {{ item.optionContent }} (+${{ item.extraPrice }})
                        </label>
                    </div>
                </div> -->
            </div>
        </div>

        <!-- 合計金額區塊  -->
        <div class="totalPriceBlock">合計 &nbsp;&nbsp;&nbsp; $ {{ totalPrice }}</div>

        <button @click="assembleComboOrder" class="submit">加入訂單</button>
    </div>

    <!-- <pre>{{ singleDishes }}</pre>
    <pre>{{ singleOptions }}</pre>

    <pre>{{ comboDishes }}</pre>
    <pre>{{ selectedDishes }}</pre> -->
</template>

<style scoped lang="scss">
.popup,
.popup2 {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background-color: white;
    border-radius: 10px;
    padding: 20px;
    border: 1px solid #ccc;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    z-index: 1000; /* 保證在 overlay 之上 */
    transition: all 0.3s ease-in-out; /* 平滑過渡效果 */
}

.popupHeader {
    display: flex;
    justify-content: space-between;
    padding-bottom: 1%;
    border-bottom: 1px solid rgba(grey, 0.6);

    h3 {
        padding: 1%;
        width: 50%;
    }
    button {
        background-color: transparent;
        border: none;
        font-size: 1.2rem;
        width: 10%;

        i {
            color: black;
        }
    }
}

.totalPriceBlock {
    padding: 2%;
    text-align: right;
    font-weight: 500;
    font-size: 1.2rem;
}

button.submit {
    width: 100%;
    padding: 1.5%;
    color: white;
    font-size: 1rem;
    background-color: rgba(black, 0.8);
    border: none;
    border-radius: 10px;
}

.popup {
    min-width: 25dvw;
    max-width: 50dvw;

    .mealNamePrice {
        padding: 3%;
        display: flex;
        justify-content: space-between;
        background-color: #ffc90e;
        margin: 2% 0;
        border-radius: 5px;
    }

    .option {
        margin: 2% 0;
        padding: 3%;
        border: 1px solid rgba(grey, 0.4);
        border-radius: 5px;

        .optionItem {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1px 0;

            .optionLabel {
                display: flex;
                align-items: center;
                gap: 10px; /* 控制 input 和文字之間的間距 */
            }

            .optionContent {
                margin-right: auto; /* 讓文字和價格之間自動撐開距離 */
            }

            .optionPrice {
                white-space: nowrap; /* 確保價格不換行 */
            }
        }
    }
}

.popup2 {
    min-width: 50dvw;
    max-width: 60dvw;
    .comboNamePrice {
        padding: 2%;
        display: flex;
        justify-content: space-between;
        background-color: rgba(grey, 0.2);
        margin: 2% 0;
        border-radius: 5px;
    }

    .comboDetail {
        display: flex;
        gap: 20px;
        justify-content: space-around;
        border-bottom: 1px solid rgba(grey, 0.8);

        .comboGroup {
            flex: 1 1 30%; /* 每個 comboGroup 占用 30% 寬度並自動調整 */
            min-width: 200px;
            padding-bottom: 2%;

            h4 {
                color: black;
                width: 40%;
                text-align: center;
                font-size: 1.2rem;
                margin-bottom: 10px;
                background-color: #ffc90e;
                padding: 5px;
                border-radius: 20px;
            }

            .dishRadioGroup {
                margin-bottom: 4%;

                .dishLabel {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    width: 100%;
                    margin-bottom: 5px;
                }

                .dishInputName {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }

                .dishPrice {
                    flex-shrink: 0; /* 保證價格不被壓縮 */
                    white-space: nowrap; /* 價格不換行 */
                }
            }

            .customOptions {
                padding: 3% 5%;
                border: 1px solid rgba(grey, 0.8);
                border-radius: 10px;

                .customOption {
                    border-bottom: 1px solid rgba(grey, 0.8);
                    margin-bottom: 3%;

                    &:last-child {
                        border-bottom: none; /* 最後一個選項不顯示 border-bottom */
                    }

                    h5 {
                        margin-bottom: 5px;
                        font-size: 1rem;
                    }

                    .optionLabel {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        width: 100%;
                        margin-bottom: 1%;

                        .optionInputName {
                            display: flex;
                            align-items: center;
                            gap: 10px;
                            flex-grow: 1;
                        }

                        .optionPrice {
                            flex-shrink: 0;
                            white-space: nowrap;
                        }
                    }
                }
            }
        }
    }
}
</style>
