<script>
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router'; // 導入 useRouter

export default {
    setup() {
        const router = useRouter(); // 獲取 router 實例

        return { router };
    },
    data() {
        return {

            user: {
                name: '',
                phone: '',
                birthday: '',
                password: '',
                email: ''

            },
            confirmPassword: ''
        };
    },
    methods: {
        handleRegister() {
            //密碼兩次輸入不一樣
            if (this.user.password !== this.confirmPassword) {

                Swal.fire({
                    title: '確認密碼錯誤',
                    icon: 'error',
                    confirmButtonText: '確定',
                })
                return;
            }

            // 判斷手機號碼格式
            const phoneRegex = /^09\d{8}$/; // 以 09 開頭，後面 8 個數字
            if (!phoneRegex.test(this.user.phone)) {
                Swal.fire({
                    title: '電話號碼格式不正確',
                    icon: 'error',
                    confirmButtonText: '確定',
                });
                return;
            }

            // 準備要傳送的資料
            const userData =
            {
                name: this.user.name,
                phone: this.user.phone,
                birthday: this.user.birthday,
                pwd: this.user.password,
                email: this.user.email,
            };

            // 將物件轉換為 JSON 字符串
            const jsonData = JSON.stringify(userData);

            // Fetch API 傳送 jsonData 到後端
            console.log('要傳送的資料:', jsonData);
            fetch('http://localhost:8080/api/member/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: jsonData
            })
                .then(response => response.json())
                .then(data => {
                    if (data.code == "200") {
                        Swal.fire({
                            title: data.message,
                            icon: 'success',
                            confirmButtonText: '確定',
                        })
                        this.router.push('/');
                    } else {
                        Swal.fire({
                            title: data.message,
                            icon: 'error',
                            confirmButtonText: '確定',
                        })
                    }
                    console.log('成功:', data);
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
    }
};
</script>


<template>
    <div class="register-container">
        <div class="register-box">
            <img src="../assets/Logo.jpg" alt="logo" class="logo" />
            <h2>註冊</h2>
            <form @submit.prevent="handleRegister">
                <div class="input-group">
                    <label for="name">姓名</label>
                    <input v-model="user.name" type="text" id="name" placeholder="請輸入姓名" required autocomplete="off" />
                </div>
                <div class="input-group">
                    <label for="phone">電話號碼</label>
                    <input v-model="user.phone" type="tel" id="phone" placeholder="輸入電話號碼" required
                        autocomplete="off" />
                </div>
                <div class="input-group">
                    <label for="birthday">生日</label>
                    <input v-model="user.birthday" type="date" id="birthday" placeholder="請輸入生日" required
                        autocomplete="off" />
                </div>
                <div class="input-group">
                    <label for="email">電子郵件</label>
                    <input v-model="user.email" type="email" id="email" placeholder="請輸入電子郵件" required
                        autocomplete="off" />
                </div>
                <div class="input-group">
                    <label for="password">密碼</label>
                    <input v-model="user.password" type="password" id="password" placeholder="請輸入密碼" required
                        autocomplete="off" />
                </div>


                <div class="input-group">
                    <label for="confirmPassword">確認密碼</label>
                    <input v-model="confirmPassword" type="password" id="confirmPassword" placeholder="再次確認密碼" required
                        autocomplete="off" />
                </div>
                <button type="submit" class="register-btn">註冊</button>
            </form>
            <router-link to="/" class="login-link">返回登入頁面</router-link> <!-- 返回登入頁面 -->
        </div>
    </div>
</template>



<style lang="scss">
$bg-color: #f0f2f5;
$box-color: #fff;
$primary-color: #333;
$border-color: #ddd;
$hover-color: #555;
$font-size-base: 14px; // 縮小字體大小
$radius: 5px;

.register-container {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    background-size: cover;

    .register-box {
        background-color: $box-color;
        padding: 1.5rem; // 減少 padding
        border-radius: 10px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        text-align: center;
        width: 24rem; // 縮小寬度

        .logo {
            width: 8rem; // 縮小 logo
            margin-bottom: 1rem;
        }

        h2 {
            margin-bottom: 1rem; // 減少標題與表單間距
            font-size: 1.25rem; // 縮小標題字體
            color: $primary-color;
        }

        form {
            .input-group {
                margin-bottom: 1rem; // 減少欄位間距
                text-align: left;

                label {
                    display: block;
                    margin-bottom: 0.25rem;
                    color: $primary-color;
                    font-size: $font-size-base;
                }

                input {
                    width: 100%;
                    padding: 0.5rem; // 減少欄位內部間距
                    font-size: $font-size-base;
                    border: 1px solid $border-color;
                    border-radius: $radius;
                    box-sizing: border-box;
                }
            }

            .register-btn {
                width: 100%;
                padding: 0.5rem; // 減少按鈕內部間距
                font-size: $font-size-base;
                background-color: $primary-color;
                color: $box-color;
                border: none;
                border-radius: $radius;
                cursor: pointer;

                &:hover {
                    background-color: $hover-color;
                }
            }
        }

        .login-link {
            display: inline-block;
            margin-top: 1rem;
            padding: 0.5rem; // 減少返回按鈕內部間距
            font-size: $font-size-base;
            background-color: $hover-color;
            color: $box-color;
            border-radius: $radius;
            text-decoration: none;

            &:hover {
                background-color: darken($hover-color, 10%);
            }
        }
    }
}
</style>