<script>
import axios from 'axios';
import LeftBar from '@/components/LeftBar.vue';
import Header from '@/components/Header.vue';
import Swal from 'sweetalert2';

export default {
    data() {
        return {
            cgInput: [{ text: '' }],
            categories: [],
            originalCategories: [],
            isEditing: false,
            savedMenuList: [],
            selectedWorkstationId: null,
        };
    },
    components: {
        LeftBar,
        Header,
    },
    methods: {
        createWorkstation() {
            this.cgInput = this.cgInput.filter(input => input.text.trim() !== "");
            if (!Array.isArray(this.categories)) {
                this.categories = [];
            }
            if (this.categories.length === 0) {
                const promises = this.cgInput.map(input => {
                    const payload = { workstationName: input.text };
                    return axios.post('http://localhost:8080/workstation/createworkstation', payload);
                });

                Promise.all(promises)
                    .then(responses => {
                        const allSuccess = responses.every(response => response.status === 200);
                        if (allSuccess) {
                            Swal.fire('成功!', '工作檯已創建', 'success');
                            this.cgInput = [{ text: '' }];
                            this.fetchWorkstations();
                        } else {
                            Swal.fire('錯誤!', '某些工作檯創建失敗', 'error');
                        }
                    })
                    .catch(error => {
                        Swal.fire('錯誤!', '創建失敗', 'error');
                    });
                return;
            }

            const existingNames = new Set(this.categories.map(category => category.workstationName));
            const duplicateNames = this.cgInput.filter(input => existingNames.has(input.text));

            if (duplicateNames.length > 0) {
                Swal.fire('錯誤!', '工作檯名稱不能重複', 'error');
                return;
            }
            const promises = this.cgInput.map(input => {
                const payload = { workstationName: input.text };
                return axios.post('http://localhost:8080/workstation/createworkstation', payload);
            });

            Promise.all(promises)
                .then(responses => {
                    const allSuccess = responses.every(response => response.status === 200);
                    if (allSuccess) {
                        Swal.fire('成功!', '工作檯已創建', 'success');
                        this.cgInput = [{ text: '' }];
                        this.fetchWorkstations();
                    } else {
                        Swal.fire('錯誤!', '某些工作檯創建失敗', 'error');
                    }
                })
                .catch(error => {
                    Swal.fire('錯誤!', '創建失敗', 'error');
                });
        }
        ,

        updateWorkstation() {
            const duplicateNames = this.categories.filter(category =>
                this.categories.filter(c => c.workstationName === category.workstationName).length > 1
            );

            if (duplicateNames.length > 0) {
                Swal.fire('錯誤!', '工作檯名稱不能重複', 'error');
                return;
            }

            const promises = this.categories.map(category => {
                const payload = { workstationId: category.workstationId, workstationName: category.workstationName };
                return axios.post('http://localhost:8080/workstation/updateworkstation', payload);
            });

            Promise.all(promises)
                .then(responses => {
                    const allSuccess = responses.every(response => response.status === 200);
                    if (allSuccess) {
                        Swal.fire('成功!', '工作檯已更新', 'success');
                        this.isEditing = false;
                        this.fetchWorkstations();
                    } else {
                        Swal.fire('錯誤!', '工作檯更新失敗', 'error');
                    }
                })
                .catch(error => {
                    console.error('更新失敗', error);
                    Swal.fire('錯誤!', '更新失敗，工作檯不可為空白', 'error');
                });
        },

        fetchWorkstations() {
            axios.post('http://localhost:8080/workstation/searchworkstation', {})
                .then(response => {
                    console.log('搜索成功', response.data);
                    this.categories = response.data.data;

                    if (this.categories.length > 0) {
                        this.selectedWorkstationId = this.categories[0].workstationId;
                    }
                })
                .catch(error => {
                    console.log('搜索失敗', error);
                });
        },
        removeWorkstation(workstationId) {
            Swal.fire({
                title: '確定要刪除這個工作檯嗎?',
                showCancelButton: true,
                confirmButtonText: '刪除',
                cancelButtonText: '取消'
            }).then((result) => {
                if (result.isConfirmed) {
                    const payload = { workstationId: workstationId };
                    axios.post('http://localhost:8080/workstation/deleteworkstation', payload)
                        .then(response => {
                            if (response.status === 200) {
                                this.categories = this.categories.filter(category => category.workstationId !== workstationId);
                                this.originalCategories = this.originalCategories.filter(category => category.workstationId !== workstationId);
                                Swal.fire('成功!', '工作檯已刪除', 'success');
                            } else {
                                Swal.fire('錯誤!', '刪除失敗', 'error');
                            }
                        })
                        .catch(error => {
                            console.error('刪除失敗', error);
                            Swal.fire('錯誤!', '刪除失敗', 'error');
                        });
                }
            });
        },

        addCgInput() {
            this.cgInput.push({ text: '' });
        },

        editCategory() {
            if (this.isEditing) {
                this.categories = JSON.parse(JSON.stringify(this.originalCategories));
            } else {
                this.originalCategories = JSON.parse(JSON.stringify(this.categories));
            }
            this.isEditing = !this.isEditing;
        },
        async fetchMenu() {
            try {
                const response = await axios.get("http://localhost:8080/menu/all");
                this.savedMenuList = response.data;

            } catch (error) {
                console.error('獲取菜單時發生錯誤:', error);
                Swal.fire({
                    title: '錯誤',
                    text: '無法獲取菜單資料，請稍後再試',
                    icon: 'error',
                    confirmButtonText: '好的'
                });
            }
        },
        selectWorkstation(workstationId) {
            this.selectedWorkstationId = workstationId;
        }
    },
    computed: {
        filteredMenuList() {
            return this.savedMenuList.filter(menu => menu.workstationId === this.selectedWorkstationId);
        }
    },
    created() {
        this.fetchWorkstations();
        this.fetchMenu();
    }
};
</script>

<template>

    <div class="menuCategory">
        <h1>工作檯分類</h1>
        <div class="optionArea">
            <div v-for="(category, index) in categories" :key="index" class="cOption"
                :class="{ selected: selectedWorkstationId === category.workstationId }"
                @click="selectWorkstation(category.workstationId)">
                <span v-if="!isEditing">
                    {{ category.workstationName }}
                </span>
                <input v-if="isEditing" type="text" v-model="category.workstationName" placeholder="請輸入工作檯名稱" />
                <i class="fa-regular fa-circle-xmark" v-if="isEditing"
                    @click="removeWorkstation(category.workstationId)"></i>
            </div>

            <div class="inputOp" v-for="(input, index) in cgInput" :key="index">
                <input type="text" v-model="input.text" placeholder="請輸入工作檯名稱" />
            </div>
            <i class="fa-solid fa-circle-plus" @click="addCgInput()"></i>
        </div>
        <div @click="isEditing ? updateWorkstation() : createWorkstation()" class="saveCategory">
            {{ isEditing ? '更新' : '儲存' }}
        </div>
        <div @click="editCategory" class="editCategory">編輯</div>
    </div>
    <div class="menuList">
        <div v-for="(menu, index) in filteredMenuList" :key="index" class="menuItem">
            {{ menu.mealName }}
        </div>
        <div v-if="filteredMenuList.length === 0">此工作檯目前無菜單</div>
    </div>
</template>


<style scoped lang="scss">
$divColor: #fff;
$addDiv: #343a3f;

* {
    font-family: "Noto Sans TC", sans-serif;
}

.menuCategory {
    width: 21%;
    height: 100%;
    border-radius: 10px;
    border: 1px solid rgba(grey, 0.5);
    border: 1px solid;
    box-shadow: -3px 3px 4px black;
    display: flex;
    justify-content: start;
    align-items: center;
    flex-direction: column;
    position: absolute;
    top: 0%;
    left: 0%;
    background-color: white;


    h1 {
        margin: 1% auto;
        letter-spacing: 3px;
        font-family: "Noto Sans TC", sans-serif;
    }

    .optionArea {
        width: 87%;
        height: 84%;
        margin-bottom: 3%;
        display: flex;
        justify-content: start;
        align-items: center;
        flex-direction: column;
        overflow-x: hidden;
        scrollbar-width: none;

        .cOption {
            width: 100%;
            height: 6%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-radius: 5px;
            margin-bottom: 5%;
            background-color: #f2f4f8;
            cursor: pointer;

            &.selected {
                color: #fff;
                background-color: #697077;
            }

            span {
                font-weight: bold;
                font-family: "Noto Sans TC", sans-serif;
                margin-left: 2.5%;
            }

            .fa-circle-xmark {
                cursor: pointer;
            }
        }

        .inputOp {
            width: 100%;
            height: 6%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-radius: 5px;
            margin-bottom: 5%;
            background-color: #f2f4f8;
        }

        .fa-circle-plus {
            font-size: 30px;
            cursor: pointer;
        }
    }

    .saveCategory {
        width: 90%;
        height: 37px;
        border-radius: 10px;
        margin-bottom: 3%;
        cursor: pointer;
        display: flex;
        justify-content: center;
        align-items: center;
        color: white;
        background-color: #343a3f;
        font-family: "Noto Sans TC", sans-serif;
    }

    .editCategory {
        width: 90%;
        height: 37px;
        border-radius: 10px;
        margin-bottom: 3%;
        cursor: pointer;
        display: flex;
        justify-content: center;
        align-items: center;
        color: black;
        background-color: #dde1e6;
        font-family: "Noto Sans TC", sans-serif;
    }
}

input {
    width: 95%;
    border: none;
    background-color: transparent;
    margin-left: 2.5%;
    font-size: 18px;
    font-weight: bold;
    font-family: "Noto Sans TC", sans-serif;
}

.menuList {
    width: 78%;
    height: 100%;
    border-radius: 10px;
    border: 1px solid rgba(grey, 0.5);
    border: 1px solid;
    box-shadow: -3px 3px 4px black;
    display: flex;
    justify-content: start;
    align-items: start;
    flex-direction: column;
    position: absolute;
    top: 0%;
    left: 22%;
    background-color: white;
    padding-left: 2%;

    .menuItem {
        margin-top: 2%;
        border-left: 5px solid #C1C7CD;
        padding-left: 0.5%;
    }
}
</style>
