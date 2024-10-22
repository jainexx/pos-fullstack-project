<script>
import defaultMenuImage from "@/assets/default-menu-img.png";

export default {
    data(){
        return {
            defaultMenuImage, // 將圖片變數放入 data，使模板可訪問
        }
    },
    props: {
        menuItems: Array,
        combos: Array,
        currentCategory: String, // 當前分類名稱，判斷是否為"套餐"
    },
    computed: {
        showCombos() {
            return this.currentCategory === "套餐"; // 判斷是否顯示套餐
        },
    },
    methods: {
        calculateComboPrice(combo) {
            return combo.comboDetail.reduce((total, detail) => total + detail.dishesList[0].price, 0) + combo.discountAmount;
        },
        isComboDisabled(combo) {
            // 檢查主餐的 available 屬性
            return !combo.comboDetail[0].dishesList[0].available;
        },
        selectItem(item) {
            console.log(item);

            if (item.available === false) return; // 不可選時直接返回
            if (item.comboDetail && this.isComboDisabled(item)) return; // 若 item 為套餐且isComboDisabled為true

            //如果是套餐，計算價格並附加到 item
            if (item.comboDetail) {
                item.comboPrice = this.calculateComboPrice(item);
            }
            // 選擇餐點後觸發事件，將資料傳給主元件
            this.$emit("selectItem", item);
        },
    },
};
</script>

<template>
    <div class="menuItems">
        <!-- 單點餐點 -->
        <div v-for="item in menuItems" :key="item.mealName" @click="selectItem(item)" :class="{ disabled: !item.available }" class="singleItem">
            <div class="imgContainer">
                <img :src="item.pictureName ? item.pictureName : defaultMenuImage" class="mealImage" />
            </div>
            <p>{{ item.mealName }}</p>
            <p style="text-align: end">${{ item.price }}</p>
        </div>

        <!-- 套餐餐點 -->
        <div v-if="showCombos" v-for="combo in combos" :key="combo.comboName" @click="selectItem(combo)" :class="{ disabled: isComboDisabled(combo) }" class="comboItem">
            <div class="imgContainer">
                <p>{{ combo.comboName }}</p>
                <ul>
                    <li v-for="dish in combo.comboDetail" :key="dish.dishesList[0].dishName">
                        {{ dish.dishesList[0].dishName }}
                    </li>
                </ul>
            </div>
            <div class="comboPrice">${{ calculateComboPrice(combo) }}</div>
        </div>
    </div>
</template>

<style scoped lang="scss">
.menuItems {
    display: flex;
    flex-wrap: wrap;
    gap: 35px;
    padding: 2% 0;
}

.singleItem {
    width: 250px;
    height: 200px;
    cursor: pointer;
    padding: 1%;
    border: 1px solid rgba(black, 0.5);
    border-radius: 10px;
    transition: background-color 0.3s;
    &:hover {
        border: 2px solid rgba(black, 1);
    }

    .imgContainer {
        width: 98%;
        height: 75%;
        border: 0.5px dashed rgba(grey, 0.3);
        margin-bottom: 3px;

        img {
            width: 100%;
            height: 100%;
        }
    }

    p {
        font-weight: 500;
        width: 100%;
    }
}

.menuItems div.disabled {
    cursor: not-allowed;
    background-color: rgba(grey, 0.3);
    opacity: 0.9;
    position: relative; /* 讓內部絕對定位的內容相對於此 div */
    &::after {
        content: "";
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: 160px;
        height: 160px;
        background-image: url("@/assets/sold-out-img.png"); /* 替換成你的圖片路徑 */
        background-size: cover;
        background-position: center;
        pointer-events: none;
        // opacity: 1;
    }

    p , img{
        opacity: 0.3;
    }
}

.mealImage {
    width: 100px;
    height: 100px;
    object-fit: cover;
    margin-bottom: 5px;
}

.comboItem {
    width: 250px;
    height: 200px;
    cursor: pointer;
    padding: 1%;
    border: 1px solid rgba(black, 0.5);
    border-radius: 10px;
    transition: background-color 0.3s;
    &:hover {
        border: 2px solid rgba(black, 0.8);
    }

    .imgContainer {
        width: 98%;
        height: 75%;
        border: 3px dashed rgba(grey, 0.3);

        margin-bottom: 3px;
        padding: 5%;

        p {
            font-weight: 500;
        }

        ul {
            margin-top: 2%;
            padding: 0 10%;
        }

    }

    .comboPrice {
        margin-top: 5%;
        text-align: right;
        font-weight: 500;
    }
}

</style>
