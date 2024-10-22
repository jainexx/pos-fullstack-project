<script>
import Swal from 'sweetalert2';

export default {
    data() {
        return {
            employees: [],
            newEmployee: {
                id: '',
                name: '',
                phone: '',
                password: '',
                email: '',
                authorization: '',
            },
            authorizations: [],
            searchQuery: '',
            editingId: null,
            showAddRow: false,
            currentPage: 1,
            pageSize: 5,
            isAddingOrEditing: false,
        };
    },
    computed: {
        // 模糊搜尋
        filteredEmployees() {
            const query = this.searchQuery.toLowerCase();
            return this.employees.filter(employee =>
                employee.name.toLowerCase().includes(query) ||
                employee.id.toLowerCase().includes(query)
            );
        },
        paginatedEmployees() {
            const start = (this.currentPage - 1) * this.pageSize;
            return this.filteredEmployees.slice(start, start + this.pageSize);
        },
        nextEmployeeId() {
            const maxId = Math.max(...this.employees.map(e => parseInt(e.id.slice(4))), 0); // 切掉前綴 "TEST"
            return `TEST${String(maxId + 1).padStart(3, '0')}`; // 返回新編號
        },
        totalPages() {
            return Math.ceil(this.filteredEmployees.length / this.pageSize);
        }
    },
    methods: {
        toggleAddEmployee() {
            // 始終顯示新增行
            this.showAddRow = !this.showAddRow;
            this.isAddingOrEditing = this.showAddRow; // 設置狀態
            this.newEmployee.password = this.nextEmployeeId;
        },
        addEmployee() {
            if (this.showAddRow) {
                this.newEmployee.id = this.nextEmployeeId; // 設定員工編號
                const employeeData = {
                    name: this.newEmployee.name,
                    phone: this.newEmployee.phone,
                    pwd: this.newEmployee.password,
                    authorization: this.newEmployee.authorization,
                    email: this.newEmployee.email,

                };

                // 發送 API 請求新增員工
                fetch("http://localhost:8080/api/staff/register", {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(employeeData)
                })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error(`HTTP error! Status: ${response.status}`);
                        }
                        return response.json(); // 解析回應的 JSON
                    })
                    .then(data => {
                        // 顯示 SweetAlert 成功提示
                        if (data.code == 200) {
                            Swal.fire({
                                title: data.message, // 假設 API 返回的訊息
                                icon: 'success',
                                confirmButtonText: '確定',
                            });


                            this.employees.push({ ...this.newEmployee, id: this.newEmployee.id }); // 將新增的員工加入本地狀態
                            this.allStaffInfo();
                            this.resetNewEmployee(); // 重置新增員工的資料
                        } else {
                            Swal.fire({
                                title: '新增員工失敗',
                                text: data.message, // 顯示錯誤訊息
                                icon: 'error',
                                confirmButtonText: '確定',
                            });

                            this.isAddingOrEditing = true; // 維持編輯狀態
                        }

                        // 檢查是否需要跳到下一頁
                        if (this.filteredEmployees.length != 1 && (this.filteredEmployees.length % this.pageSize == 1)) {
                            this.changePage(this.currentPage + 1);
                        }
                    })
                    .catch(error => {
                        console.error("新增員工失敗:", error);
                        // 顯示 SweetAlert 錯誤提示
                        Swal.fire({
                            title: '新增員工失敗',
                            text: error.message, // 顯示錯誤訊息
                            icon: 'error',
                            confirmButtonText: '確定',
                        });

                        this.isAddingOrEditing = true; // 維持編輯狀態
                    });
            }
        },
        resetNewEmployee() {
            this.newEmployee = { id: '', name: '', phone: '', password: '', email: '', authorization: '' };
            this.showAddRow = false; // 新增完成後隱藏新增行
            this.isAddingOrEditing = false; // 重置狀態
        },
        deleteEmployee(id) {
            // 確認刪除
            Swal.fire({
                title: '確定要刪除這位員工嗎?',
                text: "這個動作無法復原！",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: '是的，刪除',
                cancelButtonText: '取消'
            }).then((result) => {
                if (result.isConfirmed) {
                    // 發送 API 請求刪除員工
                    fetch(`http://localhost:8080/api/staff/delete`, {
                        method: 'POST',
                        body: id
                    })
                        .then(response => {
                            if (!response.ok) {
                                throw new Error(`HTTP error! Status: ${response.status}`);
                            }
                            return response.json(); // 解析回應的 JSON
                        })
                        .then(data => {
                            // 顯示 SweetAlert 成功提示
                            if (data.code === 200) {
                                Swal.fire({
                                    title: data.message, // 假設 API 返回的訊息
                                    icon: 'success',
                                    confirmButtonText: '確定',
                                });

                                this.employees = this.employees.filter(emp => emp.id !== id); // 從本地狀態中移除
                            } else {
                                Swal.fire({
                                    title: '刪除員工失敗',
                                    text: data.message, // 顯示錯誤訊息
                                    icon: 'error',
                                    confirmButtonText: '確定',
                                });
                            }
                        })
                        .catch(error => {
                            console.error("刪除員工失敗:", error);
                            // 顯示 SweetAlert 錯誤提示
                            Swal.fire({
                                title: '刪除員工失敗',
                                text: error.message, // 顯示錯誤訊息
                                icon: 'error',
                                confirmButtonText: '確定',
                            });
                        });
                }
            });
        },
        startEditing(id) {
            const employee = this.employees.find(emp => emp.id === id);
            this.editingId = id;
            this.newEmployee = {
                ...employee,
                authorization: this.authorizations.find(auth => auth.label === employee.authorization)?.code || '' // 這裡新增授權代碼的載入
            }; // 將選中的員工資料填入新增員工表單
            this.isAddingOrEditing = true; // 設置狀態
        },
        saveEditing() {
            const updatedData = {
                staffNumber: this.editingId,
                name: this.newEmployee.name,
                phone: this.newEmployee.phone,
                email: this.newEmployee.email,
                authorization: this.newEmployee.authorization,
            };

            // 發送 API 請求更新員工資料
            fetch("http://localhost:8080/api/staff/updateInfo", {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(updatedData)
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    }
                    return response.json(); // 解析回應的 JSON
                })
                .then(data => {
                    // 顯示 SweetAlert 成功提示
                    if (data.code === 200) {
                        Swal.fire({
                            title: data.message, // 假設 API 返回的訊息
                            icon: 'success',
                            confirmButtonText: '確定',
                        });

                        this.allStaffInfo();
                        this.cancelEditing(); // 重置狀態
                    } else {
                        Swal.fire({
                            title: '更新員工失敗',
                            text: data.message, // 顯示錯誤訊息
                            icon: 'error',
                            confirmButtonText: '確定',
                        });
                    }
                })
                .catch(error => {
                    console.error("更新員工失敗:", error);
                    // 顯示 SweetAlert 錯誤提示
                    Swal.fire({
                        title: '更新員工失敗',
                        text: error.message, // 顯示錯誤訊息
                        icon: 'error',
                        confirmButtonText: '確定',
                    });
                });
        },
        cancelEditing() {
            this.editingId = null;
            this.isAddingOrEditing = false; // 重置狀態
            this.resetNewEmployee(); // 清空新增員工表單
        },
        changePage(page) {
            this.currentPage = page;
        },
        allStaffInfo() {
            fetch("http://localhost:8080/api/staff/all", {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            })
                .then(async (staffResponse) => {
                    if (!staffResponse.ok) {
                        throw new Error(`HTTP error! Status: ${staffResponse.status}`);
                    }
                    const staffData = await staffResponse.json();

                    this.employees = staffData.staffData.map(staff => {
                        const authorizationLabel = this.authorizations.find(auth => auth.code === Number(staff.authorization))?.label || '未知';
                        return {
                            id: staff.staffNumber,
                            name: staff.name,
                            phone: staff.phone,
                            password: staff.pwd,
                            email: staff.email,
                            authorization: authorizationLabel, // 使用對應的名稱
                        };
                    });
                })
                .catch(error => {
                    console.error("取得使用者資料失敗:", error);
                });
        },
        async fetchPermissions() {
            try {
                const response = await fetch('http://localhost:8080/api/authorization/all');
                const data = await response.json();

                this.authorizations = data.map(item => ({
                    label: item.authorizationName,
                    // managedAreas: item.authorizationItem.split(','),
                    code: item.authorizationId
                }));
            } catch (error) {
                console.error('無法獲取權限資料:', error);
                Swal.fire('錯誤', '無法獲取權限資料', 'error');
            }
        },
        resetPassword(id) {

            const employee = this.employees.find(emp => emp.id === id);
            // this.editingId = id;
            this.newEmployee = {
                ...employee,
                authorization: this.authorizations.find(auth => auth.label === employee.authorization)?.code || '' // 這裡新增授權代碼的載入
            }; // 將選中的員工資料填入新增員工表單

            const requestData = {
                staffNumber: id,
                pwd: id,

            };


            fetch('http://localhost:8080/api/staff/resetPassword', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(requestData),
            })
                .then(response => response.json())
                .then(data => {
                    if (data.code == "200") {
                        Swal.fire({
                            title: "重置密碼成功", // 假設 API 返回的訊息
                            icon: 'success',
                            confirmButtonText: '確定',
                        });

                        this.allStaffInfo();
                        this.cancelEditing(); // 重置狀態
                    } else {
                        Swal.fire({
                            title: data.message,
                            icon: 'error',
                            confirmButtonText: '確定',
                        });
                    }
                })
                .catch((error) => {
                    console.error('錯誤:', error);
                    Swal.fire({
                        title: '網絡錯誤，請重試！',
                        icon: 'error',
                        confirmButtonText: '確定',
                    });
                });

        }
    },
    mounted() {
        this.fetchPermissions().then(() => {
            this.allStaffInfo();
        });
    }
};
</script>

<template>
    <div class="employee-management-container">
        <div class="employee-management">
            <h2>員工管理</h2>

            <div class="search-bar">
                <input v-model="searchQuery" placeholder="搜尋姓名或員工編號" />
            </div>

            <div class="employee-table">
                <table>
                    <thead>
                        <tr>
                            <th>員工編號</th>
                            <th>姓名</th>
                            <th>電話</th>
                            <th>密碼</th>
                            <th>email</th>
                            <th>權限</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="employee in paginatedEmployees" :key="employee.id">
                            <td>{{ employee.id }}</td>
                            <td>
                                <div class="cell-content">
                                    <input v-if="editingId === employee.id" v-model="newEmployee.name"
                                        class="edit-input" />
                                    <span v-else>{{ employee.name }}</span>
                                </div>
                            </td>
                            <td>
                                <div class="cell-content">
                                    <input v-if="editingId === employee.id" v-model="newEmployee.phone"
                                        class="edit-input" />
                                    <span v-else>{{ employee.phone }}</span>
                                </div>
                            </td>
                            <td>
                                <button @click="resetPassword(employee.id)" class="action-btn reset-btn">
                                    重置密碼
                                </button>
                            </td>
                            <td>
                                <div class="cell-content">
                                    <input v-if="editingId === employee.id" v-model="newEmployee.email"
                                        class="edit-input" />
                                    <span v-else>{{ employee.email }}</span>
                                </div>
                            </td>
                            <td>
                                <div class="cell-content">
                                    <select v-if="editingId === employee.id" v-model="newEmployee.authorization"
                                        class="edit-input">
                                        <option value="">選擇權限</option>
                                        <option v-for="auth in authorizations" :value="auth.code" :key="auth.code">
                                            {{ auth.label }}
                                        </option>
                                    </select>
                                    <span v-else>{{ employee.authorization }}</span>
                                </div>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <template v-if="editingId === employee.id">
                                        <button @click="saveEditing" class="action-btn save-btn">
                                            <i class="fas fa-check"></i>
                                        </button>
                                        <button @click="cancelEditing" class="action-btn cancel-btn">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </template>
                                    <template v-else>
                                        <button @click="startEditing(employee.id)" class="action-btn edit-btn">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </button>
                                        <button @click="deleteEmployee(employee.id)" class="action-btn delete-btn">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </template>
                                </div>
                            </td>
                        </tr>
                        <tr v-if="showAddRow" class="new-employee-row">
                            <td>{{ nextEmployeeId }}</td>
                            <td><input v-model="newEmployee.name" placeholder="輸入姓名" class="edit-input"
                                    maxlength="16px"></td>
                            <td><input v-model="newEmployee.phone" placeholder="輸入電話" class="edit-input"></td>
                            <td>
                                <div class="cell-content">
                                    <span>************</span>
                                </div>
                            </td>
                            <td><input v-model="newEmployee.email" placeholder="輸入email" class="edit-input"></td>
                            <td>
                                <select v-model="newEmployee.authorization" class="edit-input">
                                    <option value="">選擇權限</option>
                                    <option v-for="auth in authorizations" :value="auth.code" :key="auth.code">
                                        {{ auth.label }}
                                    </option>
                                </select>
                            </td>
                            <td>
                                <button @click="addEmployee" class="action-btn save-btn">
                                    <i class="fas fa-check"></i>
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="pagination">
                <button @click="changePage(currentPage - 1)" :disabled="currentPage === 1">上一頁</button>
                <span>第 {{ currentPage }} 頁 / 共 {{ totalPages }} 頁</span>
                <button @click="changePage(currentPage + 1)" :disabled="currentPage === totalPages">下一頁</button>
            </div>

            <div class="center-add-btn">
                <button @click="toggleAddEmployee" class="add-btn" :disabled="isAddingOrEditing">
                    <i class="fas fa-user-plus"></i> 新增員工
                </button>
            </div>
        </div>
    </div>
</template>



<style lang="scss" scoped>
.employee-management-container {
    display: flex;
    justify-content: center;
    align-items: center;
    max-height: 90dvh;
    width: 80dvw;
    height: 90dvh;
    padding: 20px;


    .employee-management {
        height: 100%;
        width: 100%;
        max-width: 1200px;
        padding: 30px;
        background-color: #fff;
        border-radius: 12px;
        border: 1px solid rgba(grey, 0.5);
        border: 1px solid;
        box-shadow: -3px 3px 4px black;

        h2 {
            color: #333;
            font-size: 28px;
        }

        .search-bar {
            margin-bottom: 24px;

            input {
                width: 100%;
                padding: 12px;
                border: 1px solid #ddd;
                border-radius: 6px;
                font-size: 16px;
            }
        }

        .employee-table {
            margin-bottom: 24px;
            overflow-x: auto;

            table {
                width: 100%;
                border-collapse: collapse;
                table-layout: auto;

                th,
                td {
                    width: 8%;
                    padding: 12px 16px;
                    text-align: center;
                    background-color: transparent;
                    border: none;
                    min-width: 100px;
                }

                th {
                    text-align: center;
                }
            }
        }

        .cell-content {
            // display: flex;
            // align-items: center;
        }

        .edit-input {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 10px;
        }

        .action-btn {
            background-color: #343a3f;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;

            &:hover {
                background-color: #495057;
            }
        }

        .pagination {
            display: flex;
            justify-content: center;
            margin: 20px 0;

            button {
                background-color: #343a3f;
                color: white;
                border: none;
                padding: 8px 12px;
                border-radius: 4px;
                cursor: pointer;
                margin: 0 5px;

                &:disabled {
                    background-color: #ccc;
                    cursor: not-allowed;
                }
            }
        }

        .center-add-btn {
            display: flex;
            justify-content: center;

            .add-btn {
                background-color: #343a3f;
                color: white;
                border: none;
                padding: 10px 15px;
                border-radius: 6px;
                cursor: pointer;
                transition: background-color 0.3s;

                &:hover {
                    background-color: #495057;
                }
            }
        }
    }
}
</style>
