<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link } from '@inertiajs/vue3';
import { computed, ref, onMounted, onUnmounted } from 'vue';

const props = defineProps({
    tasks: {
        type: Object,
        default: () => ({ total:0, pending:0, in_progress:0, completed:0, overdue:0, today:0 })
    },
    recentTasks: { type: Array, default: () => [] }
});

const completionRate = computed(() => {
    if (!props.tasks.total) return 0;
    return Math.round((props.tasks.completed / props.tasks.total) * 100);
});
const pendingRate = computed(() => {
    if (!props.tasks.total) return 0;
    return Math.round((props.tasks.pending / props.tasks.total) * 100);
});
const inProgressRate = computed(() => {
    if (!props.tasks.total) return 0;
    return Math.round((props.tasks.in_progress / props.tasks.total) * 100);
});

const circumference = 2 * Math.PI * 80;
const dashOffset = computed(() => circumference * (1 - completionRate.value / 100));

const formatDate = (d) => d
    ? new Date(d).toLocaleDateString('es-ES', { day:'numeric', month:'short', year:'numeric' })
    : 'Sin fecha';

const statusBadge = s => ({ pendiente:'badge-y', en_proceso:'badge-c', terminado:'badge-g' }[s] || 'badge-gray');
const statusInd   = s => ({ pendiente:'ind-y',    en_proceso:'ind-c',   terminado:'ind-g'  }[s] || 'ind-gray');
const statusLabel = s => ({ pendiente:'⏳ Pendiente', en_proceso:'⚡ En Proceso', terminado:'✅ Terminado' }[s] || s);

/* ── Fondo interactivo ─────────────────────────── */
const canvasRef   = ref(null);
const spotX       = ref(50);
const spotY       = ref(50);
let animId        = null;
let pts           = [];
let mx = -9999, my = -9999;

function initCanvas(c) {
    c.width  = window.innerWidth;
    c.height = window.innerHeight;
    const n = Math.floor(c.width * c.height / 11000);
    pts = Array.from({ length: n }, () => ({
        x:  Math.random() * c.width,
        y:  Math.random() * c.height,
        vx: (Math.random() - .5) * .38,
        vy: (Math.random() - .5) * .38,
        r:  Math.random() * 1.5 + .3,
        o:  Math.random() * .45 + .1,
        col: Math.random() > .83 ? '6,182,212' : Math.random() > .68 ? '168,85,247' : '255,255,255',
    }));
}

function render(c, ctx) {
    ctx.clearRect(0, 0, c.width, c.height);

    // conexiones entre puntos
    for (let i = 0; i < pts.length; i++)
        for (let j = i + 1; j < pts.length; j++) {
            const d = Math.hypot(pts[i].x - pts[j].x, pts[i].y - pts[j].y);
            if (d < 115) {
                ctx.beginPath();
                ctx.strokeStyle = `rgba(255,255,255,${(1-d/115)*.09})`;
                ctx.lineWidth = .5;
                ctx.moveTo(pts[i].x, pts[i].y);
                ctx.lineTo(pts[j].x, pts[j].y);
                ctx.stroke();
            }
        }

    pts.forEach(p => {
        const d = Math.hypot(p.x - mx, p.y - my);

        // líneas al cursor
        if (d < 175) {
            ctx.beginPath();
            ctx.strokeStyle = `rgba(6,182,212,${(1-d/175)*.52})`;
            ctx.lineWidth = .7;
            ctx.moveTo(p.x, p.y); ctx.lineTo(mx, my);
            ctx.stroke();
            p.vx += ((p.x - mx) / d) * .016;
            p.vy += ((p.y - my) / d) * .016;
        }

        p.vx *= .987; p.vy *= .987;
        p.x  += p.vx;  p.y  += p.vy;
        if (p.x < 0 || p.x > c.width)  p.vx *= -1;
        if (p.y < 0 || p.y > c.height) p.vy *= -1;
        p.x = Math.max(0, Math.min(c.width,  p.x));
        p.y = Math.max(0, Math.min(c.height, p.y));

        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI*2);
        ctx.fillStyle = `rgba(${p.col},${p.o})`;
        ctx.fill();
    });

    // halo del cursor
    if (mx > 0) {
        const g = ctx.createRadialGradient(mx, my, 0, mx, my, 95);
        g.addColorStop(0, 'rgba(6,182,212,.13)');
        g.addColorStop(1, 'rgba(6,182,212,0)');
        ctx.beginPath(); ctx.arc(mx, my, 95, 0, Math.PI*2);
        ctx.fillStyle = g; ctx.fill();
    }

    animId = requestAnimationFrame(() => render(c, ctx));
}

const onMove = e => {
    mx = e.clientX; my = e.clientY;
    spotX.value = (e.clientX / window.innerWidth)  * 100;
    spotY.value = (e.clientY / window.innerHeight) * 100;
};
const onResize = () => { if (canvasRef.value) initCanvas(canvasRef.value); };

onMounted(() => {
    const c = canvasRef.value;
    if (!c) return;
    const ctx = c.getContext('2d');
    initCanvas(c);
    render(c, ctx);
    window.addEventListener('mousemove', onMove);
    window.addEventListener('resize', onResize);
});
onUnmounted(() => {
    if (animId) cancelAnimationFrame(animId);
    window.removeEventListener('mousemove', onMove);
    window.removeEventListener('resize', onResize);
});
</script>

<template>
    <Head title="Dashboard" />
    <AuthenticatedLayout>
  
        <div class="db">
            <!-- ── FONDO INTERACTIVO ── -->
            <canvas ref="canvasRef" class="db-canvas"></canvas>
            <div class="db-dots"></div>
            <div class="db-spot" :style="{
                background:`radial-gradient(650px circle at ${spotX}% ${spotY}%,rgba(6,182,212,.065) 0%,rgba(168,85,247,.03) 45%,transparent 70%)`
            }"></div>
            <div class="orb o1"></div>
            <div class="orb o2"></div>
            <div class="orb o3"></div>

            <!-- ── CONTENIDO ── -->
            <div class="wrap">

                <!-- HERO -->
                <div class="hero anim-1">
                    <div class="hero-body">
                        <div>
                            <p class="eyebrow">Bienvenido de vuelta</p>
                            <h1 class="uname">{{ $page.props.auth.user.name }} <span class="wave">👋</span></h1>
                            <p class="udate">{{ new Date().toLocaleDateString('es-ES',{weekday:'long',day:'numeric',month:'long'}) }}</p>
                        </div>
                        <div class="hero-stats">
                            <div class="hs"><span class="hs-n">{{ tasks.total }}</span><span class="hs-l">Total</span></div>
                            <div class="hs hs-c"><span class="hs-n">{{ completionRate }}%</span><span class="hs-l">Completado</span></div>
                            <div class="hs hs-a"><span class="hs-n">{{ tasks.today }}</span><span class="hs-l">Hoy</span></div>
                        </div>
                    </div>
                    <div class="prog-track">
                        <div class="prog-fill" :style="{width:completionRate+'%'}">
                            <span class="prog-tip"></span>
                        </div>
                    </div>
                </div>

                <!-- STAT CARDS -->
                <div class="scards anim-2">

                    <div class="sc sc-y">
                        <div class="sc-top">
                            <div class="sc-ico ico-y">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            </div>
                            <div class="sc-ring">
                                <svg viewBox="0 0 36 36">
                                    <circle cx="18" cy="18" r="14" fill="none" stroke="#1a1108" stroke-width="3.5"/>
                                    <circle cx="18" cy="18" r="14" fill="none" stroke="#eab308" stroke-width="3.5"
                                        stroke-dasharray="87.96" :stroke-dashoffset="87.96*(1-pendingRate/100)"
                                        stroke-linecap="round" transform="rotate(-90 18 18)" class="ring-arc"/>
                                </svg>
                                <span class="rlbl">{{ pendingRate }}%</span>
                            </div>
                        </div>
                        <span class="sc-n">{{ tasks.pending }}</span>
                        <span class="sc-l">Pendientes</span>
                        <div class="sc-bar"><div class="sc-bf" style="background:#eab308" :style="{width:pendingRate+'%'}"></div></div>
                    </div>

                    <div class="sc sc-c">
                        <div class="sc-top">
                            <div class="sc-ico ico-c">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
                            </div>
                            <div class="sc-ring">
                                <svg viewBox="0 0 36 36">
                                    <circle cx="18" cy="18" r="14" fill="none" stroke="#081218" stroke-width="3.5"/>
                                    <circle cx="18" cy="18" r="14" fill="none" stroke="#06b6d4" stroke-width="3.5"
                                        stroke-dasharray="87.96" :stroke-dashoffset="87.96*(1-inProgressRate/100)"
                                        stroke-linecap="round" transform="rotate(-90 18 18)" class="ring-arc"/>
                                </svg>
                                <span class="rlbl">{{ inProgressRate }}%</span>
                            </div>
                        </div>
                        <span class="sc-n">{{ tasks.in_progress }}</span>
                        <span class="sc-l">En Proceso</span>
                        <div class="sc-bar"><div class="sc-bf" style="background:#06b6d4" :style="{width:inProgressRate+'%'}"></div></div>
                    </div>

                    <div class="sc sc-g">
                        <div class="sc-top">
                            <div class="sc-ico ico-g">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            </div>
                            <div class="sc-ring">
                                <svg viewBox="0 0 36 36">
                                    <circle cx="18" cy="18" r="14" fill="none" stroke="#081208" stroke-width="3.5"/>
                                    <circle cx="18" cy="18" r="14" fill="none" stroke="#22c55e" stroke-width="3.5"
                                        stroke-dasharray="87.96" :stroke-dashoffset="87.96*(1-completionRate/100)"
                                        stroke-linecap="round" transform="rotate(-90 18 18)" class="ring-arc"/>
                                </svg>
                                <span class="rlbl">{{ completionRate }}%</span>
                            </div>
                        </div>
                        <span class="sc-n">{{ tasks.completed }}</span>
                        <span class="sc-l">Completadas</span>
                        <div class="sc-bar"><div class="sc-bf" style="background:#22c55e" :style="{width:completionRate+'%'}"></div></div>
                    </div>

                    <div class="sc sc-r">
                        <div class="sc-top">
                            <div class="sc-ico ico-r">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
                            </div>
                            <div v-if="tasks.overdue>0" class="blink"></div>
                        </div>
                        <span class="sc-n">{{ tasks.overdue }}</span>
                        <span class="sc-l">Vencidas</span>
                        <div class="sc-bar"><div class="sc-bf" style="background:#ef4444" :style="{width:tasks.overdue>0?'100%':'0%'}"></div></div>
                    </div>

                </div>

                <!-- MAIN GRID -->
                <div class="mgrid anim-3">

                    <!-- Círculo progreso -->
                    <div class="card">
                        <p class="clabel">Progreso Global</p>
                        <div class="circ-w">
                            <svg viewBox="0 0 200 200" class="circ-svg">
                                <defs>
                                    <linearGradient id="pg" x1="0%" y1="0%" x2="100%" y2="100%">
                                        <stop offset="0%"   :stop-color="completionRate>=75?'#22c55e':completionRate>=50?'#06b6d4':'#eab308'"/>
                                        <stop offset="100%" :stop-color="completionRate>=75?'#16a34a':completionRate>=50?'#0891b2':'#ca8a04'"/>
                                    </linearGradient>
                                </defs>
                                <circle cx="100" cy="100" r="80" fill="none" stroke="#111" stroke-width="16"/>
                                <circle cx="100" cy="100" r="80" fill="none" stroke="url(#pg)" stroke-width="16"
                                    :stroke-dasharray="circumference" :stroke-dashoffset="dashOffset"
                                    stroke-linecap="round" transform="rotate(-90 100 100)" class="carc"/>
                            </svg>
                            <div class="circ-ctr">
                                <span class="cpct">{{ completionRate }}<small>%</small></span>
                                <span class="csub">completado</span>
                            </div>
                        </div>
                        <div class="leg">
                            <div class="lr"><span class="ld" style="background:#eab308;box-shadow:0 0 6px #eab308"></span><span class="lt">Pendientes</span><span class="lv">{{ tasks.pending }}</span></div>
                            <div class="lr"><span class="ld" style="background:#06b6d4;box-shadow:0 0 6px #06b6d4"></span><span class="lt">En proceso</span><span class="lv">{{ tasks.in_progress }}</span></div>
                            <div class="lr"><span class="ld" style="background:#22c55e;box-shadow:0 0 6px #22c55e"></span><span class="lt">Terminadas</span><span class="lv">{{ tasks.completed }}</span></div>
                        </div>
                    </div>

                    <!-- Tareas recientes -->
                    <div class="card">
                        <div class="ch">
                            <p class="clabel">Actividad Reciente</p>
                            <Link :href="route('tasks.index')" class="seeall">Ver todas →</Link>
                        </div>
                        <div v-if="recentTasks.length" class="tlist">
                            <div v-for="(t,i) in recentTasks" :key="t.id" class="tr" :style="{animationDelay:i*.07+'s'}">
                                <div class="tr-l">
                                    <span class="tind" :class="statusInd(t.status)"></span>
                                    <div class="tmeta">
                                        <span class="ttl">{{ t.title }}</span>
                                        <span class="tdt">
                                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                                            {{ formatDate(t.due_date) }}
                                        </span>
                                    </div>
                                </div>
                                <span class="tbadge" :class="statusBadge(t.status)">{{ statusLabel(t.status) }}</span>
                            </div>
                        </div>
                        <div v-else class="empty">
                            <div class="ei">📋</div>
                            <p class="et">Sin tareas recientes</p>
                            <Link :href="route('tasks.index')" class="eb">Crear primera tarea →</Link>
                        </div>
                    </div>
                </div>

                <!-- BOTTOM GRID -->
                <div class="bgrid anim-4">

                    <!-- Acciones -->
                    <div class="card">
                        <p class="clabel">Acciones Rápidas</p>
                        <div class="acts">
                            <Link :href="route('tasks.index')" class="act act-b">
                                <span class="ai" style="background:rgba(59,130,246,.15);color:#3b82f6"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg></span>
                                <span class="at"><span class="at1">Nueva Tarea</span><span class="at2">Crear y organizar</span></span>
                                <svg class="arr w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                            </Link>
                            <Link :href="route('tasks.index')" class="act act-c">
                                <span class="ai" style="background:rgba(6,182,212,.15);color:#06b6d4"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16"/></svg></span>
                                <span class="at"><span class="at1">Ver Todas</span><span class="at2">Gestionar todo</span></span>
                                <svg class="arr w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                            </Link>
                            <Link :href="route('profile.edit')" class="act act-p">
                                <span class="ai" style="background:rgba(168,85,247,.15);color:#a855f7"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg></span>
                                <span class="at"><span class="at1">Mi Perfil</span><span class="at2">Configuración</span></span>
                                <svg class="arr w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                            </Link>
                        </div>
                    </div>

                    <!-- Tips -->
                    <div class="card">
                        <p class="clabel">💡 Consejo del Día</p>
                        <div v-if="completionRate>=75" class="tip tip-g"><span class="te">🏆</span><div><p class="th">¡Rendimiento Excepcional!</p><p class="tb">Has completado más del 75% de tus tareas. ¡Imparable!</p></div></div>
                        <div v-else-if="tasks.overdue>0" class="tip tip-r"><span class="te">⚠️</span><div><p class="th">Atención Requerida</p><p class="tb">Tienes {{ tasks.overdue }} tarea{{ tasks.overdue>1?'s':'' }} vencida{{ tasks.overdue>1?'s':'' }}. Priorízalas hoy.</p></div></div>
                        <div v-else-if="tasks.today>0" class="tip tip-c"><span class="te">📅</span><div><p class="th">¡Hoy es el día!</p><p class="tb">{{ tasks.today }} tarea{{ tasks.today>1?'s':'' }} vence{{ tasks.today>1?'n':'' }} hoy. No las postergues.</p></div></div>
                        <div v-else class="tip tip-p"><span class="te">🎯</span><div><p class="th">Mantén el Ritmo</p><p class="tb">La constancia vence al talento. Un paso a la vez.</p></div></div>
                        <div class="tip tip-a" style="margin-top:.65rem"><span class="te">⚡</span><div><p class="th">Tip Pro</p><p class="tb">Divide las tareas grandes en micro-pasos. Lo pequeño es lo poderoso.</p></div></div>
                    </div>

                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
/* ── ROOT ─────────────────────────────────── */
.db { position:relative; min-height:100vh; background:#000; overflow:hidden; }

.db-canvas {
    position:fixed; top:0; left:0;
    width:100vw; height:100vh;
    pointer-events:none; z-index:0;
}
.db-dots {
    position:fixed; inset:0;
    background-image:radial-gradient(rgba(255,255,255,.07) 1px, transparent 1px);
    background-size:38px 38px;
    pointer-events:none; z-index:1;
}
.db-spot {
    position:fixed; inset:0;
    pointer-events:none; z-index:2;
    transition:background .08s;
}
.orb { position:fixed; border-radius:50%; pointer-events:none; z-index:1; animation:orbf 20s ease-in-out infinite; }
.o1  { width:650px;height:650px;top:-220px;right:-130px;background:radial-gradient(circle,rgba(6,182,212,.07) 0%,transparent 65%);filter:blur(70px);animation-delay:0s; }
.o2  { width:500px;height:500px;bottom:-130px;left:-90px;background:radial-gradient(circle,rgba(168,85,247,.06) 0%,transparent 65%);filter:blur(70px);animation-delay:-7s; }
.o3  { width:380px;height:380px;top:45%;left:42%;background:radial-gradient(circle,rgba(34,197,94,.04) 0%,transparent 65%);filter:blur(90px);animation-delay:-14s; }
@keyframes orbf { 0%,100%{transform:translate(0,0)} 33%{transform:translate(45px,-65px)} 66%{transform:translate(-35px,45px)} }

/* ── WRAP ─────────────────────────────────── */
.wrap {
    position:relative; z-index:10;
    max-width:1280px; margin:0 auto;
    padding:2rem 1.5rem 5rem;
    display:flex; flex-direction:column; gap:1.5rem;
}

/* ── ANIMACIONES entrada ──────────────────── */
.anim-1 { animation:fd .6s ease-out both; }
.anim-2 { animation:fd .6s ease-out .1s both; }
.anim-3 { animation:fd .6s ease-out .2s both; }
.anim-4 { animation:fd .6s ease-out .3s both; }
@keyframes fd { from{opacity:0;transform:translateY(-14px)} to{opacity:1;transform:translateY(0)} }

/* ── HEADER ───────────────────────────────── */
.pulse-dot { display:inline-block;width:10px;height:10px;background:#06b6d4;border-radius:50%;animation:pd 2s ease-in-out infinite; }
@keyframes pd { 0%,100%{box-shadow:0 0 6px #06b6d4,0 0 12px #06b6d4} 50%{box-shadow:0 0 14px #06b6d4,0 0 30px #06b6d4,0 0 44px rgba(6,182,212,.3)} }

.hbtn { display:inline-flex;align-items:center;gap:.5rem;padding:.55rem 1.2rem;background:linear-gradient(135deg,#06b6d4,#0891b2);color:#000;font-weight:700;font-size:.85rem;border-radius:8px;text-decoration:none;transition:all .2s; }
.hbtn:hover { transform:translateY(-2px);box-shadow:0 8px 24px rgba(6,182,212,.45); }

/* ── HERO ─────────────────────────────────── */
.hero {
    background:linear-gradient(135deg,rgba(6,182,212,.09),rgba(168,85,247,.06) 55%,rgba(34,197,94,.05));
    border:1px solid rgba(6,182,212,.18); border-radius:20px;
    padding:2rem 2.5rem; position:relative; overflow:hidden;
}
.hero::before { content:'';position:absolute;top:-1px;left:0;right:0;height:1px;background:linear-gradient(90deg,transparent,rgba(6,182,212,.5),transparent); }

.hero-body { display:flex;align-items:flex-start;justify-content:space-between;gap:1.5rem;flex-wrap:wrap;margin-bottom:1.5rem; }
.eyebrow { font-size:.68rem;text-transform:uppercase;letter-spacing:.14em;color:#06b6d4;font-weight:700;margin-bottom:.35rem; }
.uname  { font-size:clamp(1.6rem,4vw,2.4rem);font-weight:900;color:#f1f5f9;letter-spacing:-.03em;line-height:1.1;margin-bottom:.35rem; }
.wave   { display:inline-block;animation:wv 2.5s ease-in-out infinite;transform-origin:70% 70%; }
@keyframes wv { 0%,100%{transform:rotate(0)} 25%{transform:rotate(20deg)} 75%{transform:rotate(-10deg)} }
.udate  { color:#475569;font-size:.82rem;text-transform:capitalize; }

.hero-stats { display:flex;gap:.875rem;flex-wrap:wrap; }
.hs   { background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);border-radius:12px;padding:.8rem 1.1rem;min-width:80px;text-align:center;transition:all .25s; }
.hs:hover   { background:rgba(255,255,255,.07);transform:translateY(-3px); }
.hs-c { border-color:rgba(6,182,212,.28); }
.hs-a { border-color:rgba(234,179,8,.28); }
.hs-n { display:block;font-size:1.8rem;font-weight:900;color:#f1f5f9;letter-spacing:-.04em; }
.hs-l { display:block;font-size:.62rem;color:#64748b;text-transform:uppercase;letter-spacing:.07em;margin-top:.1rem; }

.prog-track { height:3px;background:rgba(255,255,255,.06);border-radius:99px;overflow:hidden; }
.prog-fill  { height:100%;background:linear-gradient(90deg,#06b6d4,#a855f7,#22c55e);border-radius:99px;transition:width 1.8s cubic-bezier(.16,1,.3,1);position:relative; }
.prog-tip   { position:absolute;right:0;top:50%;transform:translateY(-50%);width:8px;height:8px;background:#fff;border-radius:50%;box-shadow:0 0 10px #fff,0 0 20px #06b6d4; }

/* ── STAT CARDS ───────────────────────────── */
.scards { display:grid;grid-template-columns:repeat(4,1fr);gap:1rem; }

.sc {
    background:rgba(8,8,8,.9);border:1px solid rgba(255,255,255,.07);
    border-radius:14px;padding:1.2rem;transition:all .3s;position:relative;overflow:hidden;
}
.sc::before { content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,.025) 0%,transparent 60%);pointer-events:none; }
.sc:hover { transform:translateY(-5px); }
.sc-y:hover { border-color:rgba(234,179,8,.35); box-shadow:0 10px 40px rgba(234,179,8,.12); }
.sc-c:hover { border-color:rgba(6,182,212,.35);  box-shadow:0 10px 40px rgba(6,182,212,.12); }
.sc-g:hover { border-color:rgba(34,197,94,.35);  box-shadow:0 10px 40px rgba(34,197,94,.12); }
.sc-r:hover { border-color:rgba(239,68,68,.35);  box-shadow:0 10px 40px rgba(239,68,68,.12); }

.sc-top { display:flex;align-items:center;justify-content:space-between;margin-bottom:.875rem; }
.sc-ico { width:40px;height:40px;border-radius:9px;display:flex;align-items:center;justify-content:center; }
.ico-y { background:rgba(234,179,8,.12);color:#eab308; }
.ico-c { background:rgba(6,182,212,.12);color:#06b6d4; }
.ico-g { background:rgba(34,197,94,.12);color:#22c55e; }
.ico-r { background:rgba(239,68,68,.12);color:#ef4444; }

.sc-ring { position:relative;width:44px;height:44px; }
.sc-ring svg { width:100%;height:100%; }
.ring-arc { transition:stroke-dashoffset 1.3s ease; }
.rlbl { position:absolute;inset:0;display:flex;align-items:center;justify-content:center;font-size:.52rem;font-weight:700;color:#64748b; }

.sc-n { display:block;font-size:2rem;font-weight:900;color:#f1f5f9;letter-spacing:-.04em;line-height:1;margin-bottom:.15rem; }
.sc-l { display:block;font-size:.72rem;color:#64748b;margin-bottom:.875rem; }
.sc-bar { height:3px;background:rgba(255,255,255,.05);border-radius:99px;overflow:hidden; }
.sc-bf  { height:100%;border-radius:99px;transition:width 1.4s cubic-bezier(.16,1,.3,1); }

.blink { width:10px;height:10px;background:#ef4444;border-radius:50%;animation:bl 1.2s ease-in-out infinite; }
@keyframes bl { 0%,100%{box-shadow:0 0 4px #ef4444;opacity:1} 50%{box-shadow:0 0 14px #ef4444,0 0 28px rgba(239,68,68,.4);opacity:.7} }

/* ── CARD BASE ────────────────────────────── */
.card {
    background:rgba(8,8,8,.85);border:1px solid rgba(255,255,255,.07);
    border-radius:16px;padding:1.5rem;backdrop-filter:blur(20px);
    position:relative;overflow:hidden;transition:border-color .3s;
}
.card::before { content:'';position:absolute;inset:0;border-radius:16px;background:linear-gradient(135deg,rgba(255,255,255,.025) 0%,transparent 55%);pointer-events:none; }
.card:hover { border-color:rgba(255,255,255,.12); }

.clabel { font-size:.7rem;font-weight:700;text-transform:uppercase;letter-spacing:.1em;color:#475569;margin-bottom:1.25rem; }
.ch { display:flex;align-items:center;justify-content:space-between;margin-bottom:1.25rem; }
.ch .clabel { margin-bottom:0; }
.seeall { font-size:.7rem;font-weight:700;color:#06b6d4;text-decoration:none;transition:opacity .2s; }
.seeall:hover { opacity:.65; }

/* ── MAIN GRID ────────────────────────────── */
.mgrid { display:grid;grid-template-columns:280px 1fr;gap:1.5rem; }

.circ-w { position:relative;display:flex;align-items:center;justify-content:center;margin-bottom:1.5rem; }
.circ-svg { width:188px;height:188px; }
.carc { transition:stroke-dashoffset 1.7s cubic-bezier(.16,1,.3,1),stroke .5s ease; }
.circ-ctr { position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center; }
.cpct { font-size:2.3rem;font-weight:900;color:#f1f5f9;letter-spacing:-.05em;line-height:1; }
.cpct small { font-size:1.1rem; }
.csub { font-size:.62rem;text-transform:uppercase;letter-spacing:.09em;color:#475569;margin-top:.2rem; }

.leg { display:flex;flex-direction:column;gap:.65rem; }
.lr  { display:flex;align-items:center;gap:.7rem; }
.ld  { width:8px;height:8px;border-radius:50%;flex-shrink:0; }
.lt  { flex:1;font-size:.77rem;color:#475569; }
.lv  { font-size:.85rem;font-weight:700;color:#f1f5f9; }

/* Tasks */
.tlist { display:flex;flex-direction:column;gap:.45rem; }
.tr {
    display:flex;align-items:center;justify-content:space-between;gap:.875rem;
    padding:.82rem 1rem;background:rgba(255,255,255,.02);border:1px solid transparent;
    border-radius:10px;transition:all .2s;animation:fu .4s ease-out both;
}
@keyframes fu { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }
.tr:hover { background:rgba(255,255,255,.045);border-color:rgba(255,255,255,.08);transform:translateX(5px); }

.tr-l { display:flex;align-items:center;gap:.7rem;flex:1;min-width:0; }
.tind { width:4px;height:32px;border-radius:99px;flex-shrink:0; }
.ind-y { background:#eab308;box-shadow:0 0 8px rgba(234,179,8,.6); }
.ind-c { background:#06b6d4;box-shadow:0 0 8px rgba(6,182,212,.6); }
.ind-g { background:#22c55e;box-shadow:0 0 8px rgba(34,197,94,.6); }
.ind-gray { background:#475569; }

.tmeta { display:flex;flex-direction:column;min-width:0; }
.ttl  { font-size:.875rem;font-weight:600;color:#e2e8f0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis; }
.tdt  { display:flex;align-items:center;gap:.3rem;font-size:.67rem;color:#475569;margin-top:.15rem; }

.tbadge { font-size:.6rem;font-weight:700;padding:.27rem .62rem;border-radius:99px;white-space:nowrap;flex-shrink:0;letter-spacing:.03em;border:1px solid transparent; }
.badge-y    { background:rgba(234,179,8,.1);color:#eab308;border-color:rgba(234,179,8,.25); }
.badge-c    { background:rgba(6,182,212,.1);color:#06b6d4;border-color:rgba(6,182,212,.25); }
.badge-g    { background:rgba(34,197,94,.1);color:#22c55e;border-color:rgba(34,197,94,.25); }
.badge-gray { background:rgba(71,85,105,.1);color:#64748b;border-color:rgba(71,85,105,.25); }

.empty { text-align:center;padding:3rem 1rem; }
.ei { font-size:2.7rem;opacity:.3;margin-bottom:.7rem; }
.et { color:#475569;font-size:.83rem;margin-bottom:1rem; }
.eb { color:#06b6d4;font-size:.83rem;font-weight:600;text-decoration:none; }
.eb:hover { opacity:.7; }

/* ── BOTTOM GRID ──────────────────────────── */
.bgrid { display:grid;grid-template-columns:1fr 1fr;gap:1.5rem; }

.acts { display:flex;flex-direction:column;gap:.7rem; }
.act  { display:flex;align-items:center;gap:.875rem;padding:.875rem 1rem;border-radius:10px;text-decoration:none;border:1px solid transparent;transition:all .22s; }
.act-b { background:rgba(59,130,246,.06); }
.act-c { background:rgba(6,182,212,.06); }
.act-p { background:rgba(168,85,247,.06); }
.act-b:hover { background:rgba(59,130,246,.12);border-color:rgba(59,130,246,.25);transform:translateX(6px); }
.act-c:hover { background:rgba(6,182,212,.12);border-color:rgba(6,182,212,.25);transform:translateX(6px); }
.act-p:hover { background:rgba(168,85,247,.12);border-color:rgba(168,85,247,.25);transform:translateX(6px); }

.ai  { width:38px;height:38px;border-radius:8px;display:flex;align-items:center;justify-content:center;flex-shrink:0; }
.at  { flex:1;display:flex;flex-direction:column; }
.at1 { font-size:.875rem;font-weight:600;color:#e2e8f0; }
.at2 { font-size:.72rem;color:#475569;margin-top:.08rem; }
.arr { color:#334155;transition:transform .2s; }
.act:hover .arr { color:#64748b;transform:translateX(4px); }

.tip { display:flex;align-items:flex-start;gap:.875rem;padding:.875rem 1rem;border-radius:10px;border:1px solid transparent;margin-bottom:.6rem; }
.tip-g { background:rgba(34,197,94,.06);border-color:rgba(34,197,94,.15); }
.tip-r { background:rgba(239,68,68,.06);border-color:rgba(239,68,68,.15); }
.tip-c { background:rgba(6,182,212,.06);border-color:rgba(6,182,212,.15); }
.tip-p { background:rgba(168,85,247,.06);border-color:rgba(168,85,247,.15); }
.tip-a { background:rgba(234,179,8,.05);border-color:rgba(234,179,8,.12); }
.te  { font-size:1.35rem;flex-shrink:0;margin-top:.05rem; }
.th  { font-size:.72rem;font-weight:800;text-transform:uppercase;letter-spacing:.06em;color:#e2e8f0;margin-bottom:.22rem; }
.tb  { font-size:.77rem;color:#64748b;line-height:1.5; }

/* ── RESPONSIVE ───────────────────────────── */
@media(max-width:1024px) { .scards{grid-template-columns:repeat(2,1fr)} .mgrid{grid-template-columns:1fr} }
@media(max-width:640px)  { .scards{grid-template-columns:1fr 1fr} .bgrid{grid-template-columns:1fr} .hero-body{flex-direction:column} .wrap{padding:1.25rem 1rem 4rem} }
</style>