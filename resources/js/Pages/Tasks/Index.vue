<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import TaskCard from '@/Components/Tasks/TaskCard.vue';
import TaskModal from '@/Components/Tasks/TaskModal.vue';
import FilterButtons from '@/Components/Tasks/FilterButtons.vue';
import { Head, router } from '@inertiajs/vue3';
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'; // Añadido onMounted/Unmounted
import { useTaskStore } from '@/stores/taskStore';

const props = defineProps({
    tasks: Array,
    currentStatus: String,
});

const taskStore = useTaskStore();
const showModal = ref(false);
const editingTask = ref(null);

/* ── LÓGICA DE FONDO INTERACTIVO (Copiada del Dashboard) ── */
const canvasRef = ref(null);
const spotX = ref(50);
const spotY = ref(50);
let animId = null;
let pts = [];
let mx = -9999, my = -9999;

function initCanvas(c) {
    c.width = window.innerWidth;
    c.height = window.innerHeight;
    const n = Math.floor(c.width * c.height / 11000);
    pts = Array.from({ length: n }, () => ({
        x: Math.random() * c.width,
        y: Math.random() * c.height,
        vx: (Math.random() - .5) * .38,
        vy: (Math.random() - .5) * .38,
        r: Math.random() * 1.5 + .3,
        o: Math.random() * .45 + .1,
        col: Math.random() > .83 ? '6,182,212' : Math.random() > .68 ? '168,85,247' : '255,255,255',
    }));
}

function render(c, ctx) {
    ctx.clearRect(0, 0, c.width, c.height);
    for (let i = 0; i < pts.length; i++)
        for (let j = i + 1; j < pts.length; j++) {
            const d = Math.hypot(pts[i].x - pts[j].x, pts[i].y - pts[j].y);
            if (d < 115) {
                ctx.beginPath();
                ctx.strokeStyle = `rgba(255,255,255,${(1 - d / 115) * .09})`;
                ctx.lineWidth = .5;
                ctx.moveTo(pts[i].x, pts[i].y);
                ctx.lineTo(pts[j].x, pts[j].y);
                ctx.stroke();
            }
        }
    pts.forEach(p => {
        const d = Math.hypot(p.x - mx, p.y - my);
        if (d < 175) {
            ctx.beginPath();
            ctx.strokeStyle = `rgba(6,182,212,${(1 - d / 175) * .52})`;
            ctx.lineWidth = .7;
            ctx.moveTo(p.x, p.y); ctx.lineTo(mx, my);
            ctx.stroke();
            p.vx += ((p.x - mx) / d) * .016;
            p.vy += ((p.y - my) / d) * .016;
        }
        p.vx *= .987; p.vy *= .987;
        p.x += p.vx; p.y += p.vy;
        if (p.x < 0 || p.x > c.width) p.vx *= -1;
        if (p.y < 0 || p.y > c.height) p.vy *= -1;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(${p.col},${p.o})`;
        ctx.fill();
    });
    animId = requestAnimationFrame(() => render(c, ctx));
}

onMounted(() => {
    const c = canvasRef.value;
    if (c) {
        const ctx = c.getContext('2d');
        initCanvas(c); render(c, ctx);
        window.addEventListener('mousemove', e => {
            mx = e.clientX; my = e.clientY;
            spotX.value = (e.clientX / window.innerWidth) * 100;
            spotY.value = (e.clientY / window.innerHeight) * 100;
        });
        window.addEventListener('resize', () => initCanvas(c));
    }
});

onUnmounted(() => { if (animId) cancelAnimationFrame(animId); });

/* ── LÓGICA DE TAREAS EXISTENTE ── */
taskStore.setTasks(props.tasks);
if (props.currentStatus) taskStore.setFilter(props.currentStatus);

watch(() => props.tasks, (newTasks) => {
    taskStore.setTasks(newTasks);
}, { deep: true });

const filteredTasks = computed(() => taskStore.filteredTasks);
const stats = computed(() => ({
    total: taskStore.totalCount,
    pending: taskStore.pendingCount,
    inProgress: taskStore.inProgressCount,
    completed: taskStore.completedCount,
}));

const openCreateModal = () => { editingTask.value = null; showModal.value = true; };
const handleEdit = (task) => { editingTask.value = { ...task }; showModal.value = true; };
const handleDelete = (taskId) => {
    if (confirm('¿Estás seguro?')) {
        taskStore.removeTask(taskId);
        router.delete(route('tasks.destroy', taskId), { preserveScroll: true });
    }
};
const handleUpdateStatus = (taskId, newStatus) => {
    const taskIndex = taskStore.tasks.findIndex(t => t.id === taskId);
    if (taskIndex !== -1) taskStore.tasks[taskIndex].status = newStatus;
    router.patch(route('tasks.updateStatus', taskId), { status: newStatus }, { preserveScroll: true });
};
const handleFilterChange = (filter) => {
    taskStore.setFilter(filter);
    router.get(route('tasks.index'), { status: filter === 'all' ? null : filter }, { preserveScroll: true, preserveState: true });
};
const closeModal = () => { showModal.value = false; editingTask.value = null; };
const handleSuccess = () => { closeModal(); router.reload({ only: ['tasks'], preserveScroll: true }); };
</script>

<template>
    <Head title="Mis Tareas" />

    <AuthenticatedLayout>
        <div class="db">
            <canvas ref="canvasRef" class="db-canvas"></canvas>
            <div class="db-dots"></div>
            <div class="db-spot" :style="{
                background: `radial-gradient(650px circle at ${spotX}% ${spotY}%,rgba(6,182,212,.065) 0%,rgba(168,85,247,.03) 45%,transparent 70%)`
            }"></div>

            <div class="wrap">
                <div class="hero anim-1" style="padding: 1.5rem 2.5rem;">
                    <div class="hero-body" style="margin-bottom: 0;">
                        <div>
                            <p class="eyebrow">Gestión de Proyectos</p>
                            <h1 class="uname">Mis Tareas</h1>
                        </div>
                        <button @click="openCreateModal" class="hbtn">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                            </svg>
                            Nueva Tarea
                        </button>
                    </div>
                </div>

                <div class="scards anim-2">
                    <div class="sc sc-gray">
                        <span class="sc-n">{{ stats.total }}</span>
                        <span class="sc-l">Total General</span>
                        <div class="sc-bar"><div class="sc-bf" style="background:#64748b; width:100%"></div></div>
                    </div>
                    <div class="sc sc-y">
                        <span class="sc-n">{{ stats.pending }}</span>
                        <span class="sc-l">Pendientes</span>
                        <div class="sc-bar"><div class="sc-bf" style="background:#eab308; width:100%"></div></div>
                    </div>
                    <div class="sc sc-c">
                        <span class="sc-n">{{ stats.inProgress }}</span>
                        <span class="sc-l">En Proceso</span>
                        <div class="sc-bar"><div class="sc-bf" style="background:#06b6d4; width:100%"></div></div>
                    </div>
                    <div class="sc sc-g">
                        <span class="sc-n">{{ stats.completed }}</span>
                        <span class="sc-l">Completadas</span>
                        <div class="sc-bar"><div class="sc-bf" style="background:#22c55e; width:100%"></div></div>
                    </div>
                </div>

                <div class="card anim-3">
                    <FilterButtons
                        :current-filter="taskStore.currentFilter"
                        :counts="{ all: stats.total, pendiente: stats.pending, en_proceso: stats.inProgress, terminado: stats.completed }"
                        @filter-change="handleFilterChange"
                    />
                </div>

                <div class="anim-4">
                    <TransitionGroup 
                        name="task-list" 
                        tag="div" 
                        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
                        v-if="filteredTasks.length > 0"
                    >
                        <TaskCard
                            v-for="task in filteredTasks"
                            :key="task.id"
                            :task="task"
                            @edit="handleEdit"
                            @delete="handleDelete"
                            @update-status="handleUpdateStatus"
                            class="task-item-futuristic"
                        />
                    </TransitionGroup>

                    <div v-else class="card empty" style="padding: 5rem;">
                        <div class="ei">📋</div>
                        <h3 class="uname" style="font-size: 1.5rem; text-align: center;">No hay tareas</h3>
                        <p class="et">
                            {{ taskStore.currentFilter === 'all' ? 'Comienza creando tu primera tarea' : 'No hay tareas con este estado' }}
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <TaskModal :show="showModal" :task="editingTask" @close="closeModal" @success="handleSuccess" />
    </AuthenticatedLayout>
</template>

<style scoped>
/* ── IMPORTACIÓN DE LOS ESTILOS DEL DASHBOARD ── */
.db { position:relative; min-height:100vh; background:#000; overflow:hidden; }
.db-canvas { position:fixed; top:0; left:0; width:100vw; height:100vh; pointer-events:none; z-index:0; }
.db-dots { position:fixed; inset:0; background-image:radial-gradient(rgba(255,255,255,.07) 1px, transparent 1px); background-size:38px 38px; pointer-events:none; z-index:1; }
.db-spot { position:fixed; inset:0; pointer-events:none; z-index:2; transition:background .08s; }

.wrap { position:relative; z-index:10; max-width:1280px; margin:0 auto; padding:2rem 1.5rem 5rem; display:flex; flex-direction:column; gap:1.5rem; }

/* Reutilización de clases Hero y Cards */
.hero { background:linear-gradient(135deg,rgba(6,182,212,.09),rgba(168,85,247,.06) 55%); border:1px solid rgba(6,182,212,.18); border-radius:20px; padding:2rem; position:relative; overflow:hidden; }
.hero::before { content:'';position:absolute;top:-1px;left:0;right:0;height:1px;background:linear-gradient(90deg,transparent,rgba(6,182,212,.5),transparent); }
.hbtn { display:inline-flex;align-items:center;gap:.5rem;padding:.55rem 1.2rem;background:linear-gradient(135deg,#06b6d4,#0891b2);color:#000;font-weight:700;border-radius:8px;transition:all .2s; }
.hbtn:hover { transform:translateY(-2px); box-shadow:0 8px 24px rgba(6,182,212,.45); }

.uname { font-size: 2rem; font-weight: 900; color: #f1f5f9; letter-spacing: -.03em; }
.eyebrow { font-size: .68rem; text-transform: uppercase; letter-spacing: .14em; color: #06b6d4; font-weight: 700; }

/* Stat Cards */
.scards { display:grid; grid-template-columns:repeat(4,1fr); gap:1rem; }
.sc { background:rgba(8,8,8,.9); border:1px solid rgba(255,255,255,.07); border-radius:14px; padding:1.2rem; transition:all .3s; }
.sc-n { display:block; font-size:1.8rem; font-weight:900; color:#f1f5f9; }
.sc-l { display:block; font-size:.65rem; color:#64748b; text-transform:uppercase; margin-bottom:.5rem; }
.sc-bar { height:3px; background:rgba(255,255,255,.05); border-radius:99px; }
.sc-bf { height:100%; border-radius:99px; }

/* Animaciones */
.anim-1 { animation:fd .6s ease-out both; }
.anim-2 { animation:fd .6s ease-out .1s both; }
.anim-3 { animation:fd .6s ease-out .2s both; }
.anim-4 { animation:fd .6s ease-out .3s both; }
@keyframes fd { from{opacity:0;transform:translateY(-14px)} to{opacity:1;transform:translateY(0)} }

/* Card base para filtros y estado vacío */
.card { background:rgba(8,8,8,.85); border:1px solid rgba(255,255,255,.07); border-radius:16px; padding:1.5rem; backdrop-filter:blur(20px); }

.ei { font-size: 3rem; margin-bottom: 1rem; opacity: 0.5; }
.et { color: #475569; margin-top: 0.5rem; }

/* Transiciones de la lista */
.task-list-enter-active, .task-list-leave-active { transition: all 0.4s ease; }
.task-list-enter-from { opacity: 0; transform: scale(0.9); }
.task-list-leave-to { opacity: 0; transform: translateY(20px); }
</style>