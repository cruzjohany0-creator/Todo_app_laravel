import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useTaskStore = defineStore('task', () => {
    // Estado
    const tasks = ref([]);
    const currentFilter = ref('all');

    // Getters (computed)
    const filteredTasks = computed(() => {
        if (currentFilter.value === 'all') {
            return tasks.value;
        }
        return tasks.value.filter(task => task.status === currentFilter.value);
    });

    const pendingCount = computed(() => 
        tasks.value.filter(task => task.status === 'pendiente').length
    );

    const inProgressCount = computed(() => 
        tasks.value.filter(task => task.status === 'en_proceso').length
    );

    const completedCount = computed(() => 
        tasks.value.filter(task => task.status === 'terminado').length
    );

    const totalCount = computed(() => tasks.value.length);

    // Acciones
    function setTasks(newTasks) {
        tasks.value = newTasks;
    }

    function setFilter(filter) {
        currentFilter.value = filter;
    }

    function addTask(task) {
        tasks.value.push(task);
    }

    function updateTask(updatedTask) {
        const index = tasks.value.findIndex(t => t.id === updatedTask.id);
        if (index !== -1) {
            tasks.value[index] = updatedTask;
        }
    }

    function removeTask(taskId) {
        tasks.value = tasks.value.filter(t => t.id !== taskId);
    }

    return {
        // Estado
        tasks,
        currentFilter,
        
        // Getters
        filteredTasks,
        pendingCount,
        inProgressCount,
        completedCount,
        totalCount,
        
        // Acciones
        setTasks,
        setFilter,
        addTask,
        updateTask,
        removeTask,
    };
});