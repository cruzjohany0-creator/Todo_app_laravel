<script setup>
import { ref } from 'vue';
import Dropdown from '@/Components/Dropdown.vue';
import DropdownLink from '@/Components/DropdownLink.vue';
import { Link, usePage } from '@inertiajs/vue3';

const showMobile = ref(false);
const page = usePage();

const navItems = [
    {
        label: 'Inicio',
        route: 'dashboard',
        match: 'dashboard',
        icon: `<svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>`
    },
    {
        label: 'Mis Tareas',
        route: 'tasks.index',
        match: 'tasks.*',
        icon: `<svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"/></svg>`
    },
];

const isActive    = (match) => route().current(match);
const userName    = () => page.props.auth?.user?.name  ?? '';
const userEmail   = () => page.props.auth?.user?.email ?? '';
const userInitial = () => userName().charAt(0).toUpperCase();
</script>

<template>
    <div class="shell">

        <!-- ═══ NAVBAR ═══ -->
        <nav class="nav">
            <div class="nav-glow-line"></div>
            <div class="nav-inner">

                <!-- LOGO -->
                <Link :href="route('dashboard')" class="logo">
                    <div class="logo-box">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5"
                                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"/>
                        </svg>
                    </div>
                    <span class="logo-word">Todo<em>App</em></span>
                </Link>

                <!-- LINKS DESKTOP -->
                <div class="links">
                    <Link
                        v-for="item in navItems"
                        :key="item.route"
                        :href="route(item.route)"
                        class="lnk"
                        :class="{ 'lnk--on': isActive(item.match) }"
                    >
                        <span class="lnk-ico" v-html="item.icon"></span>
                        <span>{{ item.label }}</span>
                        <span v-if="isActive(item.match)" class="lnk-pip"></span>
                    </Link>
                </div>

                <!-- DERECHA DESKTOP -->
                <div class="nav-end">
                    <!-- Badge online -->
                    <div class="online">
                        <span class="online-dot"></span>
                        <span class="online-txt">En línea</span>
                    </div>

                    <!-- Usuario dropdown -->
                    <Dropdown align="right" width="56">
                        <template #trigger>
                            <button class="u-btn">
                                <div class="u-av">
                                    {{ userInitial() }}
                                    <span class="u-ring"></span>
                                </div>
                                <div class="u-meta">
                                    <span class="u-name">{{ userName() }}</span>
                                    <span class="u-role">Usuario</span>
                                </div>
                                <svg class="u-chev w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                                </svg>
                            </button>
                        </template>

                        <template #content>
                            <div class="dd">
                                <!-- Header -->
                                <div class="dd-top">
                                    <div class="dd-av">{{ userInitial() }}</div>
                                    <div class="dd-info">
                                        <p class="dd-nm">{{ userName() }}</p>
                                        <p class="dd-em">{{ userEmail() }}</p>
                                    </div>
                                </div>
                                <div class="dd-sep"></div>

                                <DropdownLink :href="route('profile.edit')">
                                    <span class="dd-row">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                                        </svg>
                                        Mi Perfil
                                    </span>
                                </DropdownLink>

                                <DropdownLink :href="route('two-factor.index')" v-if="route().has('two-factor.index')">
                                    <span class="dd-row">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                                        </svg>
                                        Seguridad 2FA
                                    </span>
                                </DropdownLink>

                                <div class="dd-sep"></div>

                                <DropdownLink :href="route('logout')" method="post" as="button">
                                    <span class="dd-row dd-out">
                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
                                        </svg>
                                        Cerrar Sesión
                                    </span>
                                </DropdownLink>
                            </div>
                        </template>
                    </Dropdown>
                </div>

                <!-- HAMBURGUESA -->
                <button class="hbg" :class="{ open: showMobile }" @click="showMobile = !showMobile">
                    <span></span><span></span><span></span>
                </button>
            </div>

            <!-- MENÚ MOBILE -->
            <Transition name="mob">
                <div v-if="showMobile" class="mob-menu">
                    <div class="mob-links">
                        <Link v-for="item in navItems" :key="item.route"
                            :href="route(item.route)"
                            class="mob-lnk" :class="{ 'mob-lnk--on': isActive(item.match) }"
                            @click="showMobile=false">
                            <span class="mob-ico" v-html="item.icon"></span>
                            <span>{{ item.label }}</span>
                            <svg v-if="isActive(item.match)" class="w-4 h-4 ml-auto" style="color:#06b6d4" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                            </svg>
                        </Link>
                    </div>
                    <div class="mob-sep"></div>
                    <div class="mob-user">
                        <div class="mob-av">{{ userInitial() }}</div>
                        <div>
                            <p class="mob-un">{{ userName() }}</p>
                            <p class="mob-ue">{{ userEmail() }}</p>
                        </div>
                    </div>
                    <div class="mob-acts">
                        <Link :href="route('profile.edit')" class="mob-act" @click="showMobile=false">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                            Mi Perfil
                        </Link>
                        <Link :href="route('logout')" method="post" as="button" class="mob-act mob-out" @click="showMobile=false">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                            Cerrar Sesión
                        </Link>
                    </div>
                </div>
            </Transition>
        </nav>

        <!-- HEADER DE PÁGINA -->
        <header v-if="$slots.header" class="ph">
            <div class="ph-inner"><slot name="header" /></div>
        </header>

        <!-- CONTENIDO -->
        <main><slot /></main>
    </div>
</template>

<style scoped>
.shell { min-height:100vh; background:#000; display:flex; flex-direction:column; }
main   { flex:1; }

/* ═══ NAVBAR ═══ */
.nav {
    position:sticky; top:0; z-index:100;
    background:rgba(0,0,0,0.88);
    backdrop-filter:blur(24px);
    -webkit-backdrop-filter:blur(24px);
    border-bottom:1px solid rgba(255,255,255,0.07);
}

.nav-glow-line {
    height:1px;
    background:linear-gradient(90deg,
        transparent 0%,
        rgba(6,182,212,.55) 20%,
        rgba(168,85,247,.5) 50%,
        rgba(34,197,94,.4) 80%,
        transparent 100%);
}

.nav-inner {
    max-width:1280px; margin:0 auto;
    padding:0 1.5rem; height:64px;
    display:flex; align-items:center; gap:1.75rem;
}

/* LOGO */
.logo { display:flex;align-items:center;gap:.625rem;text-decoration:none;flex-shrink:0;transition:opacity .2s; }
.logo:hover { opacity:.82; }

.logo-box {
    width:34px; height:34px;
    background:linear-gradient(135deg,#06b6d4,#0891b2);
    border-radius:9px;
    display:flex; align-items:center; justify-content:center;
    color:#000; flex-shrink:0;
    box-shadow:0 0 18px rgba(6,182,212,.4);
    transition:box-shadow .3s;
}
.logo:hover .logo-box { box-shadow:0 0 28px rgba(6,182,212,.6); }
.logo-box svg { width:18px; height:18px; }

.logo-word { font-size:1.15rem;font-weight:800;color:#f1f5f9;letter-spacing:-.03em;font-style:normal; }
.logo-word em { color:#06b6d4;font-style:normal; }

/* LINKS */
.links { display:flex;align-items:center;gap:.2rem;flex:1; }

.lnk {
    position:relative;
    display:inline-flex; align-items:center; gap:.5rem;
    padding:.48rem .875rem;
    border-radius:8px;
    text-decoration:none;
    font-size:.875rem; font-weight:500;
    color:#64748b;
    transition:all .2s;
    white-space:nowrap;
}
.lnk:hover { color:#e2e8f0; background:rgba(255,255,255,.05); }
.lnk--on   { color:#f1f5f9 !important; background:rgba(6,182,212,.1) !important; font-weight:600; }

.lnk-ico { width:17px;height:17px;flex-shrink:0;opacity:.65;transition:opacity .2s; }
.lnk:hover .lnk-ico, .lnk--on .lnk-ico { opacity:1; }
.lnk-ico :deep(svg) { width:100%;height:100%; }

.lnk-pip {
    position:absolute; bottom:-2px; left:50%; transform:translateX(-50%);
    width:20px; height:2px;
    background:linear-gradient(90deg,#06b6d4,#0891b2);
    border-radius:99px;
    box-shadow:0 0 8px rgba(6,182,212,.7);
    animation:pip .3s ease-out;
}
@keyframes pip { from{width:0;opacity:0} to{width:20px;opacity:1} }

/* DERECHA */
.nav-end { display:flex;align-items:center;gap:.875rem;margin-left:auto; }

.online {
    display:flex; align-items:center; gap:.4rem;
    background:rgba(34,197,94,.08);
    border:1px solid rgba(34,197,94,.2);
    border-radius:99px; padding:.28rem .7rem;
}
.online-dot { width:6px;height:6px;background:#22c55e;border-radius:50%;box-shadow:0 0 6px #22c55e;animation:od 2s ease-in-out infinite; }
@keyframes od { 0%,100%{box-shadow:0 0 4px #22c55e} 50%{box-shadow:0 0 10px #22c55e,0 0 18px rgba(34,197,94,.4)} }
.online-txt { font-size:.66rem;font-weight:700;color:#22c55e;text-transform:uppercase;letter-spacing:.04em; }

.u-btn {
    display:flex; align-items:center; gap:.6rem;
    padding:.35rem .7rem .35rem .35rem;
    background:rgba(255,255,255,.04);
    border:1px solid rgba(255,255,255,.08);
    border-radius:99px; cursor:pointer;
    transition:all .2s;
}
.u-btn:hover { background:rgba(255,255,255,.08);border-color:rgba(255,255,255,.15); }

.u-av {
    position:relative; width:32px;height:32px;
    background:linear-gradient(135deg,#06b6d4,#a855f7);
    border-radius:50%;
    display:flex;align-items:center;justify-content:center;
    font-size:.78rem;font-weight:800;color:#fff;flex-shrink:0;
}
.u-ring {
    position:absolute;inset:-2px;border-radius:50%;
    border:1.5px solid transparent;
    background:linear-gradient(135deg,#06b6d4,#a855f7) border-box;
    -webkit-mask:linear-gradient(#fff 0 0) padding-box, linear-gradient(#fff 0 0);
    -webkit-mask-composite:destination-out; mask-composite:exclude;
}

.u-meta { display:flex;flex-direction:column;text-align:left; }
.u-name { font-size:.78rem;font-weight:600;color:#e2e8f0;line-height:1.2;max-width:110px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap; }
.u-role { font-size:.62rem;color:#475569;text-transform:uppercase;letter-spacing:.06em; }

.u-chev { color:#475569;transition:transform .2s;flex-shrink:0; }
.u-btn:hover .u-chev { transform:rotate(180deg); }

/* DROPDOWN */
.dd {
    background:rgba(6,6,6,.98);
    border:1px solid rgba(255,255,255,.1);
    border-radius:14px; overflow:hidden;
    backdrop-filter:blur(20px);
    min-width:220px;
    box-shadow:0 24px 64px rgba(0,0,0,.85), 0 0 0 1px rgba(6,182,212,.07);
}
.dd-top { display:flex;align-items:center;gap:.75rem;padding:1rem;background:rgba(255,255,255,.025); }
.dd-av  { width:40px;height:40px;background:linear-gradient(135deg,#06b6d4,#a855f7);border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.95rem;font-weight:800;color:#fff;flex-shrink:0; }
.dd-info { min-width:0; }
.dd-nm { font-size:.875rem;font-weight:700;color:#f1f5f9;overflow:hidden;text-overflow:ellipsis;white-space:nowrap; }
.dd-em { font-size:.7rem;color:#475569;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;margin-top:.1rem; }
.dd-sep { height:1px;background:rgba(255,255,255,.06);margin:.25rem 0; }

.dd-row { display:flex;align-items:center;gap:.6rem;width:100%; }
.dd-out { color:#f87171 !important; }

/* Sobreescribir DropdownLink */
.dd :deep(a),
.dd :deep(button) {
    display:block !important; width:100% !important;
    padding:.6rem 1rem !important;
    font-size:.875rem !important; font-weight:500 !important;
    color:#94a3b8 !important; text-decoration:none !important;
    background:transparent !important; border:none !important;
    cursor:pointer !important; transition:all .15s !important;
    text-align:left !important;
}
.dd :deep(a):hover { color:#f1f5f9 !important;background:rgba(255,255,255,.05) !important; }
.dd :deep(button):last-of-type:hover { color:#f87171 !important;background:rgba(239,68,68,.08) !important; }

/* HAMBURGUESA */
.hbg {
    display:none; flex-direction:column; justify-content:center;
    gap:5px; width:36px;height:36px;
    background:rgba(255,255,255,.05);
    border:1px solid rgba(255,255,255,.1);
    border-radius:8px; cursor:pointer;
    padding:0 8px; margin-left:auto;
    transition:background .2s;
}
.hbg:hover { background:rgba(255,255,255,.1); }
.hbg span { display:block;width:100%;height:1.5px;background:#94a3b8;border-radius:99px;transition:all .28s ease;transform-origin:center; }
.hbg.open span:nth-child(1) { transform:translateY(6.5px) rotate(45deg); }
.hbg.open span:nth-child(2) { opacity:0;transform:scaleX(0); }
.hbg.open span:nth-child(3) { transform:translateY(-6.5px) rotate(-45deg); }

/* MOBILE MENU */
.mob-menu {
    border-top:1px solid rgba(255,255,255,.06);
    background:rgba(3,3,3,.97);
    backdrop-filter:blur(24px);
    padding:1rem 1.5rem 1.5rem;
}
.mob-links { display:flex;flex-direction:column;gap:.2rem;margin-bottom:.875rem; }
.mob-lnk {
    display:flex;align-items:center;gap:.75rem;
    padding:.72rem 1rem; border-radius:10px;
    text-decoration:none; font-size:.9rem; font-weight:500;
    color:#64748b; border:1px solid transparent; transition:all .2s;
}
.mob-lnk:hover { color:#e2e8f0;background:rgba(255,255,255,.05); }
.mob-lnk--on { color:#06b6d4 !important;background:rgba(6,182,212,.09) !important;border-color:rgba(6,182,212,.2) !important;font-weight:600; }
.mob-ico { width:17px;height:17px;flex-shrink:0; }
.mob-ico :deep(svg) { width:100%;height:100%; }

.mob-sep { height:1px;background:rgba(255,255,255,.06);margin:.7rem 0; }

.mob-user { display:flex;align-items:center;gap:.75rem;padding:.72rem 1rem;background:rgba(255,255,255,.03);border-radius:10px;margin-bottom:.7rem; }
.mob-av   { width:38px;height:38px;background:linear-gradient(135deg,#06b6d4,#a855f7);border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.875rem;font-weight:800;color:#fff;flex-shrink:0; }
.mob-un   { font-size:.875rem;font-weight:700;color:#f1f5f9; }
.mob-ue   { font-size:.7rem;color:#475569;margin-top:.1rem; }

.mob-acts { display:flex;flex-direction:column;gap:.2rem; }
.mob-act  {
    display:flex;align-items:center;gap:.7rem;
    padding:.68rem 1rem; border-radius:10px;
    text-decoration:none; font-size:.875rem; font-weight:500;
    color:#64748b; background:transparent; border:none;
    cursor:pointer; width:100%; text-align:left; transition:all .2s;
}
.mob-act:hover { color:#e2e8f0;background:rgba(255,255,255,.05); }
.mob-out:hover { color:#f87171 !important;background:rgba(239,68,68,.08) !important; }

.mob-enter-active,.mob-leave-active { transition:all .26s ease; }
.mob-enter-from,.mob-leave-to       { opacity:0;transform:translateY(-10px); }

/* PAGE HEADER */
.ph       { background:rgba(0,0,0,.7);border-bottom:1px solid rgba(255,255,255,.06);backdrop-filter:blur(20px); }
.ph-inner { max-width:1280px;margin:0 auto;padding:1.2rem 1.5rem; }

/* RESPONSIVE */
@media(max-width:768px) {
    .links,.nav-end { display:none; }
    .hbg { display:flex; }
}
</style>