<script>
import Swal from 'sweetalert2'; // 引入 SweetAlert2

export default {
    data() {
        return {
            user: {
                name: '',
                phone: '',
                email: '',
                staffId: '',
                authorizationName: '',

            },
            newPassword: '',
            confirmPassword: '',
            passwordVisible: false,
            confirmPasswordVisible: false,
            showModal: false,
            selectedPurchase: null,
            permissions: []
        };
    },
    methods: {
        openModal(purchase) {
            this.selectedPurchase = purchase;
            this.showModal = true;
        },
        closeModal() {
            this.showModal = false;
        },
        changePassword() {
            if (this.newPassword == this.confirmPassword) {
                const memberId = sessionStorage.getItem('memberId');
                const staffNumber = sessionStorage.getItem('staffNumber');

                if (memberId) {
                    const reqData = {
                        phone: this.user.phone,
                        pwd: this.newPassword,
                    };

                    fetch('http://localhost:8080/api/member/resetpassword', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(reqData),
                    })
                        .then(response => {
                            if (!response.ok) {
                                throw new Error(`HTTP error! Status: ${response.status}`);
                            }
                            return response.json();
                        })
                        .then(data => {
                            Swal.fire({
                                title: data.message,
                                icon: 'success',
                                confirmButtonText: '確定',
                            });
                            this.newPassword = '';
                            this.confirmPassword = '';
                        })
                        .catch(error => {
                            console.error('修改密碼失敗:', error);
                            Swal.fire({
                                title: '修改密碼失敗',
                                text: '請稍後再試。',
                                icon: 'error',
                                confirmButtonText: '確定',
                            });
                        });
                }

                if (staffNumber) {
                    const reqData = {
                        staffNumber: this.user.staffId,
                        pwd: this.newPassword,
                    };

                    fetch('http://localhost:8080/api/staff/resetPassword', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(reqData),
                    })
                        .then(response => {
                            if (!response.ok) {
                                throw new Error(`HTTP error! Status: ${response.status}`);
                            }
                            return response.json();
                        })
                        .then(data => {
                            console.log(data);
                            if (data.code == 200) {
                                Swal.fire({
                                    title: data.message,
                                    icon: 'success',
                                    confirmButtonText: '確定',
                                });
                                this.newPassword = '';
                                this.confirmPassword = '';
                            }else{
                                Swal.fire({
                                    title: data.message,
                                    icon: 'error',
                                    confirmButtonText: '確定',
                                });
                            }
                            
                        })
                        .catch(error => {
                            console.error('修改密碼失敗:', error);
                            Swal.fire({
                                title: '修改密碼失敗',
                                text: '請稍後再試。',
                                icon: 'error',
                                confirmButtonText: '確定',
                            });
                        });
                }


            } else {
                Swal.fire({
                    title: '錯誤',
                    text: '新密碼與確認新密碼不一致',
                    icon: 'warning',
                    confirmButtonText: '確定',
                });
            }
        },
        getUserData() {
            const memberId = sessionStorage.getItem('memberId');

            if (memberId) {
                fetch(`http://localhost:8080/api/member/${memberId}`, {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json'
                    }
                })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error(`HTTP error! Status: ${response.status}`);
                        }
                        return response.json();
                    })
                    .then(data => {
                        console.log(data);
                        this.user.name = data.member.name;
                        this.user.phone = data.member.phone;
                        this.user.email = data.member.email;
                        this.user.totalSpent = data.member.totalSpendingAmount;
                        this.user.memberLevel = data.member.memberLevel;
                    })
                    .catch(error => {
                        console.error("取得使用者資料失敗:", error);
                    });
            } else {
                console.error("無法取得使用者資料");
            }
        },
        getStaffData() { // 抓員工資料
            const staffNumber = sessionStorage.getItem('staffNumber');  // 登入的時候已經把 staffNumber 寫在 session 了

            if (staffNumber) {
                fetch(`http://localhost:8080/api/staff/${staffNumber}`, {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json'
                    }
                })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error(`HTTP error! Status: ${response.status}`);
                        }
                        return response.json(); // 解析回應為 JSON 格式
                    })
                    .then(data => {
                        if (data && data.staff) {

                            this.user.name = data.staff.name;
                            this.user.email = data.staff.email;
                            this.user.phone = data.staff.phone;
                            this.user.staffId = data.staff.staffNumber;


                            // 找到相對應的權限物件
                            const foundPermission = this.permissions.find(permission => permission.id == data.staff.authorization);

                            if (foundPermission) {
                                this.managedAreas = foundPermission.managedAreas;
                                this.user.authorizationName = foundPermission.name; // 將角色設置為權限名稱
                            } else {
                                console.log("找不到相應的權限");
                                this.user.authorizationName = "無權限資訊"; // 若找不到權限，給予一個預設值
                            }
                        } else {
                            console.error("回傳的資料格式不正確或沒有 staff 資料");
                        }
                    })
                    .catch(error => {
                        console.error("取得員工資料失敗:", error);
                    });
            } else {
                console.error("Session 中的 staffNumber 不存在，無法取得員工資料");
            }
        },
        async fetchPermissions() {
            try {
                const response = await fetch('http://localhost:8080/api/authorization/all');
                const data = await response.json();

                this.permissions = data.map(item => ({
                    name: item.authorizationName,
                    managedAreas: item.authorizationItem.split(','),
                    id: item.authorizationId
                }));
            } catch (error) {
                console.error('無法獲取權限資料:', error);
                Swal.fire('錯誤', '無法獲取權限資料', 'error');
            }
        }
    },
    mounted() {

        this.fetchPermissions().then(() => {
            const memberId = sessionStorage.getItem('memberId');
            const staffNumber = sessionStorage.getItem('staffNumber');

            if (memberId) {
                //抓使用者資料
                this.getUserData();
            } else if (staffNumber) {
                //抓員工資料
                this.getStaffData();
            }
        });



    }
};
</script>


<template>
    <div class="user-info-container">
        <div class="user-info">
            <h2>用戶資訊</h2>
            <div class="info-section">
                <h3>個人資料</h3>
                <div class="info-field">
                    <label>員工編號:</label>
                    <span>{{ user.staffId }}</span>
                </div>
                <div class="info-field">
                    <label>姓名:</label>
                    <span>{{ user.name }}</span>
                </div>
                <div class="info-field">
                    <label>手機:</label>
                    <span>{{ user.phone }}</span>
                </div>
                <div class="info-field">
                    <label>電子郵件:</label>
                    <span>{{ user.email }}</span>
                </div>
                <div class="info-field">
                    <label>權限:</label>
                    <span>{{ user.authorizationName }}</span>
                </div>
            </div>

            <div class="password-section">
                <h3>修改密碼</h3>
                <div class="password-field">
                    <div class="input-group">
                        <input v-model="newPassword" :type="passwordVisible ? 'text' : 'password'"
                            placeholder="輸入新密碼" />
                        <span @click="passwordVisible = !passwordVisible" class="eye-icon">
                            <i :class="passwordVisible ? 'fas fa-eye' : 'fas fa-eye-slash'"></i>
                        </span>
                    </div>
                    <div class="input-group">
                        <input v-model="confirmPassword" :type="confirmPasswordVisible ? 'text' : 'password'"
                            placeholder="確認新密碼" />
                        <span @click="confirmPasswordVisible = !confirmPasswordVisible" class="eye-icon">
                            <i :class="confirmPasswordVisible ? 'fas fa-eye' : 'fas fa-eye-slash'"></i>
                        </span>
                    </div>
                    <button @click="changePassword" class="change-password-btn">修改密碼</button>
                </div>
            </div>
        </div>

        <!-- 浮現視窗 -->
        <div v-if="showModal" class="modal" @click.self="closeModal">
            <div class="modal-content">
                <span class="close" @click="closeModal">&times;</span>
                <h3>消費明細</h3>
                <p>日期: {{ selectedPurchase?.date }}</p>
                <p>金額: {{ selectedPurchase?.amount }}</p>
                <p>詳細內容: {{ selectedPurchase?.details }}</p>
            </div>
        </div>
    </div>
</template>




<style scoped>
.user-info-container {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 40vw;
    height: 80vh;
    overflow: hidden;
}

.user-info {
    max-width: 80dvw;
    max-height: 90dvh;
    width: 98%;
    background-color: #fff;
    border-radius: 12px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    padding: 15px;
    overflow-y: auto;
    /* 允許垂直滾動 */
    display: flex;
    flex-direction: column;
}

h2 {
    font-size: 26px;
    /* 增加標題字體大小 */
    color: #2c3e50;
    margin-bottom: 15px;
    border-bottom: 2px solid #e0e0e0;
    padding-bottom: 8px;
}

h3 {
    font-size: 22px;
    /* 增加副標題字體大小 */
    color: #34495e;
    margin-bottom: 10px;
}

.info-grid {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: 15px;
}

.info-section,
.purchase-section {
    background-color: #f9f9f9;
    border-radius: 8px;
    padding: 12px;
}

.info-field {
    display: flex;
    justify-content: space-between;
    margin-bottom: 8px;
    padding: 6px;
    border-radius: 4px;
    font-size: 16px;
    /* 增加內容字體大小 */
}

.info-field label {
    font-weight: bold;
    color: #555;
}

table {
    width: 100%;
    border-collapse: collapse;
    font-size: 16px;
    /* 增加表格字體大小 */
}

th,
td {
    text-align: left;
    padding: 10px;
    /* 增加表格內邊距 */
    border-bottom: 1px solid #e0e0e0;
}

th {
    background-color: #ecf0f1;
    color: #2c3e50;
}

.details-btn {
    background-color: #3498db;
    color: white;
    border: none;
    padding: 6px 12px;
    /* 增加按鈕內邊距 */
    border-radius: 3px;
    cursor: pointer;
    transition: background-color 0.3s;
    font-size: 14px;
    /* 增加按鈕字體大小 */
}

.details-btn:hover {
    background-color: #2980b9;
}

.password-section {
    margin-top: 15px;
}

.password-field {
    display: flex;
    flex-direction: column;
    /* 垂直排列 */
    gap: 10px;
}

.password-field input {
    width: 100%;
    /* 讓輸入框填滿 */
}

input {
    flex: 1;
    padding: 10px;
    /* 增加輸入框內邊距 */
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 16px;
    /* 增加輸入框字體大小 */
}

.change-password-btn {
    padding: 10px 16px;
    /* 增加按鈕內邊距 */
    background-color: #343a3f;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 16px;
    /* 增加按鈕字體大小 */
    transition: background-color 0.3s;
}

.change-password-btn:hover {
    background-color: #27ae60;
}

.modal {
    display: flex;
    position: fixed;
    z-index: 1;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    overflow: hidden;
    background-color: rgba(0, 0, 0, 0.5);
    justify-content: center;
    align-items: center;
}

.modal-content {
    background-color: #fefefe;
    padding: 15px;
    border-radius: 8px;
    width: 90%;
    max-width: 380px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.close {
    color: #aaa;
    float: right;
    font-size: 22px;
    font-weight: bold;
    cursor: pointer;
    transition: color 0.3s;
}

.close:hover {
    color: #333;
}

.input-group {
    position: relative;
    display: flex;
    align-items: center;
}

.eye-icon {
    position: absolute;
    right: 10px;
    cursor: pointer;
    color: #777;
    /* 可根據需求調整顏色 */
}

@media (max-width: 1024px) {
    .info-grid {
        grid-template-columns: 1fr;
    }

    .password-field {
        flex-direction: column;
    }

    input,
    .change-password-btn {
        width: 100%;
    }
}

@media (max-width: 600px) {
    .user-info {
        padding: 10px;
    }

    h2 {
        font-size: 24px;
        /* 增加手機版標題字體大小 */
    }

    h3 {
        font-size: 20px;
        /* 增加手機版副標題字體大小 */
    }

    .info-field,
    table,
    input,
    .change-password-btn {
        font-size: 14px;
        /* 增加手機版內容字體大小 */
    }
}
</style>
