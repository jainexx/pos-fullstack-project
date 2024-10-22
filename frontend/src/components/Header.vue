<script>
export default {
    data() {
        return {
            selected: "menuManage"
        }
    },
    methods: {
        selectMenu() {
            this.$emit('changeComponent', 'AddMenu');
            this.selectRoute('menuManage');
        },
        selectWorkbench() {
            this.$emit('changeComponent', 'Workbench');
            this.selectRoute('workbench');
        },
        selectAnnounce() {
            this.$emit('changeComponent', 'Announce');
            this.selectRoute('announce');
        },
        selectBusiSetting() {
            this.$emit('changeComponent', 'BusiSetting');
            this.selectRoute('busiSetting');
        },
        authorizations() {
            this.$emit('changeComponent', 'Authorizations');
            this.selectRoute('authorizations');
        },
        selectRoute(option) {
            this.selected = option
        }
    }
}
</script>

<template>
    <div class="headerBar">
        <div class="menuManage" :class="{ isSelected: selected === 'menuManage' }" @click="selectMenu">
            <span>菜單管理</span>
        </div>
        <div class="workbench" :class="{ isSelected: selected === 'workbench' }" @click="selectWorkbench">
            <span>工作檯</span>
        </div>
        <div class="announce" :class="{ isSelected: selected === 'announce' }" @click="selectAnnounce">
            <span>公告設定</span>
        </div>
        <div class="busiSetting" :class="{ isSelected: selected === 'busiSetting' }" @click="selectBusiSetting">
            <span>桌位與訂位</span>
        </div>
        <div class="authorizations" :class="{ isSelected: selected === 'authorizations' }" @click="authorizations">
            <span>權限管理</span>
        </div>
        <!-- <router-link class="comboLink" :to="{ name: 'comboPage' }">套餐入口</router-link> -->
    </div>
</template>

<style scoped lang="scss">
$bgColor: #fff;
$selectedTextColor: #21272a;
$textColor: #697077;

.headerBar {
    width: 100%;
    height: 100%;
    border-radius: 10px;
    border: 1px solid;
    box-shadow: -2px 2px 2px black;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: $bgColor;
    position: relative;

    .menuManage,
    .workbench,
    .announce,
    .busiSetting,
    .authorizations {
        width: 10%;
        height: 100%;
        cursor: pointer;
        display: flex;
        justify-content: center;
        align-items: center;
        position: relative;
        letter-spacing: 3px;
        color: $textColor;
        font-weight: bold;
        font-family: "Noto Sans TC", sans-serif;
        transition: transform 0.3s, color 0.3s, border-bottom 0.3s;

        span {
            z-index: 1;
        }
    }

    .menuManage::before,
    .workbench::before,
    .announce::before,
    .busiSetting::before,
    .authorizations::before {
        content: '';
        position: absolute;
        top: 12px;
        left: 15px;
        width: 100%;
        height: 100%;
        background-image: url('/src/assets/highlightpen1.png');
        background-repeat: no-repeat;
        background-position: left;
        background-size: 80%;
        opacity: 0; //0.8
        clip-path: inset(0 100% 0 0); // 完全遮擋
        transition: clip-path 0.7s ease, opacity 0s;
    }

    .isSelected {
        color: #000; //$selectedTextColor
    }

    .isSelected::before {
        opacity: 1;
        clip-path: inset(0 0 0 0); // 全部顯示
    }

    .comboLink {
        position: absolute;
        left: 0;
        top: 0;
        font-size: 20px;
        color: red;
        // background-color: red;
        text-decoration: none;
        cursor: default;
    }
}
</style>
