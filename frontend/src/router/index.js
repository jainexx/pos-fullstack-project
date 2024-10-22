import { createRouter, createWebHistory } from "vue-router";
import HomeView from "../views/HomeView.vue";
import IndexView from "../views/IndexView.vue";

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: "/",
            name: "index",
            component: IndexView,
        },
        {
            path: "/setting",
            name: "setting",
            component: () => import("../views/Setting.vue"),
        },
        {
            path: "/operation",
            name: "operation",
            component: () => import("../views/Operation.vue"),
        },
        {
            path: "/order",
            name: "order",
            component: () => import("../views/Order.vue"),
        },
        {
            path: "/orderStatus",
            name: "orderStatus",
            component: () => import("../views/OrderStatus.vue"),
        },
        {
            path: "/tableAndCheckout",
            name: "tableAndCheckout",
            component: () => import("../views/TableAndCheckout.vue"),
        },
        {
            path: "/event",
            name: "event",
            component: () => import("../views/Event.vue"),
        },
        {
            path: "/workstation",
            name: "workstation",
            component: () => import("../views/Workstation.vue"),
        },
        {
            path: "/history",
            name: "history",
            component: () => import("../views/History.vue"),
        },
        {
            path: "/system",
            name: "system",
            component: () => import("../views/System.vue"),
        },
        {
            path: "/register",
            name: "register",
            component: () => import("../views/RegisterView.vue"),
        },
        {
            path: "/staffInfo",
            name: "staffInfo",
            component: () => import("../views/StaffInfoView.vue"),
        },
        {
            path: "/forgotPassword",
            name: "forgotPassword",
            component: () => import("../views/ForgotPasswordView.vue"),
        },
        {
            path: "/userInfo",
            name: "userInfo",
            component: () => import("../views/UserInfoView.vue"),
        },
        {
            path: "/comboPage",
            name: "comboPage",
            component: () => import("../components/combo/ComboComponent.vue"),
        },
    ],
});

export default router;
