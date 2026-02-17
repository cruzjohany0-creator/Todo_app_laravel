<script setup>
import { useForm } from '@inertiajs/vue3';
import { watch, computed } from 'vue';

const props = defineProps({
    show: Boolean,
    task: Object,
});

const emit = defineEmits(['close', 'success']);

const isEditing = computed(() => !!props.task);

const form = useForm({
    title: '',
    description: '',
    due_date: '',
    status: 'pendiente',
});

watch(() => props.task, (newTask) => {
    if (newTask) {
        form.title = newTask.title || '';
        form.description = newTask.description || '';
        form.due_date = newTask.due_date || '';
        form.status = newTask.status || 'pendiente';
    } else {
        form.reset();
    }
}, { immediate: true });

const closeModal = () => {
    emit('close');
    form.reset();
};

const submit = () => {
    const action = isEditing.value 
        ? route('tasks.update', props.task.id) 
        : route('tasks.store');
    
    const method = isEditing.value ? 'put' : 'post';

    form[method](action, {
        preserveScroll: true,
        onSuccess: () => {
            emit('success');
            form.reset();
        },
    });
};

const today = new Date().toISOString().split('T')[0];
const descriptionLength = computed(() => form.description?.length || 0);
</script>

<template>
    <Teleport to="body">
        <Transition name="cyber-modal">
            <div v-if="show" class="modal-overlay" @click.self="closeModal">
                
                <div class="modal-container" @click.stop>
                    <div class="modal-glow-line"></div>

                    <div class="modal-header">
                        <div>
                            <p class="modal-eyebrow">{{ isEditing ? 'Acceso a Registro' : 'Nueva Entrada de Datos' }}</p>
                            <h3 class="modal-title">
                                {{ isEditing ? '✏️ EDITAR TAREA' : '➕ CREAR TAREA' }}
                            </h3>
                        </div>
                        <button @click="closeModal" class="close-btn">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </button>
                    </div>

                    <form @submit.prevent="submit" class="modal-body">
                        
                        <div class="input-group">
                            <label for="title" class="cyber-label">Identificador del Título</label>
                            <input
                                id="title"
                                v-model="form.title"
                                type="text"
                                class="cyber-input"
                                placeholder="Nombre de la tarea..."
                                required
                            />
                            <p v-if="form.errors.title" class="error-msg">{{ form.errors.title }}</p>
                        </div>

                        <div class="input-group">
                            <label for="description" class="cyber-label">Detalles de la Misión</label>
                            <textarea
                                id="description"
                                v-model="form.description"
                                rows="3"
                                maxlength="5000"
                                class="cyber-input cyber-textarea"
                                placeholder="Especificaciones adicionales..."
                            ></textarea>
                            <div class="flex justify-between mt-1">
                                <p v-if="form.errors.description" class="error-msg">{{ form.errors.description }}</p>
                                <p class="char-count">{{ descriptionLength }} / 5000</p>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="input-group">
                                <label for="due_date" class="cyber-label">Fecha Límite</label>
                                <input
                                    id="due_date"
                                    v-model="form.due_date"
                                    type="date"
                                    :min="today"
                                    class="cyber-input"
                                    required
                                />
                            </div>

                            <div class="input-group">
                                <label for="status" class="cyber-label">Estado del Sistema</label>
                                <select id="status" v-model="form.status" class="cyber-input cyber-select" required>
                                    <option value="pendiente">⏳ PENDIENTE</option>
                                    <option value="en_proceso">⚡ EN PROCESO</option>
                                    <option value="terminado">✅ TERMINADO</option>
                                </select>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" @click="closeModal" class="cancel-btn">
                                ABORTAR
                            </button>
                            <button 
                                type="submit" 
                                :disabled="form.processing"
                                class="submit-btn"
                            >
                                <div class="btn-content" v-if="!form.processing">
                                    {{ isEditing ? 'SINCRONIZAR' : 'DESPLEGAR TAREA' }}
                                </div>
                                <span v-else class="animate-pulse">PROCESANDO...</span>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </Transition>
    </Teleport>
</template>

<style scoped>
.modal-overlay {
    position: fixed;
    inset: 0;
    z-index: 100;
    background: rgba(0, 0, 0, 0.75);
    backdrop-filter: blur(4px);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 1rem;
}

.modal-container {
    position: relative;
    width: 100%;
    max-width: 600px;
    background: rgba(10, 10, 15, 0.9);
    border: 1px solid rgba(6, 182, 212, 0.2);
    border-radius: 20px;
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(16px);
    overflow: hidden;
}

.modal-glow-line {
    height: 3px;
    background: linear-gradient(90deg, #06b6d4, #8b5cf6, #06b6d4);
    background-size: 200% auto;
    animation: flow 3s linear infinite;
}

@keyframes flow {
    to { background-position: 200% center; }
}

.modal-header {
    padding: 1.5rem 2rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.modal-eyebrow {
    font-size: 0.65rem;
    font-weight: 800;
    color: #06b6d4;
    text-transform: uppercase;
    letter-spacing: 0.15em;
}

.modal-title {
    font-size: 1.5rem;
    font-weight: 900;
    color: #fff;
    letter-spacing: -0.02em;
}

.modal-body {
    padding: 2rem;
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
}

/* Inputs Cyberpunk */
.cyber-label {
    display: block;
    font-size: 0.75rem;
    font-weight: 700;
    color: #94a3b8;
    margin-bottom: 0.5rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}

.cyber-input {
    width: 100%;
    background: rgba(255, 255, 255, 0.03);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 10px;
    padding: 0.8rem 1rem;
    color: #fff;
    transition: all 0.3s;
}

.cyber-input:focus {
    outline: none;
    background: rgba(255, 255, 255, 0.05);
    border-color: #06b6d4;
    box-shadow: 0 0 15px rgba(6, 182, 212, 0.2);
}

.cyber-textarea {
    resize: none;
    min-height: 100px;
}

.cyber-select {
    cursor: pointer;
}

.cyber-select option {
    background: #0a0a0f;
    color: #fff;
}

/* Botones */
.modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
    margin-top: 1rem;
}

.cancel-btn {
    padding: 0.75rem 1.5rem;
    font-size: 0.75rem;
    font-weight: 800;
    color: #64748b;
    border-radius: 10px;
    transition: all 0.3s;
}

.cancel-btn:hover {
    color: #fff;
    background: rgba(255, 255, 255, 0.05);
}

.submit-btn {
    padding: 0.75rem 2rem;
    background: linear-gradient(135deg, #06b6d4, #3b82f6);
    color: #000;
    font-weight: 900;
    font-size: 0.8rem;
    border-radius: 10px;
    transition: all 0.3s;
    box-shadow: 0 4px 15px rgba(6, 182, 212, 0.3);
}

.submit-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(6, 182, 212, 0.5);
}

.submit-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    transform: none;
}

.error-msg {
    font-size: 0.7rem;
    color: #ef4444;
    margin-top: 0.4rem;
}

.char-count {
    font-size: 0.7rem;
    color: #475569;
}

.close-btn {
    color: #475569;
    transition: color 0.3s;
}

.close-btn:hover {
    color: #fff;
}

/* Animaciones */
.cyber-modal-enter-active,
.cyber-modal-leave-active {
    transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}

.cyber-modal-enter-from,
.cyber-modal-leave-to {
    opacity: 0;
}

.cyber-modal-enter-from .modal-container {
    transform: scale(0.9) translateY(20px);
}

.cyber-modal-leave-to .modal-container {
    transform: scale(0.95);
}
</style>