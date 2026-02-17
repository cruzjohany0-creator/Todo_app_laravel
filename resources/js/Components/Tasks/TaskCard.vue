<template>
    <div class="task-card-futuristic group">
        <div class="status-glow-bar" :class="statusClasses[task.status]"></div>
        
        <div class="p-6 relative z-10">
            <div class="flex justify-between items-start mb-4 gap-3 border-b border-white/10 pb-3">
                <h3 class="task-title flex-1">
                    {{ task.title }}
                </h3>
                <span class="cyber-badge" :class="statusClasses[task.status]">
                    {{ statusLabel }}
                </span>
            </div>

            <div class="mb-4">
                <p v-if="task.description" class="task-desc">
                    {{ task.description }}
                </p>
                <p v-else class="task-desc-empty">
                    // SIN DESCRIPCIÓN DISPONIBLE _
                </p>
            </div>

            <div class="date-tag mb-5" :class="dateColorClass">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                          d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                <span class="font-bold tracking-widest">{{ formattedDate }}</span>
            </div>

            <div class="mb-5">
                <label class="cyber-label">Cambiar Estado Operativo:</label>
                <select 
                    :value="task.status"
                    @change="$emit('updateStatus', task, $event.target.value)"
                    class="cyber-select"
                >
                    <option value="pendiente">⏳ PENDIENTE</option>
                    <option value="en_proceso">⚡ EN PROCESO</option>
                    <option value="terminado">✅ TERMINADO</option>
                </select>
            </div>

            <div class="flex gap-3">
                <button @click="$emit('edit', task)" class="action-btn edit-btn">
                    EDITAR
                </button>
                <button @click="$emit('delete', task)" class="action-btn delete-btn">
                    ELIMINAR
                </button>
            </div>
        </div>
    </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
    task: { type: Object, required: true }
});

defineEmits(['edit', 'delete', 'updateStatus']);

const statusClasses = {
    'pendiente': 'is-pending',
    'en_proceso': 'is-progress',
    'terminado': 'is-done'
};

const statusLabel = computed(() => {
    const labels = { 'pendiente': 'PENDIENTE', 'en_proceso': 'EN PROCESO', 'terminado': 'TERMINADO' };
    return labels[props.task.status];
});

const formattedDate = computed(() => {
    const date = new Date(props.task.due_date);
    return date.toLocaleDateString('es-CO', {
        day: '2-digit', month: 'short', year: 'numeric'
    }).toUpperCase();
});

const dateColorClass = computed(() => {
    const today = new Date();
    today.setHours(0,0,0,0);
    const dueDate = new Date(props.task.due_date);
    const diffDays = Math.ceil((dueDate - today) / (1000 * 60 * 60 * 24));
    
    if (diffDays < 0) return 'date-urgent'; 
    if (diffDays <= 3) return 'date-near';
    return 'date-normal';
});
</script>

<style scoped>
/* Fondo oscuro para que el texto resalte */
.task-card-futuristic {
    position: relative;
    background: rgba(10, 15, 25, 0.9); /* Más oscuro y menos transparente */
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.15);
    border-radius: 12px;
    transition: all 0.3s ease;
    overflow: hidden;
}

.task-card-futuristic:hover {
    border-color: #06b6d4;
    box-shadow: 0 0 20px rgba(6, 182, 212, 0.2);
}

/* Barra lateral con más brillo */
.status-glow-bar {
    position: absolute;
    left: 0; top: 0; bottom: 0;
    width: 6px;
}
.is-pending { background: #facc15; box-shadow: 2px 0 10px #facc15; }
.is-progress { background: #06b6d4; box-shadow: 2px 0 10px #06b6d4; }
.is-done { background: #22c55e; box-shadow: 2px 0 10px #22c55e; }

/* Título en Blanco Puro */
.task-title {
    color: #ffffff;
    font-weight: 800;
    font-size: 1.2rem;
}

/* DESCRIPCIÓN: Color claro para lectura perfecta */
.task-desc {
    color: #e2e8f0; 
    font-size: 0.95rem;
    line-height: 1.6;
}

.task-desc-empty {
    color: #475569;
    font-family: monospace;
    font-size: 0.8rem;
}

/* ETIQUETA DE FECHA: Resaltada */
.date-tag {
    display: inline-flex;
    align-items: center;
    padding: 4px 10px;
    border-radius: 4px;
    background: rgba(0, 0, 0, 0.3);
    font-size: 0.75rem;
}
.date-urgent { color: #f87171; border: 1px solid #f87171; }
.date-near { color: #fbbf24; border: 1px solid #fbbf24; }
.date-normal { color: #22d3ee; border: 1px solid #22d3ee; }

/* BADGE DE ESTADO */
.cyber-badge {
    font-size: 0.7rem;
    font-weight: 900;
    padding: 2px 8px;
    border-radius: 4px;
    color: #fff;
    text-shadow: 0 0 5px rgba(0,0,0,0.5);
}
.cyber-badge.is-pending { background: #a16207; }
.cyber-badge.is-progress { background: #0891b2; }
.cyber-badge.is-done { background: #15803d; }

/* SELECTOR */
.cyber-label {
    display: block;
    color: #94a3b8;
    font-size: 0.7rem;
    font-weight: 700;
    margin-bottom: 5px;
    text-transform: uppercase;
}
.cyber-select {
    width: 100%;
    background: #1e293b;
    border: 1px solid #334155;
    color: #fff;
    padding: 8px;
    border-radius: 6px;
    outline: none;
}

/* BOTONES */
.action-btn {
    flex: 1;
    padding: 10px;
    font-weight: 800;
    font-size: 0.7rem;
    border-radius: 6px;
    transition: 0.2s;
    text-transform: uppercase;
}
.edit-btn { background: #2563eb; color: white; }
.delete-btn { background: #dc2626; color: white; }
.action-btn:hover { filter: brightness(1.2); transform: translateY(-2px); }
</style>