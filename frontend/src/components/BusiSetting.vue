<script>
import TableManagement from './BusiSetting/TableManagement.vue';
import TimeSetting from './BusiSetting/TimeSetting.vue';
import TimeManagement from './BusiSetting/TimeManagement.vue';

export default {
    data () {
        return {
            selectedMenu: '桌號管理', // 預設選中的選單項目
            managementItems: ['桌號管理', '營業時間設定', '營業時間管理'], // 選單項目
        };
    },

    components: {
        TableManagement,
        TimeSetting,
        TimeManagement
    },

    methods: {
        // 切換選單
        selectMenu (item) {
            this.selectedMenu = item;
        },
    }
};
</script>

<template>
<div class="managementSettingArea">
    <div class="managementList">
        <ul>
            <li v-for="(item, index) in managementItems" :key="index" :class="{ active: selectedMenu === item }" @click="selectMenu(item)">
                {{ item }}
            </li>
        </ul>
    </div>
</div>

<TableManagement v-if="selectedMenu === '桌號管理'" />

<TimeSetting v-if="selectedMenu === '營業時間設定'" />

<TimeManagement v-if="selectedMenu === '營業時間管理'" />

</template>

<style scoped lang="scss">
$background-color: #FFFFFF;
$black-color: #1E1E1E;
$gray-color: #DDE1E6;
$boxShadow: #F2F4F8;

.managementSettingArea {
    width: 19%; 
    height: 100%;
    border-radius: 0.625rem; /* 10px -> 0.625rem */
    border: 1px solid rgba(grey, 0.5);
    border: 1px solid;
    box-shadow: -3px 3px 4px black;
    background-color: $background-color;
    display: flex;
    justify-content: start;
    align-items: center;
    flex-direction: column;

    .managementList {
        width: 100%;
        padding: 0.625rem 0; /* 10px -> 0.625rem */

        ul {
            list-style-type: none;

            li {
                border-right: 0.25rem solid transparent; /* 4px -> 0.25rem */
                font-size: 1.25rem; /* 20px -> 1.25rem */
                font-weight: bolder;
                text-align: center;
                padding: 0.625rem; /* 10px -> 0.625rem */
                margin: 1.25rem 0; /* 20px -> 1.25rem */
                cursor: pointer;
                transition: all 0.3s;

                &.active {
                    background-color: $gray-color;
                    border-right-color: $black-color;
                }

                &:hover {
                    background-color: $boxShadow;
                }
            }
        }
    }
}
</style>
