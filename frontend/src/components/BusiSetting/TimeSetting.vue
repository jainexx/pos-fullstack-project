<script>
import axios from "axios";
import Swal from "sweetalert2";

export default {
    data() {
        return {
            businessHours: [
                // 存放多個營業時間段
                { openingTime: "", closingTime: "" },
            ],
            diningDuration: "", // 用餐時間
            timeSlots: [], // 初始化 timeSlots
            weekDays: [
                { name: "星期一", value: "Monday", selected: false },
                { name: "星期二", value: "Tuesday", selected: false },
                { name: "星期三", value: "Wednesday", selected: false },
                { name: "星期四", value: "Thursday", selected: false },
                { name: "星期五", value: "Friday", selected: false },
                { name: "星期六", value: "Saturday", selected: false },
                { name: "星期日", value: "Sunday", selected: false },
            ],
            showAddButton: true, // 用來控制按鈕顯示狀態的布林值
        };
    },

    watch: {
        businessHours: {
            handler(newValue) {
                const hasValidHours = newValue.some((hour) => hour.openingTime && hour.closingTime);
                if (hasValidHours && this.diningDuration) {
                    this.fetchTimeSlots();
                }
            },
            deep: true, // 深度監聽
        },
        diningDuration(newValue) {
            if (newValue > 0 && this.businessHours.some((hour) => hour.openingTime && hour.closingTime)) {
                this.fetchTimeSlots();
            }
        },
    },

    methods: {
        // 新增一個營業時間區段
        addBusinessHour() {
            this.businessHours.push({ openingTime: "", closingTime: "" });
            this.showAddButton = false; // 隱藏新增按鈕
        },

        // 保存營業時間及選定的營業日
        async saveBusinessHoursAndDays() {
            // 確保所有時間段的營業時間和用餐時間都已設置
            for (let hour of this.businessHours) {
                if (!hour.openingTime || !hour.closingTime || !this.diningDuration) {
                    Swal.fire("錯誤", "請先填寫所有必要的時間資訊", "error");
                    return;
                }

                // 檢查營業開始時間不能晚於結束時間
                if (hour.openingTime >= hour.closingTime) {
                    Swal.fire("錯誤", "營業開始時間不能晚於結束時間", "error");
                    return;
                }
            }

            // 確保至少選擇了一個營業日
            const selectedDays = this.weekDays.filter((day) => day.selected).map((day) => day.name);
            if (selectedDays.length === 0) {
                Swal.fire("錯誤", "請至少選擇一個營業日", "error");
                return;
            }

            // 構建要傳送到後端的資料
            const operatingHoursReqList = [];
            for (let hour of this.businessHours) {
                selectedDays.forEach((day) => {
                    operatingHoursReqList.push({
                        dayOfWeek: day,
                        openingTime: hour.openingTime,
                        closingTime: hour.closingTime,
                        diningDuration: this.diningDuration,
                    });
                });
            }

            try {
                // 發送 POST 請求到後端 API
                const response = await axios.post("http://localhost:8080/operatingHours/saveOperatingHours", operatingHoursReqList);

                // 檢查返回的結果
                if (response.data.every((res) => res.code === 200)) {
                    Swal.fire("成功", "營業時間已成功保存", "success");
                    // 清空所有欄位
                    this.businessHours.forEach((hour) => {
                        hour.openingTime = "";
                        hour.closingTime = "";
                    });
                    this.diningDuration = ""; // 清空用餐時長
                    this.timeSlots = []; // 重置時間段
                    this.weekDays.forEach((day) => {
                        day.selected = false; // 清空選擇的營業日
                    });
                } else {
                    Swal.fire("錯誤", "部分營業時間保存失敗，請檢查輸入", "error");
                }
            } catch (error) {
                console.error("Error saving business hours:", error);
                Swal.fire("錯誤", "保存營業時間時發生錯誤", "error");
            }
        },

        // 格式化訂位時間段的時間
        formatTime(time) {
            return time.substring(0, 5); // 取小時和分鐘
        },

        // 加載訂位時間段
        async fetchTimeSlots() {
            this.timeSlots = []; // 重置時間段
            for (let hour of this.businessHours) {
                if (hour.openingTime && hour.closingTime) {
                    try {
                        const response = await axios.get("http://localhost:8080/operatingHours/calculateAvailableStartTimes", {
                            params: {
                                openingTime: hour.openingTime,
                                closingTime: hour.closingTime,
                                diningDuration: this.diningDuration,
                            },
                        });

                        // 提取並格式化開始時間
                        const formattedSlots = response.data.map((slot) => this.formatTime(slot));

                        // 合併計算出的時間段
                        this.timeSlots = this.timeSlots.concat(formattedSlots);
                    } catch (error) {
                        console.error("Error fetching time slots:", error);
                        Swal.fire("錯誤", "獲取時間段時發生錯誤", "error");
                    }
                }
            }
            console.log("Fetched time slots:", this.timeSlots); // 調試輸出
        },

        // 重置表單
        resetForm() {
            // 重置營業時間
            this.businessHours = [{ openingTime: "", closingTime: "" }]; // 確保只有一個時間段
            this.diningDuration = ""; // 清空用餐時間
            // 也可以重置選擇的日期
            this.weekDays.forEach((day) => {
                day.selected = false; // 取消選擇所有星期
            });
            this.showAddButton = true; // 隱藏新增按鈕
        },
    },
};
</script>

<template>
    <div class="reserveSettingArea">
        <!-- 顯示訂位管理標題 -->
        <h2 class="reserveTitle">訂位時段管理</h2>

        <!-- 顯示訂位管理注意事項 -->
        <p class="reminderText">請依照步驟依序設定</p>

        <!-- 顯示訂位管理表格區域 -->
        <div class="reserveArea">
            <!-- 營業時間設定 -->
            <div class="businessHoursSection">
                <div class="sectionHeader">
                    <div class="sectionNumber">1</div>

                    <div class="sectionTitle">營業時間設定</div>
                </div>

                <!-- 動態生成的營業時間區段 -->
                <div class="timeSelectContainer">
                    <div v-for="(hour, index) in businessHours" :key="index" class="timeSelectArea">
                        <div class="beginTimeSelectArea">
                            <label class="beginTimeLabel" for="openingTime">開始時間</label>
                            <input class="beginTimeInput" type="time" v-model="hour.openingTime" />
                        </div>

                        <div class="endTimeSelectArea">
                            <label class="endTimeLabel" for="closingTime">結束時間</label>
                            <input class="endTimeInput" type="time" v-model="hour.closingTime" />
                        </div>
                    </div>
                </div>

                <!-- 新增營業時間按鈕 -->
                <button v-if="showAddButton" @click="addBusinessHour" class="addButton">
                    <i class="fa-solid fa-plus"></i>
                </button>
            </div>

            <!-- 用餐時間設定 -->
            <div class="diningDurationSection">
                <div class="sectionHeader">
                    <div class="sectionNumber">2</div>

                    <div class="sectionTitle">用餐時間設定</div>
                </div>

                <div class="diningDurationArea">
                    <input class="diningDurationInput" type="number" v-model="diningDuration" placeholder="輸入客人用餐時間" min="1" />
                    <span class="diningDurationLabel">分鐘</span>
                </div>
            </div>

            <!-- 預設訂位時段設定 -->
            <div class="timeSlotSection">
                <div class="sectionHeader">
                    <div class="sectionNumber">3</div>
                    <div class="sectionTitle">預覽訂位時間段</div>
                </div>

                <div class="timeSlotArea">
                    <p class="description">根據步驟 1 和步驟 2 自動計算</p>

                    <div class="timeSlotBox">
                        <div class="timeSlot" v-for="(time, index) in timeSlots" :key="index">
                            {{ time }}
                        </div>
                    </div>
                </div>
            </div>

            <!-- 選擇營業日期 -->
            <div class="daySelectSection">
                <div class="sectionHeader">
                    <div class="sectionNumber">4</div>
                    <div class="sectionTitle">選擇營業日期</div>
                </div>

                <div class="daySelectArea">
                    <label v-for="(day, index) in weekDays" :key="index" class="daySelectLabel">
                        <input type="checkbox" v-model="day.selected" />
                        {{ day.name }}
                    </label>
                </div>
            </div>
        </div>

        <!-- 取消、儲存操作按鈕區域 -->
        <div class="buttonArea">
            <button class="cancelButton" @click="resetForm">取消</button>
            <button class="saveButton" @click="saveBusinessHoursAndDays">儲存</button>
        </div>
    </div>
</template>

<style scoped lang="scss">
$background-color: #ffffff;
$black-color: #1e1e1e;
$gray-color: #dde1e6;
$boxShadow: #f2f4f8;

.reserveSettingArea {
    width: 80%;
    height: 100%;
    border-radius: 0.625rem; // 10px -> 0.625rem
    background-color: $background-color;
    padding: 1.25rem 2.1875rem; // 20px 35px -> 1.25rem 2.1875rem
    position: absolute;
    top: 0%;
    right: 0%;
    border: 1px solid rgba(grey, 0.5);
    border: 1px solid;
    box-shadow: -3px 3px 4px black;

    .reserveTitle {
        font-size: 1.5625rem; // 25px -> 1.5625rem
        letter-spacing: 0.25rem; // 4px -> 0.25rem
        margin-bottom: 0.625rem; // 10px -> 0.625rem
    }

    .reminderText {
        margin-bottom: 1.25rem; // 20px -> 1.25rem
        color: $black-color;
        opacity: 0.6;
    }

    .reserveArea {
        width: 100%;
        height: 85%;
        border: 0.125rem solid $gray-color; // 2px -> 0.125rem
        padding: 0.9375rem 0.625rem; // 15px 10px -> 0.9375rem 0.625rem
        max-height: 37.625rem; // 650px -> 40.625rem
        overflow-y: auto;

        .businessHoursSection {
            width: 75%;
            height: 14.6875rem; // 235px -> 14.6875rem
            border-radius: 0.625rem; // 10px -> 0.625rem
            border: 0.125rem solid $gray-color; // 2px -> 0.125rem
            padding: 0.9375rem; // 15px -> 0.9375rem
            margin: auto;
            margin-bottom: 1.25rem; // 20px -> 1.25rem
            position: relative;

            .sectionHeader {
                display: flex;
                align-items: center;
                margin-bottom: 1rem; // 15px -> 1rem
                padding-bottom: 0.625rem; // 10px -> 0.625rem
                border-bottom: 0.125rem solid $gray-color; // 2px -> 0.125rem

                .sectionNumber {
                    width: 3.125rem; // 50px -> 3.125rem
                    height: 2.8125rem; // 45px -> 2.8125rem
                    background-color: $gray-color;
                    border-radius: 0.3125rem; // 5px -> 0.3125rem
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 1.25rem; // 20px -> 1.25rem
                    font-weight: bold;
                    color: $black-color;
                }

                .sectionTitle {
                    font-size: 1.4375rem; // 23px -> 1.4375rem
                    font-weight: bold;
                    letter-spacing: 0.1875rem; // 3px -> 0.1875rem
                    margin-left: 0.625rem; // 10px -> 0.625rem
                    color: $black-color;
                }
            }

            .timeSelectContainer {
                max-width: 100%;
                overflow-x: auto;
                display: flex;
                justify-content: space-between;
                white-space: nowrap; /* 防止內容換行，強制水平排列 */

                .timeSelectArea {
                    width: 49%;
                    height: 8.125rem; // 130px -> 8.125rem
                    border-radius: 0.625rem; // 10px -> 0.625rem
                    background-color: $boxShadow;
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    padding-top: 0.625rem; // 10px -> 0.625rem

                    .beginTimeSelectArea {
                        width: 100%;
                        height: 3.625rem; // 58px -> 3.625rem
                        display: flex;
                        justify-content: space-evenly;
                        align-items: center;

                        .beginTimeLabel {
                            font-size: 1.0625rem; // 17px -> 1.0625rem
                            color: $black-color;
                        }

                        .beginTimeInput {
                            width: 35%; // 35% 寬度
                            border: 0.0625rem solid $gray-color; // 1px -> 0.0625rem
                            border-radius: 0.625rem; // 10px -> 0.625rem
                            background-color: $background-color;
                            outline: none;
                            font-size: 0.8125rem; // 13px -> 0.8125rem
                            padding: 0.625rem; // 10px -> 0.625rem
                            color: $black-color;
                        }
                    }

                    .endTimeSelectArea {
                        width: 100%;
                        height: 3.625rem; // 58px -> 3.625rem
                        display: flex;
                        justify-content: space-evenly;
                        align-items: center;

                        .endTimeLabel {
                            font-size: 1.0625rem; // 17px -> 1.0625rem
                            color: $black-color;
                        }

                        .endTimeInput {
                            width: 35%; // 35% 寬度
                            border: 0.0625rem solid $gray-color; // 1px -> 0.0625rem
                            border-radius: 0.625rem; // 10px -> 0.625rem
                            background-color: $background-color;
                            outline: none;
                            font-size: 0.8125rem; // 13px -> 0.8125rem
                            padding: 0.625rem; // 10px -> 0.625rem
                            color: $black-color;
                        }
                    }
                }
            }

            .addButton {
                border: none;
                border-radius: 50%;
                background-color: $black-color;
                color: $background-color;
                padding: 0.625rem 0.75rem; // 10px 12px -> 0.625rem 0.75rem
                cursor: pointer;
                position: absolute;
                top: 60%;
                right: 32%;

                i {
                    font-size: 0.9375rem; // 15px -> 0.9375rem
                }
            }
        }

        .diningDurationSection {
            width: 75%;
            height: 12.5rem; // 200px -> 12.5rem
            border-radius: 0.625rem; // 10px -> 0.625rem
            border: 0.125rem solid $gray-color; // 2px -> 0.125rem
            padding: 0.9375rem; // 15px -> 0.9375rem
            margin: auto;
            margin-bottom: 1.25rem; // 20px -> 1.25rem
            position: relative;

            .sectionHeader {
                display: flex;
                align-items: center;
                margin-bottom: 0.9375rem; // 15px -> 0.9375rem
                padding-bottom: 0.625rem; // 10px -> 0.625rem
                border-bottom: 0.125rem solid $gray-color; // 2px -> 0.125rem

                .sectionNumber {
                    width: 3.125rem; // 50px -> 3.125rem
                    height: 2.8125rem; // 45px -> 2.8125rem
                    background-color: $gray-color;
                    border-radius: 0.3125rem; // 5px -> 0.3125rem
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 1.25rem; // 20px -> 1.25rem
                    font-weight: bold;
                    color: $black-color;
                }

                .sectionTitle {
                    font-size: 1.4375rem; // 23px -> 1.4375rem
                    font-weight: bold;
                    letter-spacing: 0.1875rem; // 3px -> 0.1875rem
                    margin-left: 0.625rem; // 10px -> 0.625rem
                    color: $black-color;
                }
            }

            .diningDurationArea {
                height: 5.9375rem; // 95px -> 5.9375rem
                border-radius: 0.625rem; // 10px -> 0.625rem
                background-color: $boxShadow;
                display: flex;
                align-items: center;
                margin-top: 0.9375rem; // 15px -> 0.9375rem
                padding-top: 0.625rem; // 10px -> 0.625rem;

                .diningDurationInput {
                    width: 30%;
                    border: 0.125rem solid $gray-color; // 2px -> 0.125rem
                    border-radius: 0.625rem; // 10px -> 0.625rem
                    background-color: transparent;
                    outline: none;
                    font-size: 0.9375rem; // 15px -> 0.9375rem
                    padding: 0.625rem; // 10px -> 0.625rem
                    color: $black-color;
                    margin-left: 3.75rem; // 60px -> 3.75rem
                }

                .diningDurationLabel {
                    font-size: 1.0625rem; // 17px -> 1.0625rem
                    color: $black-color;
                    margin-left: 1.25rem; // 20px -> 1.25rem
                }
            }
        }

        .timeSlotSection {
            width: 75%;
            height: 13.4375rem; // 215px -> 13.4375rem
            border-radius: 0.625rem; // 10px -> 0.625rem
            border: 0.125rem solid $gray-color; // 2px -> 0.125rem
            padding: 0.9375rem; // 15px -> 0.9375rem
            margin: auto;
            margin-bottom: 1.25rem; // 20px -> 1.25rem
            position: relative;

            .sectionHeader {
                display: flex;
                align-items: center;
                margin-bottom: 0.9375rem; // 15px -> 0.9375rem
                padding-bottom: 0.625rem; // 10px -> 0.625rem
                border-bottom: 0.125rem solid $gray-color; // 2px -> 0.125rem

                .sectionNumber {
                    width: 3.125rem; // 50px -> 3.125rem
                    height: 2.8125rem; // 45px -> 2.8125rem
                    background-color: $gray-color;
                    border-radius: 0.3125rem; // 5px -> 0.3125rem
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 1.25rem; // 20px -> 1.25rem
                    font-weight: bold;
                    color: $black-color;
                }

                .sectionTitle {
                    font-size: 1.4375rem; // 23px -> 1.4375rem
                    font-weight: bold;
                    letter-spacing: 0.1875rem; // 3px -> 0.1875rem
                    margin-left: 0.625rem; // 10px -> 0.625rem
                    color: $black-color;
                }
            }

            .timeSlotArea {
                max-width: 776px;
                height: 6.875rem; // 110px -> 6.875rem
                overflow-x: scroll; // 橫向滾動
                border-radius: 0.625rem; // 10px -> 0.625rem
                background-color: $boxShadow;
                display: flex;
                flex-direction: column;
                justify-content: space-evenly;
                margin-top: 0.9375rem; // 15px -> 0.9375rem
                padding-top: 0.625rem; // 10px -> 0.625rem

                .description {
                    font-size: 1rem; // 16px -> 1rem
                    color: $black-color;
                    opacity: 0.6;
                    margin-left: 3.75rem; // 60px -> 3.75rem
                }

                .timeSlotBox {
                    display: flex;
                    justify-content: space-between;
                    padding: 0.9375rem; // 15px -> 0.9375rem
                    border-radius: 0.5rem; // 8px -> 0.5rem

                    .timeSlot {
                        flex: 1;
                        text-align: center;
                        padding: 0.8125rem 2.5rem; // 13px ->0.8125rem 40px ->2.5rem
                        font-size: 1rem; // 16px -> 1rem
                        background-color: $background-color;
                        border: 0.0625rem solid $gray-color; // 1px -> 0.0625rem
                        border-radius: 0.5rem; // 8px -> 0.5rem
                        margin: 0 0.3125rem; // 5px -> 0.3125rem
                        color: $black-color;
                        font-weight: bold;
                        cursor: pointer;
                    }
                }
            }
        }

        .daySelectSection {
            width: 75%;
            height: 12.5rem; // 200px -> 12.5rem
            border-radius: 0.625rem; // 10px -> 0.625rem
            border: 0.125rem solid $gray-color; // 2px -> 0.125rem
            padding: 0.9375rem; // 15px -> 0.9375rem
            margin: auto;
            margin-bottom: 1.25rem; // 20px -> 1.25rem
            position: relative;

            .sectionHeader {
                display: flex;
                align-items: center;
                margin-bottom: 0.9375rem; // 15px -> 0.9375rem
                padding-bottom: 0.625rem; // 10px -> 0.625rem
                border-bottom: 0.125rem solid $gray-color; // 2px -> 0.125rem

                .sectionNumber {
                    width: 3.125rem; // 50px -> 3.125rem
                    height: 2.8125rem; // 45px -> 2.8125rem
                    background-color: $gray-color;
                    border-radius: 0.3125rem; // 5px -> 0.3125rem
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 1.25rem; // 20px -> 1.25rem
                    font-weight: bold;
                    color: $black-color;
                }

                .sectionTitle {
                    font-size: 1.4375rem; // 23px -> 1.4375rem
                    font-weight: bold;
                    letter-spacing: 0.1875rem; // 3px -> 0.1875rem
                    margin-left: 0.625rem; // 10px -> 0
                    color: $black-color;
                }
            }

            .daySelectArea {
                height: 5.9375rem; // 95px -> 5.9375rem
                border-radius: 0.625rem; // 10px -> 0.625rem
                background-color: $boxShadow;
                display: flex;
                justify-content: space-between;
                padding: 0.9375rem; // 15px -> 0.9375rem

                .daySelectLabel {
                    font-size: 1.125rem; // 18px -> 1.125rem
                    display: flex;
                    align-items: center;
                    cursor: pointer;

                    input {
                        cursor: pointer;
                        margin-right: 0.5rem; // 8px -> 0.5rem
                    }
                }
            }
        }
    }

    .buttonArea {
        margin-top: 1.5625rem; // 25px -> 1.5625rem
        display: flex;
        justify-content: flex-end;

        .cancelButton {
            width: 15%;
            border-radius: 0.625rem; // 10px -> 0.625rem
            border: 0.125rem solid $black-color; // 2px -> 0.125rem
            background-color: transparent;
            font-size: 1rem; // 16px -> 1rem
            letter-spacing: 0.3125rem; // 5px -> 0.3125rem
            padding: 0.625rem 1.25rem; // 10px 20px -> 0.625rem 1.25rem
            cursor: pointer;
        }

        .saveButton {
            width: 15%;
            border-radius: 0.625rem; // 10px -> 0.625rem
            border: none;
            background-color: $black-color;
            color: $boxShadow;
            font-size: 1rem; // 16px -> 1rem
            letter-spacing: 0.3125rem; // 5px -> 0.3125rem
            margin-left: 2.5rem; // 40px -> 2.5rem
            padding: 0.625rem 1.25rem; // 10px 20px -> 0.625rem 1.25rem
            cursor: pointer;
        }
    }
}
</style>
