<script>
export default {
    props: {
        categories: Array,
        activeCategoryId: Number, // 接收當前選中的分類 ID
    },
    methods: {
        selectCategory(categoryId) {
            this.$emit("selectCategory", categoryId); // 發出事件通知父元件
        },
    },
};
</script>

<template>
    <div class="categories">
        <button v-for="category in categories" :key="category.categoryId" :class="{ active: category.categoryId === activeCategoryId }" @click="selectCategory(category.categoryId)">
            {{ category.category }}
        </button>
    </div>
</template>

<style scoped lang="scss">
.categories {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    border-bottom: 1px dashed rgba(grey, 0.5);
    padding-bottom: 2%;
}

button {
    letter-spacing: 0.2dvw;
    font-weight: 500;
    font-size: 1rem;
    padding: 6px 25px;
    border: 1px solid rgba(grey, 0.5);
    border-radius: 5px;
    background-color: transparent;
    cursor: pointer;
    // transition: border 0.3s;
}

button:hover {
    border: 1px solid grey;
    background-color: rgba(grey, 0.1);
}

button.active {
    border: 2px solid black; /* 點擊後維持2px的邊框 */
    background-color: #FFC90E;
}
</style>
