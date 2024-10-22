<script>
import LeftBar from '@/components/LeftBar.vue'
export default {
    data() {
        return {

        }
    },
    components: {
        LeftBar
    },
}
</script>

<template>
    <div class="leftBar">
        <LeftBar />
    </div>
    <div class="mainArea">
    </div>
</template>

<style scoped lang="scss">
.leftBar {
    width: 10%;
    height: 100vh;
    position: fixed;
    top: 0;
    left: 0;
    display: flex;
    align-items: center;
}

.mainArea {
    width: 100%;
    height: 90%;
    overflow-y: scroll;
    display: flex;
    justify-content: start;
    align-items: center;
    flex-direction: column;
}
</style>