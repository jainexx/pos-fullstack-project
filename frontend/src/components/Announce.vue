<script>
import axios from "axios";
import LeftBar from "@/components/LeftBar.vue";
import Header from "@/components/Header.vue";
import Swal from "sweetalert2";

export default {
    data() {
        const today = new Date().toISOString().split("T")[0];
        return {
            currentView: "createAnnounce",
            imageFile: null,
            imageUrl: null,
            announceTitle: "",
            announceContent: "",
            announceStartTime: today,
            announceEndTime: "",
            today,
            announceId: "",
            announcements: [],
            displayedAnnouncements: [],
            currentPage: 1,
            itemsPerPage: 6,
            totalAnnouncements: 0,
            filterType: "upcoming",
            currentEditingAnnounce: null,
        };
    },
    mounted() {
        this.fetchAllannounceId();
        this.setFilterType("upcoming");
    },
    components: {
        LeftBar,
        Header,
    },
    methods: {
        triggerFileInput() {
            this.$refs.fileInput.click();
        },

        onFileChange(event) {
            const file = event.target.files[0];
            if (file && file.type.startsWith("image/")) {
                this.imageFile = file;
                const reader = new FileReader();
                reader.onload = (e) => {
                    this.imageUrl = e.target.result;
                };
                reader.readAsDataURL(file);
            } else {
                this.imageFile = null;
                this.imageUrl = null;
            }
        },

        async createAnnounce() {
            if (this.imageFile) {
                const reader = new FileReader();
                reader.onload = async (e) => {
                    const base64Image = e.target.result;

                    const postData = {
                        announceTitle: this.announceTitle,
                        announceContent: this.announceContent,
                        announcePictureName: base64Image,
                        announceStartTime: this.announceStartTime,
                        announceEndTime: this.announceEndTime,
                    };

                    await this.submitAnnounce(postData);
                };
                reader.readAsDataURL(this.imageFile);
            } else {
                const postData = {
                    announceTitle: this.announceTitle,
                    announceContent: this.announceContent,
                    announcePictureName: null,
                    announceStartTime: this.announceStartTime,
                    announceEndTime: this.announceEndTime,
                };

                await this.submitAnnounce(postData);
            }
        },

        async submitAnnounce(postData) {
            try {
                const response = await axios.post("http://localhost:8080/announce/create", postData);
                if (response.status === 200) {
                    Swal.fire("公告發佈成功");
                    this.clearForm();
                    this.fetchAllannounceId();
                    this.updateDisplayedAnnouncements();
                } else {
                    Swal.fire("公告發佈失敗");
                }
            } catch (error) {
                console.error("公告發佈失敗", error);
                Swal.fire("公告發佈失敗，請稍後再試");
            }
        },

        clearForm() {
            this.imageFile = null;
            this.imageUrl = null;
            this.announceTitle = "";
            this.announceContent = "";
            this.announceStartTime = this.today;
            this.announceEndTime = "";
        },

        switchView(view, announce = null) {
            this.currentView = view;
            if (view === "createAnnounce") {
                this.clearForm();
            } else if (view === "announceList") {
                this.setFilterType("upcoming");
            } else if (view === "announceUpdate" && announce) {
                this.currentEditingAnnounce = announce;
                this.announceId = announce.announceId;
                this.announceTitle = announce.announceTitle;
                this.announceContent = announce.announceContent;
                this.announceStartTime = announce.announceStartTime;
                this.announceEndTime = announce.announceEndTime;
                this.imageUrl = announce.announcePictureName;
            }
        },

        fetchAllannounceId() {
            axios
                .post("http://localhost:8080/announce/searchAnnounce", {})
                .then((response) => {
                    if (response.data.data) {
                        this.announcements = response.data.data;
                        this.updateDisplayedAnnouncements();
                        console.log("獲取的公告數據：", this.announcements);
                    }
                })
                .catch((error) => {
                    console.error("獲取公告失敗：", error);
                });
        },

        updateDisplayedAnnouncements() {
            const start = (this.currentPage - 1) * this.itemsPerPage;
            const end = start + this.itemsPerPage;

            const filteredAnnouncements = this.announcements.filter((announce) => {
                if (this.filterType === "upcoming") {
                    return new Date(announce.announceEndTime) >= new Date(this.today);
                } else {
                    return new Date(announce.announceEndTime) < new Date(this.today);
                }
            });

            if (this.filterType === "upcoming") {
                filteredAnnouncements.sort((a, b) => {
                    const startDiff = new Date(a.announceStartTime) - new Date(b.announceStartTime);
                    if (startDiff !== 0) {
                        return startDiff;
                    } else {
                        return new Date(a.announceEndTime) - new Date(b.announceEndTime);
                    }
                });
            } else {
                filteredAnnouncements.sort((a, b) => new Date(b.announceEndTime) - new Date(a.announceEndTime));
            }

            this.totalAnnouncements = filteredAnnouncements.length;
            this.displayedAnnouncements = filteredAnnouncements.slice(start, end);
        },
        setCurrentPage(page) {
            if (page >= 1 && page <= Math.ceil(this.totalAnnouncements / this.itemsPerPage)) {
                this.currentPage = page;
                this.updateDisplayedAnnouncements();
            }
        },
        setFilterType(type) {
            this.filterType = type;
            this.currentPage = 1;
            this.updateDisplayedAnnouncements();
        },

        async deleteAnnounce(announceId) {
            const postData = { announceId: announceId };

            const result = await Swal.fire({
                title: "確定要刪除這個公告嗎?",
                showCancelButton: true,
                confirmButtonText: "刪除",
                cancelButtonText: "取消",
            });

            if (result.isConfirmed) {
                try {
                    const response = await axios.post("http://localhost:8080/announce/delete", postData);
                    if (response.status === 200) {
                        Swal.fire("公告刪除成功");
                        this.fetchAllannounceId();
                    } else {
                        Swal.fire("公告刪除失敗");
                    }
                } catch (error) {
                    console.error("刪除公告出錯", error);
                    Swal.fire("刪除公告出錯，請稍後再試");
                }
            }
        },
        showAnnouncePreview(announce) {
            const imageHtml = announce.announcePictureName ? `<img src="${announce.announcePictureName}" alt="圖片預覽" style="width: 100%; height: auto;"/>` : "";

            Swal.fire({
                html: `
            ${imageHtml}
            <h3 style="text-align: left;">${announce.announceTitle}</h3>
            <p style="text-align: left; padding-top: 3%;">活動時間 ${announce.announceStartTime} ~ ${announce.announceEndTime}</p>
            <pre style="text-align: left; padding-top: 2%; white-space: pre-wrap; word-break: break-word; overflow-y: auto;">${announce.announceContent}</pre>
        `,
                focusConfirm: false,
                confirmButtonText: "關閉",
                width: "800px",
            });
        },
        async updateAnnounce() {
            const postData = {
                announceId: this.announceId,
                announceTitle: this.announceTitle,
                announceContent: this.announceContent,
                announceStartTime: this.announceStartTime,
                announceEndTime: this.announceEndTime,
                announcePictureName: this.imageUrl,
            };

            try {
                const response = await axios.post("http://localhost:8080/announce/update", postData);
                if (response.status === 200) {
                    Swal.fire("公告更新成功");
                    this.switchView("announceList");
                    this.fetchAllannounceId();
                } else {
                    Swal.fire("公告更新失敗");
                }
            } catch (error) {
                console.error("更新公告出錯", error);
                Swal.fire("更新公告出錯，請稍後再試");
            }
        },
    },
};
</script>

<template>
    <div>
        <div class="menuCategory">
            <h3 @click="switchView('createAnnounce')" :class="{ active: currentView === 'createAnnounce' }">建立公告</h3>
            <h3 @click="switchView('announceList')" :class="{ active: currentView === 'announceList' }">公告列表</h3>
        </div>

        <div class="mainArea">
            <div v-if="currentView === 'createAnnounce'">
                <h2>建立公告</h2>
                <div class="announceArea">
                    <input type="file" ref="fileInput" @change="onFileChange" accept="image/*" style="display: none" />
                    <div @click="triggerFileInput" v-if="imageUrl" class="upload-container no-border" style="cursor: pointer">
                        <img :src="imageUrl" alt="圖片預覽" class="preview-image" />
                    </div>

                    <div @click="triggerFileInput" v-else class="upload-container with-border" style="cursor: pointer">
                        <div class="upload-placeholder">點擊此處上傳圖片</div>
                    </div>
                    <div style="width: 100%; display: flex; justify-content: space-between; margin-top: 2%">
                        <h3>
                            標題
                            <input type="text" v-model="announceTitle" />
                        </h3>
                        <h3 style="margin-right: 12%">
                            活動時間 <input type="date" v-model="announceStartTime" :min="today" /> ~
                            <input type="date" v-model="announceEndTime" :min="announceStartTime" />
                        </h3>
                    </div>
                    <div></div>
                    <div class="contentArea">
                        <textarea name="" id="" v-model="announceContent" placeholder="活動內容:"></textarea>
                    </div>
                </div>
                <div class="buttons">
                    <button @click="clearForm" class="cancelBtn">取消</button>
                    <button @click="createAnnounce" class="publishBtn">發佈</button>
                </div>
            </div>

            <div v-if="currentView === 'announceList'">
                <div class="headerArea">
                    <h2>公告列表</h2>
                    <button @click="setFilterType('upcoming')" :class="{ active: filterType === 'upcoming' }">近期</button>
                    <button @click="setFilterType('ended')" :class="{ active: filterType === 'ended' }">已結束</button>
                </div>
                <div class="listArea">
                    <div v-for="announce in displayedAnnouncements" :key="announce.announceId" class="announcement-item">
                        <img :src="announce.announcePictureName || '/images/default-menu-img.png'" class="previewlist-image" @click="showAnnouncePreview(announce)" />
                        <div class="item-content">
                            <div class="textlistArea">
                                <h3 @click="showAnnouncePreview(announce)" style="cursor: pointer; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; padding-bottom: 2%">
                                    {{ announce.announceTitle }}
                                </h3>
                                <span>{{ announce.announceStartTime }}</span> ~
                                <span>{{ announce.announceEndTime }}</span>
                            </div>
                            <div class="icon">
                                <i class="fa-solid fa-pen" @click="switchView('announceUpdate', announce)"></i>
                                <i class="fa-solid fa-trash-can" @click="deleteAnnounce(announce.announceId)"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="pagination">
                    <button :disabled="currentPage === 1" @click="setCurrentPage(currentPage - 1)"><</button>
                    <button :disabled="currentPage === Math.ceil(totalAnnouncements / itemsPerPage) || totalAnnouncements === 0" @click="setCurrentPage(currentPage + 1)">></button>
                </div>
            </div>
            <div v-if="currentView === 'announceUpdate'">
                <h2>編輯公告</h2>
                <div class="announceArea">
                    <input type="file" ref="fileInput" @change="onFileChange" accept="image/*" style="display: none" />
                    <div @click="triggerFileInput" v-if="imageUrl" class="upload-container no-border" style="cursor: pointer">
                        <img :src="imageUrl" alt="圖片預覽" class="preview-image" />
                    </div>

                    <div @click="triggerFileInput" v-else class="upload-container with-border" style="cursor: pointer">
                        <div class="upload-placeholder">點擊此處上傳圖片</div>
                    </div>
                    <div style="width: 100%; display: flex; justify-content: space-between; margin-top: 2%">
                        <h3>
                            標題
                            <input type="text" v-model="announceTitle" />
                        </h3>
                        <h3 style="margin-right: 12%">
                            活動時間 <input type="date" v-model="announceStartTime" :min="today" /> ~
                            <input type="date" v-model="announceEndTime" :min="announceStartTime" />
                        </h3>
                    </div>
                    <div></div>
                    <div class="contentArea">
                        <textarea name="" id="" v-model="announceContent" placeholder="活動內容"></textarea>
                    </div>
                </div>
                <div class="buttons">
                    <button @click="switchView('announceList')" class="cancelBtn">取消</button>
                    <button @click="updateAnnounce" class="publishBtn">更新</button>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">
$divColor: #fff;
$addDiv: #343a3f;

* {
    font-family: "Noto Sans TC", sans-serif;
    font-weight: bold;
}

.menuCategory {
    width: 15%;
    height: 89dvh;
    border-radius: 10px;
    display: flex;
    justify-content: start;
    align-items: center;
    flex-direction: column;
    position: absolute;
    top: 0%;
    left: 0%;
    background-color: white;
    border: 1px solid rgba(grey, 0.5);
    border: 1px solid;
    box-shadow: -3px 3px 4px black;

    h3 {
        width: 100%;
        cursor: pointer;
        padding: 10px;
        transition: background-color 0.3s ease;

        &.active {
            background-color: rgba(199, 199, 199, 0.5);
            border-right: 5px solid black;
        }
    }
}

.mainArea {
    width: 83%;
    height: 89dvh;
    border-radius: 10px;
    position: absolute;
    top: 0%;
    left: 17%;
    background-color: white;
    border: 1px solid rgba(grey, 0.5);
    border: 1px solid;
    box-shadow: -3px 3px 4px black;

    h2 {
        position: absolute;
        top: 1%;
        left: 5%;
    }

    .announceArea {
        width: 90%;
        height: 80%;
        border: solid 1px black;
        border-radius: 10px;
        position: absolute;
        top: 10%;
        left: 5%;
        padding-left: 10%;
        display: flex;
        justify-content: center;
        flex-direction: column;

        .upload-container {
            width: 88%;
            height: 300px;
        }

        .with-border {
            border: 1px dashed black;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .no-border {
            border: none;
        }

        .preview-image {
            width: 100%;
            height: 300px;
            object-fit: contain;
        }

        .upload-placeholder {
            color: #888;
            font-size: 16px;
            display: flex;
        }

        .contentArea {
            margin-top: 2%;

            textarea {
                width: 88%;
                resize: none;
                height: 100px;
                border: 1px solid black;
                padding-left: 1%;
                font-size: 16px;
            }
        }
    }

    .headerArea {
        width: 97%;
        height: 7%;
        border-bottom: 1px solid black;
        display: flex;
        justify-content: end;
        margin-top: 3%;
        margin-left: 1%;

        button {
            margin-left: 2%;
            margin-right: 2%;
            margin-bottom: 1%;
            background-color: white;
            width: 8%;
            border-radius: 10px;

            &.active {
                background-color: rgba(199, 199, 199, 0.5);
            }
        }
    }

    .listArea {
        width: 100%;
        height: 500px;
        min-height: 500px;
        display: flex;
        margin-top: 2%;
        flex-wrap: wrap;

        .announcement-item {
            width: calc(33.33%);
            margin-bottom: 20px;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .previewlist-image {
            width: 250px;
            height: 150px;
            object-fit: fill;
            border-top-right-radius: 10px;
            border-top-left-radius: 10px;
            cursor: pointer;
        }

        .textlistArea {
            width: 96%;
            margin-left: 2%;
            border-bottom: 1px solid;
            padding: 3%;
        }

        .item-content {
            width: 250px;
            height: 110px;
            border: 1px solid;
            border-top: none;
            border-bottom-right-radius: 10px;
            border-bottom-left-radius: 10px;
        }

        .icon {
            display: flex;
            justify-content: space-between;
            padding-right: 10%;
            padding-top: 5%;
        }
    }

    .pagination {
        position: absolute;
        bottom: -20px;
        width: 100%;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 70px;
        margin-top: 3%;

        button {
            width: 5%;
            font-size: 100%;
            border-radius: 10px;
            background-color: #c1c7cd;
            margin-left: 10px;
            margin-right: 10px;

            &:disabled {
                cursor: not-allowed;
            }
        }
    }

    .buttons {
        position: absolute;
        bottom: 2%;
        right: 5%;

        button {
            margin-left: 10px;
            padding: 10px 20px;
            border-radius: 5px;
        }
    }
}

.fa-solid {
    font-size: 20px;
    cursor: pointer;
    margin-left: 10%;
}

button {
    cursor: pointer;
}
</style>
