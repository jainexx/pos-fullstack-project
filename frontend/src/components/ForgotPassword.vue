<script>
import Swal from 'sweetalert2';

export default {
    data() {
        return {
            staffNumber: '',
            email: '',
            verificationCode: '', // 新增驗證碼欄位
            confirmVerificationCode: '', // 用來接回傳的驗證碼
            confirmVerificationCodeTime: '', // 接有效期間
            newPassword: '',
            confirmNewPassword: '',
            step: 1, // 用來控制顯示的步驟
            showNewPassword: false,
            showConfirmPassword: false,
        };
    },
    methods: {
        handleSubmit() {
            if (this.step === 1) {
                const requestData = {
                    staffNumber: this.staffNumber,
                    email: this.email,
                };

                fetch('http://localhost:8080/api/staff/forgotpassword', { // 更新API路徑
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
                                title: data.message,
                                icon: 'success',
                                confirmButtonText: '確定',
                            });
                            this.confirmVerificationCode = data.verificationCode;
                            this.confirmVerificationCodeTime = data.verificationCodeExpiry;

                            console.log("驗證碼:" + this.confirmVerificationCode);
                            this.step = 2; // 更新步驟以顯示驗證碼輸入
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
        handleVerify() {
            const currentTime = new Date();
            const expiryTime = new Date(this.confirmVerificationCodeTime);

            if (this.verificationCode === this.confirmVerificationCode) {
                if (currentTime <= expiryTime) {
                    Swal.fire({
                        title: '驗證成功！',
                        icon: 'success',
                        confirmButtonText: '確定',
                    });
                    this.step = 3;
                } else {
                    Swal.fire({
                        title: '驗證碼已過期！',
                        icon: 'error',
                        confirmButtonText: '確定',
                    });
                }
            } else {
                Swal.fire({
                    title: '驗證碼不正確！',
                    icon: 'error',
                    confirmButtonText: '確定',
                });
            }
        },
        resetPassword() {
            if (this.newPassword !== this.confirmNewPassword) {
                Swal.fire({
                    title: '密碼不一致！',
                    icon: 'error',
                    confirmButtonText: '確定',
                });
                return;
            }

            const requestData = {
                staffNumber: this.staffNumber,
                pwd: this.newPassword,
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
                            title: '密碼重置成功！',
                            icon: 'success',
                            confirmButtonText: '確定',
                        }).then(() => {
                            this.$router.push('/'); // 重置密碼後跳轉到登入頁面
                        });
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
        },
        // 新增顯示/隱藏密碼的切換方法
        toggleNewPasswordVisibility() {
            this.showNewPassword = !this.showNewPassword;
        },
        toggleConfirmPasswordVisibility() {
            this.showConfirmPassword = !this.showConfirmPassword;
        }
    }
};
</script>


<template>
    <div class="forgot-password-container">
        <div class="forgot-password-box">
            <h2>忘記密碼</h2>
            <form
                @submit.prevent="step === 1 ? handleSubmit() : step === 2 ? handleVerify() : step === 3 ? resetPassword() : null">
                <div class="input-group">
                    <label for="staffNumber">帳號</label>
                    <div v-if="step === 1">
                        <input v-model="staffNumber" type="text" id="staffNumber" placeholder="請輸入帳號" required
                            autocomplete="off" />
                    </div>
                    <div v-else>
                        <div class="phone-display">{{ staffNumber }}</div> <!-- 只顯示帳號 -->
                    </div>
                </div>

                <div v-if="step === 1" class="input-group">
                    <label for="email">電子郵件</label>
                    <input v-model="email" type="email" id="email" placeholder="請輸入電子郵件" required autocomplete="off" />
                </div>

                <div v-if="step === 2" class="input-group">
                    <label for="verificationCode">驗證碼</label>
                    <input v-model="verificationCode" type="text" id="verificationCode" placeholder="請輸入驗證碼" required
                        autocomplete="off" />
                </div>

                <div v-if="step === 3" class="input-group">
                    <label for="newPassword">新密碼</label>
                    <div class="password-input">
                        <input :type="showNewPassword ? 'text' : 'password'" v-model="newPassword" id="newPassword"
                            placeholder="請輸入新密碼" required autocomplete="off" />
                        <span @click="toggleNewPasswordVisibility">
                            <i :class="showNewPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                        </span>
                    </div>
                </div>

                <div v-if="step === 3" class="input-group">
                    <label for="confirmNewPassword">確認新密碼</label>
                    <div class="password-input">
                        <input :type="showConfirmPassword ? 'text' : 'password'" v-model="confirmNewPassword"
                            id="confirmNewPassword" placeholder="請再次輸入新密碼" required autocomplete="off" />
                        <span @click="toggleConfirmPasswordVisibility">
                            <i :class="showConfirmPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
                        </span>
                    </div>
                </div>

                <button type="submit" class="submit-btn">
                    {{ step === 1 ? '發送驗證碼' : step === 2 ? '驗證' : step === 3 ? '重置密碼' : '' }}
                </button>
            </form>
            <div class="back-to-login">
                <router-link to="/">回到登入頁面</router-link>
            </div>
        </div>
    </div>
</template>


<style scoped lang="scss">
$bg-color: #f0f2f5;
$black-color: #1E1E1E;
$white-color: #FFFFFF;
$gray-color: #F2F4F8;
$hover-color: #555;
$font-size-base: 16px;
$radius: 5px;

.forgot-password-container {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    background-color: $bg-color;

    .forgot-password-box {
        background-color: $white-color;
        padding: 2.5rem;
        border-radius: 10px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        text-align: center;
        width: 28rem;

        h2 {
            margin-bottom: 1.25rem;
            color: $black-color;
            letter-spacing: 5px;
            font-size: 1.5rem;
        }

        .input-group {
            margin-bottom: 1.25rem;
            text-align: left;

            label {
                display: block;
                margin-bottom: 0.3125rem;
                color: $black-color;
                font-size: $font-size-base;
                letter-spacing: 2px;
            }

            .phone-display {
                padding: 0.625rem;
                border: 1px solid #ddd;
                border-radius: $radius;
                background-color: #f9f9f9;
                /* 可以使用不同顏色區分顯示區 */
            }

            input {
                width: 100%;
                padding: 0.625rem;
                background-color: $gray-color;
                border: none;
                outline: none;
                border-radius: $radius;
                font-size: $font-size-base;
                text-indent: 5px;
                letter-spacing: 2px;
            }
        }

        .submit-btn {
            width: 100%;
            border: none;
            border-radius: $radius;
            background-color: $black-color;
            color: $white-color;
            font-size: $font-size-base;
            letter-spacing: 2px;
            padding: 0.625rem;
            cursor: pointer;
            margin-top: 20px;

            &:hover {
                background-color: $hover-color;
            }
        }

        .back-to-login {
            margin-top: 1.5rem;

            a {
                color: $black-color;
                text-decoration: none;
                letter-spacing: 2px;
            }
        }
    }

    .password-input {
        position: relative;

        input {
            width: 100%;
            padding: 0.625rem;
            border: 1px solid #ddd;
            border-radius: $radius;
        }

        span {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #333;
        }
    }
}
</style>
