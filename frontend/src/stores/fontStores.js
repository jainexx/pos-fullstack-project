import { defineStore } from "pinia";

export const useFontStore = defineStore("font", {
    state: () => ({
        fonts: ["Baloo Paaji 2", "Inter", "Karla", "Times New Roman", "Nunito", "Roboto Condensed", "Rubik"], // 字型列表
        currentFontIndex: 0, // 當前字型的索引
    }),
    actions: {
        nextFont() {
            // 切換到下一個字型
            this.currentFontIndex = (this.currentFontIndex + 1) % this.fonts.length;
        },
    },
});