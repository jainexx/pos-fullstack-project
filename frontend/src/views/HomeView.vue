<script>
export default{
    data(){
        return{

        }
    },
    methods:{
        goSystem() {
            this.$router.push("./system")
        },
    }
}
</script>

<template>
    <button @click="goSystem()">登入</button>
    <h1>或在網址列後面新增 /system</h1>
</template>

<style scoped lang="scss">
button{
    width: 300px;
    height: 100px;
}
</style>