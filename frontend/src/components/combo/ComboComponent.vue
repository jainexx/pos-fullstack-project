<script>
import LeftBar from '@/components/LeftBar.vue'
import Header from '@/components/Header.vue'
import Swal from 'sweetalert2';
import axios from 'axios';
export default {
    data() {
        return {
            // editeMode:true,
            editeMode: false,
            createMode: false,
            menus: [],
            // {
            // "mealName": "九層塔蛋餅",
            // "categoryId": 4,
            // "workstationId": 3,
            // "price": 45,
            // "available": true,
            // "pictureName": null
            // },
            categories: [],

            //edit template
            comboItemIndex: null,
            comboName: null,
            oldComboName: null,
            selectedMeal: [],  // ['', '']
            selectedCategory: [],
            comboDetail: [], // [[], []]
            comboContentInnerQuantity: 0,
            discountAmount: "",
            //searchCombo container 
            comboItemsList: [],

            countCombo: 0,
            disabledNames: [], // 需要禁用的 select 的 name 列表

        }
    },
    components: {
        Header
    },
    created() {
        axios.post("http://localhost:8080/pos/searchCombo", {
            "comboName": ""
        })
            .then(response => {
                this.comboItemsList = response.data.comboItemsList
                this.comboItemsList.forEach(comboItem => {
                    comboItem.comboDetail = JSON.parse(comboItem.comboDetail);
                });
                console.log(response)

                return axios.get("http://localhost:8080/menu/all", {
                })
            })
            .then(response => {
                this.menus = response.data
                console.log(response)

                return axios.get("http://localhost:8080/category/all", {
                })
            })
            .then(response => {
                this.categories = response.data
                console.log(response)

            })
            .catch(error => {
                console.error("Error:", error.response ? error.response.data : error.message);
            });

    },
    methods: {
        createMeal() {
            this.editeMode = true
            this.createMode = true
            this.selectedMeal = []
            this.selectedCategory = []
        },
        saveMeal() {
            for (const item of this.comboItemsList) {
                // 檢查新資料的 comboName 是否與現有資料的 comboName 重複
                if (item.comboName === this.comboName) {
                    Swal.fire({
                        title: '錯誤',
                        text: '此套餐名稱已存在，請使用其他名稱！',
                        icon: 'warning',
                        confirmButtonText: '確定'
                    });
                    return; // 停止函式執行，不發送 axios 請求
                }
            }
            axios.post("http://localhost:8080/pos/createCombo", {
                "comboName": this.comboName,
                "comboDetail": JSON.stringify(this.comboDetail),
                "discountAmount": -(this.discountAmount),
                "categoryId": 8
            })
                .then(response => {
                    console.log(response)
                    return axios.post("http://localhost:8080/pos/searchCombo", {
                        "comboName": "",
                    });
                })

                .then(response => {
                    console.log(response)
                    this.comboItemsList = response.data.comboItemsList
                    this.comboItemsList.forEach(comboItem => {
                        comboItem.comboDetail = JSON.parse(comboItem.comboDetail);
                    });

                    Swal.fire({
                        title: '新增套餐成功',
                        icon: 'success',
                    });
                })
                .catch(error => {
                    console.error("Error:", error.response ? error.response.data : error.message);
                    Swal.fire({
                        title: '新增套餐失敗',
                        icon: 'error',
                    });
                });

            this.editeMode = false
            this.createMode = false
            this.comboItemIndex = null,
                this.comboName = null,
                this.selectedMeal = [],  // ['', '']
                this.comboDetail = [], // [[], []]
                this.comboContentInnerQuantity = 0,
                this.discountAmount = 0

        },

        cancelIcon() {
            this.editeMode = false
            this.createMode = false
            this.comboItemIndex = null,
                this.comboName = null,
                this.selectedMeal = [],  // ['', '']
                this.comboDetail = [], // [[], []]
                this.comboContentInnerQuantity = 0,
                this.discountAmount = 0
        },

        editeMeal(comboItem, comboItemIndex) {
            this.editeMode = true
            this.comboItemIndex = comboItemIndex
            this.comboName = comboItem.comboName
            this.oldComboName = comboItem.comboName

            this.selectedMeal = []
            this.selectedCategory = []
            for (let i = 0; i < comboItem.comboDetail.length; i++) {
                this.selectedMeal.push('')
                let categoryItem = this.categories.find(category => category.categoryId == comboItem.comboDetail[i].categoryId)
                this.selectedCategory.push(categoryItem.category)
            }

            this.comboDetail = comboItem.comboDetail
            this.discountAmount = Math.abs(comboItem.discountAmount)
        },
        updateMeal() {
            Swal.fire({
                title: '確定要繼續嗎？',
                text: "確認是否要更新套餐內容",
                icon: 'warning',
                showCancelButton: true,  // 顯示取消按鈕
                confirmButtonText: '是的，繼續',
                cancelButtonText: '取消',
            })
                .then((result) => {
                    if (result.isConfirmed) {
                        Swal.fire({
                            title: '已成功更新',
                            icon: 'success',
                        });
                        this.comboDetail = this.comboDetail.filter(combo => combo.dishes.length != 0)
                        return axios.post("http://localhost:8080/pos/updateCombo", {
                            "oldComboName": this.oldComboName,
                            "comboName": this.comboName,
                            "comboDetail": JSON.stringify(this.comboDetail),
                            "discountAmount": -(this.discountAmount),
                            "category_id": 8
                        })
                            .then(response => {
                                console.log(response)
                                return axios.post("http://localhost:8080/pos/searchCombo", {
                                    "comboName": "",
                                });
                            })
                            .then(response => {
                                console.log(response)
                                this.comboItemsList = response.data.comboItemsList
                                this.comboItemsList.forEach(comboItem => {
                                    comboItem.comboDetail = JSON.parse(comboItem.comboDetail);
                                });
                                this.editeMode = false
                                this.createMode = false
                                this.comboItemIndex = null,
                                    this.comboName = null,
                                    this.selectedMeal = [],  // ['', '']
                                    this.comboDetail = [], // [[], []]
                                    this.comboContentInnerQuantity = 0,
                                    this.discountAmount = 0
                            })
                            .catch(error => {
                                console.error("Error:", error.response ? error.response.data : error.message);
                                Swal.fire({
                                    title: '新增套餐失敗',
                                    icon: 'error',
                                });
                            });


                    }
                }
                )


            // this.comboDetail = this.comboDetail.filter(combo=>combo.dishes.length!=0)
            // console.log(this.oldComboName)
            // console.log(this.comboName)
            // axios.post("http://localhost:8080/pos/updateCombo",{
            //     "oldComboName":this.oldComboName,
            //     "comboName":this.comboName,
            //     "comboDetail":JSON.stringify(this.comboDetail),
            //     "discountAmount":this.discountAmount,
            //     "category_id":9
            // })
            // .then(response=>{
            //     console.log(response)
            //     return axios.post("http://localhost:8080/pos/searchCombo", {
            //         "comboName": "",
            //     });
            // })

            // .then(response=>{
            //     console.log(response)
            //     this.comboItemsList = response.data.comboItemsList
            //     this.comboItemsList.forEach(comboItem => {
            //         comboItem.comboDetail = JSON.parse(comboItem.comboDetail);
            //     });
            // })
            // .catch(error => {
            //     console.error("Error:", error.response ? error.response.data : error.message);
            //     Swal.fire({
            //             title:'新增套餐失敗',
            //             icon: 'error',
            //         });
            // });

            // this.editeMode = false
            // this.createMode = false
            // this.comboItemIndex = null,
            // this.comboName = null,
            // this.selectedMeal = [],  // ['', '']
            // this.comboDetail = [], // [[], []]
            // this.comboContentInnerQuantity = 0,
            // this.discountAmount = 0

        },


        trashMeal(comboName) {
            Swal.fire({
                title: '確定要繼續嗎？',
                text: "確認是否要刪除套餐",
                icon: 'warning',
                showCancelButton: true,  // 顯示取消按鈕
                confirmButtonText: '是的，繼續',
                cancelButtonText: '取消',
            })
                .then((result) => {
                    if (result.isConfirmed) {
                        axios.post("http://localhost:8080/pos/deleteCombo", {
                            "comboName": comboName,
                        })
                            .then(response => {
                                console.log(response)
                                return axios.post("http://localhost:8080/pos/searchCombo", {
                                    "comboName": "",
                                });
                            })
                            .then(response => {
                                console.log(response)
                                this.comboItemsList = response.data.comboItemsList
                                this.comboItemsList.forEach(comboItem => {
                                    comboItem.comboDetail = JSON.parse(comboItem.comboDetail);
                                });
                                Swal.fire({
                                    title: '已成功刪除',
                                    icon: 'success',
                                });
                            })
                            .catch(error => {
                                console.error("Error:", error.response ? error.response.data : error.message);
                            });
                    }
                });



        },

        addComboContentInner() {
            this.comboDetail.push({ "categoryId": 1, "dishes": [] })
            this.selectedMeal.push('')
            this.selectedCategory.push('')


        },
        totalPrice(comboItem) {
            let totalAmount = 0;
            comboItem.comboDetail.forEach(item => {
                // 确保 detailList 存在且有元素
                if (item.dishes && item.dishes.length > 0) {
                    const meal = item.dishes[0]; // 取第一个元素
                    const menu = this.menus.find(menu => menu.mealName == meal);

                    // 确保找到了对应的菜单
                    if (menu) {
                        totalAmount += menu.price;
                    } else {
                        console.warn(`Menu not found for meal: ${meal}`);
                    }
                } else {
                    console.warn(`detailList is empty or undefined for item: ${item}`);
                }
            });

            totalAmount += Number(comboItem.discountAmount) || 0; // 确保 discountAmount 是有效数字

            return totalAmount;
        },
        // addCategory(categorName){
        //     const categoryId = this.categories.find(category=>category.category == categorName)
        // },

        addMeal(comboItemIndex) {
            const dishes = this.comboDetail[comboItemIndex].dishes
            const mealExists = dishes.some(dishes => dishes == this.selectedMeal[comboItemIndex]);

            if (!mealExists) {
                const selectedMeal = this.menus.find(menu => menu.mealName == this.selectedMeal[comboItemIndex]);
                this.comboDetail[comboItemIndex].dishes.push(selectedMeal.mealName)
                const category = this.categories.find(category => category.categoryId == selectedMeal.categoryId)
                this.comboDetail[comboItemIndex].categoryId = category.categoryId
            }

            const disabledName = this.disabledNames.some(disabledName => disabledName == `select${comboItemIndex}`);
            if (!disabledName) {
                this.disabledNames.push(`select${comboItemIndex}`)
            }
        },
        deleteMeal(comboItemIndex, meal) {
            // 獲取指定容器
            const subContainer = this.comboDetail[comboItemIndex];

            // 使用filter刪除指定的餐點
            this.comboDetail[comboItemIndex].dishes = subContainer.dishes.filter(subContainerMeal => subContainerMeal != meal);
        },
        deleteSelection(comboItemIndex) {
            this.comboDetail = this.comboDetail.filter((_, index) => index != comboItemIndex);
        },

        searchMealPrice(meal) {
            const mealItem = this.menus.find(menu => menu.mealName == meal)
            return mealItem ? mealItem.price : 0; // 或者你可以返回其他值，例如 '未找到' 等
        },
        editTotalPrice() {
            let totalPrice = 0;

            // 遍歷 comboDetail 中的每個容器
            this.comboDetail.forEach(container => {
                // 確保每個 container 都有 detailList 並且不為空
                if (container.dishes && container.dishes.length > 0) {
                    const meal = container.dishes[0]
                    // 獲取對應的價格
                    const menu = this.menus.find(menu => menu.mealName === meal);
                    if (menu) {
                        totalPrice += menu.price; // 累加價格
                    }
                }
            });

            totalPrice -= Number(this.discountAmount); // 加上折扣
            return totalPrice;
        },
        menuWithSelectedCategory(selectedCategory) {
            let categoryItem = this.categories.find(categoryItem => categoryItem.category == selectedCategory)
            console.log('selectedCategory' + selectedCategory)
            console.log('categoryItem' + categoryItem)
            let menuWithSelectedCategory = this.menus.filter(menu => menu.categoryId == categoryItem.categoryId)

            return menuWithSelectedCategory
        },

        validateDiscount(event) {
            const value = event.target.value;
            const regex = /^[1-9][0-9]*$/;
            if (regex.test(value)) {
                this.discountAmount = Number(value); // 將字串轉換為數字
            } else {
                this.discountAmount = ''; // 不符合格式，清空輸入
            }
        }
    }
}
</script>

<template>
    <div class="ComboMainArea">
        <div class="glassMorphism" v-if="editeMode">
        </div>
        <div class="windowArea" v-if="editeMode">
            <div class="comboName">
                <p class="necessaryName">*必填</p>
                <input type="text" placeholder="套餐名稱" v-model="comboName">
            </div>
            <!-- <h1>{{ comboName }}</h1> -->
            <!-- <h1>{{ comboDetail }}</h1> -->
            <!-- <h1>{{ selectedCategory }}</h1> -->
            <!-- <h1>{{ selectedMeal }}</h1> -->
            <!-- <h1>{{ comboDetail }}</h1> -->
            <!-- <h1>{{ comboItemsList }}</h1> -->
            <div class="comboContent">
                <div class="comboContentInner" v-for="(comboItem, comboItemIndex) in comboDetail">
                    <!-- <h1>{{ this.comboDetail }}</h1> -->
                    <div class="selectionContainer">
                        <select :disabled="this.comboDetail[comboItemIndex].dishes.length!=0" :name="`select${comboItemIndex}`" v-model="selectedCategory[comboItemIndex]">
                            <option value="" disabled selected>選擇餐點分類</option>
                            <option v-for="(category, index) in categories" :key="index" :value="category.category">{{
                                category.category }}</option>
                        </select>
                        <select :name="`select${comboItemIndex}`" v-model="selectedMeal[comboItemIndex]"
                            @change="addMeal(comboItemIndex)">
                            <option value="" disabled selected>選擇餐點</option>
                            <option v-if="selectedCategory[comboItemIndex]"
                                v-for="(menu, index) in menuWithSelectedCategory(selectedCategory[comboItemIndex])"
                                :key="index" :value="menu.mealName">{{ menu.mealName }}</option>
                        </select>
                        <i class="fa-solid fa-circle-xmark" @click="deleteSelection(comboItemIndex)"></i>
                    </div>
                    
                    <div class="comboDetail" v-for="(meal, mealIndex) in comboDetail[comboItemIndex].dishes">
                        <p>• {{ meal }}</p>
                        <p>$ {{ searchMealPrice(meal) }}</p>
                        <i class="fa-solid fa-circle-xmark" @click="deleteMeal(comboItemIndex, meal)"></i>
                    </div>
                </div>
            </div>
            <div class="plusIcon" @click="addComboContentInner">
                <i class="fa-solid fa-circle-plus"></i>
            </div>
            <div class="comboTotal">
                <div class="discount">
                    <p>折扣 </p>
                    <input type="text" placeholder="折扣" v-model="discountAmount" @input="validateDiscount">
                </div>
                <div class="total">
                    <p>合計</p>
                    <p>${{ editTotalPrice() }}</p>
                </div>
            </div>
            <div class="editAndDelete">
                <button @click="updateMeal" v-if="!createMode">更新</button>
            </div>
            <div class="editAndDelete">
                <button @click="saveMeal" v-if="createMode">儲存</button>
            </div>
            <div class="cancelIcon">
                <i class="fa-regular fa-circle-xmark" @click="cancelIcon"></i>
            </div>
        </div>
        <div class="comboArea">
            <!-- <h1>editeMode {{ editeMode }}</h1> -->
            <!-- <h1>createMode {{ createMode }}</h1> -->
            <div class="comboTop">
                <div class="mtLeft">
                    <span>套餐</span>
                </div>
                <div class="mtRight">
                    <div class="selCate">
                        <!-- <div class="countOp">{{ comboItemsList.length }}</div> -->
                    </div>
                    <!-- <div class="saveBtn">儲存</div> -->
                </div>
            </div>
            <!-- <h1>{{this.categories}}</h1> -->
            <!-- <h1>{{ mealContainer }}</h1> -->
            <!-- <h1>{{ discountAmount }}</h1> -->
            <!-- <h1 v-if="mealContainer[0].length>0 && mealContainer[1].length>0">{{ totalPrice() }}</h1> -->
            <div class="comboMain">
                <!-- <h1>{{ categories[0] }}</h1> -->
                <!-- <h1>{{ menus[0] }}</h1> -->
                <!-- <h1>{{ comboItemsList[0] }}</h1> -->
                <div class="createCombo" @click="createMeal">+&nbsp&nbsp新增套餐</div>
                <div class="comboItem" v-for="(comboItem, comboItemIndex) in comboItemsList">
                    <!-- <h1>{{ comboItem }}</h1> -->

                    <div class="comboName">
                        <!-- <input type="text" placeholder="套餐名稱"> -->
                        <h1>{{ comboItem.comboName }}</h1>
                    </div>
                    <div class="comboContent">
                        <div class="comboContentInner" v-for="(detailItem, detailItemIndex) in comboItem.comboDetail">
                            <!-- <h1>{{ containerIndex }}</h1> -->
                            <!-- <h1>{{ selectedMeal }}</h1> -->
                            <!-- <select :name="`select${comboItemIndex}${detailItemIndex}`" v-model="selectedMeal[containerIndex]" @change="addMeal(containerIndex)">
                                    <option value="" disabled selected >{{ detailItem.detailName}}</option>
                                    <option v-for="(menu, index) in detailItem.detailList" :key="index" :value="menu.name" >{{ menu.name }}</option>
                                </select> -->

                            <!-- this.menus.find(menu=>menu.categoryId == detailItem.categoryId) -->
                            <!-- <h2 class="detailName">{{ this.menus.find(menu=>menu.categoryId == detailItem.categoryId)}}</h2> -->
                            <h2 class="detailName"></h2>
                            <div class="comboDetail" v-for="(meal, mealIndex) in detailItem.dishes">
                                <p class="mealName" :class="{ 'firstMealClass': mealIndex == 0 }">• {{ meal }}</p>
                                <p>$ {{ searchMealPrice(meal) }}</p>
                            </div>
                        </div>
                    </div>

                    <div class="comboTotal">
                        <div class="discount">
                            <p>折扣 </p>
                            <!-- <input type="text" placeholder="-10" v-model="discountAmount"> -->
                            <p>{{ -comboItem.discountAmount }}</p>
                        </div>
                        <div class="total">
                            <p>合計</p>
                            <p>${{ totalPrice(comboItem) }}</p>
                        </div>
                    </div>
                    <div class="editAndDelete" v-if="!editeMode">
                        <i class="fa-solid fa-pen-to-square" @click="editeMeal(comboItem, comboItemIndex)"></i>
                        <i class="fa-solid fa-trash" @click="trashMeal(comboItem.comboName)"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">
$divColor: #fff;
$addDiv: #343a3f;
$soldOut: #e02d11;

.ComboMainArea {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: start;
    align-items: start;
    position: relative;

    .glassMorphism {
        width: 86dvw;
        height: 90dvh;
        left: -20dvw;
        top: 0;
        background-color: rgba(0, 0, 0, 0.5);
        /* 背景颜色 */
        backdrop-filter: blur(5px);
        /* 磨砂玻璃效果 */
        z-index: 99;
        position: absolute
    }

    .windowArea {
        width: 40%;
        height: 80%;
        border-radius: 10px;
        border: 2px solid rgba(0, 0, 0, 1);
        border-radius: 20px;
        background-color: white;
        margin: 5% 4% 1% 20%;
        padding: 2% 1%;
        overflow: hidden;
        overflow-y: auto;
        scrollbar-width: none;
        z-index: 99;
        position: absolute;

        .comboName {
            margin: 5% 0 10% 0;

            .necessaryName {
                font-family: "Noto Sans TC", sans-serif;
                font-weight: bold;
                color: $soldOut;
            }

            h1 {
                font-size: 20px;
            }

            input {
                width: 100%;
                height: 40px;
                font-size: 20px;
                border-radius: 6px;
                border: 1px solid rgba(0, 0, 0, 0.4);
                background-color: white;
                padding: 2% 5%;
                box-shadow: 0px 0px 5px rgba(255, 0, 0, 0.8),
                    0px 0px 10px rgba(255, 0, 0, 0.4),
                    0px 0px 15px rgba(255, 0, 0, 0.1), ;

                &:focus {
                    outline: none;
                    background-color: rgba(0, 0, 0, 0.05);
                }
            }
        }

        .comboContent {
            .comboContentInner {
                margin: 0 0 5% 0;

                select {
                    width: 50%;
                    font-size: 20px;
                    border: 1px solid rgba(0, 0, 0, 0.2);
                    border-radius: 6px;
                    background-color: rgba(0, 0, 0, 0.05);
                    cursor: pointer;
                    padding: 0 5%;
                    margin: 0 0 2% 0;
                }

                .selectionContainer {
                    display: flex;
                    align-items: center;
                    justify-content: center;

                    i {
                        cursor: pointer;
                    }

                }

                .comboDetail {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 0 2% 0 5%;

                    p {
                        width: 30%;
                    }

                    i {
                        cursor: pointer;
                    }

                }
            }
        }

        .plusIcon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 80%;
            height: 5%;
            font-size: 18px;
            cursor: pointer;
            border: 1px solid rgba(0, 0, 0, 0.3);
            border-radius: 6px;
            background-color: rgba(0, 0, 0, 0.05);
            margin: 0 0 5% 0;

        }

        .comboTotal {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            justify-content: center;
            width: 100%;
            margin: 0 0 10% 0;
            position: relative;

            .discount {
                width: 50%;
                display: flex;
                align-items: center;
                justify-content: flex-start;

                p {
                    margin: 0 10% 0 0;
                }

                input {
                    width: 30%;
                    font-size: 15px;
                    border: 1px solid rgba(0, 0, 0, 0.3);
                    border-radius: 6px;
                    background-color: rgba(0, 0, 0, 0.05);
                    outline: none;
                    padding: 2% 5%;
                }
            }

            .total {
                width: 50%;
                display: flex;
                align-items: center;
                justify-content: flex-start;

                p {
                    margin: 0 10% 0 0;
                }
            }

            &:before {
                position: absolute;
                content: "";
                width: 100%;
                height: 1px;
                left: 0;
                bottom: -30%;
                background-color: #697077;
            }
        }

        .editAndDelete {
            width: 100%;
            height: 5%;
            display: flex;
            align-items: start;
            justify-content: flex-end;

            button {
                width: 30%;
                height: 100%;
                border: none;
                border-radius: 6px;
                font-size: 20px;
                color: white;
                background-color: black;
                cursor: pointer;
            }
        }

        .cancelIcon {
            position: absolute;
            cursor: pointer;
            right: 2%;
            top: 0;
            font-size: 25px;
            color: red;
        }
    }

    .comboArea {
        width: 100%;
        height: 100%;
        border-radius: 10px;
        border: 1px solid;
        display: flex;
        justify-content: start;
        align-items: center;
        flex-direction: column;
        background-color: $divColor;

        .comboTop {
            width: 97%;
            height: 6.6%;
            margin: 1% 0 1% 0;
            border-bottom: 1px solid #343a3f;
            display: flex;
            justify-content: space-between;
            align-items: center;

            .mtLeft {
                width: 30%;
                font-size: 30px;
                font-weight: bold;
                letter-spacing: 3px;
                margin-left: 1%;
                font-family: "Noto Sans TC", sans-serif;
            }

            .mtRight {
                width: 26%;
                display: flex;
                justify-content: center;
                align-items: center;
                letter-spacing: 3px;

                .selCate {
                    width: 66%;
                    display: flex;
                    justify-content: space-evenly;
                    align-items: center;
                    font-weight: bold;
                    font-family: "Noto Sans TC", sans-serif;

                    .countOp {
                        min-width: 20%;
                        letter-spacing: 0px;
                        font-weight: 500;
                        color: white;
                        background-color: rgb(0, 0, 0);
                        border-radius: 30px;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                    }
                }

                .saveBtn {
                    width: 32.4%;
                    height: 91%;
                    border-radius: 5px;
                    color: white;
                    background-color: black;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    font-family: "Noto Sans TC", sans-serif;
                }
            }
        }

        .comboMain {
            width: 97%;
            height: 89%;
            display: flex;
            overflow-y: scroll;
            scrollbar-width: none;
            flex-wrap: wrap;

            .createCombo {
                width: 22%;
                height: 48%;
                margin: 0 4% 1% 0;
                border-radius: 10px;
                display: flex;
                justify-content: center;
                align-items: center;
                color: white;
                background-color: $addDiv;
                font-size: 25px;
                cursor: pointer;
                font-family: "Noto Sans TC", sans-serif;
            }

            .createCombo:nth-child(4n) {
                margin: 0 0 1% 0;
            }

            .comboItem {
                width: 22%;
                height: 48%;
                border-radius: 10px;
                border: 1px solid black;
                margin: 0 4% 2% 0;
                padding: 1% 1% 0 1%;
                overflow-y: auto;
                scrollbar-width: none;

                .comboName {
                    margin: 0 0 5% 0;

                    h1 {
                        width: max-content;
                        display: flex;
                        align-items: center;
                        justify-content: start;
                        font-size: 20px;
                        font-weight: 600;
                        border-radius: 12px;
                        color: white;
                        background-color: rgba(17, 146, 0, 0.849);
                        padding: 2% 6%;
                    }

                    input {
                        width: 100%;
                        height: 40px;
                        font-size: 20px;
                        border-radius: 6px;
                        border: 1px solid rgba(0, 0, 0, 0.4);
                        background-color: white;
                        padding: 2% 5%;

                        &:focus {
                            outline: none;
                            background-color: rgba(0, 0, 0, 0.05);
                        }
                    }
                }

                .comboContent {
                    margin: 0 0 10% 0;

                    .comboContentInner {
                        margin: 0 0 5% 0;

                        select {
                            width: 80%;
                            font-size: 20px;
                            border: 1px solid rgba(0, 0, 0, 0.2);
                            border-radius: 6px;
                            background-color: rgba(0, 0, 0, 0.05);
                            cursor: pointer;
                            padding: 0 5%;
                            margin: 0 0 2% 0;
                        }

                        h2 {
                            width: 80%;
                            // background-color: rgba(250, 235, 215, 0.623);
                            border: 1px solid rgba(0, 0, 0, 0.453);
                            border-radius: 12px;
                            background-color: rgba(0, 0, 0, 0.1);
                            padding: 0 4%;
                            margin: 4% 0;
                        }

                        .comboDetail {
                            display: flex;
                            align-items: center;
                            justify-content: space-between;
                            font-size: 17px;
                            font-weight: 700;
                            padding: 0 2% 0 5%;

                            p:nth-child(1) {
                                width: max-content;
                                display: flex;
                                align-items: center;
                                justify-content: start;
                                padding: 0 4%;
                            }

                            p:nth-child(2) {
                                width: 30%;
                                display: flex;
                                align-items: center;
                                justify-content: start;
                            }

                            .firstMealClass {
                                width: 30%;
                                border-radius: 12px;
                                background-color: rgba(255, 51, 0, 0.226);
                            }
                        }
                    }
                }

                .plusIcon {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    width: 80%;
                    height: 12%;
                    font-size: 18px;
                    cursor: pointer;
                    border: 1px solid rgba(0, 0, 0, 0.3);
                    border-radius: 6px;
                    background-color: rgba(0, 0, 0, 0.05);
                    margin: 0 0 5% 0;

                }

                .comboTotal {
                    display: flex;
                    flex-direction: column;
                    align-items: flex-end;
                    justify-content: center;
                    width: 100%;
                    margin: 0 0 10% 0;
                    position: relative;
                    font-size: 15px;
                    font-weight: 900;

                    .discount {
                        width: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: flex-start;

                        p {
                            margin: 0 10% 0 0;
                        }

                        input {
                            width: 50%;
                            font-size: 15px;
                            border: 1px solid rgba(0, 0, 0, 0.3);
                            border-radius: 6px;
                            background-color: rgba(0, 0, 0, 0.05);
                            outline: none;
                            padding: 2% 5%;
                        }
                    }

                    .total {
                        width: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: flex-start;

                        p {
                            margin: 0 5% 0 0;
                        }
                    }

                    &:before {
                        position: absolute;
                        content: "";
                        width: 100%;
                        height: 1px;
                        left: 0;
                        bottom: -5px;
                        background-color: #697077;
                    }
                }

                .editAndDelete {
                    width: 100%;
                    height: 20%;
                    display: flex;
                    align-items: center;
                    justify-content: flex-end;

                    i {
                        width: 50%;
                        height: 100%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 30px;
                        margin: 0 2%;

                        &:nth-child(1) {
                            cursor: pointer;
                            border-radius: 6px;
                            color: white;
                            background-color: #697077;
                        }

                        &:nth-child(2) {
                            cursor: pointer;
                            border-radius: 6px;
                            background-color: #697077;
                        }
                    }

                    // button{
                    //     width: 30%;
                    //     height: 80%;
                    //     border: none;
                    //     border-radius: 6px;
                    //     color: white;
                    //     background-color: black;
                    //     cursor: pointer;
                    // }

                }
            }

            .comboItem:nth-child(4n) {
                margin: 0 0 1% 0;
            }
        }
    }
}
</style>
