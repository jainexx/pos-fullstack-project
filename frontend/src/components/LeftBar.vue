<script>
import { RouterLink } from "vue-router";
import Swal from "sweetalert2";

import { computed } from "vue";
import { useFontStore } from "@/stores/fontStores";
export default {
    data() {
        return {
            timeCode: "",
            userName: "",
            role: "", // 員工的話顯示權限
            permissions: [],
            managedAreas: [],
        };
    },
    methods: {
        updateTime() {
            //更新時間方法
            const now = new Date();
            let hours = now.getHours();
            const minutes = String(now.getMinutes()).padStart(2, "0");
            const ampm = hours >= 12 ? "PM" : "AM"; //判斷AM PM

            // 轉12小時制
            hours = hours % 12;
            hours = hours ? hours : 12; //小時為0時，顯示為12
            hours = String(hours).padStart(2, "0");

            this.timeCode = `${hours}:${minutes} ${ampm}`;

            const options = { year: "numeric", month: "short", day: "numeric" };
            this.dateCode = now.toLocaleDateString("en-US", options);
        },
        goSetting() {
            this.$router.push("./setting");
        },
        goOperation() {
            this.$router.push("./operation");
        },
        goOrder() {
            this.$router.push("./order");
        },
        goStatus() {
            this.$router.push("./orderStatus");
        },
        goTCheckout() {
            this.$router.push("./tableAndCheckout");
        },
        goEvent() {
            this.$router.push("./event");
        },
        goWorkstation() {
            this.$router.push("./workstation");
        },
        goHistory() {
            this.$router.push("./history");
        },
        goStaffInfo() {
            this.$router.push("./staffInfo");
        },
        goUserInfo() {
            this.$router.push("./userInfo");
        },
        getUserData() {
            //抓會員資料
            const memberId = sessionStorage.getItem("memberId"); //登入的時候已經把memberId寫在session了

            if (memberId) {
                // 使用 fetch 發送 GET 請求
                fetch(`http://localhost:8080/api/member/${memberId}`, {
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
                        // 客人的話回傳等級
                        this.userName = data.member.name;
                        this.role = "等級" + data.member.memberLevel;
                    })
                    .catch((error) => {
                        console.error("取得使用者資料失敗:", error);
                    });
            } else {
                console.error("Session 中的 memberId 不存在，無法取得使用者資料");
            }
        },
        getStaffData() {
            // 抓員工資料
            const staffNumber = sessionStorage.getItem("staffNumber"); // 登入的時候已經把 staffNumber 寫在 session 了

            if (staffNumber) {
                fetch(`http://localhost:8080/api/staff/${staffNumber}`, {
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
                        if (data && data.staff) {
                            this.userName = data.staff.name;

                            if (data.staff.firstLogin) {
                                Swal.fire({
                                    title: "第一次登入請修改密碼",
                                    text: "",
                                    icon: "warning",
                                    confirmButtonText: "確定",
                                }).then(() => {
                                    fetch(`http://localhost:8080/api/staff/updateFirstLogin/${staffNumber}`, {
                                        method: "GET",
                                        headers: {
                                            "Content-Type": "application/json",
                                        },
                                    });
                                });

                                this.goUserInfo();
                            }

                            // 找到相對應的權限物件
                            const foundPermission = this.permissions.find((permission) => permission.id == data.staff.authorization);

                            if (foundPermission) {
                                this.managedAreas = foundPermission.managedAreas;
                                this.role = "權限: " + foundPermission.name; // 將角色設置為權限名稱
                            } else {
                                console.log("找不到相應的權限");
                                this.role = "無權限資訊"; // 若找不到權限，給予一個預設值
                            }
                        } else {
                            console.error("回傳的資料格式不正確或沒有 staff 資料");
                        }
                    })
                    .catch((error) => {
                        console.error("取得員工資料失敗:", error);
                    });
            } else {
                console.error("Session 中的 staffNumber 不存在，無法取得員工資料");
            }
        },
        logout() {
            sessionStorage.clear(); // 清除所有 sessionStorage 資料
            this.$router.push("/"); // 跳轉至首頁或登錄頁面
        },
        async fetchPermissions() {
            try {
                const response = await fetch("http://localhost:8080/api/authorization/all");
                const data = await response.json();

                this.permissions = data.map((item) => ({
                    name: item.authorizationName,
                    managedAreas: item.authorizationItem.split(","),
                    id: item.authorizationId,
                }));
            } catch (error) {
                console.error("無法獲取權限資料:", error);
                Swal.fire("錯誤", "無法獲取權限資料", "error");
            }
        },
        refresh() {
            this.fetchPermissions().then(() => {
                const memberId = sessionStorage.getItem("memberId");
                const staffNumber = sessionStorage.getItem("staffNumber");

                if (memberId) {
                    //抓使用者資料
                    this.getUserData();
                } else if (staffNumber) {
                    //抓員工資料
                    this.getStaffData();
                }
            });
        },
    },
    mounted() {
        this.fetchPermissions().then(() => {
            const memberId = sessionStorage.getItem("memberId");
            const staffNumber = sessionStorage.getItem("staffNumber");

            if (memberId) {
                //抓使用者資料
                this.getUserData();
            } else if (staffNumber) {
                //抓員工資料
                this.getStaffData();
            }
        });

        // 初始化時間
        this.updateTime();

        this.timeInterval = setInterval(() => {
            this.updateTime();
        }, 60000);
    },
    beforeDestroy() {
        // 清除計時器
        clearInterval(this.timeInterval);
    },
    setup() {
        const fontStore = useFontStore();
        const currentFont = computed(() => fontStore.fonts[fontStore.currentFontIndex]);
        const changeFont = () => {
            fontStore.nextFont();
        };
        return {
            currentFont,
            changeFont,
        };
    },
};
</script>

<template>
    <div class="lefter">
        <div class="timeCode" @click="changeFont">
            <div class="timeStyle" :style="{ fontFamily: currentFont }">{{ timeCode }}</div>
            <div class="timeStyle" :style="{ fontFamily: currentFont }">{{ dateCode }}</div>
        </div>
        <div class="control">
            <div class="event" @click="goEvent()" :class="{ selected: this.$route.path == '/event' }" v-if="managedAreas.includes('活動')">
                <i class="fa-regular fa-calendar-check"></i>
                <h3>活動</h3>
            </div>
            <div class="tableChechout" @click="goTCheckout()" :class="{ selected: this.$route.path == '/tableAndCheckout' }" v-if="managedAreas.includes('桌位結帳')">
                <div>
                    <span class="material-symbols-outlined"> table_restaurant </span>
                    <span class="material-symbols-outlined"> request_quote </span>
                </div>
                <h3>桌位結帳</h3>
            </div>
            <div class="order" @click="goOrder()" :class="{ selected: this.$route.path == '/order' }" v-if="managedAreas.includes('點餐')">
                <i class="fa-solid fa-utensils"></i>
                <h3>點餐</h3>
            </div>
            <div class="orderStatus" @click="goStatus()" :class="{ selected: this.$route.path == '/orderStatus' }" v-if="managedAreas.includes('餐點狀態')">
                <i class="fa-solid fa-list-check"></i>
                <h3>餐點狀態</h3>
            </div>
            <div class="workstation" @click="goWorkstation()" :class="{ selected: this.$route.path == '/workstation' }" v-if="managedAreas.includes('工作檯')">
                <i class="fa-solid fa-fire-burner"></i>
                <h3>工作檯</h3>
            </div>
            <div class="history" @click="goHistory()" :class="{ selected: this.$route.path == '/history' }" v-if="managedAreas.includes('歷史紀錄')">
                <i class="fa-solid fa-clock-rotate-left"></i>
                <h3>歷史紀錄</h3>
            </div>
            <div class="operation" @click="goOperation()" :class="{ selected: this.$route.path == '/operation' }" v-if="managedAreas.includes('銷售分析')">
                <i class="fa-solid fa-chart-simple"></i>
                <h3>銷售分析</h3>
            </div>
            <div class="staffInfo" @click="goStaffInfo()" :class="{ selected: this.$route.path == '/staffInfo' }" v-if="managedAreas.includes('員工管理')">
                <i class="fa-solid fa-user"></i>
                <h3>員工管理</h3>
            </div>
            <div class="setting" @click="goSetting()" :class="{ selected: this.$route.path == '/setting' }" v-if="managedAreas.includes('設定')">
                <i class="fa-solid fa-gear"></i>
                <h3>設定</h3>
            </div>
        </div>
        <div class="userAndlogoutArea">
            <div class="Permissions" @click="goUserInfo()" :class="{ selected: this.$route.path == '/userInfo' }">
                <h3>{{ this.userName }}</h3>
                <p>{{ this.role }}</p>
            </div>
            <RouterLink to="/" class="logout-button" @click="logout">登出</RouterLink>
        </div>
    </div>
</template>

<style scoped lang="scss">
@import url("https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@100..900&display=swap");
$boxShadow: #2d2d2d;
$selectedColor: #ffc90e;
$background-color: #ffffff;
$black-color: #1e1e1e;
$gray-color: #dde1e6;

.lefter {
    width: 90%;
    height: 100%;
    background-color: $background-color;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 0.625rem;
    border-radius: 10px;
    border: 1px solid;
    box-shadow: -3px 3px 4px black;

    .timeCode {
        width: 100%;
        height: 8%;
        border-bottom: 0.0625rem solid $gray-color; // 原本的 1px 轉換為 0.0625rem
        display: flex;
        justify-content: center;
        align-items: center;
        flex-direction: column;
        cursor: pointer;

        .timeStyle {
            margin: 0.025rem auto;
            font-size: 1.125rem;
        }
    }

    .control {
        width: 80%;
        height: 90%;
        display: flex;
        justify-content: start;
        align-items: center;
        flex-direction: column;
        color: $black-color;
        margin-top: 6%;
        gap: 1.5%;

        // 新增通用按鈕樣式
        .button-common {
            width: 90%;
            height: 4.6875rem; // 原本的 75px 轉換為 4.6875rem
            border-radius: 0.625rem; // 原本的 10px 轉換為 0.625rem
            box-shadow: -0.175rem 0.2125rem 0.1625rem $boxShadow; // 原本的 -6px 5px 1px $boxShadow 轉換為 rem
            display: flex;
            flex-direction: column;
            justify-content: space-evenly;
            align-items: center;
            font-family: "Noto Sans TC", sans-serif;
            cursor: pointer;
            padding: 6% 0; // 原本的 5px 轉換為 0.3125rem
            border: 1px solid gray;

            i,
            .material-symbols-outlined {
                max-height: 50%; // 設定最大高度為 50%
                height: auto; // 讓高度自動
            }

            h3 {
                font-size: 1rem; // 原本的 16px 轉換為 1rem
                letter-spacing: 0.125rem; // 原本的 2px 轉換為 0.125rem
            }
        }

        // 為每個按鈕應用通用樣式
        .setting,
        .operation,
        .order,
        .orderStatus,
        .tableChechout,
        .event,
        .workstation,
        .history,
        .staffInfo {
            height: 10%;
            @extend .button-common;
        }

        .selected {
            background-color: $selectedColor;
            box-shadow: none;
        }
    }

    .userAndlogoutArea {
        width: 100%;
        height: 7.5rem; // 原本的 120px 轉換為 7.5rem
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-direction: column;
        color: $black-color;

        .Permissions {
            width: 97%;
            height: 5.3125rem; // 原本的 85px 轉換為 5.3125rem
            border-bottom: 0.0625rem solid $gray-color; // 原本的 1px 轉換為 0.0625rem
            display: flex;
            flex-direction: column;
            justify-content: space-evenly;
            align-items: center;
            font-family: "Noto Sans TC", sans-serif;
            cursor: pointer;
            padding: 0.3125rem; // 原本的 5px 轉換為 0.3125rem

            i,
            .material-symbols-outlined {
                max-height: 50%; // 設定最大高度為 50%
                height: auto; // 讓高度自動
            }

            h3 {
                font-size: 1rem; // 原本的 16px 轉換為 1rem
                letter-spacing: 0.125rem; // 原本的 2px 轉換為 0.125rem
            }
        }

        .logout-button {
            border: none;
            text-decoration: none;
            color: $black-color;
            font-weight: bold;
            letter-spacing: 0.25rem; // 原本的 4px 轉換為 0.25rem
            font-size: 1.25rem; // 原本的 20px 轉換為 1.25rem
            padding: 0.25rem; // 原本的 10px 轉換為 0.625rem
            cursor: pointer;
        }
    }

    .disabled {
        background-color: $gray-color; // 按鈕變成灰色
        color: #ccc; // 文字變成淺灰色
        pointer-events: none; // 禁止點擊事件
        cursor: not-allowed; // 顯示禁用指標
    }
}
</style>
