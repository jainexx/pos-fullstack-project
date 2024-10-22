<script>
import LeftBar from "@/components/LeftBar.vue";
import axios from "axios";
import FullCalendar from '@fullcalendar/vue3'
import dayGridPlugin from '@fullcalendar/daygrid'
import interactionPlugin from '@fullcalendar/interaction'
import zhLocale from '@fullcalendar/core/locales/zh-tw'
import Swal from 'sweetalert2';

export default {
    components: {
        LeftBar,
        FullCalendar
    },
    data() {
        return {
            announceId: "",
            allAnnouncements: [],
            displayedAnnouncements: [],
            today: new Date().toISOString().split("T")[0],
            selectDate: null,
            calendarOptions: {
                plugins: [dayGridPlugin, interactionPlugin],
                initialView: 'dayGridMonth',
                locales: [zhLocale],
                locale: 'zh-tw',
                dateClick: this.handleDateClick,
                displayEventTime: false,
                events: [],
                height: 'auto',
                headerToolbar: {
                    left: 'title',
                    right: 'prev,next'
                },
            }
        };
    },
    mounted() {
        this.fetchAllAnnouncements();
        this.displayCurrentMonthAnnouncements();
    },
    methods: {
        fetchAllAnnouncements() {
            const params = { announceId: this.announceId };
            axios
                .post("http://localhost:8080/announce/searchAnnounce", params)
                .then((response) => {
                    this.allAnnouncements = response.data.data;
                    console.log("獲取的公告數據：", this.allAnnouncements);
                    this.calendarOptions.events = this.getEvents();
                    this.displayCurrentMonthAnnouncements();
                })
                .catch((error) => {
                    console.error("獲取公告失敗：", error);
                });
        },
        getEvents() {
            const colorPalette = ['#7F7F7F', '#F4D800', '#050707', '#3A6A59', '#A7A88A', '#D6C18A', '#B9C8BC'];
            const assignedEvents = [];

            return this.allAnnouncements.map((announce) => {
                const startDate = new Date(announce.announceStartTime);
                const endDate = new Date(announce.announceEndTime);
                const overlappingColors = assignedEvents
                    .filter(event => !(new Date(event.end) < startDate || new Date(event.start) > endDate))
                    .map(event => event.color);

                // 使用隨機顏色，避免重疊顏色
                let eventColor;
                do {
                    // eventColor = this.getRandomColor();
                    eventColor = colorPalette[Math.floor(Math.random() * colorPalette.length)];
                } while (overlappingColors.includes(eventColor));

                assignedEvents.push({
                    title: announce.announceTitle,
                    start: startDate,
                    end: endDate,
                    color: eventColor
                });

                return {
                    title: announce.announceTitle,
                    start: startDate,
                    end: endDate,
                    color: eventColor
                };
            });
        },

        // 隨機生成 HEX 顏色
        // getRandomColor() {
        //     const letters = '0123456789ABCDEF';
        //     let color = '#';
        //     for (let i = 0; i < 6; i++) {
        //         color += letters[Math.floor(Math.random() * 16)];
        //     }
        //     return color;
        // },
        displayCurrentMonthAnnouncements() {
            const currentMonth = new Date().getMonth();
            const currentYear = new Date().getFullYear();

            this.displayedAnnouncements = this.allAnnouncements
                .filter(announce => {
                    const startDate = new Date(announce.announceStartTime);
                    const endDate = new Date(announce.announceEndTime);
                    const startMonth = startDate.getMonth();
                    const endMonth = endDate.getMonth();
                    const startYear = startDate.getFullYear();
                    const endYear = endDate.getFullYear();

                    return (startMonth === currentMonth || endMonth === currentMonth) &&
                        (startYear === currentYear || endYear === currentYear);
                })
                .sort((a, b) => {
                    const aStartDate = new Date(a.announceStartTime);
                    const aEndDate = new Date(a.announceEndTime);
                    const bStartDate = new Date(b.announceStartTime);
                    const bEndDate = new Date(b.announceEndTime);


                    const aDuration = aEndDate - aStartDate;
                    const bDuration = bEndDate - bStartDate;

                    if (aStartDate.getTime() !== bStartDate.getTime()) {
                        return aStartDate - bStartDate;
                    }
                    return aDuration - bDuration;
                });
        },

        handleDateClick(info) {
            const calendarApi = info.view.calendar;
            calendarApi.gotoDate(info.date);

            this.selectDate = info.dateStr;

            const previouslySelected = document.querySelector('.selected-date');
            if (previouslySelected) {
                previouslySelected.classList.remove('selected-date');
            }
            info.dayEl.classList.add('selected-date');

            this.displayedAnnouncements = this.allAnnouncements.filter(announce => {
                const startDate = new Date(announce.announceStartTime).toISOString().split("T")[0];
                const endDate = new Date(announce.announceEndTime).toISOString().split("T")[0];
                return this.selectDate >= startDate && this.selectDate <= endDate;
            });
            this.displayedAnnouncements.sort((a, b) => {
                const aStartDate = new Date(a.announceStartTime);
                const aEndDate = new Date(a.announceEndTime);
                const bStartDate = new Date(b.announceStartTime);
                const bEndDate = new Date(b.announceEndTime);

                if (aStartDate.getTime() !== bStartDate.getTime()) {
                    return aStartDate - bStartDate;
                }

                return aEndDate - bEndDate;
            });
        },
        showAnnouncePreview(announce) {
            const imageHtml = announce.announcePictureName
                ? `<img src="${announce.announcePictureName}" alt="圖片預覽" style="width: 100%; height: auto;"/>`
                : "";
            Swal.fire({
                html: `
            ${imageHtml}
            <h3 style="text-align: left;">${announce.announceTitle}</h3>
            <p style="text-align: left; padding-top: 3%;">活動時間 ${announce.announceStartTime} ~ ${announce.announceEndTime}</p>
            <pre style="text-align: left; padding-top: 2%; white-space: pre-wrap; word-break: break-word; overflow-y: auto;">${announce.announceContent}</pre>
        `,
                focusConfirm: false,
                confirmButtonText: '關閉',
                width: '800px',
            });
        },
    }
};
</script>


<template>
    <div class="big">
        <div class="leftBar">
            <LeftBar />
        </div>
        <div class="mainArea">
            <div class="mainbox">

                <div class="calendar-container">
                    <FullCalendar :options="calendarOptions" />
                </div>
            </div>
            <div>
                <div class="announcebox">
                    <div class="announcetitle">
                        <h2>近期活動</h2>
                    </div>
                    <div class="announcebox-content">
                        <div v-for="announce in displayedAnnouncements" :key="announce.announceId"
                            class="announcement-item" @click="showAnnouncePreview(announce)">
                            <img v-if="announce.announcePictureName" :src="announce.announcePictureName"
                                class="preview-image" />
                            <img v-else src="/images/default-menu-img.png" class="preview-image" />
                            <div class="announcetext">
                                <h3
                                    style="text-overflow: ellipsis; overflow: hidden; white-space: nowrap; margin-bottom: 2%;">
                                    {{ announce.announceTitle }}</h3>
                                <span style="letter-spacing: 0.2dvw;">{{ announce.announceStartTime }}~</span>
                                <span style="letter-spacing: 0.2dvw;">{{ announce.announceEndTime }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">


.big {
    width: 100%;
    height: 100dvh;
    display: flex;
    justify-content: center;
    align-items: center;

    .leftBar {
        width: 10%;
        height: 96.4vh;
        position: fixed;
        top: 2%;
        left: 1.4%;
        display: flex;
        align-items: center;
    }


    .mainArea {
        width: 100%;
        height: 96.4dvh;
        display: flex;
        justify-content: start;
        overflow: hidden;
        letter-spacing: 0.2dvw;

        .mainbox {
            width: 65%;
            height: 100%;
            background-color: #fff;
            box-shadow: -3px 3px 4px black;
            border: 1px solid rgba(grey, 0.5);
            border: 1px solid;
            border-radius: 10px;
            margin-left: 2%;
            overflow-y: scroll;
            scrollbar-width: none;
            border: 1px solid rgba($color: gray, $alpha: 0.6);
        }

        .calendar-container {
            width: 90%;
            margin-left: 5%;
            margin-bottom: 2%;
        }
    }
}

.announcebox {
    width: 400px;
    height: 100%;
    margin-left: 8%;
    border: 1px solid rgba(grey, 0.5);
    border: 1px solid;
    border-radius: 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
    background-color: #fff;
    box-shadow: -3px 3px 4px black;
}

.announcetitle {
    width: 90%;
    margin-top: 5%;
    margin-bottom: 2%;
    padding-bottom: 2%;
    border-bottom: 1px solid rgba($color: gray, $alpha: 0.8);
}

.announcebox-content {
    width: 100%;
    max-height: 90%;
    overflow-y: scroll;
    display: flex;
    flex-direction: column;
    align-items: center;
    scrollbar-width: none;
}

.announcement-item {
    width: 290px;
    height: 300px;
    margin-top: 2%;
    margin-bottom: 2%;
    cursor: pointer;
    border: 1px solid rgba($color: gray, $alpha: 0.8);
    border-radius: 10px;
}

.preview-image {
    width: 288px;
    height: 200px;
    object-fit: fill;
    border-top-right-radius: 10px;
    border-top-left-radius: 10px;
}

.announcetext {
    height: 70px;
    padding-left: 5%;
    padding-right: 5%;
    padding-top: 4%;
    margin-bottom: 2%;
    border-top: 1px solid rgba($color: gray, $alpha: 0.8);
}

pre {
    white-space: pre-wrap;
    word-break: break-word;
    overflow-y: auto;
}

th {
    border-radius: 10px;
    background-color: #DDE1E6;
}
</style>

<style>
.fc-event {
    pointer-events: none;
}

.selected-date {
    border: 2px solid #0000ff;
    background-color: rgba(0, 0, 255, 0.1);
}

.fc-toolbar-chunk .fc-button {
    border-radius: 100%;
}

.fc-col-header {
    background-color: #DDE1E6;
    border-radius: 10px;
}

.fc table,
.fc table th,
.fc table td {
    border: none;
    box-shadow: none;
}

.fc .fc-scrollgrid-liquid {
    border: none;
}

.fc .fc-daygrid-day-frame {
    border: 1px solid black;
}

.fc-scrollgrid-sync-table {
    margin-top: 2%;
    overflow: hidden;
    height: 100%;

}

.fc .fc-daygrid-day {
    height: 100px;

}

.fc-event-title {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    max-width: 100%;
}


.fc .fc-button-group>.fc-button {
    margin-top: 10%;
}

.fc .fc-scrollgrid {
    border: none;

}

.fc-toolbar {
    height: 100px;
    position: sticky;
    top: 0;
    z-index: 10;
    background-color: white;
}

.fc .fc-toolbar.fc-header-toolbar {
    margin-bottom: 0px;
}

.fc .fc-scrollgrid-section-header.fc-scrollgrid-section-sticky>* {
    top: 0px;
    position: sticky;
    top: 100px;
    z-index: 50;
    background-color: #DDE1E6;
    padding: 0.5%;
    border-radius: 10px;
}
</style>
