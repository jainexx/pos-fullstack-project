<script>
import axios from 'axios';
import Swal from 'sweetalert2';

export default {
    data () {
        return {
            tableList: [], // 桌位列表，從後端獲取資料
            newTable: { table_number: '', table_capacity: '', table_status: '可使用' }, // 新增桌號的初始值
            showNewTableRow: false, // 控制新增桌號行是否顯示
        };
    },

    mounted() {
        this.loadInitialTableData();
    },

    methods: {
        // 加載初始的桌位數據
        async loadInitialTableData () {
            try {
                const response = await axios.get('http://localhost:8080/tableManagement/getAllTables');
                this.tableList = response.data.map(table => ({
                    table_number: table.tableNumber,
                    table_capacity: table.tableCapacity, // 這裡設為數字
                    table_status: table.tableStatus,  // 保留桌位狀態
                }));
                console.log('桌號加載成功:', this.tableList);
                this.originalTableList = JSON.parse(JSON.stringify(this.tableList)); // 深拷貝，保存初始數據
            } catch (error) {
                console.error('加載桌位數據失敗:', error);

                Swal.fire({
                    icon: 'error',
                    title: '加載失敗',
                    text: '加載桌位數據失敗，請稍後再試。',
                });
            }
        },

        // 新增桌號輸入欄位
        addTableRow() {
            // 在 tableList 中新增一個新的輸入欄位
            this.tableList.push({
                table_number: '', 
                table_capacity: '', 
                table_status: '可使用',
            });
        },

        // 刪除桌位
        removeTable (index) {
            const table = this.tableList[index];
            // 檢查狀態，如果是 訂位中 或 用餐中，則禁止刪除
            if (table.table_status === '訂位中' || table.table_status === '用餐中') {
                Swal.fire({
                    icon: 'error',
                    title: '無法刪除桌位',
                    text: `桌位 ${table.table_number} 正在使用或已預訂，無法刪除。`,
                    confirmButtonText: '確認'
                });
                return; // 阻止刪除
            }

            // 否則，執行刪除
            this.tableList.splice(index, 1);
        },

        // 刪除新增桌號欄位
        deleteNewTable () {
            this.showNewTableRow = false;
        },

        // 新增、刪除、更新桌號操作
        async saveChanges() {
            try {
                // 確保 originalTableList 不為 undefined
                if (!this.originalTableList) {
                    this.originalTableList = [];
                }

                // 進行所有桌位資料的檢查
                for (const table of this.tableList) {
                    // 檢查桌號是否有輸入
                    if (!table.table_number.trim() || !table.table_capacity) {
                        Swal.fire({
                            icon: 'warning',
                            title: '錯誤',
                            text: '請輸入桌號並選擇容納人數。',
                        });
                        return; // 阻止儲存操作
                    }

                     // 檢查桌號格式是否正確（大寫字母+兩個數字）
                    const tableNumberPattern = /^[A-Z]\d{2}$/;
                    if (!table.table_number.trim().match(tableNumberPattern)) {
                        Swal.fire({
                            icon: 'warning',
                            title: '桌號格式錯誤',
                            text: '桌號必須是一個大寫字母加兩個數字（如 A01）。',
                        });
                        return; // 阻止儲存操作
                    }

                    // 檢查是否有重複的桌號
                    const existingTable = this.tableList.filter(t => t.table_number === table.table_number);
                    if (existingTable.length > 1) { // 如果出現重複桌號
                        Swal.fire({
                            icon: 'warning',
                            title: '錯誤',
                            text: `桌號 ${table.table_number} 已存在，請選擇其他桌號。`,
                        });
                        return; // 阻止儲存操作
                    }
                }

                // 處理桌位更新
                for (const table of this.tableList) {
                    const originalTable = this.originalTableList.find(orig => orig.table_number === table.table_number);

                    if (originalTable) {
                        // 如果桌號或容納人數發生變更，則進行更新
                        if (originalTable.table_number !== table.table_number || originalTable.table_capacity !== table.table_capacity) {
                            await axios.put('http://localhost:8080/tableManagement/updateTable', null, {
                                params: {
                                    oldTableNumber: originalTable.table_number,  // 傳遞舊的桌號
                                    newTableNumber: table.table_number !== originalTable.table_number ? table.table_number : null,  // 若桌號不同則傳遞新桌號
                                    newCapacity: table.table_capacity !== originalTable.table_capacity ? parseInt(table.table_capacity) : null,  // 若容量不同則傳遞新容量
                                }
                            });
                        }
                    } else {
                        // 若桌位是新的，則發送新增請求
                        const tableData = this.tableList.map(table => ({
                            tableNumber: table.table_number,
                            tableCapacity: parseInt(table.table_capacity),
                            tableStatus: table.table_status,
                        }));

                        // 發送批量新增桌位請求
                        await axios.post('http://localhost:8080/tableManagement/createTable', tableData);
                    }
                }

                // 刪除已移除的桌位
                const deletedTables = this.originalTableList.filter(orig => !this.tableList.some(table => table.table_number === orig.table_number));
                for (const table of deletedTables) {
                    await axios.delete(`http://localhost:8080/tableManagement/deleteTable/${table.table_number}`);
                }

                // 更新成功後，刷新頁面數據
                this.loadInitialTableData();
                Swal.fire({
                    icon: 'success',
                    title: '儲存成功',
                    text: '所有變更已成功儲存。',
                });

            } catch (error) {
                console.error('儲存桌位變更時發生錯誤:', error);
                Swal.fire({
                    icon: 'error',
                    title: '儲存失敗',
                    text: '儲存過程中發生錯誤，請稍後再試。',
                });
            }
        },

        // 取消桌號操作
        cancelChanges () {
            Swal.fire({
                icon: 'warning',
                title: '取消變更',
                text: '已取消變更桌位操作。',
            });

            // 還原 tableList 為原始數據
            this.tableList = JSON.parse(JSON.stringify(this.originalTableList)); 

            // 隱藏新增桌號行，並重置 newTable
            this.showNewTableRow = false;
            this.newTable = { table_number: '', table_capacity: '', table_status: 'AVAILABLE' };

            // 清空所有輸入匡
            document.querySelectorAll('.tableNumber').forEach(input => input.value = '');

            document.querySelectorAll('.tableCapacity').forEach(select => select.selectedIndex = 0);
        },
    }
};
</script>

<template>
<div class="tableManagementArea">
    <!-- 顯示桌號標題 -->
    <h2 class="tableNumberTitle">桌號管理</h2>

    <!-- 顯示桌號注意事項 -->
    <p class="reminderText">桌號必須是一個大寫字母加兩個數字（如 A01）</p>

    <!-- 顯示桌號表格區域 -->
    <div class="tableArea">
        <!-- 顯示桌號表格列表 -->
        <table class="tableList">
            <!-- 桌號列表頭 -->
            <thead>
                <tr>
                    <th>桌號</th>
                    <th>容納人數</th>
                    <th>編輯</th>
                </tr>
            </thead>

            <!-- 桌號列表內容 -->
            <tbody>
                <!-- 桌號列表行 -->
                <tr v-for="(table, index) in tableList" :key="index">
                    <!-- 桌號 -->
                    <td>
                        <input class="tableNumber" v-model="table.table_number" type="text" placeholder="輸入桌號" />
                    </td>

                    <!-- 容納人數 -->
                    <td>
                        <select class="tableCapacity" v-model="table.table_capacity" >
                            <option value="" disabled>選擇容納人數</option>
                            <option v-for="n in 20" :key="n" :value="n">{{ n }}人桌</option>
                        </select>
                    </td>

                    <!-- 刪除 Button -->
                    <td>
                        <button class="trashButton" @click="removeTable(index)">
                            <i class="fa-solid fa-trash"></i>
                        </button>
                    </td>
                </tr>
    
                <!-- 新增桌號行 -->
                <tr v-if="showNewTableRow">
                    <!-- 桌號 -->
                    <td>
                        <input class="tableNumber" v-model="newTable.table_number" type="text" placeholder="輸入桌號" />
                    </td>

                    <!-- 容納人數 -->
                    <td>
                        <select class="tableCapacity" v-model="newTable.table_capacity">
                            <option value="" disabled>選擇容納人數</option>
                            <option v-for="n in 20" :key="n" :value="n">{{ n }}人桌</option>
                        </select>
                    </td>

                    <!-- 刪除 Button -->
                    <td>
                        <button class="trashButton" @click="deleteNewTable">
                            <i class="fa-solid fa-trash"></i>
                        </button>
                    </td>
                </tr>
            </tbody>
        </table>

        <!-- 新增 Button -->
        <div class="addButtonArea">
            <button class="addButton" @click="addTableRow">
                <i class="fa-solid fa-circle-plus"></i>
            </button>
        </div>
    </div>

    <!-- 取消、儲存操作按鈕區域 -->
    <div class="buttonArea">
        <button class="cancelButton" @click="cancelChanges">取消</button>
        <button class="saveButton" @click="saveChanges">儲存</button>
    </div>
</div>
</template>

<style scoped lang="scss">
$background-color: #FFFFFF;
$black-color: #1E1E1E;
$gray-color: #DDE1E6;
$boxShadow: #F2F4F8;

.tableManagementArea {
    width: 80%; 
    height: 100%;
    border-radius: 0.625rem; // 10px -> 0.625rem
    border: 1px solid rgba(grey, 0.5);
    border: 1px solid;
    box-shadow: -3px 3px 4px black;
    background-color: $background-color;
    padding: 1.25rem 2.1875rem; // 20px 35px -> 1.25rem 2.1875rem
    position: absolute;
    top: 0%;
    right: 0%;

    .tableNumberTitle {
        font-size: 1.5625rem; // 25px -> 1.5625rem
        letter-spacing: 0.25rem; // 4px -> 0.25rem
        margin-bottom: 0.625rem; // 10px -> 0.625rem
    }

    .reminderText {
        margin-bottom: 1.25rem; // 20px -> 1.25rem
        color: $black-color;
        opacity: 0.6;
    }

    .tableArea {
        width: 100%;
        height: 85%;
        border: 0.125rem solid $gray-color; // 2px -> 0.125rem
        padding: 0.9375rem 0.625rem; // 15px 10px -> 0.9375rem 0.625rem
        max-height: 37.625rem; // 650px -> 40.625rem
        overflow-y: auto;

        .tableList {
            width: 100%;
            border-collapse: collapse; /* 使用 separate 來啟用 border-spacing */
            table-layout: fixed; /* 讓表格的列寬固定 */

            thead {
                height: 3.75rem; // 60px -> 3.75rem
                background-color: $gray-color;
                letter-spacing: 0.25rem; // 4px -> 0.25rem
            }

            tbody {
                tr {
                    height: 4.375rem; // 70px -> 4.375rem
                    border-bottom: 0.0625rem dashed $gray-color; // 1px -> 0.0625rem
                }

                td {
                    padding: 0.3125rem; // 5px -> 0.3125rem
                    text-align: center;
                    vertical-align: middle; // 垂直居中內容

                    .tableNumber {
                        width: 80%;
                        height: 2.1875rem; // 35px -> 2.1875rem
                        border: none;
                        background-color: transparent;
                        font-size: 1.25rem; // 20px -> 1.25rem
                        text-align: center;
                        outline: none;
                    }

                    .tableCapacity {
                        width: 80%;
                        height: 2.5rem; // 40px -> 2.5rem
                        border-radius: 0.625rem; // 10px -> 0.625rem
                        border: 0.0625rem solid $gray-color; // 1px -> 0.0625rem
                        letter-spacing: 0.3125rem; // 5px -> 0.3125rem
                        padding-left: 0.625rem; // 10px -> 0.625rem
                        appearance: none; // 隱藏默認的箭頭
                        background: url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyLjcxNzUgNi41NDc1QzEzLjE3OTcgNi4xNDcyIDEzLjI4MjIgNS40MTMgMTIuOTg3MiA0LjkzMjVDMTIuNjkzMiA0LjQ1MjUgMTIuMDEwNCA0LjQ1MjUgMTEuNzE3IDQuOTMyNUw4IDkuMzM1NEw0LjI4MjUgNC45MzI1QzMuOTg5NiA0LjQ1MjUgMy4zMDY4IDQuNDUyNSAyLjAxMjggNC45MzI1QzEuNzE4OCA1LjQxMyAxLjgyMTEgNi4xNDcyIDIuMjg0MTIgNi41NDc1TDcuMzE1MTIgMTEuNTA2QzcuNzU4NDEgMTEuOTYxIDguMjQxNiAxMS45NjEgOC42ODY4IDExLjUwNkMxMC4xNzA4IDEwLjI1NyAxMS41OTExIDguOTAzNTggMTIuNzE3NSA3LjY2MjVIMTIuNzE3NVoiIGZpbGw9IiMyMjIyMjIiLz4KPC9zdmc+') no-repeat; // 使用 base64 格式的箭頭圖標
                        background-position: calc(100% - 0.9375rem) center; // 15px -> 0.9375rem
                        background-size: 0.9375rem; // 15px -> 0.9375rem
                        outline: none;
                        cursor: pointer;
                    }

                    .trashButton {
                        border: none;
                        background-color: transparent;
                        font-size: 1.875rem; // 30px -> 1.875rem
                        cursor: pointer;
                    }
                }
            }
        }

        .addButtonArea {
            width: 100%;
            height: 10%;
            display: flex;
            justify-content: center;
            align-items: center;

            .addButton {
                border: none;
                background-color: transparent;
                font-size: 1.5625rem; // 25px -> 1.5625rem
                margin-top: 0.9375rem; // 15px -> 0.9375rem
                cursor: pointer;
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