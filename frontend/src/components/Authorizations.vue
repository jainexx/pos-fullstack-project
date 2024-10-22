<script>
import Swal from "sweetalert2";

export default {
    data() {
        return {
            permissions: [],
            selectedPermission: null,
            showModal: false,
            showAddModal: false,
            newPermission: { name: "", managedAreas: [] },
            allAreas: ["活動", "桌位結帳", "點餐", "餐點狀態", "工作檯", "歷史紀錄", "銷售分析", "員工管理", "設定"],
            isAllSelected: false,
        };
    },
    mounted() {
        //抓資料
        this.fetchPermissions();
    },
    methods: {
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
        openEditModal(permission) {
            this.selectedPermission = JSON.parse(JSON.stringify(permission));
            this.isAllSelected = this.selectedPermission.managedAreas.length === this.allAreas.length; // 更新全選狀態
            this.showModal = true;
        },
        savePermission() {
            if (this.selectedPermission) {
                const requestData = {
                    authorizationId: this.selectedPermission.id,
                    authorizationName: this.selectedPermission.name,
                    authorizationItem: this.selectedPermission.managedAreas.join(","),
                };

                fetch("http://localhost:8080/api/authorization/update", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify(requestData),
                })
                    .then((response) => {
                        if (response.ok) {
                            return response.json();
                        } else {
                            throw new Error("更新權限時發生錯誤");
                        }
                    })
                    .then((data) => {
                        if (data.code == "200") {
                            Swal.fire({
                                title: data.message,
                                icon: "success",
                                confirmButtonText: "確定",
                            });
                            this.fetchPermissions(); // 重新抓取權限資料以更新顯示
                            this.resetNewPermission(); // 重置表單
                            this.$emit("refreshLeftBar"); // 發出事件
                        } else {
                            Swal.fire({
                                title: data.message,
                                icon: "error",
                                confirmButtonText: "確定",
                            });
                        }
                    })
                    .catch((error) => {
                        console.error("更新權限時發生錯誤:", error);
                        Swal.fire("錯誤", "更新權限時發生錯誤", "error");
                    });
            }
        },
        addNewPermission() {
            if (this.newPermission.name && this.newPermission.managedAreas.length > 0) {
                const requestData = {
                    authorizationName: this.newPermission.name,
                    authorizationItem: this.newPermission.managedAreas.join(","),
                };

                try {
                    fetch("http://localhost:8080/api/authorization/insert", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                        },
                        body: JSON.stringify(requestData),
                    })
                        .then((response) => {
                            if (response.ok) {
                                return response.json();
                            } else {
                                throw new Error("新增權限時發生錯誤");
                            }
                        })
                        .then((data) => {
                            this.fetchPermissions();

                            if (data.code == "200") {
                                Swal.fire({
                                    title: data.message,
                                    icon: "success",
                                    confirmButtonText: "確定",
                                });
                                this.resetNewPermission();
                            } else {
                                Swal.fire({
                                    title: data.message,
                                    icon: "error",
                                    confirmButtonText: "確定",
                                });
                            }
                        })
                        .catch((error) => {
                            console.error("新增權限時發生錯誤:", error);
                            Swal.fire("錯誤", "新增權限時發生錯誤", "error");
                        });
                } catch (error) {
                    console.error("捕獲的錯誤:", error);
                    Swal.fire("錯誤", "新增權限時發生錯誤", "error");
                }
            } else {
                Swal.fire("錯誤", "請輸入完整的權限名稱與管理項目", "error");
            }
        },
        toggleArea(area) {
            const index = this.newPermission.managedAreas.indexOf(area);
            if (index > -1) {
                this.newPermission.managedAreas.splice(index, 1);
            } else {
                this.newPermission.managedAreas.push(area);
            }
            this.updateSelectAllState();
        },
        toggleEditArea(area) {
            const index = this.selectedPermission.managedAreas.indexOf(area);
            if (index > -1) {
                this.selectedPermission.managedAreas.splice(index, 1);
            } else {
                this.selectedPermission.managedAreas.push(area);
            }
            this.updateSelectAllStateForEdit(); // 更新編輯視窗的全選狀態
        },
        async deletePermission(index) {
            const permissionToDelete = this.permissions[index];
            const permissionId = permissionToDelete.id;

            const result = await Swal.fire({
                title: "確認刪除?",
                text: "您確定要刪除這個權限嗎?",
                icon: "warning",
                showCancelButton: true,
                confirmButtonText: "刪除",
                cancelButtonText: "取消",
            });

            if (result.isConfirmed) {
                try {
                    const response = await fetch(`http://localhost:8080/api/authorization/delete/${permissionId}`, {
                        method: "DELETE",
                    })
                        .then((response) => {
                            if (response.ok) {
                                return response.json();
                            } else {
                                throw new Error("刪除權限時發生錯誤");
                            }
                        })
                        .then((data) => {
                            this.fetchPermissions();

                            if (data.code == "200") {
                                Swal.fire({
                                    title: data.message,
                                    icon: "success",
                                    confirmButtonText: "確定",
                                });
                                this.resetNewPermission();
                            } else {
                                Swal.fire({
                                    title: data.message,
                                    icon: "error",
                                    confirmButtonText: "確定",
                                });
                            }
                        });
                } catch (error) {
                    console.error("刪除權限時發生錯誤:", error);
                    Swal.fire({
                        title: "刪除權限時發生錯誤",
                        icon: "error",
                        confirmButtonText: "確定",
                    });
                }
            }
        },
        resetNewPermission() {
            this.newPermission = { name: "", managedAreas: [] };
            this.showAddModal = false;
            this.showModal = false;
            this.isAllSelected = false;
        },
        toggleSelectAll() {
            this.isAllSelected = !this.isAllSelected;
            if (this.isAllSelected) {
                this.newPermission.managedAreas = [...this.allAreas];
            } else {
                this.newPermission.managedAreas = [];
            }
        },
        toggleSelectAllForEdit() {
            this.isAllSelected = !this.isAllSelected; // 切換全選狀態
            if (this.isAllSelected) {
                this.selectedPermission.managedAreas = [...this.allAreas]; // 選擇所有項目
            } else {
                this.selectedPermission.managedAreas = []; // 清空所有選擇
            }
        },
        updateSelectAllState() {
            this.isAllSelected = this.newPermission.managedAreas.length === this.allAreas.length;
        },
        updateSelectAllStateForEdit() {
            this.isAllSelected = this.selectedPermission.managedAreas.length === this.allAreas.length; // 更新編輯視窗的全選狀態
        },
    },
};
</script>

<template>
    <div class="addMenu">
        <div class="permissionsArea">
            <h1>權限管理</h1>
            <table>
                <thead>
                    <tr>
                        <th>權限名稱</th>
                        <th>管理範圍</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="(permission, index) in permissions" :key="index">
                        <td>{{ permission.name }}</td>
                        <td>{{ permission.managedAreas.join(", ") }}</td>
                        <td>
                            <button @click="openEditModal(permission)">編輯</button>
                            <button @click="deletePermission(index)" style="margin-left: 10px">刪除</button>
                        </td>
                    </tr>
                </tbody>
            </table>

            <button @click="showAddModal = true">新增權限</button>
        </div>

        <!-- 新增權限的彈窗 -->
        <div v-if="showAddModal" class="modal">
            <div class="modal-content">
                <h2>新增權限</h2>
                <input v-model="newPermission.name" placeholder="權限名稱" />
                <table>
                    <thead>
                        <tr>
                            <th>選項</th>
                            <th>選擇頁面</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="checkbox-cell">
                                <label>
                                    <input type="checkbox" :checked="isAllSelected" @change="toggleSelectAll" />
                                </label>
                            </td>
                            <td class="name-cell">全選</td>
                        </tr>
                        <tr v-for="area in allAreas" :key="area">
                            <td class="checkbox-cell">
                                <label>
                                    <input type="checkbox" :value="area" :checked="newPermission.managedAreas.includes(area)" @change="toggleArea(area)" />
                                </label>
                            </td>
                            <td class="name-cell">
                                {{ area }}
                            </td>
                        </tr>
                    </tbody>
                </table>
                <button @click="addNewPermission">新增</button>
                <button @click="resetNewPermission">取消</button>
            </div>
        </div>

        <!-- 編輯權限的彈窗 -->
        <div v-if="showModal" class="modal">
            <div class="modal-content">
                <h2>編輯權限</h2>
                <input v-model="selectedPermission.name" placeholder="權限名稱" />
                <table>
                    <thead>
                        <tr>
                            <th>選項</th>
                            <th>選擇頁面</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="checkbox-cell">
                                <label>
                                    <input type="checkbox" :checked="isAllSelected" @change="toggleSelectAllForEdit" />
                                </label>
                            </td>
                            <td class="name-cell">全選</td>
                        </tr>
                        <tr v-for="area in allAreas" :key="area">
                            <td class="checkbox-cell">
                                <label>
                                    <input type="checkbox" :value="area" :checked="selectedPermission.managedAreas.includes(area)" @change="toggleEditArea(area)" />
                                </label>
                            </td>
                            <td class="name-cell">
                                {{ area }}
                            </td>
                        </tr>
                    </tbody>
                </table>
                <button @click="savePermission">儲存</button>
                <button @click="resetNewPermission">取消</button>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">
$divColor: #fff;
$addDiv: #343a3f;

.addMenu {
    width: 100%;
    height: 100%;
    font-size: 16px;
    /* 增加整體字體大小 */
}

.permissionsArea {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    background-color: $divColor;
    padding: 10px;
    border-radius: 10px;
    border: 1px solid rgba(grey, 0.5);
    border: 1px solid;
    box-shadow: -3px 3px 4px black;

    h1 {
        font-size: 28px;
        /* 增加標題字體大小 */
        font-family: "Noto Sans TC", sans-serif;
        margin-bottom: 15px;
    }

    table {
        width: 100%;
        border-collapse: collapse;

        th,
        td {
            border: 1px solid #ccc;
            padding: 10px;
            /* 增加內邊距 */
            text-align: center;
            font-size: 16px;
            /* 增加表格字體大小 */
        }

        th {
            background-color: #f5f5f5;
        }
    }

    button {
        background-color: $addDiv;
        color: white;
        border-radius: 5px;
        cursor: pointer;
        padding: 10px 15px;
        /* 增加內邊距 */
        margin-top: 15px;
        font-size: 16px;
        /* 增加按鈕字體大小 */

        &:hover {
            background-color: darken($addDiv, 10%);
        }
    }
}

.modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 2;

    .modal-content {
        background-color: #fff;
        padding: 20px;
        border-radius: 8px;
        text-align: center;
        width: 500px;
        /* 調整彈窗寬度 */

        h2 {
            font-size: 24px;
            /* 增加彈窗標題字體大小 */
        }

        input {
            margin-bottom: 10px;
            padding: 5px;
            width: 80%;
            font-size: 16px;
            /* 增加輸入框字體大小 */
        }

        table {
            width: 100%;
            border-collapse: collapse;

            th,
            td {
                border: 1px solid #ccc;
                padding: 10px;
                /* 增加內邊距 */
                text-align: center;
                font-size: 16px;
                /* 增加表格字體大小 */
            }

            th {
                background-color: #f5f5f5;
            }
        }

        button {
            background-color: $addDiv;
            color: white;
            border-radius: 5px;
            cursor: pointer;
            padding: 10px 15px;
            /* 增加內邊距 */
            margin: 5px;
            font-size: 16px;
            /* 增加按鈕字體大小 */

            &:hover {
                background-color: darken($addDiv, 10%);
            }
        }
    }
}
</style>
