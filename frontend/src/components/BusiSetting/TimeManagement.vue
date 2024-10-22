<script>
import axios from "axios";
import Swal from "sweetalert2";

export default {
    data() {
        return {
            businessHoursList: [], // 用於存儲營業時間的數據
            toBeDeleted: [], // 儲存要刪除的營業時間的 ID
            diningDuration: null, // 用餐時長
        };
    },

    mounted() {
        this.loadBusinessHours();
    },

    methods: {
        // 加載營業時間
        async loadBusinessHours() {
            try {
                // 獲取營業時間資料
                const response = await axios.get("http://localhost:8080/operatingHours/getOperatingHours");
                this.businessHoursList = response.data; // 儲存獲取的資料

                // 格式化資料
                this.businessHours = this.formatBusinessHours(this.businessHoursList);
                console.log("營業時間資料:", this.businessHours);
            } catch (error) {
                console.error("加載營業時間失敗:", error);
                Swal.fire({
                    icon: "error",
                    title: "加載失敗",
                    text: "獲取營業時間時發生錯誤，請稍後再試。",
                });
            }
        },

        // 將營業時間依照日期區分群組
        formatBusinessHours(businessHoursList) {
            const formatted = [];

            // 將數據按星期分組
            businessHoursList.forEach((item) => {
                const { dayOfWeek, openingTime, closingTime } = item;

                // 檢查是否已存在該星期的條目
                let existingDay = formatted.find((day) => day.dayOfWeek === dayOfWeek);

                if (!existingDay) {
                    existingDay = {
                        dayOfWeek: dayOfWeek,
                        timeSlots: [],
                    };
                    formatted.push(existingDay);
                }

                // 添加時間段
                existingDay.timeSlots.push({
                    openingTime,
                    closingTime,
                });
            });

            return formatted;
        },

        // 刪除營業時間
        removeBusinessHour(index) {
            const businessHour = this.businessHoursList[index];
            this.toBeDeleted.push(businessHour.id); // 將要刪除的 ID 添加到待刪除列表
            this.businessHoursList.splice(index, 1); // 從本地列表中移除
        },

        // 確定刪除營業時間，並發送請求到後端
        async deleteBusinessHour() {
            if (this.toBeDeleted.length === 0) {
                Swal.fire({
                    icon: "info",
                    title: "沒有選擇要刪除的營業時間",
                    text: "請先選擇要刪除的營業時間。",
                });
                return; // 如果沒有選擇要刪除的項目，則返回
            }

            try {
                // 發送 DELETE 請求到後端 API
                const response = await axios.delete("http://localhost:8080/operatingHours/deleteOperatingHours", {
                    data: this.toBeDeleted, // 將要刪除的 ID 傳送作為請求體
                });

                // 簡化的成功回應處理
                Swal.fire({
                    icon: "success",
                    title: "刪除成功",
                    text: response.data.message, // 使用後端返回的消息
                });
                this.toBeDeleted = []; // 清空待刪除列表
                this.loadBusinessHours(); // 重新加載營業時間
            } catch (error) {
                console.error("刪除營業時間失敗:", error);
                Swal.fire({
                    icon: "error",
                    title: "刪除失敗",
                    text: "刪除營業時間時發生錯誤，請稍後再試。",
                });
            }
        },

        cancelChanges() {
            Swal.fire({
                icon: "warning",
                title: "取消變更",
                text: "已取消刪除營業時間操作。",
            });
            this.loadBusinessHours(); // 重新加載營業時間列表
        },
    },
};
</script>

<template>
    <div class="reserveManagementArea">
        <h2 class="reserveSlotTitle">訂位時段管理</h2>
        <p class="reminderText">所有已設定的營業時間如下</p>
        <div class="reserveSlotArea">
            <table class="reserveSlotList">
                <thead>
                    <tr>
                        <th>營業日期</th>
                        <th>營業時間</th>
                        <th>編輯</th>
                    </tr>
                </thead>

                <tbody>
                    <!-- 只顯示營業日期和營業時間 -->
                    <tr v-for="(businessHours, index) in businessHoursList" :key="index">
                        <!-- 營業日期 -->
                        <td>
                            <p class="bussinessDate">{{ businessHours.dayOfWeek }}</p>
                        </td>

                        <!-- 營業時間 -->
                        <td>
                            <p class="bussinessTime">{{ businessHours.openingTime }} - {{ businessHours.closingTime }}</p>
                        </td>

                        <!-- 刪除 Button -->
                        <td>
                            <button class="trashButton" @click="removeBusinessHour(index)">
                                <i class="fa-solid fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="buttonArea">
            <button class="cancelButton" @click="cancelChanges">取消</button>
            <button class="saveButton" @click="deleteBusinessHour">儲存</button>
        </div>
    </div>
</template>

<style scoped lang="scss">
$background-color: #ffffff;
$black-color: #1e1e1e;
$gray-color: #dde1e6;
$boxShadow: #f2f4f8;

.reserveManagementArea {
    width: 80%;
    height: 100%;
    border-radius: 0.625rem; /* 10px -> 0.625rem */
    background-color: $background-color;
    padding: 1.25rem 2.1875rem; /* 20px 20px -> 1.25rem 1.375rem */
    position: absolute;
    top: 0%;
    right: 0%;
    border: 1px solid rgba(grey, 0.5);
    border: 1px solid;
    box-shadow: -3px 3px 4px black;

    .reserveSlotTitle {
        font-size: 1.5625rem; /* 25px -> 1.5625rem */
        letter-spacing: 0.25rem; /* 4px -> 0.25rem */
        margin-bottom: 0.625rem; /* 10px -> 0.625rem */
    }

    .reminderText {
        margin-bottom: 1.25rem; /* 20px -> 1.25rem */
        color: $black-color;
        opacity: 0.6;
    }

    .reserveSlotArea {
        width: 100%;
        height: 85%;
        border: 0.125rem solid $gray-color; /* 2px -> 0.125rem */
        padding: 0.9375rem 0.625rem; /* 15px 10px -> 0.9375rem 0.625rem */
        max-height: 37.625rem; /* 650px -> 40.625rem */
        overflow-y: auto;

        .reserveSlotList {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;

            thead {
                height: 3.4375rem; /* 55px -> 3.4375rem */
                background-color: $gray-color;
                letter-spacing: 0.25rem; /* 4px -> 0.25rem */
            }

            tbody {
                tr {
                    height: 4.0625rem; /* 65px -> 4.0625rem */
                    border-bottom: 0.0625rem dashed $gray-color; /*  1px -> 0.0625rem */
                }

                td {
                    padding: 0.3125rem; /* 減少內邊距以減小行高 (5px -> 0.3125rem) */
                    text-align: center;
                    vertical-align: middle; /* 垂直居中內容 */

                    .bussinessDate {
                        width: 100%;
                        height: 1.5625rem; /* 25px -> 1.5625rem */
                        border: none;
                        background-color: transparent;
                        font-size: 1.125rem; /* 18px -> 1.125rem */
                        letter-spacing: 0.0625rem; /* 1px -> 0.0625rem */
                        outline: none;
                    }

                    .bussinessTime {
                        width: 100%;
                        height: 1.5625rem; /* 25px -> 1.5625rem */
                        border: none;
                        background-color: transparent;
                        font-size: 1.125rem; /* 18px -> 1.125rem */
                        letter-spacing: 0.0625rem; /* 1px -> 0.0625rem */
                        cursor: pointer;
                    }

                    .durationTime {
                        width: 100%;
                        height: 1.5625rem; /* 25px -> 1.5625rem */
                        border: none;
                        background-color: transparent;
                        font-size: 1.125rem; /* 18px -> 1.125rem */
                        letter-spacing: 0.0625rem; /* 1px -> 0.0625rem */
                        cursor: pointer;
                    }

                    .trashButton {
                        border: none;
                        background-color: transparent;
                        font-size: 1.875rem; /* 30px -> 1.875rem */
                        cursor: pointer;
                    }
                }
            }
        }
    }

    .buttonArea {
        margin-top: 1.5625rem; /* 25px -> 1.5625rem */
        display: flex;
        justify-content: flex-end;

        .cancelButton {
            width: 15%; /* 保持不變 */
            border-radius: 0.625rem; /* 10px -> 0.625rem */
            border: 0.125rem solid $black-color; /* 2px -> 0.125rem */
            background-color: transparent;
            font-size: 1rem; /* 16px -> 1rem */
            letter-spacing: 0.3125rem; /* 5px -> 0.3125rem */
            padding: 0.625rem 1.25rem; /* 10px 20px -> 0.625rem 1.25rem */
            cursor: pointer;
        }

        .saveButton {
            width: 15%; /* 保持不變 */
            border-radius: 0.625rem; /* 10px -> 0.625rem */
            border: none;
            background-color: $black-color;
            color: $boxShadow;
            font-size: 1rem; /* 16px -> 1rem */
            letter-spacing: 0.3125rem; /* 5px -> 0.3125rem */
            margin-left: 2.5rem; /* 40px -> 2.5rem */
            padding: 0.625rem 1.25rem; /* 10px 20px -> 0.625rem 1.25rem */
            cursor: pointer;
        }
    }
}
</style>
