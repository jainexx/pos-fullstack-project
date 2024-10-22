<script>
import Swal from "sweetalert2";
import axios from "axios";
import { number } from "echarts";
import ComboComponent from "./combo/ComboComponent.vue";
import { ref } from "vue";
import defaultMenuImage from "@/assets/default-menu-img.png";
export default {
    data() {
        return {
            defaultMenuImage,
            startX: 0,
            optionType: "checkbox",
            showEditPen: false,
            selectedCategory: null, // 選中的菜單分類
            selectedCategoryId: null, // 選中的菜單分類Id
            selectedWorkbench: "0", //選中的工作檯
            editingWorkbench: false,
            categories: [], // 已存在資料庫的菜單分類
            cgInput: [], // 菜單分類的input
            editingIndexes: [], // 用來追蹤正在編輯的菜單分類
            modifiedCategories: [], // 編輯過的分類推入這個陣列
            savedMenuList: [], // 已存在資料庫的菜單
            menuList: [], // 菜單的input
            editIndexList: [], // 正在編輯的項目索引
            editedMenuItems: [], // 儲存編輯過的菜單項目
            savedCustList: [], // 已存在資料庫的客製化選項
            custList: [], // 客製化的input
            editStates: [], // 客製化的編輯狀態
            originalOptions: [], // 儲存原始數據
            workstationData: [], // DB中的工作檯數據
            selectedWorkstationId: this.selectedWorkstation ? this.selectedWorkstation.workstationId : 0, //當前選擇的工作檯ID
            selectedWorkstation: "", //當前選擇的工作檯名稱
            lastSelectedWorkstationId: 0, // 用於儲存上次的選擇
            comboPage: false,
            comboCount: 0, //儲存後端資料的計數
        };
    },
    components: {
        ComboComponent,
    },
    methods: {
        startTouch(event, index) {
            this.categories[index].startX = event.touches[0].clientX;
        },
        moveTouch(event, index) {
            const currentX = event.touches[0].clientX;
            this.categories[index].translateX = currentX - this.categories[index].startX; // 根據滑動距離更新 translateX
            if (this.categories[index].translateX < -55) {
                this.categories[index].translateX = -55;
            }
            if (this.categories[index].translateX > 0) {
                this.categories[index].translateX = 0; // 避免滑動超過初始位置
            }
        },
        endTouch(index) {
            if (this.categories[index].translateX > -50) {
                this.categories[index].translateX = 0;
            }
        },
        selectCategory(category) {
            if (this.menuList.length > 0 || this.editedMenuItems.length > 0) {
                Swal.fire({
                    title: "錯誤",
                    text: "請先儲存菜單",
                    icon: "error",
                    confirmButtonText: "好的",
                });
                return;
            }
            if (this.custList.length > 0 || this.originalOptions.length > 0) {
                Swal.fire({
                    title: "錯誤",
                    text: "請先儲存客製化選項",
                    icon: "error",
                    confirmButtonText: "好的",
                });
                return;
            }
            this.selectedCategory = category.category;
            this.selectedCategoryId = category.categoryId;
            this.lastSelectedWorkstationId = category.workstationId;
            this.selectedWorkstationId = this.lastSelectedWorkstationId;
            this.selectedWorkstation = this.workstationData.find((wsItem) => wsItem.workstationId === this.lastSelectedWorkstationId);
            this.editingWorkbench = false;
            this.fetchCategories();
            // console.log(this.selectedCategory);
            // console.log(this.selectedCategoryId);
            if (category.category == "套餐") {
                this.comboPage = true;
            } else {
                this.comboPage = false;
            }
        },
        // 刪除菜單分類
        confirmDelete(cIndex) {
            const categoryId = this.categories[cIndex].categoryId; //根據 cIndex 取得 categoryId

            Swal.fire({
                title: "確定要刪除這項菜單分類嗎？",
                icon: "warning",
                showCancelButton: true,
                confirmButtonText: "確定",
                cancelButtonText: "取消",
            }).then(async (result) => {
                if (result.isConfirmed) {
                    try {
                        const response = await axios.post("http://localhost:8080/category/delete", {
                            categoryId: categoryId, // 傳遞 categoryId 給後端
                        });
                        console.log(response);
                        if (response.data.code == 200) {
                            // 從前端 categories 列表中移除該分類
                            this.categories = this.categories.filter((category) => category.categoryId !== categoryId);
                            Swal.fire("已刪除!", "該分類已被刪除。", "success");
                            this.selectedCategoryId = null;
                            this.selectedCategory = null;
                            this.fetchCategories();
                        } else {
                            Swal.fire("錯誤!", "刪除分類失敗。", "error");
                        }
                    } catch (error) {
                        console.error("刪除分類時發生錯誤：", error);
                        Swal.fire("錯誤!", "請稍後再嘗試。", "error");
                    }
                }
            });
        },
        addCgInput() {
            this.cgInput.push({ category: "" });
            this.$nextTick(() => {
                // 獲取最新新增的輸入框元素
                const lastCgInput = document.querySelector(".fa-circle-plus:last-child");
                if (lastCgInput) {
                    lastCgInput.scrollIntoView({ behavior: "smooth" }); // 平滑滾動到新增的輸入框
                }
            });
            this.selectedCategory = null;
            this.selectedCategoryId = null;
        },
        editCategory() {
            this.showEditPen = !this.showEditPen;
        },
        startEditing(index) {
            if (!this.editingIndexes.includes(index)) {
                this.editingIndexes.push(index);
                console.log("開始編輯:", this.editingIndexes);
            }
            // 檢查是否已經在編輯狀態
            const category = this.categories[index];
            if (!this.editingIndexes.some((item) => item.categoryId === category.categoryId)) {
                // 將該 categoryId 和 category 放入 editingIndexes
                this.editingIndexes.push({
                    categoryId: category.categoryId,
                    category: category.category,
                });
                console.log("正在編輯的分類:", this.editingIndexes);
            }
        },
        stopEditing(index, isBlur) {
            if (isBlur) {
                // 用戶沒有按下 Enter 鍵，提示警告視窗
                Swal.fire({
                    title: "注意!",
                    text: "請先按下 Enter 以暫存資料",
                    icon: "warning",
                    confirmButtonText: "好的",
                });
                return; // 不繼續執行 stopEditing 邏輯
            }

            this.editingIndexes = this.editingIndexes.filter((i) => i !== index);
            // 移除 editingIndexes 中的該項目
            const category = this.categories[index];
            this.editingIndexes = this.editingIndexes.filter((item) => item.categoryId !== category.categoryId);

            // 檢查該項目是否已修改，若修改則推到 modifiedCategories
            const modifiedCategory = {
                categoryId: category.categoryId,
                category: category.category,
            };

            const alreadyModified = this.modifiedCategories.some((item) => item.categoryId === modifiedCategory.categoryId);

            if (!alreadyModified) {
                this.modifiedCategories.push(modifiedCategory);
                console.log("已修改的分類:", this.modifiedCategories);
            }
        },
        isEditing(index) {
            // 檢查該 index 是否正在編輯
            return this.editingIndexes.includes(index);
        },
        switchSta(menu) {
            menu.available = !menu.available;
            // 查找正在編輯的菜單項目，並更新其 available 狀態
            const itemToEdit = this.editedMenuItems.find((item) => item.mealName === menu.mealName);
            if (itemToEdit) {
                itemToEdit.available = menu.available;
            }
        },
        // 新增菜單input
        addMenu() {
            if (this.selectedCategory == null) {
                Swal.fire({
                    title: "錯誤",
                    text: "請先選擇菜單分類",
                    icon: "error",
                    confirmButtonText: "好的",
                });
                return;
            }
            this.menuList.push({
                mealName: "", // 餐點名稱
                price: "", // 餐點金額
                workstationId: this.selectedWorkstationId, // 工作檯
                available: true, // 供應狀態
                categoryId: this.selectedCategoryId, //餐點的菜單分類Id
                pictureName: "", // 新增 pictureName 屬性以儲存圖片名稱或 base64
            });
            this.$nextTick(() => {
                // 獲取最新新增的餐點元素
                const lastMenuItem = document.querySelector(".menuItem:last-child");
                if (lastMenuItem) {
                    lastMenuItem.scrollIntoView({ behavior: "smooth" }); // 平滑滾動到新增的餐點
                }
            });
        },
        removeMenu(index) {
            this.menuList.splice(index, 1);
        },
        addCust() {
            if (this.selectedCategory == null) {
                Swal.fire({
                    title: "錯誤",
                    text: "請先選擇菜單分類",
                    icon: "error",
                    confirmButtonText: "好的",
                });
                return;
            }
            this.custList.push({
                categoryId: this.selectedCategoryId, //餐點的菜單分類Id
                optionTitle: "", // 客製化標題
                optionType: "checkbox", // 客製化選擇
                options: [
                    //客製化選項
                    { optionContent: "", extraPrice: "" },
                ],
            });
            this.$nextTick(() => {
                // 獲取最新新增的餐點元素
                const lastCustItem = document.querySelector(".custInput:last-child");
                if (lastCustItem) {
                    lastCustItem.scrollIntoView({ behavior: "smooth" }); // 平滑滾動到新增的餐點
                }
            });
        },
        removeCust(index) {
            this.custList.splice(index, 1);
        },
        updateWorkbench(event) {
            // 確保將選項值轉為數字
            this.selectedWorkstationId = Number(event.target.value);
            this.selectedWorkstation = this.workstationData.find((wsItem) => wsItem.workstationId === this.selectedWorkstationId) || null;

            if (this.selectedWorkstation) {
                console.log("選擇的工作檯 ID:", this.selectedWorkstationId);
                console.log("選擇的工作檯名稱:", this.selectedWorkstation.workstationName);
            } else {
                console.log("找不到對應的工作檯");
            }
        },
        addOption(custIndex) {
            // 獲取指定索引的 custList 項目
            const targetCustItem = this.custList[custIndex];

            // 檢查是否存在該項目並新增選項
            if (targetCustItem) {
                targetCustItem.options.push({
                    optionContent: "", // 選項內容
                    extraPrice: "", // 選項金額
                });

                // 平滑滾動到新增的選項
                this.$nextTick(() => {
                    const groupedOptionsLength = Object.keys(this.groupedOptions).length;
                    const custInputs = document.querySelectorAll(".custInput");
                    const targetCustInput = custInputs[custIndex + groupedOptionsLength]; // 根據 custIndex 動態定位
                    if (targetCustInput) {
                        const lastOption = targetCustInput.querySelector(".oneOption:last-child");
                        if (lastOption) {
                            lastOption.scrollIntoView({ behavior: "smooth" });
                        }
                    }
                });
            }
        },
        // 儲存菜單分類
        async saveCategory() {
            this.showEditPen = false;
            const categoryData = this.cgInput.map((item) => ({ category: item.category }));

            try {
                for (const category of categoryData) {
                    const response = await axios.post("http://localhost:8080/category/create", category);

                    if (response.data.code === 200) {
                        const newCategory = { text: category.category, translateX: 0 };
                        this.categories.push(newCategory);

                        Swal.fire({
                            title: "成功",
                            text: "成功新增菜單分類",
                            icon: "success",
                            confirmButtonText: "好的",
                        });
                    } else {
                        Swal.fire({
                            title: "錯誤",
                            text: "菜單分類已存在",
                            icon: "error",
                            confirmButtonText: "好的",
                        });
                    }
                }
                this.cgInput = [];
                this.selectedCategory = null;
                this.selectedCategoryId = null;
                if (this.modifiedCategories.length > 0) {
                    for (const modifiedCategory of this.modifiedCategories) {
                        // 檢查是否有重複的分類名稱，且忽略相同的 categoryId
                        const isDuplicate = this.categories.some((category) => category.category === modifiedCategory.category && category.categoryId !== modifiedCategory.categoryId);

                        if (isDuplicate) {
                            // 如果有重複，顯示警告，並終止儲存程序
                            Swal.fire({
                                title: "錯誤",
                                text: `分類名稱 "${modifiedCategory.category}" 已存在，請使用不同的名稱`,
                                icon: "error",
                                confirmButtonText: "好的",
                            });
                            return; // 中斷後續處理
                        }

                        const response = await axios.post("http://localhost:8080/category/update", modifiedCategory);

                        if (response.data.code === 200) {
                            Swal.fire({
                                title: "成功",
                                text: "成功更新菜單分類",
                                icon: "success",
                                confirmButtonText: "好的",
                            });
                        } else {
                            Swal.fire({
                                title: "錯誤",
                                text: "更新菜單分類失敗",
                                icon: "error",
                                confirmButtonText: "好的",
                            });
                        }
                    }

                    // 清空已修改的分類陣列
                    this.modifiedCategories = [];
                }
                this.selectedCategory = categoryData.category;
                this.fetchCategories();
            } catch (error) {
                console.error("儲存分類時發生錯誤：", error);
                Swal.fire({
                    title: "錯誤",
                    text: "請稍後再嘗試",
                    icon: "error",
                    confirmButtonText: "好的",
                });
            }
        },
        // 更新菜單分類
        fetchCategories() {
            axios
                .get("http://localhost:8080/category/all")
                .then((response) => {
                    this.categories = response.data.map((category) => ({
                        categoryId: category.categoryId,
                        category: category.category,
                        workstationId: category.workstationId,
                        translateX: 0, // 初始化 translateX 為 0
                    }));
                    // console.log(response.data); // 所有 Categories 資料
                })
                .catch((error) => {
                    console.error("獲取分類時發生錯誤:", error);
                });
        },
        // 執行新增或編輯操作
        saveMenu() {
            // 檢查是否有新增或修改的菜單項目
            if (this.menuList.length > 0 || this.editedMenuItems.length > 0 || this.selectedWorkstationId !== this.lastSelectedWorkstationId) {
                if (this.menuList.length > 0) {
                    this.createMenu(); // 處理新增菜單
                    // console.log(this.menuList);
                }
                if (this.editedMenuItems.length > 0) {
                    this.updateMenu(); // 處理修改菜單
                    // console.log(this.editedMenuItems);
                }
                if (this.selectedWorkstationId !== this.lastSelectedWorkstationId) {
                    this.updateMenuWorkId(); // 處理修改菜單的工作檯
                }
            } else {
                Swal.fire({
                    title: "提示",
                    text: "沒有需要儲存的變更",
                    icon: "info",
                    confirmButtonText: "好的",
                });
            }
        },
        // 新增菜單到資料庫
        async createMenu() {
            console.log(this.menuList);

            let invalidMealNames = [];
            let invalidPrices = [];

            // 檢查 menuList 中每個菜單項的 mealName 和 price
            this.menuList.forEach((menuItem) => {
                if (menuItem.mealName.trim() === "") {
                    invalidMealNames.push(menuItem);
                }
                if (menuItem.price <= 0) {
                    invalidPrices.push(menuItem);
                }
            });

            // 如果有無效的餐點名稱，顯示提示框
            if (invalidMealNames.length > 0) {
                Swal.fire({
                    title: "錯誤",
                    text: "餐點名稱不能為空",
                    icon: "error",
                    confirmButtonText: "好的",
                });
                return; // 如果有無效項目，則不繼續執行
            }

            // 如果有無效的價格，顯示提示框
            if (invalidPrices.length > 0) {
                Swal.fire({
                    title: "錯誤",
                    text: "以下餐點價格無效：" + invalidPrices.map((item) => item.mealName).join(", "),
                    icon: "error",
                    confirmButtonText: "好的",
                });
                return; // 如果有無效項目，則不繼續執行
            }
            try {
                const menuData = { menuList: this.menuList };
                console.log(menuData);
                const response = await axios.post("http://localhost:8080/menu/create", menuData);
                if (response.data.code === 200) {
                    Swal.fire({
                        title: "成功",
                        text: "菜單已成功儲存",
                        icon: "success",
                        confirmButtonText: "好的",
                    });
                    this.fetchMenu();
                    this.menuList = [];
                } else {
                    Swal.fire({
                        title: "錯誤",
                        text: "儲存菜單時發生錯誤",
                        icon: "error",
                        confirmButtonText: "好的",
                    });
                }
            } catch (error) {
                console.error("新增菜單失敗:", error);
                Swal.fire({
                    title: "錯誤",
                    text: "請稍後再試",
                    icon: "error",
                    confirmButtonText: "好的",
                });
            }
        },
        // 編輯菜單
        async updateMenu() {
            let invalidPrices = [];

            // 檢查每個菜單項的price
            this.editedMenuItems.forEach((item) => {
                if (item.price <= 0) {
                    invalidPrices.push(item);
                }
            });

            // 如果有無效的價格，顯示提示框
            if (invalidPrices.length > 0) {
                Swal.fire({
                    title: "錯誤",
                    text: "以下餐點價格無效：" + invalidPrices.map((item) => item.mealName).join(", "),
                    icon: "error",
                    confirmButtonText: "好的",
                });
                return; // 如果有無效項目，則不繼續執行
            }
            try {
                for (const item of this.editedMenuItems) {
                    const response = await axios.post("http://localhost:8080/menu/update", {
                        mealName: item.mealName,
                        categoryId: item.categoryId,
                        price: item.price,
                        workstationId: item.workstationId,
                        available: item.available,
                        pictureName: item.pictureName || "",
                    });
                    if (response.data.code !== 200) {
                        throw new Error(response.data.message || "更新失敗");
                    }
                }

                Swal.fire({
                    title: "成功",
                    text: "菜單更新成功",
                    icon: "success",
                    confirmButtonText: "好的",
                });

                this.fetchMenu(); // 刷新菜單列表
                this.editedMenuItems = []; // 清空修改過的菜單列表
                this.editIndexList = []; // 清空編輯索引
                this.editMode = false; // 關閉編輯模式
            } catch (error) {
                console.error("更新菜單失敗:", error);
                Swal.fire({
                    title: "錯誤",
                    text: "請稍後再試",
                    icon: "error",
                    confirmButtonText: "好的",
                });
            }
        },
        // 編輯菜單的workId
        async updateMenuWorkId() {
            const categoryId = this.selectedCategoryId;
            const workstationId = this.selectedWorkstationId;

            try {
                const response = await axios.post("http://localhost:8080/menu/updateWorkId", {
                    workstationId,
                    categoryId,
                });

                if (response.data.code === 200) {
                    Swal.fire({
                        title: "成功",
                        text: "工作檯更新成功",
                        icon: "success",
                        confirmButtonText: "好的",
                    });
                    // 根據 workstationId 更新 selectedWorkstation
                    this.selectedWorkstation = this.workstationData.find((ws) => ws.workstationId === workstationId);
                    this.editingWorkbench = false;
                } else {
                    Swal.fire({
                        title: "錯誤",
                        text: response.data.message,
                        icon: "error",
                        confirmButtonText: "好的",
                    });
                }
            } catch (error) {
                console.error("工作檯更新失敗:", error);
                Swal.fire({
                    title: "錯誤",
                    text: "請稍後再試",
                    icon: "error",
                    confirmButtonText: "好的",
                });
            }
        },
        // 更新菜單
        async fetchMenu() {
            try {
                const response = await axios.get("http://localhost:8080/menu/all");
                this.savedMenuList = response.data;
                console.log(this.savedMenuList); // 查看獲取的菜單資料
            } catch (error) {
                // console.error('獲取菜單時發生錯誤:', error);
                Swal.fire({
                    title: "錯誤",
                    text: "無法獲取菜單資料，請稍後再試",
                    icon: "error",
                    confirmButtonText: "好的",
                });
            }
        },
        // 進入編輯模式
        editMenuFromDB(mealName) {
            // 檢查是否已經在編輯列表中
            if (!this.editIndexList.includes(mealName)) {
                this.editIndexList.push(mealName);
            }

            // 如果該菜單項目還沒被加入到 editedMenuItems，則初始化該項目
            const itemToEdit = this.savedMenuList.find((item) => item.mealName === mealName);
            const existingItem = this.editedMenuItems.find((item) => item.mealName === mealName);

            if (!existingItem) {
                this.editedMenuItems.push({ ...itemToEdit });
            }

            // console.log("目前正在編輯的項目:", this.editedMenuItems);
        },
        editWorkbench() {
            // 切換編輯模式
            this.editingWorkbench = !this.editingWorkbench;

            if (this.editingWorkbench) {
                // 開始編輯時設置 selectedWorkstationId 為當前選中的工作檯 ID
                this.selectedWorkstationId = this.selectedWorkstation ? this.selectedWorkstation.workstationId : null;
            } else {
                // 停止編輯時，顯示當前選擇的工作檯名稱
                const selected = this.workstationData.find((ws) => ws.workstationId === this.selectedWorkstationId);
                this.selectedWorkstation = selected || { workstationName: "未選擇工作檯" };
            }
        },
        updateEditedItem(item) {
            const index = this.editedMenuItems.findIndex((editedItem) => editedItem.mealName === item.mealName);
            if (index !== -1) {
                this.editedMenuItems[index] = { ...item };
            } else {
                this.editedMenuItems.push({ ...item });
            }
        },
        // 刪除菜單
        async deleteMenuFromDB(item) {
            Swal.fire({
                title: "確定要刪除這項菜單嗎？",
                icon: "warning",
                showCancelButton: true,
                confirmButtonText: "確定",
                cancelButtonText: "取消",
            }).then(async (result) => {
                if (result.isConfirmed) {
                    const mealName = item;
                    const categoryId = this.selectedCategoryId;
                    try {
                        // 發送刪除請求到後端，傳遞 mealName 和 categoryId 作為參數
                        const response = await axios.post("http://localhost:8080/menu/delete", { mealName, categoryId });

                        if (response.data.code === 200) {
                            // 刪除成功，在前端列表中移除該項目
                            this.savedMenuList = this.savedMenuList.filter((item) => item.mealName !== mealName || item.categoryId !== categoryId);

                            Swal.fire({
                                title: "成功",
                                text: "菜單已刪除",
                                icon: "success",
                                confirmButtonText: "好的",
                            });
                        } else {
                            Swal.fire({
                                title: "錯誤",
                                text: "刪除失敗，請稍後再試",
                                icon: "error",
                                confirmButtonText: "好的",
                            });
                        }
                    } catch (error) {
                        console.error("刪除菜單時發生錯誤：", error);
                        Swal.fire({
                            title: "錯誤",
                            text: "請稍後再試",
                            icon: "error",
                            confirmButtonText: "好的",
                        });
                    }
                }
            });
        },
        // 儲存客製化選項
        saveCust() {
            if (this.originalOptions.length > 0) {
                // 過濾掉空的 originalOptions，僅處理已編輯的項目
                const updateRequests = this.originalOptions
                    .map((option, index) => {
                        if (option) {
                            // 只處理非空的項目
                            return {
                                categoryId: option.categoryId,
                                optionTitle: Object.keys(this.groupedOptions)[index],
                                optionType: option.optionType,
                                options: option.optionContent.map((content, opIndex) => ({
                                    optionContent: content,
                                    extraPrice: option.extraPrice[opIndex],
                                })),
                            };
                        }
                        return null; // 對於未編輯的項目，返回 null
                    })
                    .filter((req) => req !== null); // 過濾掉 null 的項目
                console.log(updateRequests);

                // 發送更新請求
                axios
                    .post("http://localhost:8080/option/update", updateRequests)
                    .then((response) => {
                        if (response.data.code == 200) {
                            Swal.fire({
                                title: "成功",
                                text: "客製化選項已成功更新",
                                icon: "success",
                                confirmButtonText: "好的",
                            });
                            // 清空 originalOptions
                            this.originalOptions = [];
                            this.editStates = [];
                            this.fetchCust(); // 重新加載資料
                        } else {
                            Swal.fire({
                                title: "錯誤",
                                text: "更新客製化選項時發生錯誤，請檢查輸入資料",
                                icon: "error",
                                confirmButtonText: "好的",
                            });
                        }
                    })
                    .catch((error) => {
                        console.error(error);
                        Swal.fire({
                            title: "錯誤",
                            text: "更新客製化選項時發生錯誤",
                            icon: "error",
                            confirmButtonText: "好的",
                        });
                    });
            }
            if (this.custList.length > 0) {
                // 檢查每個選項的 extraPrice 和唯一性
                for (const cust of this.custList) {
                    if (cust.optionTitle == "") {
                        Swal.fire({
                            title: "錯誤",
                            text: "請輸入客製化選項標題",
                            icon: "error",
                            confirmButtonText: "好的",
                        });
                        return;
                    }

                    // 檢查 extraPrice
                    for (const option of cust.options) {
                        if (option.optionContent == "") {
                            Swal.fire({
                                title: "錯誤",
                                text: "請輸入客製化選項",
                                icon: "error",
                                confirmButtonText: "好的",
                            });
                            return;
                        }
                        if (option.extraPrice == null || option.extraPrice === "") {
                            Swal.fire({
                                title: "錯誤",
                                text: "請輸入金額",
                                icon: "error",
                                confirmButtonText: "好的",
                            });
                            return;
                        }
                        if (option.extraPrice < 0) {
                            Swal.fire({
                                title: "錯誤",
                                text: "每個額外價格必須大於或等於零",
                                icon: "error",
                                confirmButtonText: "好的",
                            });
                            return;
                        }
                    }

                    // 檢查 optionTitle, categoryId 和 optionContent 的組合是否已存在
                    for (const option of cust.options) {
                        const exists = this.savedCustList.some((savedOption) => savedOption.optionTitle === cust.optionTitle && savedOption.categoryId === cust.categoryId);

                        if (exists) {
                            Swal.fire({
                                title: "錯誤",
                                text: "此選項的組合已存在",
                                icon: "error",
                                confirmButtonText: "好的",
                            });
                            return;
                        }
                    }
                }

                // 建立要傳送到後端的資料結構
                const requests = this.custList.map((cust) => ({
                    categoryId: cust.categoryId,
                    optionTitle: cust.optionTitle,
                    optionType: cust.optionType,
                    options: cust.options.map((option) => ({
                        optionContent: option.optionContent,
                        extraPrice: option.extraPrice,
                    })),
                }));

                console.log(requests);

                // 使用 Axios 發送 POST 請求到後端
                axios
                    .post("http://localhost:8080/option/create", requests)
                    .then((response) => {
                        if (response.data.code == 200) {
                            Swal.fire({
                                title: "成功",
                                text: "客製化選項已成功儲存",
                                icon: "success",
                                confirmButtonText: "好的",
                            });
                            // 清空 custList
                            this.custList = [];
                            this.fetchCust();
                        } else {
                            // 處理其他狀況的錯誤消息
                            Swal.fire({
                                title: "錯誤",
                                text: "儲存客製化選項時發生錯誤，請檢查輸入資料",
                                icon: "error",
                                confirmButtonText: "好的",
                            });
                        }
                    })
                    .catch((error) => {
                        console.error(error);
                        Swal.fire({
                            title: "錯誤",
                            text: "儲存客製化選項時發生錯誤",
                            icon: "error",
                            confirmButtonText: "好的",
                        });
                    });
            }
        },
        // 更新客製化選項
        async fetchCust() {
            try {
                const response = await axios.get("http://localhost:8080/option/all");
                this.savedCustList = response.data;
                //console.log(this.savedCustList);
            } catch (error) {
                console.error("獲取客製化選項時發生錯誤:", error);
                Swal.fire({
                    title: "錯誤",
                    text: "無法獲取客製化菜單資料，請稍後再試",
                    icon: "error",
                    confirmButtonText: "好的",
                });
            }
        },
        // 刪除客製化選項
        async deleteCustFromDB(index) {
            Swal.fire({
                title: "確定要刪除這項客製化選項嗎？",
                icon: "warning",
                showCancelButton: true,
                confirmButtonText: "確定",
                cancelButtonText: "取消",
            }).then(async (result) => {
                if (result.isConfirmed) {
                    try {
                        // 取得要刪除的選項資料
                        const optionKeys = Object.keys(this.groupedOptions);
                        const option = this.groupedOptions[optionKeys[index]];

                        const payload = {
                            optionTitle: option.optionTitle,
                            categoryId: this.selectedCategoryId,
                        };
                        console.log(payload);

                        // 發送刪除請求
                        const response = await axios.post("http://localhost:8080/option/delete", payload);

                        // 如果刪除成功，從前端資料中移除
                        if (response.data.code === 200) {
                            Swal.fire("刪除成功", "該選項已成功刪除", "success");

                            // 移除前端資料
                            this.savedCustList = this.savedCustList.filter(
                                (item) => item.optionTitle !== payload.optionTitle // 根據 optionTitle 移除
                            );
                        } else {
                            Swal.fire("刪除失敗", response.data.message, "error");
                        }
                    } catch (error) {
                        console.error("刪除選項時發生錯誤:", error);
                        Swal.fire("刪除失敗", "刪除過程中發生錯誤，請稍後重試。", "error");
                    }
                }
            });
        },
        editThisCust(item) {
            const index = Object.keys(this.groupedOptions).indexOf(item.optionTitle);
            if (index !== -1) {
                // 切換當前項目的編輯狀態
                this.editStates[index] = !this.editStates[index];
                if (this.editStates[index]) {
                    // 如果切換到編輯模式，保存原始數據
                    this.originalOptions[index] = {
                        categoryId: this.selectedCategoryId,
                        optionType: item.optionType,
                        optionContent: item.options.map((opt) => opt.optionContent),
                        extraPrice: item.options.map((opt) => opt.extraPrice),
                    };
                    console.log(this.originalOptions);
                }
            }
        },
        initializeEditStates() {
            // 使用 groupedOptions 的長度初始化 editStates
            this.editStates = Object.values(this.groupedOptions).map(() => false);
        },
        onPriceChange(option, itemIndex, optionIndex) {
            console.log(`Index: ${itemIndex}, Option Index: ${optionIndex}, New Price: ${option.extraPrice}`);
            // 更新對應的 originalOptions 內的 extraPrice
            if (this.originalOptions[itemIndex]) {
                this.originalOptions[itemIndex].extraPrice[optionIndex] = option.extraPrice;
            }
        },
        onTypeChange(newType, index) {
            // 確保 originalOptions 有對應的項目
            if (this.originalOptions[index]) {
                this.originalOptions[index].optionType = newType;
            }
        },
        async workstationFromDB() {
            try {
                const response = await axios.post("http://localhost:8080/workstation/searchworkstation", { workstationId: "" });
                this.workstationData = response.data.data;
                // console.log(this.workstationData);
            } catch (error) {
                console.error("獲取工作檯時發生錯誤:", error);
                Swal.fire({
                    title: "錯誤",
                    text: "無法獲取工作檯資料，請稍後再試",
                    icon: "error",
                    confirmButtonText: "好的",
                });
            }
        },
        // 用於觸發隱藏的 input 框
        selectFile(mealName) {
            const fileInput = this.$refs[`fileInput_new_${mealName}`];
            const inputElement = Array.isArray(fileInput) ? fileInput[0] : fileInput;
            if (inputElement) {
                inputElement.click();
            } else {
                console.error("new file input is undefined or not a valid input element");
            }
        },
        // 處理文件上傳
        handleFileChange(event, mealName) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = (e) => {
                    // 將 base64 資料設置到 pictureName
                    const menuItem = this.menuList.find((menu) => menu.mealName === mealName);
                    if (menuItem) {
                        menuItem.pictureName = e.target.result;
                    }
                };
                reader.readAsDataURL(file);
            }
        },
        // 點擊圖片打開input[type='file']，編輯圖片
        selectFileFromDB(mealName) {
            const fileInput = this.$refs[`fileInput_db_${mealName}`];
            const inputElement = Array.isArray(fileInput) ? fileInput[0] : fileInput;
            if (inputElement) {
                inputElement.click();
            } else {
                console.error("db file input is undefined or not a valid input element");
            }
        },
        // 選擇圖片後觸發預覽
        handleFileChangeFromDB(event, mealName) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = (e) => {
                    const menuItem = this.savedMenuList.find((item) => item.mealName === mealName);
                    if (menuItem) {
                        menuItem.pictureName = e.target.result;
                    }

                    const editedItem = this.editedMenuItems.find((item) => item.mealName === mealName);
                    if (editedItem) {
                        editedItem.pictureName = e.target.result;
                    }
                };
                reader.readAsDataURL(file);
            }
        },
        // 後端計算資料表數量的資料
        async countComboData() {
            try {
                // 發送 GET 請求到後端的 API
                const response = await axios.get("http://localhost:8080/pos/countComboData");

                // 將獲取到的資料存儲到 comboCount
                this.comboCount = response.data;

                // 日誌顯示結果（可選）
                // console.log("計數結果：", this.comboCount);
            } catch (error) {
                console.error("獲取計數資料時出錯：", error);
            }
        },
    },
    mounted() {
        this.fetchCategories(); // 載入時獲取分類
        this.fetchMenu(); // 載入時獲取菜單
        this.fetchCust(); // 載入時獲取客製化菜單資料
        this.initializeEditStates();
        this.workstationFromDB(); // 載入時獲得工作檯資料
        this.countComboData(); // 載入時獲得後端資料
    },
    computed: {
        // 計算各菜單分類的菜單選項
        categoryMenuCount() {
            const counts = {};
            this.savedMenuList.forEach((menu) => {
                if (counts[menu.categoryId]) {
                    counts[menu.categoryId]++;
                } else {
                    counts[menu.categoryId] = 1;
                }
            });
            return counts;
        },
        // 撈相同categoryId並將相同optionTitle作為鍵，塞入其他值
        groupedOptions() {
            // 先根據選擇的 categoryId 過濾資料
            const filteredList = this.savedCustList.filter((item) => item.categoryId === this.selectedCategoryId);

            // 使用 reduce 根據 optionTitle 將相同 title 的選項合併
            return filteredList.reduce((acc, item) => {
                const optionTitle = item.optionTitle;

                if (!acc[optionTitle]) {
                    // 如果沒有該 optionTitle，創建一個新項目
                    acc[optionTitle] = {
                        optionTitle: item.optionTitle,
                        optionType: item.optionType,
                        options: [], // 儲存合併後的 options
                    };
                }

                // 將相同 optionTitle 的選項推入 options 陣列
                acc[optionTitle].options.push({
                    optionContent: item.optionContent,
                    extraPrice: item.extraPrice || 0, // 默認價格為 0
                });

                return acc;
            }, {});
        },
    },
    setup() {
        const images = ref({}); // 使用物件來儲存圖片 Base64 字符串

        const onFileChange = (event, mealName) => {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();

                reader.onload = (e) => {
                    const base64String = e.target.result;
                    console.log(base64String);
                    images.value[mealName] = base64String; // 使用 mealName 作為鍵
                };

                reader.readAsDataURL(file);
            }
        };

        return { images, onFileChange };
    },
};
</script>

<template>
    <div class="addMenu">
        <div class="menuCategory">
            <h1>菜單分類</h1>
            <div class="optionArea">
                <!-- 已存在的菜單分類 -->
                <div
                    class="cOption"
                    v-for="(category, cIndex) in categories"
                    :key="cIndex"
                    :style="{ transform: `translate(${37 + category.translateX}px)` }"
                    @touchstart="startTouch($event, cIndex)"
                    @touchmove="moveTouch($event, cIndex)"
                    @touchend="endTouch(cIndex)">
                    <div class="opContent" :class="{ cateSelc: category.category == this.selectedCategory }" @click="selectCategory(category)">
                        <span v-if="!isEditing(cIndex)"> <i class="fa-solid fa-pen" v-show="showEditPen" @click.stop="startEditing(cIndex)">&nbsp&nbsp</i>{{ category.category }} </span>
                        <input v-else class="editInputCategory" type="text" v-model="category.category" @blur="stopEditing(cIndex, true)" @keydown.enter="stopEditing(cIndex, false)" />
                        <div class="groupOne">
                            <div class="countOp">
                                <span v-if="category.category === '套餐'">{{ comboCount }}</span>
                                <span v-else>{{ categoryMenuCount[category.categoryId] || 0 }}</span>
                            </div>
                            <i class="fa-regular fa-circle-xmark" @click="confirmDelete(cIndex)"></i>
                        </div>
                    </div>
                    <div @click="confirmDelete" class="deleteOp">
                        <span>刪除</span>
                    </div>
                </div>
                <!-- 動態新增的輸入框 -->
                <div class="inputOp" v-for="(item, cgIndex) in cgInput" :key="cgIndex">
                    <input type="text" v-model="item.category" placeholder="輸入菜單分類" />
                </div>
                <i class="fa-solid fa-circle-plus" @click="addCgInput()"></i>
            </div>
            <div class="saveCategory" @click="saveCategory()">儲存</div>
            <div class="editCategory" @click="editCategory()">編輯</div>
        </div>
        <div class="menuAndCust" v-if="!comboPage">
            <div class="menuArea">
                <div class="menuTop">
                    <div class="mtLeft">
                        <span>{{ selectedCategoryId == null ? "菜單分類" : selectedCategory }}</span>
                    </div>
                    <div class="mtMid">
                        <span class="necessary" :style="{ opacity: this.lastSelectedWorkstationId === null ? 1 : 0 }">*必選&nbsp&nbsp</span>
                        <i
                            class="fa-solid fa-square-pen"
                            :class="{ disIcon: selectedCategory == null }"
                            :style="{ 'pointer-events': selectedCategory == null ? 'none' : 'auto' }"
                            @click="editWorkbench()"></i>
                        <span class="subtitle" v-if="editingWorkbench">工作檯</span>
                        <select v-if="editingWorkbench" v-model="selectedWorkstationId" @change="updateWorkbench">
                            <option value="0" disabled>工作檯選擇</option>
                            <option v-for="wsItem in workstationData" :key="wsItem.workstationId" :value="wsItem.workstationId">
                                {{ wsItem.workstationName }}
                            </option>
                        </select>
                        <span class="subtitle" v-if="!editingWorkbench && selectedWorkstation">
                            {{ selectedWorkstation.workstationName }}
                        </span>
                    </div>
                    <div class="mtRight">
                        <div class="saveBtn" @click="saveMenu()">儲存</div>
                    </div>
                </div>
                <div class="menuMain">
                    <div class="addMenuDiv" @click="addMenu()">+&nbsp&nbsp新增餐點</div>
                    <!-- 存在於資料庫的部分 -->
                    <div class="menuItem" v-for="(item, index) in savedMenuList.filter((item) => item.categoryId === selectedCategoryId)" :key="'db' + item.mealName">
                        <div class="itemPic">
                            <input
                                v-if="editIndexList.includes(item.mealName)"
                                type="file"
                                :ref="'fileInput_db_' + item.mealName"
                                @change="(event) => handleFileChangeFromDB(event, item.mealName)"
                                accept="image/*"
                                style="display: none" />
                            <div
                                class="prePicture"
                                @click="editIndexList.includes(item.mealName) ? selectFileFromDB(item.mealName) : null"
                                :style="{ cursor: editIndexList.includes(item.mealName) ? 'pointer' : 'default' }">
                                <img :src="item.pictureName ? item.pictureName : defaultMenuImage" alt="Image Preview" style="width: 100%; height: 100%" />
                                <!-- <i v-else class="fa-solid fa-upload"></i> -->
                            </div>
                        </div>
                        <div class="itemName">
                            <span>{{ item.mealName }}</span>
                        </div>
                        <div class="itemPrice">
                            <span v-if="!editIndexList.includes(item.mealName)">${{ item.price }}</span>
                            <input v-else v-model="item.price" type="number" @input="updateEditedItem(item)" />
                        </div>
                        <div class="itemWorksta">
                            <div class="itemStatus" v-if="!editIndexList.includes(item.mealName)" :class="{ soldOut: item.available == false }">
                                <span>{{ item.available ? "供應" : "售完" }}</span>
                            </div>
                            <div v-else class="itemStatus" :class="{ flip: !item.available }" @click="switchSta(item)">
                                <span>{{ item.available ? "供應" : "售完" }}</span>
                            </div>
                        </div>
                        <div class="itemBot">
                            <div class="itemIcon">
                                <i class="fa-solid fa-square-pen" @click="editMenuFromDB(item.mealName)"></i>
                                <i class="fa-solid fa-trash-can" @click="deleteMenuFromDB(item.mealName)"></i>
                            </div>
                        </div>
                    </div>
                    <!-- 按下新增餐點，動態新增的div -->
                    <div class="menuItem" v-for="(menu, index) in menuList" :key="index">
                        <div class="itemPic">
                            <input
                                type="file"
                                :ref="'fileInput_new_' + menu.mealName"
                                :key="'new' + mealName"
                                @change="(event) => handleFileChange(event, menu.mealName)"
                                accept="image/*"
                                style="display: none" />
                            <!-- 如果有圖片預覽則顯示圖片，否則顯示上傳圖標 -->
                            <div class="prePicture" @click="selectFile(menu.mealName)" style="cursor: pointer">
                                <img v-if="menu.pictureName" :src="menu.pictureName" alt="Image Preview" style="width: 100%; height: 100%" />
                                <i v-else class="fa-solid fa-upload"></i>
                            </div>
                        </div>
                        <div class="itemName">
                            <input type="text" v-model="menu.mealName" placeholder="輸入餐點名稱" />
                        </div>
                        <div class="itemPrice">
                            <input type="number" v-model.number="menu.price" placeholder="餐點金額" />
                        </div>
                        <div class="itemWorksta">
                            <div class="itemStatus" :class="{ flip: !menu.available }" @click="switchSta(menu)">
                                <span>{{ menu.available ? "供應" : "售完" }}</span>
                            </div>
                        </div>
                        <div class="itemBot">
                            <div class="itemIcon">
                                <i class="fa-solid disable fa-square-pen" style="pointer-events: none"></i>
                                <i class="fa-solid fa-trash-can" @click="removeMenu(index)"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="customerization">
                <div class="cuTop">
                    <div class="cuLeft">
                        <span>客製化選項</span>
                    </div>
                    <div class="cuRight">
                        <div class="selCate">
                            <span>{{ selectedCategoryId == null ? "菜單分類" : selectedCategory }}</span>
                            <div class="countOp">{{ categoryMenuCount[selectedCategoryId] || 0 }}</div>
                        </div>
                        <div class="saveBtn" @click="saveCust()">儲存</div>
                    </div>
                </div>
                <div class="custItem">
                    <div class="addItem" @click="addCust()">+&nbsp&nbsp新增客製化選項</div>
                    <!-- 已存在資料庫的客製化選項 -->
                    <div class="custInput" v-for="(item, dbIndex) in Object.values(groupedOptions)" :key="dbIndex">
                        <div class="cuTitle">
                            <span>{{ item.optionTitle }}</span>
                            <span v-if="!editStates[dbIndex]">{{ item.optionType == "checkbox" ? "多選" : "單選" }}</span>
                            <select v-else v-model="item.optionType" @change="onTypeChange(item.optionType, dbIndex)">
                                <option value="checkbox">多選</option>
                                <option value="radio">單選</option>
                            </select>
                        </div>
                        <div class="titleOption">
                            <div class="oneOption" v-for="(option, opIndex) in item.options" :key="opIndex">
                                <div class="optionL">
                                    <span>{{ option.optionContent }}</span>
                                </div>
                                <div class="optionPrice">
                                    <span>$</span>
                                    <span v-if="!editStates[dbIndex]">{{ option.extraPrice }}</span>
                                    <input v-else v-model="option.extraPrice" class="editOpPrice" type="number" @input="onPriceChange(option, dbIndex, opIndex)" />
                                </div>
                            </div>
                        </div>
                        <div class="cuInputCtrl">
                            <i class="fa-solid fa-trash-can" @click="deleteCustFromDB(dbIndex)"></i>
                            <i class="fa-solid fa-pencil" @click="editThisCust(item)"></i>
                            <i class="fa-solid disable fa-circle-plus" style="pointer-events: none"></i>
                        </div>
                    </div>
                    <!-- 動態新增的輸入框 -->
                    <div class="custInput" v-for="(cust, custIndex) in custList" :key="custIndex">
                        <div class="cuTitle">
                            <input type="text" v-model="cust.optionTitle" placeholder="客製化標題" />
                            <select v-model="cust.optionType">
                                <option value="checkbox">多選</option>
                                <option value="radio">單選</option>
                            </select>
                        </div>
                        <div class="titleOption">
                            <div class="oneOption" v-for="(option, opIndex) in cust.options" :key="opIndex">
                                <div class="optionL">
                                    <input type="checkbox" v-if="cust.optionType === 'checkbox'" disabled />
                                    <input type="radio" v-if="cust.optionType === 'radio'" disabled />
                                    <input type="text" v-model="option.optionContent" class="inText" :placeholder="'選項' + (opIndex + 1)" />
                                </div>
                                <div class="optionPrice">
                                    <span>$</span>
                                    <input type="number" v-model.number="option.extraPrice" class="inPrice" placeholder="金額" />
                                </div>
                            </div>
                        </div>
                        <div class="cuInputCtrl">
                            <i class="fa-solid fa-trash-can" @click="removeCust(custIndex)"></i>
                            <i class="fa-solid fa-circle-plus" @click="addOption(custIndex)"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <ComboComponent class="comboArea" v-if="comboPage"></ComboComponent>
    </div>
</template>

<style scoped lang="scss">
$divColor: #fff;
$addDiv: #343a3f;
$suppliable: #28a745;
$soldOut: #e02d11;
$borderBot: #697077;
$editColor: #e6b800;
$selectedColor: #ffc90e;
$subColor: #000000;

.addMenu {
    width: 100%;
    height: 100%;
    position: relative;

    .menuCategory {
        width: 21.7%;
        height: 100%;
        border-radius: 10px;
        border: 1px solid rgba(grey, 0.5);
        border: 1px solid;
        box-shadow: -3px 3px 4px black;
        display: flex;
        justify-content: start;
        align-items: center;
        flex-direction: column;
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
                width: 130%;
                min-height: 6%;
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-direction: column;
                border-radius: 5px;
                margin-bottom: 5%;
                overflow-y: scroll;
                transition: transform 0.7s;
                background-color: #f2f4f8;

                .cateSelc {
                    color: $subColor;
                    background-color: $selectedColor;
                }

                .opContent {
                    width: 81%;
                    min-height: 100%;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    position: absolute;
                    left: 0;
                    overflow: hidden;
                    cursor: pointer;

                    span {
                        font-weight: bold;
                        font-family: "Noto Sans TC", sans-serif;
                        margin-left: 4.5%;
                    }

                    .editInputCategory {
                        width: 95%;
                        margin-left: 2.5%;
                        border: none;
                        font-size: 18px;
                        font-weight: bold;
                        font-family: "Noto Sans TC", sans-serif;
                    }

                    .groupOne {
                        width: 30%;
                        height: 100%;
                        margin-right: 3%;
                        display: flex;
                        justify-content: end;
                        align-items: center;

                        .countOp {
                            min-width: 45%;
                            height: 60%;
                            display: flex;
                            justify-content: center;
                            align-items: center;
                            margin-right: 6.5%;
                            border-radius: 30px;
                            color: $divColor;
                            background-color: $subColor;

                            span {
                                font-weight: normal;
                                font-family: "Noto Sans TC", sans-serif;
                            }
                        }

                        .fa-circle-xmark {
                            cursor: pointer;

                            &:hover {
                                color: #e02d11;
                                font-weight: bold;
                            }
                        }
                    }
                }

                .deleteOp {
                    width: 18%;
                    height: 100%;
                    letter-spacing: 2px;
                    position: absolute;
                    right: 0;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    color: white;
                    font-weight: bold;
                    font-family: "Noto Sans TC", sans-serif;
                    background-color: red;
                }
            }

            .inputOp {
                width: 100%;
                min-height: 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-radius: 5px;
                margin-bottom: 5%;
                background-color: #f2f4f8;

                input {
                    width: 95%;
                    border: none;
                    background-color: transparent;
                    margin-left: 2.5%;
                    font-size: 18px;
                    font-weight: bold;
                    font-family: "Noto Sans TC", sans-serif;
                }
            }

            .fa-circle-plus {
                font-size: 30px;
                cursor: pointer;
                margin-top: 1%;
            }
        }

        .saveCategory {
            width: 90%;
            height: 37px;
            border-radius: 10px;
            border: 2px solid black;
            margin-bottom: 3%;
            cursor: pointer;
            display: flex;
            justify-content: center;
            align-items: center;
            font-weight: bold;
            color: $subColor;
            background-color: $selectedColor;
            font-family: "Noto Sans TC", sans-serif;
        }

        .editCategory {
            width: 90%;
            height: 37px;
            border-radius: 10px;
            border: 2px solid black;
            font-weight: bold;
            margin-bottom: 3%;
            cursor: pointer;
            display: flex;
            justify-content: center;
            align-items: center;
            color: black;
            background-color: $divColor;
            font-family: "Noto Sans TC", sans-serif;
        }
    }

    .menuAndCust {
        width: 76.5%;
        height: 100%;
        display: flex;
        justify-content: center;
        align-items: center;
        flex-direction: column;
        position: absolute;
        top: 0;
        right: 0;

        .menuArea {
            width: 100%;
            // min-height: 457px; //71%
            height: 100%;
            border-radius: 10px;
            border: 1px solid rgba(grey, 0.5);
            border: 1px solid;
            box-shadow: -3px 3px 4px black;
            display: flex;
            justify-content: start;
            align-items: center;
            flex-direction: column;
            background-color: $divColor;
            overflow-y: scroll;
            scrollbar-width: none;

            .menuTop {
                width: 97%;
                height: 10%;
                margin: 1% 0 1% 0;
                border-bottom: 1px solid #343a3f;
                display: flex;
                justify-content: space-between;
                align-items: center;

                .mtLeft {
                    width: 30%;
                    font-size: 30px;
                    font-weight: bold;
                    display: flex;
                    align-items: end;
                    letter-spacing: 3px;
                    margin-left: 1%;
                    font-family: "Noto Sans TC", sans-serif;
                }

                .mtMid {
                    width: 30%;

                    .necessary{
                        font-family: "Noto Sans TC", sans-serif;
                        font-weight: bold;
                        color: $soldOut;
                    }

                    .subtitle {
                        font-size: 15px;
                        font-weight: bold;
                        letter-spacing: 3px;
                        font-family: "Noto Sans TC", sans-serif;
                        color: $borderBot;
                    }

                    .fa-square-pen {
                        font-size: 18px;
                        margin-right: 1%;
                        cursor: pointer;

                        &:hover {
                            color: $editColor;
                        }
                    }

                    select,
                    option {
                        width: 35%;
                        font-weight: bold;
                        letter-spacing: 3px;
                        font-family: "Noto Sans TC", sans-serif;
                    }

                    .disIcon {
                        color: $borderBot;
                    }
                }

                .mtRight {
                    width: 20%;
                    height: 80%;
                    display: flex;
                    justify-content: end;
                    align-items: center;
                    letter-spacing: 3px;

                    .selCate {
                        width: 48%;
                        margin-right: 3%;
                        display: flex;
                        justify-content: end;
                        align-items: center;
                        font-weight: bold;
                        font-family: "Noto Sans TC", sans-serif;

                        span {
                            margin-right: 8%;
                        }

                        .countOp {
                            min-width: 14%;
                            margin-right: 7%;
                            font-weight: 500;
                            color: white;
                            background-color: gray;
                            border-radius: 30px;
                            display: flex;
                            justify-content: center;
                            align-items: center;
                        }
                    }

                    .saveBtn {
                        width: 43.4%;
                        height: 91%;
                        border-radius: 10px;
                        border: 2px solid black;
                        font-weight: bold;
                        color: $subColor;
                        background-color: $selectedColor;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        cursor: pointer;
                        font-family: "Noto Sans TC", sans-serif;
                    }
                }
            }

            .menuMain {
                width: 97%;
                height: 85%;
                display: flex;
                overflow-y: scroll;
                scrollbar-width: none;
                flex-wrap: wrap;

                .addMenuDiv {
                    width: 22%;
                    height: 72%; //65%
                    margin: 0 4% 1% 0;
                    border-radius: 10px;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    color: white;
                    background-color: $addDiv;
                    font-size: 25px;
                    font-family: "Noto Sans TC", sans-serif;
                    cursor: pointer;
                }

                .addMenuDiv:nth-child(4n) {
                    margin: 0 0 1% 0;
                }

                .menuItem {
                    display: grid;
                    grid-template-columns: repeat(6, 1fr);
                    grid-template-rows: repeat(8, 1fr);
                    grid-column-gap: 8px;
                    grid-row-gap: 6px;
                    width: 22%;
                    height: 72%; //65%
                    margin: 0 4% 1% 0;
                    border-radius: 10px;
                    border: 1px solid black;

                    .itemPic {
                        grid-area: 1 / 1 / 6 / 7;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        border: dotted;
                        margin: 4% 4% 0 4%;
                        min-height: 111.7px;
                        overflow: hidden;

                        .fa-upload {
                            font-size: 30px;
                        }

                        .prePicture {
                            width: 100%;
                            height: auto;
                            display: flex;
                            justify-content: center;
                            align-items: center;

                            img {
                                object-fit: contain;
                                overflow: hidden;
                            }
                        }
                    }

                    .itemName {
                        grid-area: 6 / 1 / 7 / 5;
                        display: flex;
                        align-items: center;
                        font-weight: bold;
                        letter-spacing: 3px;
                        font-family: "Noto Sans TC", sans-serif;
                        margin: 0 10%;

                        input {
                            max-width: 100%;
                            font-size: 18px;
                            font-family: "Noto Sans TC", sans-serif;
                        }
                    }

                    .itemPrice {
                        grid-area: 7 / 1 / 8 / 5;
                        display: flex;
                        align-items: center;
                        font-weight: bold;
                        font-family: "Noto Sans TC", sans-serif;
                        margin: 0 10%;

                        input {
                            max-width: 70%;
                            font-size: 15px;
                            font-family: "Noto Sans TC", sans-serif;
                        }
                    }

                    .itemWorksta {
                        grid-area: 6 / 5 / 8 / 7;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        margin: 0 4%;

                        .itemStatus {
                            width: 100%;
                            height: 80%;
                            margin-right: 10%;
                            border-radius: 5px;
                            letter-spacing: 3px;
                            cursor: pointer;
                            font-size: 17px;
                            font-weight: bold;
                            font-family: "Noto Sans TC", sans-serif;
                            color: white;
                            background-color: $suppliable;
                            border: 1px solid $suppliable;
                            display: flex;
                            justify-content: center;
                            align-items: center;
                            transition: transform 0.7s, background-color 0.5s;
                            writing-mode: vertical-lr;
                        }

                        .soldOut {
                            background-color: white;
                            border-color: $soldOut;
                            color: $soldOut;
                        }

                        .flip {
                            transform: rotateX(360deg);
                            background-color: white;
                            border-color: $soldOut;
                            color: $soldOut;
                        }
                    }

                    .itemBot {
                        grid-area: 8 / 1 / 9 / 7;
                        margin: 0 4%;
                        border-top: 1px solid $borderBot;
                        display: flex;

                        .itemIcon {
                            width: 100%;
                            margin-left: 4%;
                            margin-right: 4%;
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            padding: 3% 0;

                            .fa-solid {
                                cursor: pointer;
                                font-size: 25px;
                            }

                            .fa-trash-can {
                                &:hover {
                                    color: #e02d11;
                                }
                            }

                            .fa-square-pen {
                                &:hover {
                                    color: $editColor;
                                }
                            }

                            .disable {
                                color: #697077;
                            }
                        }
                    }
                }

                .menuItem:nth-child(4n) {
                    margin: 0 0 1% 0;
                }
            }
        }

        .customerization {
            width: 100%;
            max-height: 31%; //31%
            min-height: 31%;
            margin-top: 1.5%;
            border-radius: 10px;
            border: 1px solid rgba(grey, 0.5);
            border: 1px solid;
            box-shadow: -3px 3px 4px black;
            display: flex;
            justify-content: start;
            align-items: center;
            flex-direction: column;
            background-color: $divColor;

            .cuTop {
                width: 97%;
                height: 18%;
                margin: 2% 0 1% 0;
                border-bottom: 1px solid #343a3f;
                display: flex;
                justify-content: space-between;
                align-items: center;

                .cuLeft {
                    width: 40%;
                    font-size: 30px;
                    font-weight: bold;
                    letter-spacing: 3px;
                    margin-left: 1%;
                    margin-bottom: 1%;
                    font-family: "Noto Sans TC", sans-serif;
                }

                .cuRight {
                    width: 50%;
                    height: 87.5%;
                    display: flex;
                    justify-content: end;
                    align-items: center;
                    letter-spacing: 3px;

                    .selCate {
                        width: 48%;
                        height: 100%;
                        margin-right: 3%;
                        display: flex;
                        justify-content: end;
                        align-items: center;
                        font-weight: bold;
                        font-family: "Noto Sans TC", sans-serif;

                        span {
                            margin-right: 8%;
                        }

                        .countOp {
                            min-width: 14%;
                            margin-right: 7%;
                            font-weight: 500;
                            color: white;
                            background-color: black;
                            border-radius: 30px;
                            display: flex;
                            justify-content: center;
                            align-items: center;
                        }
                    }

                    .saveBtn {
                        width: 17.4%;
                        height: 100%;
                        border-radius: 10px;
                        border: 2px solid black;
                        font-weight: bold;
                        cursor: pointer;
                        color: $subColor;
                        background-color: $selectedColor;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        font-family: "Noto Sans TC", sans-serif;
                    }
                }
            }

            .custItem {
                width: 97%;
                height: 65%;
                margin-bottom: 1%;
                display: flex;
                justify-content: start;
                align-items: center;
                overflow-x: scroll;
                scrollbar-width: none;
                white-space: nowrap;

                .addItem {
                    min-width: 25%;
                    height: 100%;
                    margin-right: 3%;
                    border-radius: 10px;
                    font-size: 25px;
                    font-family: "Noto Sans TC", sans-serif;
                    color: white;
                    background-color: $addDiv;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    cursor: pointer;
                }

                .custInput {
                    display: grid;
                    grid-template-columns: repeat(4, 1fr);
                    grid-template-rows: repeat(4, 1fr);
                    grid-column-gap: 4px;
                    grid-row-gap: 4px;
                    min-width: 25%;
                    max-width: 25%;
                    height: 100%;
                    margin-right: 3%;
                    border-radius: 10px;
                    border: 1px solid $borderBot;
                    font-family: "Noto Sans TC", sans-serif;
                }

                .cuTitle {
                    grid-area: 1 / 1 / 2 / 5;
                    width: 98%;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin: 0 1%;

                    input {
                        width: 69%;
                        font-size: 15px;
                        margin-left: 2%;
                    }
                }

                .titleOption {
                    grid-area: 2 / 1 / 4 / 5;
                    width: 98%;
                    display: flex;
                    justify-content: start;
                    align-items: center;
                    flex-direction: column;
                    overflow-y: scroll;
                    overflow-x: hidden;
                    scrollbar-width: none;
                    margin: 0 1%;

                    .oneOption {
                        width: 100%;
                        max-height: 30px;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;

                        .optionL {
                            width: 70%;
                            margin-left: 1%;
                            display: flex;
                            justify-content: start;
                            align-items: center;

                            .inText,
                            .editOpInput {
                                max-width: 89%;
                                font-size: 15px;
                                margin-left: 2%;
                                margin-top: 1%;
                                font-family: "Noto Sans TC", sans-serif;
                            }
                        }

                        .optionPrice {
                            width: 30%;
                            display: flex;
                            justify-content: end;
                            align-items: center;

                            .inPrice,
                            .editOpPrice {
                                max-width: 60%;
                                font-size: 15px;
                                margin: 1% 5%;
                                font-family: "Noto Sans TC", sans-serif;
                            }
                        }
                    }
                }

                .cuInputCtrl {
                    grid-area: 4 / 1 / 5 / 5;
                    border-top: 1px solid $borderBot;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;

                    .fa-solid {
                        font-size: 20px;
                    }

                    .fa-trash-can {
                        margin-left: 3%;

                        &:hover {
                            color: $soldOut;
                            cursor: pointer;
                        }
                    }

                    .fa-pencil {
                        &:hover {
                            color: $editColor;
                            cursor: pointer;
                        }
                    }

                    .fa-circle-plus {
                        margin-right: 3%;

                        &:hover {
                            color: $editColor;
                            cursor: pointer;
                        }
                    }

                    .disable {
                        color: #697077;
                    }
                }
            }
        }
    }

    .comboArea {
        width: 76.5%;
        height: 100%;
        z-index: 99;
        position: absolute;
        top: 0;
        right: 0;
    }
}
</style>
