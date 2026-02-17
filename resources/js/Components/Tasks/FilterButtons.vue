<template>
    <div class="flex flex-wrap gap-2">
        <button
            v-for="filter in filters"
            :key="filter.value"
            @click="$emit('filterChange', filter.value)"
            :class="[
                'px-4 py-2 rounded-lg font-medium transition-all duration-200',
                activeFilter === filter.value
                    ? 'bg-blue-600 text-white shadow-md transform scale-105'
                    : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-300'
            ]"
        >
            <span class="flex items-center gap-2">
                <span>{{ filter.label }}</span>
                <span 
                    v-if="filter.count !== undefined" 
                    :class="[
                        'px-2 py-0.5 rounded-full text-xs font-bold',
                        activeFilter === filter.value
                            ? 'bg-white bg-opacity-30 text-white'
                            : 'bg-gray-200 text-gray-700'
                    ]"
                >
                    {{ filter.count }}
                </span>
            </span>
        </button>
    </div>
</template>

<script setup>
defineProps({
    filters: {
        type: Array,
        required: true
    },
    activeFilter: {
        type: String,
        default: 'all'
    }
});

defineEmits(['filterChange']);
</script>